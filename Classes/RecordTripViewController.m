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
//  RecordTripViewController.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/10/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>

#define GRIDVIEW 1
#import "constants.h"
#import "MapViewController.h"
#import "NoteViewController.h"
#import "PersonalInfoViewController.h"
#import "PickerViewController.h"
#import "RecordTripViewController.h"
#import "ReminderManager.h"
#import "TripManager.h"
#import "NoteManager.h"
#import "Trip.h"
#import "User.h"
#import "NoteToDetailViewController.h"
#import "GridViewController.h"
#import "UIImage+ImageEffects.m"
#import "GlobalVars.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation RecordTripViewController
@synthesize tripManager, noteManager;
@synthesize infoButton, saveButton, startButton, noteButton, parentView;
@synthesize timer, timeCounter, distCounter, noteToDetailAlert, localNotification;
@synthesize recording, shouldUpdateCounter, userInfoSaved;
@synthesize appDelegate;
@synthesize saveActionSheet;
@synthesize locationManager;


-(IBAction)unwindToRecordTripViewController:(UIStoryboardSegue *)segue {
    NSLog(@"Back to main tab");
}

#pragma mark CLLocationManagerDelegate methods

- (void)initTripManager:(TripManager*)manager
{
	manager.dirty			= YES;
	self.tripManager		= manager;
    manager.parent          = self;
}


- (void)initNoteManager:(NoteManager*)manager
{
	self.noteManager = manager;
    manager.parent = self;
}


