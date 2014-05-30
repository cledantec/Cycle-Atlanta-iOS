/** Cycle Atlanta, Copyright 2012, 2013 Georgia Institute of Technology
 *                                    Atlanta, GA. USA
 *
 *   @author Christopher Le Dantec <ledantec@gatech.edu>
 *   @author Anhong Guo <guoanhong@gatech.edu>
 *
 *   Updated/Modified for Atlanta's app deployment. Based on the
 *   CycleTracks codebase for SFCTA.
 *
 ** CycleTracks, Copyright 2009,2010 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  SavedTripsViewController.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/10/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "constants.h"
#import "Coord.h"
#import "LoadingView.h"
#import "MapViewController.h"
#import "PickerViewController.h"
#import "SavedTripsViewController.h"
#import "Trip.h"
#import "TripManager.h"
#import "TripPurposeDelegate.h"


#define kAccessoryViewX	282.0
#define kAccessoryViewY 24.0

#define kCellReuseIdentifierCheck		@"CheckMark"
#define kCellReuseIdentifierExclamation @"Exclamataion"
#define kCellReuseIdentifierInProgress	@"InProgress"

#define kRowHeight	75
#define kTagTitle	1
#define kTagDetail	2
#define kTagImage	3


@interface TripCell : UITableViewCell
{	
}

- (void)setTitle:(NSString *)title;
- (void)setDetail:(NSString *)detail;
- (void)setDirty;

@end

@implementation TripCell

- (void)setTitle:(NSString *)title
{
	self.textLabel.text = title;
	[self setNeedsDisplay];
}

- (void)setDetail:(NSString *)detail
{
	self.detailTextLabel.text = detail;
	[self setNeedsDisplay];
}

- (void)setDirty
{
	[self setNeedsDisplay];
}

@end


@implementation SavedTripsViewController
@synthesize delegate, managedObjectContext;
@synthesize trips, tripManager, selectedTrip, tripToDisplay;
@synthesize tripInProgressTime, timer;


- (id)initWithManagedObjectContext:(NSManagedObjectContext*)context
{
    if (self = [super init]) {
		self.managedObjectContext = context;

		// Set the title NOTE: important for tab bar tab item to set title here before view loads
		self.title = @"View Saved Trips";
    }
    return self;
}

- (void)initTripManager:(TripManager*)manager
{
	self.tripManager = manager;   
}

- (id)initWithTripManager:(TripManager*)manager
{
    if (self = [super init]) {
		//NSLog(@"SavedTripsViewController::initWithTripManager");
		self.tripManager = manager;
		
		// Set the title NOTE: important for tab bar tab item to set title here before view loads
		self.title = @"View Saved Trips";
    }
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"SavedTripsToMap"])
    {
        // Get reference to the destination view controller
        MapViewController *nvc = [segue destinationViewController];
        [nvc loadTrip:tripToDisplay];
        [loading removeFromSuperview];
    }
}

- (void)refreshTableView
{
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:tripManager.managedObjectContext];
	[request setEntity:entity];
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error;
	NSInteger count = [tripManager.managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"count = %ld", (long)count);
	
	NSMutableArray *mutableFetchResults = [[tripManager.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
		NSLog(@"no saved trips");
		if ( error != nil )
			NSLog(@"Unresolved error2 %@, %@", error, [error userInfo]);
	}
	
	[self setTrips:mutableFetchResults];
	[self.tableView reloadData];

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    timer = nil;
    
    self.tableView.rowHeight = kRowHeight;
    
	// Set up the buttons.
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    // no trip selection by default
	selectedTrip = nil;
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)viewWillAppear:(BOOL)animated
{    	
	// load trips from CoreData
	[self refreshTableView];

	[super viewWillAppear:animated];
}

 - (void)viewDidDisappear:(BOOL)animated
{
    if([timer isValid]){
        [timer invalidate], timer = nil;
    }
	[super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)_recalculateDistanceForSelectedTripMap
{
	// important if we call from a background thread
    @autoreleasepool { // Top-level pool
	
	// instantiate a temporary TripManager to recalcuate distance
		TripManager *mapTripManager = [[TripManager alloc] initWithTrip:selectedTrip];
		CLLocationDistance newDist	= [mapTripManager calculateTripDistance:selectedTrip];
		
		// save updated distance to CoreData
		[mapTripManager.trip setDistance:@(newDist)];

		NSError *error;
		if (![mapTripManager.managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"_recalculateDistanceForSelectedTripMap error %@, %@", error, [error localizedDescription]);
		}
		
		tripManager.dirty = YES;
		
		[self performSelectorOnMainThread:@selector(_displaySelectedTripMap) withObject:nil waitUntilDone:NO];
    }  // Release the objects in the pool.
}


- (void)_displaySelectedTripMap
{
	// important if we call from a background thread
    @autoreleasepool { // Top-level pool

		if ( selectedTrip )
		{
        tripToDisplay = selectedTrip;
		    [self performSegueWithIdentifier:@"SavedTripsToMap" sender:self];
			selectedTrip = nil;
		}

    }  // Release the objects in the pool.
}


// display map view
- (void)displaySelectedTripMap
{
	loading		= [LoadingView loadingViewInView:self.parentViewController.view messageString:@"Loading..."];
	loading.tag = 909;
	[self performSelectorInBackground:@selector(_recalculateDistanceForSelectedTripMap) withObject:nil];
}


#pragma mark Table view methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [trips count];
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
}
*/