-(UIImage *)convertViewToImage:(UIView*)view_self
{
    UIGraphicsBeginImageContext(view_self.bounds.size);
    [view_self drawViewHierarchyInRect:view_self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (CLLocationManager *)getLocationManager {
    
    if(locationManager!=nil)
    {
        return locationManager;
    }
    locationManager = [[CLLocationManager alloc]init]; // initializing locationManager
    locationManager.delegate = self; // we set the delegate of locationManager to self.
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // setting the accuracy
    return locationManager;
    
 
	appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.locationManager != nil) {
        return appDelegate.locationManager;
    }
	
    appDelegate.locationManager = [[CLLocationManager alloc] init];
    appDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    appDelegate.locationManager.delegate = self;
    
    return appDelegate.locationManager;
 
}



-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSString *errorString;
    [manager stopUpdatingLocation];
    NSLog(@"Error: %@",[error localizedDescription]);
    UIAlertView *alert=[[UIAlertView alloc]init];
    switch([error code]) {
        case kCLErrorDenied:
            if(locationAccessAsked==false)
            {
            locationAccessAsked=true;
            //Access denied by user
            errorString = @"Access to Location Services is denied for this app. Do you wish to enable it?";
            //Do something...
            alert=[alert initWithTitle:@"Enable Location Services" message:errorString delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alert addButtonWithTitle:@"Yes"];
            [alert addButtonWithTitle:@"No"];
            alert.tag=kAccessNotGiven;
                [alert show];
            }
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = @"Location data unavailable";
            alert=[alert initWithTitle:@"No location available" message:errorString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag=kLocationNotAvailable;
            [alert show];
            
            break;
        default:
            errorString = @"An unknown error has occurred";
            alert=[alert initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
    }


   // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    


}

/*********************/
/// Taken from http://www.devfright.com/didupdatelocations-ios-example/
/********************/
/******************************************/
/******************************************/
// After iOS 6
/******************************************/
/******************************************/
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    CLLocation *oldLocation;
    if (locations.count > 1) {
        oldLocation = [locations objectAtIndex:locations.count-2];
    } else {
        oldLocation = nil;
    }
    NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
    
    CLLocationDistance deltaDistance = [newLocation distanceFromLocation:oldLocation];
    
    if (!myLocation) {
        myLocation = newLocation;
    }
    else if ([myLocation distanceFromLocation:newLocation]) {
        myLocation = newLocation;
    }
    
    if ( !didUpdateUserLocation )
    {
        NSLog(@"zooming to current user location");
        MKCoordinateRegion region = { newLocation.coordinate, { 0.0078, 0.0068 } };
        [mapView setRegion:region animated:YES];
        
        didUpdateUserLocation = YES;
    }
    
    // only update map if deltaDistance is at least some epsilon
    else if ( deltaDistance > 1.0 )
    {
        //NSLog(@"center map to current user location");
        [mapView setCenterCoordinate:newLocation.coordinate animated:YES];
    }
    
    if ( recording )
    {
        // add to CoreData store
        CLLocationDistance distance = [tripManager addCoord:newLocation];
        self.distCounter.text = [NSString stringWithFormat:@"%.1f mi", distance / 1609.344];
    }
    
    // 	double mph = ( [trip.distance doubleValue] / 1609.344 ) / ( [trip.duration doubleValue] / 3600. );
    if ( newLocation.speed >= 0. )
        speedCounter.text = [NSString stringWithFormat:@"%.1f mph", newLocation.speed * 3600 / 1609.344];
    else
        speedCounter.text = @"0.0 mph";
    
    // Magnetormeter
   // [self locationManager:[self getLocationManager] didUpdateHeading:[self getLocationManager].heading];
    // if ([CLLocationManager locationServicesEnabled]) {
         [self locationManager:self.locationManager didUpdateHeading:self.locationManager.heading];
    // }
}

/******************************************/
/******************************************/
// Before iOS 6
/******************************************/
/******************************************/
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	CLLocationDistance deltaDistance = [newLocation distanceFromLocation:oldLocation];
    
    if (!myLocation) {
        myLocation = newLocation;
    }
    else if ([myLocation distanceFromLocation:newLocation]) {
        myLocation = newLocation;
    }
    
	if ( !didUpdateUserLocation )
	{
		NSLog(@"zooming to current user location");
		MKCoordinateRegion region = { newLocation.coordinate, { 0.0078, 0.0068 } };
		[mapView setRegion:region animated:YES];

		didUpdateUserLocation = YES;
	}
	
	// only update map if deltaDistance is at least some epsilon 
	else if ( deltaDistance > 1.0 )
	{
		//NSLog(@"center map to current user location");
		[mapView setCenterCoordinate:newLocation.coordinate animated:YES];
	}

	if ( recording )
	{
		// add to CoreData store
		CLLocationDistance distance = [tripManager addCoord:newLocation];
		self.distCounter.text = [NSString stringWithFormat:@"%.1f mi", distance / 1609.344];
	}
	
	// 	double mph = ( [trip.distance doubleValue] / 1609.344 ) / ( [trip.duration doubleValue] / 3600. );
	if ( newLocation.speed >= 0. )
		speedCounter.text = [NSString stringWithFormat:@"%.1f mph", newLocation.speed * 3600 / 1609.344];
	else
		speedCounter.text = @"0.0 mph";
    
    // Magnetormeter
   // [self locationManager:[self getLocationManager] didUpdateHeading:[self getLocationManager].heading];
     if ([CLLocationManager locationServicesEnabled])
     {
    [self locationManager:self.locationManager didUpdateHeading:self.locationManager.heading];
     }
}


-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    NSLog(@"updateHeading");
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"magnetometerIsOn"])
    {
        if (heading.headingAccuracy < 0)
            return;
        
        CGFloat fieldNorm2 = sqrt (pow(heading.x,2)+
                                   pow(heading.y,2)+
                                   pow(heading.z,2));
        if(fieldNorm) {
            NSLog(@"%f %f",fieldNorm, fieldNorm2 / fieldNorm);
            if(fieldNorm2 / fieldNorm > 2.5)
            {
                if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
                {
                    AudioServicesPlaySystemSound (1350);
                    AudioServicesPlaySystemSound (1351);
                }
                else
                {
                    [self fireNotif];
                }
                
                if (myLocation){
                    NSMutableArray *notesToDetail;
                    if([[NSUserDefaults standardUserDefaults] objectForKey:@"notesToDetail"])
                    {
                        NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"notesToDetail"];
                        notesToDetail = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
                    }
                    else
                    {
                        notesToDetail = [[NSMutableArray alloc] init];
                    }
                    [notesToDetail addObject:myLocation];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:notesToDetail];
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"notesToDetail"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    noteToDetailAlert.hidden=false;
                    [noteToDetailAlert setTitle:[NSString stringWithFormat:@"%lu notes to detail", (unsigned long)[notesToDetail count]] forState:UIControlStateNormal];
                    
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Activate location services"
                                                                    message:@"You can't write a note because we're not able to get your location."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
        }
        fieldNorm = fieldNorm2;
    }
}





#pragma mark MKMapViewDelegate methods



- (BOOL)hasUserInfoBeenSaved
{
	BOOL					response = NO;
    NSManagedObjectContext  *context = [appDelegate managedObjectContext];
	NSFetchRequest			*request = [[NSFetchRequest alloc] init];
	NSEntityDescription		*entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
	[request setEntity:entity];

                
	NSError *error;
	NSInteger count = [context countForFetchRequest:request error:&error];
	//NSLog(@"saved user count  = %d", count);
	if ( count )
	{	
		NSArray *fetchResults = [context executeFetchRequest:request error:&error];
		if ( fetchResults != nil )
		{
			User *user = (User*)fetchResults[0];
			if (user			!= nil &&
				(user.age		!= nil ||
				 user.gender	!= nil ||
				 user.email		!= nil ||
				 user.homeZIP	!= nil ||
				 user.workZIP	!= nil ||
				 user.schoolZIP	!= nil ||
				 ([user.cyclingFreq intValue] < 4 )))
			{
				NSLog(@"found saved user info");
				self.userInfoSaved = YES;
				response = YES;
			}
			else
				NSLog(@"no saved user info");
		}
		else
		{
			// Handle the error.
			NSLog(@"no saved user");
			if ( error != nil )
				NSLog(@"PersonalInfo viewDidLoad fetch error %@, %@", error, [error localizedDescription]);
		}
	}
	else
		NSLog(@"no saved user");
	
	return response;
}


- (void)hasRecordingBeenInterrupted
{
	if ( [tripManager countUnSavedTrips] )
	{        
        [self resetRecordingInProgress];
	}
	else
		NSLog(@"no unsaved trips found");
}


- (void)infoAction:(id)sender
{
	if ( !recording )
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: kInfoURL]];
}

-(void)refreshLocation
{
    
        [self.locationManager startUpdatingLocation];
    
}

- (void)viewDidLoad
{
    locationAccessAsked=false;
    self.hidesBottomBarWhenPushed=NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshLocation)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"Services are enabled");
    }
    [super viewDidLoad];
    
    NSLog(@"RecordTripViewController viewDidLoad");
    NSLog(@"Bundle ID: %@", [[NSBundle mainBundle] bundleIdentifier]);

    
	// init map region to Atlanta
	MKCoordinateRegion region = { { 33.749038, -84.388068 }, { 0.0078, 0.0068 } };
    [mapView setRegion:region animated:NO];
    [mapView setDelegate:self];
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = NO;
	self.recording = NO;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	self.shouldUpdateCounter = NO;

   
	// Start the location manager.
	//[[self getLocationManager] startUpdatingLocation];
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if(IS_OS_8_OR_LATER) {
            [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
    
    // TODO explain
    [appDelegate initUniqueIDHash];
    
    [appDelegate setStoreLoadingView: [ProgressView progressViewInView: [appDelegate storeLoadingView] messageString:nil progressTypePlain:NO]] ;
    [[appDelegate window] addSubview:appDelegate.storeLoadingView];
    
    [[appDelegate window] makeKeyAndVisible];
    [appDelegate performSelector:@selector(loadPersistentStore) withObject:nil];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // setup the noteManager
    [self initNoteManager:[[NoteManager alloc] initWithManagedObjectContext:context]];
    
	// check if any user data has already been saved and pre-select personal info cell accordingly
	if ( [self hasUserInfoBeenSaved] )
		[self setSaved:YES];
	
	// check for any unsaved trips / interrupted recordings
	[self hasRecordingBeenInterrupted];
    
	NSLog(@"save");


}


- (void)viewWillAppear:(BOOL)animated
{
  
    
    [super viewWillAppear:animated];
    
  
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //Start magnetometer if needed
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"magnetometerIsOn"])
    {
       // [[self getLocationManager] startUpdatingHeading];
         if ([CLLocationManager locationServicesEnabled]) {
         [self.locationManager startUpdatingHeading];
         }
    }
    
    // Shows alert if there is any magnet notes to be detailed
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"notesToDetail"];
    NSMutableArray *notesToDetail = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"magnetometerIsOn"] && [notesToDetail count])
    {
        noteToDetailAlert.hidden=false;
        if([notesToDetail count] > 1)
        {
            [noteToDetailAlert setTitle:[NSString stringWithFormat:@"%lu notes to detail", (unsigned long)[notesToDetail count]] forState:UIControlStateNormal];
        }
        else
        {
            [noteToDetailAlert setTitle:@"1 note to detail" forState:UIControlStateNormal];
        }

    }
    else {
        noteToDetailAlert.hidden=true;
    }
    
    UIImageView* imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    imageView1.center = CGPointMake(25, noteButton.frame.size.height / 2);
    imageView1.image = [UIImage imageNamed:@"tabbar_notes.png"];
    [noteButton addSubview:imageView1];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"recordTripToNoteToDetail"])
    {
        NoteToDetailViewController *ntdvc = [segue destinationViewController];
        [ntdvc setNoteManager:noteManager];
        [ntdvc setRecordTripVC:self];
    }
}