- (TripCell *)getCellWithReuseIdentifier:(NSString *)reuseIdentifier
{
	TripCell *cell = (TripCell*)[self.tableView dequeueReusableCellWithIdentifier:nil];
    
	if (cell == nil)
	{
		cell = [[TripCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
		cell.detailTextLabel.numberOfLines = 2;
		if ( [reuseIdentifier isEqual: kCellReuseIdentifierCheck] )
		{
			/*
			// add check mark
			UIImage		*image		= [UIImage imageNamed:@"GreenCheckMark2.png"];
			UIImageView *imageView	= [[UIImageView alloc] initWithImage:image];
			imageView.frame = CGRectMake( kAccessoryViewX, kAccessoryViewY, image.size.width, image.size.height );
			imageView.tag	= kTagImage;
			//[cell.contentView addSubview:imageView];
			cell.accessoryView = imageView;
			 */
		}
		else if ( [reuseIdentifier isEqual: kCellReuseIdentifierExclamation] )
		{
			// add exclamation point
			UIImage		*image		= [UIImage imageNamed:@"failedUpload.png"];
			UIImageView *imageView	= [[UIImageView alloc] initWithImage:image];
			imageView.frame = CGRectMake( kAccessoryViewX, kAccessoryViewY, image.size.width, image.size.height );
			imageView.tag	= kTagImage;
			//[cell.contentView addSubview:imageView];
			cell.accessoryView = imageView;
		}
		else if ( [reuseIdentifier isEqual: kCellReuseIdentifierInProgress] )
		{
			// prevent user from selecting the current recording in progress
			cell.selectionStyle = UITableViewCellSelectionStyleNone; 
			
			// reuse existing indicator if available
			UIActivityIndicatorView *inProgressIndicator = (UIActivityIndicatorView *)[cell viewWithTag:kTagImage];
			if ( !inProgressIndicator )
			{
				// create activity indicator if needed
				CGRect frame = CGRectMake( kAccessoryViewX + 4.0, kAccessoryViewY + 4.0, kActivityIndicatorSize, kActivityIndicatorSize );
				inProgressIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
				inProgressIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;		
				[inProgressIndicator sizeToFit];
				[inProgressIndicator startAnimating];
				inProgressIndicator.tag	= kTagImage;
				[cell.contentView addSubview:inProgressIndicator];
			}
		}
	}
	else
		[[cell.contentView viewWithTag:kTagImage] setNeedsDisplay];

	// slide accessory view out of the way during editing
	cell.editingAccessoryView = cell.accessoryView;

	return cell;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A date formatter for timestamp
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    
    static NSDateFormatter *timeFormatter = nil;
    if (timeFormatter == nil) {
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
	
	Trip *trip = (Trip *)trips[indexPath.row];
	TripCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	// check for recordingInProgress
	Trip *recordingInProgress = [delegate getRecordingInProgress];
	
	//only update contents if cell does not exist. improves intermittent overlap bug
    if(cell == nil)
    {
        UILabel *timeText = [[UILabel alloc] init];
        timeText.frame = CGRectMake( 10, 5, 220, 25);
        [timeText setFont:[UIFont systemFontOfSize:15]];
        [timeText setTextColor:[UIColor grayColor]];
        
        UILabel *purposeText = [[UILabel alloc] init];
        purposeText.frame = CGRectMake( 10, 24, 120, 30);
        [purposeText setFont:[UIFont boldSystemFontOfSize:18]];
        [purposeText setTextColor:[UIColor blackColor]];
        
        UILabel *durationText = [[UILabel alloc] init];
        durationText.frame = CGRectMake( 140, 24, 190, 30);
        [durationText setFont:[UIFont systemFontOfSize:18]];
        [durationText setTextColor:[UIColor blackColor]];
        
        UILabel *CO2Text = [[UILabel alloc] init];
        CO2Text.frame = CGRectMake( 10, 50, 120, 20);
        [CO2Text setFont:[UIFont systemFontOfSize:12]];
        [CO2Text setTextColor:[UIColor grayColor]];
        
        UILabel *CaloryText = [[UILabel alloc] init];
        CaloryText.frame = CGRectMake( 140, 50, 190, 20);
        [CaloryText setFont:[UIFont systemFontOfSize:12]];
        [CaloryText setTextColor:[UIColor grayColor]];
        
        UIImage	*image;

        // completed
        if ( trip.uploaded )
        {
            [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifierCheck];
            cell = [self getCellWithReuseIdentifier:kCellReuseIdentifierCheck];
            
            // add check mark
            // image = [UIImage imageNamed:@"GreenCheckMark2.png"];
            
            int index = [TripPurpose getPurposeIndex:trip.purpose];
            NSLog(@"trip.purpose: %d => %@", index, trip.purpose);
            //int index =0;
            
            // add purpose icon
            switch ( index ) {
                case kTripPurposeCommute:
                    image = [UIImage imageNamed:kTripPurposeCommuteIcon];
                    break;
                case kTripPurposeSchool:
                    image = [UIImage imageNamed:kTripPurposeSchoolIcon];
                    break;
                case kTripPurposeWork:
                    image = [UIImage imageNamed:kTripPurposeWorkIcon];
                    break;
                case kTripPurposeExercise:
                    image = [UIImage imageNamed:kTripPurposeExerciseIcon];
                    break;
                case kTripPurposeSocial:
                    image = [UIImage imageNamed:kTripPurposeSocialIcon];
                    break;
                case kTripPurposeShopping:
                    image = [UIImage imageNamed:kTripPurposeShoppingIcon];
                    break;
                case kTripPurposeErrand:
                    image = [UIImage imageNamed:kTripPurposeErrandIcon];
                    break;
                case kTripPurposeOther:
                    image = [UIImage imageNamed:kTripPurposeOtherIcon];
                    break;
                default:
                    image = [UIImage imageNamed:@"GreenCheckMark2.png"];
            }
            UIImageView *imageView	= [[UIImageView alloc] initWithImage:image];
            imageView.frame			= CGRectMake( kAccessoryViewX, kAccessoryViewY, image.size.width, image.size.height );
            
            //[cell.contentView addSubview:imageView];
            cell.accessoryView = imageView;
        }

        // saved but not yet uploaded
        else if ( trip.saved )
        {
            [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifierExclamation];
            cell = [self getCellWithReuseIdentifier:kCellReuseIdentifierExclamation];
        }
        // recording for this trip is still in progress (or just completed)
        // NOTE: this test may break when attempting re-upload
        else if ( trip == recordingInProgress )
        {
            [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifierInProgress];
            cell = [self getCellWithReuseIdentifier:kCellReuseIdentifierInProgress];
        }        
        // this trip was orphaned (an abandoned previous recording)
        // not used in current version.
        else
        {
            [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifierExclamation];
            cell = [self getCellWithReuseIdentifier:kCellReuseIdentifierExclamation];
            //tripStatus = @"(recording interrupted)";
        }
        
        cell.detailTextLabel.tag	= kTagDetail;
        cell.textLabel.tag			= kTagTitle;
        
        // display duration, distance as navbar prompt
        static NSDateFormatter *inputFormatter = nil;
        if ( inputFormatter == nil )
            inputFormatter = [[NSDateFormatter alloc] init];
        
        [inputFormatter setDateFormat:@"HH:mm:ss"];
        NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
        [inputFormatter setDateFormat:@"HH:mm:ss"];
        NSLog(@"trip duration: %f", [trip.duration doubleValue]);
        NSDate *outputDate = [[NSDate alloc] initWithTimeInterval:(NSTimeInterval)[trip.duration doubleValue]
                                                        sinceDate:fauxDate];
        
        cell.detailTextLabel.numberOfLines = 2;
        
        timeText.text = [NSString stringWithFormat:@"%@ at %@", [dateFormatter stringFromDate:[trip start]], [timeFormatter stringFromDate:[trip start]]];
        
        if ( trip == recordingInProgress )
        {
            purposeText.text = @"In progress...";
            durationText.text = [NSString stringWithFormat:@"%@",[inputFormatter stringFromDate:outputDate]];
            tripInProgressTime = durationText;
            timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                               target:self
                                                             selector:@selector(updateTripTimeLabel)
                                                             userInfo:nil
                                                              repeats:YES];
        }
        else
        {
            purposeText.text = [NSString stringWithFormat:@"%@", trip.purpose];
            durationText.text = [NSString stringWithFormat:@"%@",[inputFormatter stringFromDate:outputDate]];
        }
            
        durationText.text = [NSString stringWithFormat:@"%@",[inputFormatter stringFromDate:outputDate]];
        
        CO2Text.text = [NSString stringWithFormat:@"CO2 Saved: %.1f lbs", 0.93 * [trip.distance doubleValue] / 1609.344];
        
        double calory = 49 * [trip.distance doubleValue] / 1609.344 - 1.69;
        if (calory <= 0) {
            CaloryText.text = [NSString stringWithFormat:@"Calories Burned: 0 kcal"];
        }
        else
            CaloryText.text = [NSString stringWithFormat:@"Calories Burned: %.1f kcal", calory];
        
        
        [cell.contentView addSubview:CaloryText];
        [cell.contentView addSubview:CO2Text];
        [cell.contentView addSubview:durationText];
        [cell.contentView addSubview:purposeText];
        [cell.contentView addSubview:timeText];
        
        cell.editingAccessoryView = cell.accessoryView;
        
    }
    return cell;
}

- (void) updateTripTimeLabel
{
    Trip *trip = (Trip *)trips[0];
    
    static NSDateFormatter *inputFormatter = nil;
    if ( inputFormatter == nil )
        inputFormatter = [[NSDateFormatter alloc] init];
    
    [inputFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
    [inputFormatter setDateFormat:@"HH:mm:ss"];
    NSLog(@"trip duration: %f", [trip.duration doubleValue]);
    NSDate *outputDate = [[NSDate alloc] initWithTimeInterval:(NSTimeInterval)[trip.duration doubleValue]
                                                     sinceDate:fauxDate];
    
    tripInProgressTime.text = [NSString stringWithFormat:@"%@",[inputFormatter stringFromDate:outputDate]];
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"willDisplayCell: %@", cell);
}
*/

- (void)promptToConfirmPurpose
{
	NSLog(@"promptToConfirmPurpose");
	
	// construct purpose confirmation string
//	NSString *purpose = nil;
//	if ( tripManager != nil )
//	//	purpose = [self getPurposeString:[tripManager getPurposeIndex]];
//		purpose = tripManager.trip.purpose;

	//NSString *confirm = [NSString stringWithFormat:@"This trip has not yet been uploaded. Confirm the trip's purpose to try again: %@", purpose];
	NSString *confirm = [NSString stringWithFormat:@"This trip has not yet been uploaded. Try now?"];
	
	// present action sheet
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:confirm
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Upload", nil];
	
	[actionSheet showInView:self.tabBarController.view];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	// identify trip by row
	//NSLog(@"didSelectRow: %d", indexPath.row);
	selectedTrip = (Trip *)trips[indexPath.row];
	//NSLog(@"%@", selectedTrip);

	// check for recordingInProgress
	Trip *recordingInProgress = [delegate getRecordingInProgress];

	// if trip not yet uploaded => prompt to re-upload
	if ( recordingInProgress != selectedTrip )
	{
		if ( !selectedTrip.uploaded )
		{
			// init new TripManager instance with selected trip
			// release previously set tripManager
			
			tripManager = [[TripManager alloc] initWithTrip:selectedTrip];
			tripManager.parent = self;
			// prompt to upload
			[self promptToConfirmPurpose];
		}
		
		// else => goto map view
		else 
			[self displaySelectedTripMap];
	}
	//else disallow selection of recordingInProgress
}


// Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	return ( ![cell.reuseIdentifier isEqual: kCellReuseIdentifierInProgress] );
}

- (void)displayUploadedTripMap
{
    tripToDisplay = tripManager.trip;
    // load map view of saved trip
    [self performSegueWithIdentifier:@"SavedTripsToMap" sender:self];

}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{	
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSLog(@"Delete");
		
        // Delete the managed object at the given index path.
        NSManagedObject *tripToDelete = trips[indexPath.row];
        [tripManager.managedObjectContext deleteObject:tripToDelete];
		
        // Update the array and table view.
        [trips removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
		
        // Commit the change.
        NSError *error;
        if (![tripManager.managedObjectContext save:&error]) {
            // Handle the error.
			NSLog(@"Unresolved error %@", [error localizedDescription]);
        }
    }
	else if ( editingStyle == UITableViewCellEditingStyleInsert )
		NSLog(@"INSERT");
}


#pragma mark UINavigationController


- (void)navigationController:(UINavigationController *)navigationController 
	  willShowViewController:(UIViewController *)viewController 
					animated:(BOOL)animated
{
	if ( viewController == self )
	{
		//NSLog(@"willShowViewController:self");
		self.title = @"View Saved Trips";
	}
	else
	{
		//NSLog(@"willShowViewController:else");
		self.title = @"Back";
		self.tabBarItem.title = @"View Saved Trips"; // important to maintain the same tab item title
	}
}


#pragma mark UIActionSheet delegate methods


// NOTE: implement didDismissWithButtonIndex to process after sheet has been dismissed
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"actionSheet clickedButtonAtIndex %ld", (long)buttonIndex);
	switch ( buttonIndex )
	{
			
		//case kActionSheetButtonChange:
		case 0:
			NSLog(@"Upload => push Trip Purpose picker");						
            [tripManager saveTrip];
			break;
			
		//case kActionSheetButtonCancel:
		case 1:
		default:
			NSLog(@"Cancel");
			[self displaySelectedTripMap];
			break;
	}
}


// called if the system cancels the action sheet (e.g. homescreen button has been pressed)
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	NSLog(@"actionSheetCancel");
}


#pragma mark UIAlertViewDelegate methods


// NOTE: method called upon closing save error / success alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag) {
		case 202:
		{
			NSLog(@"zeroDistance didDismissWithButtonIndex: %ld", (long)buttonIndex);
			switch (buttonIndex) {
				case 0:
					// nothing to do
					break;
				case 1:
				default:
					// Recalculate
					[tripManager recalculateTripDistances];
					break;
			}
		}
			break;
		case 303:
		{
			NSLog(@"unSyncedTrips didDismissWithButtonIndex: %ld", (long)buttonIndex);
			switch (buttonIndex) {
				case 0:
					// Nevermind
					[self displaySelectedTripMap];
					break;
				case 1:
				default:
					// Upload Now
					break;
			}
		}
			break;
		default:
		{
			NSLog(@"SavedTripsView alertView: didDismissWithButtonIndex: %ld", (long)buttonIndex);
			[self displaySelectedTripMap];
		}
	}
}


#pragma mark TripPurposeDelegate methods


- (NSString *)setPurpose:(unsigned int)index
{
	return [tripManager setPurpose:index];
}


- (NSString *)getPurposeString:(unsigned int)index
{
	return [tripManager getPurposeString:index];
}


- (void)didCancelPurpose
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void)didPickPurpose:(unsigned int)index
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	[tripManager setPurpose:index];
}



@end