- (UIButton *)createStartButton
{
    UIImage *buttonImage = [[UIImage imageNamed:@"StartButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"StartButton.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [startButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [startButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];

    startButton.enabled = YES;
    
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    
	return startButton;
}



- (void)displayUploadedTripMap
{
    Trip *trip = tripManager.trip;
    
    // load map view of saved trip
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Note" bundle: nil];
    MapViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"Map"];
    [mvc loadTrip:trip];
    [[self navigationController] pushViewController:mvc animated:YES];
    NSLog(@"displayUploadedTripMap");
}


- (void)displayUploadedNote
{
    Note *note = noteManager.note;
    
    // load map view of note
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Note" bundle: nil];
    NoteViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"Note"];
    [mvc loadNote:note];
    [[self navigationController] pushViewController:mvc animated:YES];
    NSLog(@"displayUploadedNote");
}


- (void)resetTimer
{
	if ( timer )
	{
		[timer invalidate];
		timer = nil;
	}
}


- (void)resetRecordingInProgress
{
	// reset button states
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = NO;
	recording = NO;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self createStartButton];
	
	// reset trip, reminder managers
	NSManagedObjectContext *context = tripManager.managedObjectContext;
	[self initTripManager:[[TripManager alloc] initWithManagedObjectContext:context]];
	tripManager.dirty = YES;
    
	[self resetCounter];
	[self resetTimer];
}

- (void)resetRecordingInProgressDelete
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Trip" inManagedObjectContext:tripManager.managedObjectContext];
	[request setEntity:entity];
	
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:NO];
    NSSortDescriptor *sortDescriptorSaved = [[NSSortDescriptor alloc] initWithKey:@"saved" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sortDescriptorSaved, nil];
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error;
	NSInteger count = [tripManager.managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"count = %ld", (long)count);
	
	NSMutableArray *mutableFetchResults = [[tripManager.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    NSManagedObject *tripToDelete = mutableFetchResults[0];
    
    
    if (tripManager.trip!= nil && tripManager.trip.saved == nil) {
        [noteManager.managedObjectContext deleteObject:tripToDelete];
    }
    
    
    if (![tripManager.managedObjectContext save:&error]) {
        // Handle the error.
        NSLog(@"Unresolved error %@", [error localizedDescription]);
    }

    
	// reset button states
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = NO;
	recording = NO;
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	startButton.enabled = YES;
    
    UIImage *buttonImage = [[UIImage imageNamed:@"StartButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"StartButton.png"]
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [startButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [startButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
	
	// reset trip, reminder managers
	NSManagedObjectContext *context = tripManager.managedObjectContext;
	[self initTripManager:[[TripManager alloc] initWithManagedObjectContext:context]];
	tripManager.dirty = YES;

	[self resetCounter];
	[self resetTimer];

}


#pragma mark UIActionSheet delegate methods


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"actionSheet clickedButtonAtIndex %ld", (long)buttonIndex);
	switch ( buttonIndex )
	{			
       case 0:
       {
           NSLog(@"Discard!!!!");
           [self resetRecordingInProgressDelete];
           break;
       }
        case 1:{
            [self save];
            break;
        }
		default:{
			NSLog(@"Cancel");
			// re-enable counter updates
			shouldUpdateCounter = YES;
			break;
        }
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
		case 101:
		{
			NSLog(@"recording interrupted didDismissWithButtonIndex: %ld", (long)buttonIndex);
			switch (buttonIndex) {
				case 0:
					// new trip => do nothing
					break;
				case 1:
				default:
					// continue => load most recent unsaved trip
					[tripManager loadMostRecentUnSavedTrip];
					
					// update UI to reflect trip once loading has completed
					[self setCounterTimeSince:tripManager.trip.start
									 distance:[tripManager getDistanceEstimate]];

					startButton.enabled = YES;
                    [startButton setTitle:@"Continue" forState:UIControlStateNormal];
					break;
			}
		}
        case kAccessNotGiven:
        {
            switch (buttonIndex) {
                case 0:
                {
                    NSLog(@"User wants to give access now");
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                    
                case 1:
                {
                    NSLog(@"User doesn't want to give access!");
                }
             
            }
            break;
        }
        case kLocationNotAvailable:
        {
            NSLog(@"Location not available");
            break;
        }
        case kNoteNotPossible:
        {
            NSLog(@"saving didDismissWithButtonIndex: %ld", (long)buttonIndex);
            break;
        }
			break;
		default:
		{
			NSLog(@"saving didDismissWithButtonIndex: %ld", (long)buttonIndex);
			
			// keep a pointer to our trip to pass to map view below
			Trip *trip = tripManager.trip;
			
            [self resetRecordingInProgress];
            
			// load map view of saved trip
			MapViewController *mvc = [[MapViewController alloc] initWithTrip:trip];
			[[self navigationController] pushViewController:mvc animated:YES];
		}
			break;
	}
}

- (NSDictionary *)newTripTimerUserInfo
{
    return @{@"StartDate": [NSDate date],
			@"TripManager": tripManager};
}


// handle start button action
- (IBAction)start:(UIButton *)sender
{
    
    if(recording == NO)
    {
        NSLog(@"start");
        
        // start the timer if needed
        if ( timer == nil )
        {
			[self resetCounter];
			timer = [NSTimer scheduledTimerWithTimeInterval:kCounterTimeInterval
													 target:self selector:@selector(updateCounter:)
												   userInfo:[self newTripTimerUserInfo] repeats:YES];
        }
        
        UIImage *buttonImage = [[UIImage imageNamed:@"SaveButton.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        UIImage *buttonImageHighlight = [[UIImage imageNamed:@"SaveButton.png"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        [startButton setBackgroundImage:buttonImage forState:UIControlStateNormal]; // setBackgroundColor doesn't exist...
        [startButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [startButton setTitle:@"Stop" forState:UIControlStateNormal];

        // set recording flag so future location updates will be added as coords
        appDelegate = [[UIApplication sharedApplication] delegate];
        appDelegate.isRecording = YES;
        recording = YES;
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey: @"recording"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // set flag to update counter
        shouldUpdateCounter = YES;
    }
    // do the saving
    else
    {
        NSLog(@"User Press Save Button");
        saveActionSheet = [[UIActionSheet alloc]
                           initWithTitle:@""
                           delegate:self
                           cancelButtonTitle:@"Continue"
                           destructiveButtonTitle:@"Discard"
                           otherButtonTitles:@"Save",nil];
        [saveActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
	
}
- (void)save
{
#ifndef GRIDVIEW
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
		NSLog(@"INIT + PUSH");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
    PickerViewController *pickerViewController = [[storyboard instantiateViewControllerWithIdentifier:@"Picker"] initWithNibName:@"Picker" bundle:nil];
        [pickerViewController setDelegate:self];
		[self presentViewController:pickerViewController animated:YES completion:nil];
#else
    if(!myLocation)
    {
        NSLog(@"Not saving trips, as location is not available");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location not available" message:@"Cannot save trips as location is not avaiable" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        alert.tag=kNoteNotPossible;
        [alert show];
    }
    else
    {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"gridCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"INIT + PUSH");
    self.imageOfUnderlyingView =[self convertViewToImage:self.view];
    self.imageOfUnderlyingView = [_imageOfUnderlyingView applyBlurWithRadius:10
                                                                       tintColor:[UIColor colorWithWhite:1.0 alpha:0.4]
                                                           saturationDeltaFactor:1.3
                                                                       maskImage:nil];
        
        
    GridViewController* grvc= [[GridViewController alloc]initWithDelegate:self];
    //grvc.hidesBottomBarWhenPushed=YES;
    grvc.backImage=self.imageOfUnderlyingView ;
#ifdef MODAL
    [self presentViewController:grvc animated:YES completion:nil];
#else
    [[self navigationController] pushViewController:grvc animated:YES];
    self.navigationItem.backBarButtonItem.title=@"Cancel";
#endif

   
    }
    
#endif
}


//s Note this calls here
-(IBAction)notethis:(id)sender{
    /*if ([CLLocationManager locationServicesEnabled]) {
        if(IS_OS_8_OR_LATER) {
            [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }*/
    
#ifndef GRIDVIEW
    
    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Note This");
   
    
    //***** THIS IS THE ERROR POINT!!!!!********//
    
    if (myLocation){
        [noteManager addLocation:myLocation];
    }
	
		// Trip Purpose
		NSLog(@"INIT + PUSH");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
		PickerViewController *pickerViewController = [[storyboard instantiateViewControllerWithIdentifier:@"Picker"] initWithNibName:@"Picker" bundle:nil];
		[pickerViewController setDelegate:self];
		[self presentViewController:pickerViewController animated:YES completion:nil];
#else
    
    // Instead of picker category, we will set 'Grid Category'
    // And use it in the grid controller
    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey: @"gridCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Note This");
    
    if(!myLocation)
        {
            NSLog(@"Not taking notes, as location is not available");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location not available" message:@"Cannot take notes as location is not avaiable" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag=kNoteNotPossible;
            [alert show];
        }
    else
        {
            // Add note, push the grid view
            [noteManager addLocation:myLocation];
            NSLog(@"INIT + PUSH");
            
            NSLog(@"view is %@", self.view);
            self.imageOfUnderlyingView =[self convertViewToImage:self.view];
          
            //UIImageWriteToSavedPhotosAlbum(imageOfUnderlyingView, nil, nil, nil);
            self.imageOfUnderlyingView = [_imageOfUnderlyingView applyBlurWithRadius:10
                                                                     tintColor:[UIColor colorWithWhite:1.0 alpha:0.4]
                                                         saturationDeltaFactor:1.3
                                                                     maskImage:nil];
          
            
            GridViewController* grvc= [[GridViewController alloc]initWithDelegate:self];
            PersonalInfoViewController* prvc=[[PersonalInfoViewController alloc]init];
            //grvc.hidesBottomBarWhenPushed=YES;
            grvc.backImage=self.imageOfUnderlyingView ;
#ifdef MODAL
            UINavigationController *navigationController = [[UINavigationController alloc]
                                                            initWithRootViewController:grvc];
             grvc.hidesBottomBarWhenPushed=YES;
            grvc.navigationItem.backBarButtonItem.title=@"Cancel";
            grvc.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal ;
            
            [self presentViewController:navigationController animated:YES completion: nil];
           
#else
           
            [[self navigationController] pushViewController:grvc animated:YES];
            self.navigationItem.backBarButtonItem.title=@"Cancel";
#endif
        }
    
   
#endif
}


- (void)resetCounter
{
	if ( timeCounter != nil )
		timeCounter.text = @"00:00:00";
	
	if ( distCounter != nil )
		distCounter.text = @"0 mi";
}


- (void)setCounterTimeSince:(NSDate *)startDate distance:(CLLocationDistance)distance
{
	if ( timeCounter != nil )
	{
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
		
		static NSDateFormatter *inputFormatter = nil;
		if ( inputFormatter == nil )
			inputFormatter = [[NSDateFormatter alloc] init];
		
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *outputDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:fauxDate];
		
		timeCounter.text = [inputFormatter stringFromDate:outputDate];
	}
	
	if ( distCounter != nil )
		distCounter.text = [NSString stringWithFormat:@"%.1f mi", distance / 1609.344];
;
}


// handle start button action
- (void)updateCounter:(NSTimer *)theTimer
{
	//NSLog(@"updateCounter");
	if ( shouldUpdateCounter )
	{
		NSDate *startDate = [theTimer userInfo][@"StartDate"];
		NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];

		static NSDateFormatter *inputFormatter = nil;
		if ( inputFormatter == nil )
			inputFormatter = [[NSDateFormatter alloc] init];
		
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *fauxDate = [inputFormatter dateFromString:@"00:00:00"];
		[inputFormatter setDateFormat:@"HH:mm:ss"];
		NSDate *outputDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:fauxDate];
		
		//NSLog(@"Timer started on %@", startDate);
		//NSLog(@"Timer started %f seconds ago", interval);
		//NSLog(@"elapsed time: %@", [inputFormatter stringFromDate:outputDate] );
		
		//self.timeCounter.text = [NSString stringWithFormat:@"%.1f sec", interval];
		self.timeCounter.text = [inputFormatter stringFromDate:outputDate];
	}

}




- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillShow:(NSNotification *)aNotification
{
	NSLog(@"keyboardWillShow");
}


- (void)keyboardWillHide:(NSNotification *)aNotification
{
	NSLog(@"keyboardWillHide");
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (NSString *)updatePurposeWithString:(NSString *)purpose
{	
	// only enable start button if we don't already have a pending trip
	if ( timer == nil )
		startButton.enabled = YES;
	
	startButton.hidden = NO;
	
	return purpose;
}


- (NSString *)updatePurposeWithIndex:(unsigned int)index
{
	return [self updatePurposeWithString:[tripManager getPurposeString:index]];
}


#pragma mark UINavigationController


- (void)navigationController:(UINavigationController *)navigationController 
	   willShowViewController:(UIViewController *)viewController 
					animated:(BOOL)animated
{
	if ( viewController == self )
	{
		//NSLog(@"willShowViewController:self");
		self.title = @"Record New Trip";
	}
	else
	{
		//NSLog(@"willShowViewController:else");
		self.title = @"Back";
		self.tabBarItem.title = @"Record New Trip"; // important to maintain the same tab item title
	}
}


#pragma mark UITabBarControllerDelegate


- (BOOL)tabBarController:(UITabBarController *)tabBarController 
shouldSelectViewController:(UIViewController *)viewController
{
		return YES;		
}


#pragma mark PersonalInfoDelegate methods


- (void)setSaved:(BOOL)value
{
	NSLog(@"setSaved");
	// no-op

}


#pragma mark TripPurposeDelegate methods


- (NSString *)setPurpose:(unsigned int)index
{
	NSString *purpose = [tripManager setPurpose:index];
	NSLog(@"setPurpose: %@", purpose);
	
	return [self updatePurposeWithString:purpose];
}


- (NSString *)getPurposeString:(unsigned int)index
{
	return [tripManager getPurposeString:index];
}


- (void)didCancelPurpose
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.isRecording = YES;
	recording = YES;
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey: @"recording"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	shouldUpdateCounter = YES;
}

- (void)didCancelNote
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    appDelegate = [[UIApplication sharedApplication] delegate];
}


- (void)didCancelNoteDelete
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:noteManager.managedObjectContext];
	[request setEntity:entity];
    
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[@"note_type",@"recorded"]];
    
	// configure sort order
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recorded" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error;
	NSInteger count = [noteManager.managedObjectContext countForFetchRequest:request error:&error];
	NSLog(@"count = %ld", (long)count);
	
	NSMutableArray *mutableFetchResults = [[noteManager.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    
    NSManagedObject *noteToDelete = mutableFetchResults[0];
    [noteManager.managedObjectContext deleteObject:noteToDelete];
    
    if (![noteManager.managedObjectContext save:&error]) {
        // Handle the error.
        NSLog(@"Unresolved error %@", [error localizedDescription]);
    }
    

}


- (void)didPickPurpose:(unsigned int)index
{
	[tripManager setPurpose:index];
}

- (void)didEnterTripDetails:(NSString *)details{
    [tripManager saveNotes:details];
    NSLog(@"Trip Added details: %@",details);
}

- (void)saveTrip{
    [tripManager saveTrip];
    [self resetRecordingInProgress];
    NSLog(@"Save trip");
}

- (void)didPickNoteType:(NSNumber *)index
{
    
    // This is where the note is set...
    noteManager.note.note_type=index;
    NSLog(@"Added note type: %d", [noteManager.note.note_type intValue]);
    //do something here: may change to be the save as a separate view. Not prompt.
}

- (void)didEnterNoteDetails:(NSString *)details{
    [noteManager.note setDetails:details];
    NSLog(@"Note Added details: %@", noteManager.note.details);
}

- (void)didSaveImage:(NSData *)imgData{
    [noteManager.note setImage_data:imgData];
    NSLog(@"Added image, Size of Image(bytes):%lu", (unsigned long)[imgData length]);
}

- (void)getTripThumbnail:(NSData *)imgData{
    [tripManager.trip setThumbnail:imgData];
    NSLog(@"Trip Thumbnail, Size of Image(bytes):%lu", (unsigned long)[imgData length]);
}

- (void)getNoteThumbnail:(NSData *)imgData{
    [noteManager.note setThumbnail:imgData];
    NSLog(@"Note Thumbnail, Size of Image(bytes):%lu", (unsigned long)[imgData length]);
}

- (void)saveNote{
    [noteManager saveNote];
    NSLog(@"Save note");
}




#pragma mark RecordingInProgressDelegate method


- (Trip *)getRecordingInProgress {
	if ( recording )
		return tripManager.trip;
	else
		return nil;
}


- (void)dealloc {
    
    appDelegate.locationManager = nil;
    self.timer = nil;
    self.recording = nil;
    self.shouldUpdateCounter = nil;
    self.userInfoSaved = nil;
    
    
    
}

#pragma mark Local notification
// Used for the magnetNotes feature when app is in background (impossible to vibrate)
-(void) fireNotif
{
    NSLog(@"Fire notif");
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    self.localNotification = [[UILocalNotification alloc] init];
    if (self.localNotification == nil)
    {
        return;
    }
    else
    {
        self.localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        self.localNotification.alertAction = nil;
        self.localNotification.soundName = UILocalNotificationDefaultSoundName;
        self.localNotification.alertBody = @"Magnet detected !";
        self.localNotification.alertAction = NSLocalizedString(@"Detail note", nil);
        //self.localNotification.applicationIconBadgeNumber=1;
        self.localNotification.repeatInterval=0;
        [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotification];
    }
}

/*
- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif
{
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    app.applicationIconBadgeNumber = notif.applicationIconBadgeNumber -1;
    
    notif.soundName = UILocalNotificationDefaultSoundName;
    
     [self _showAlert:[NSString stringWithFormat:@"%@",Your msg withTitle:@"Title"];

}

- (void) _showAlert:(NSString*)pushmessage withTitle:(NSString*)title
    {
        [self.alertView_local removeFromSuperview];
        self.alertView_local = [[UIAlertView alloc] initWithTitle:title message:pushmessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.alertView_local show];
        
        if (self.alertView_local)
        {
        }
}*/

@end