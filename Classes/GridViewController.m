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
//	PickerViewController.m
//	CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/28/09.
//	For more information on the project,
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>


#import "CustomView.h"
#import "GridViewController.h"
#import "DetailViewController.h"
#import "TripDetailViewController.h"
#import "TripManager.h"
#import "NoteManager.h"
#import "RecordTripViewController.h"
#import "SelectViewController.h"

@implementation GridViewController

- (id)init
{
	self = [super init];
	
	if (self) {
		[self setMenuItems:[self createMenuItems]];
	}
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated

{
    [self.navigationController setNavigationBarHidden:NO];
}
#pragma mark - Local Methods

- (NSArray *)createMenuItems {
	NSMutableArray *items = [[NSMutableArray alloc] init];
	
	// First Item
	NAMenuItem *item1 = [[NAMenuItem alloc] initWithTitle:@"First Item"
                                                    image:[UIImage imageNamed:@"icon.png"]
                                                  vcClass:[SelectViewController class]];
	[items addObject:item1];
	
	// Second Item
	NAMenuItem *item2 = [[NAMenuItem alloc] initWithTitle:@"Second Item"
                                                    image:[UIImage imageNamed:@"icon.png"]
                                                  vcClass:[SelectViewController class]];
	[items addObject:item2];
	
	// Third Item
	NAMenuItem *item3 = [[NAMenuItem alloc] initWithTitle:@"Third Item"
                                                    image:[UIImage imageNamed:@"icon.png"]
                                                  vcClass:[SelectViewController class]];
	[items addObject:item3];
	
	// Fourth Item
	NAMenuItem *item4 = [[NAMenuItem alloc] initWithTitle:@"Fourth Item"
                                                    image:[UIImage imageNamed:@"icon.png"]
                                                  vcClass:[SelectViewController class]];
	[items addObject:item4];
	
	// Fifth Item
	NAMenuItem *item5 = [[NAMenuItem alloc] initWithTitle:@"Fifth Item"
                                                    image:[UIImage imageNamed:@"icon.png"]
                                                  vcClass:[SelectViewController class]];
	[items addObject:item5];
	
	// Sixth Item
	NAMenuItem *item6 = [[NAMenuItem alloc] initWithTitle:@"Sixth Item"
                                                    image:[UIImage imageNamed:@"icon.png"]
                                                  vcClass:[SelectViewController class]];
	[items addObject:item6];
	
	// Seventh Item
	NAMenuItem *item7 = [[NAMenuItem alloc] initWithTitle:@"Seventh Item"
                                                    image:[UIImage imageNamed:@"icon.png"]
                                                  vcClass:[SelectViewController class]];
	[items addObject:item7];
	
	// Eighth Item
	NAMenuItem *item8 = [[NAMenuItem alloc] initWithTitle:@"Eighth Item"
                                                    image:[UIImage imageNamed:@"icon.png"]
                                                  vcClass:[SelectViewController class]];
	[items addObject:item8];
    
	// Ninth Item
	NAMenuItem *item9 = [[NAMenuItem alloc] initWithTitle:@"Ninth Item" 
                                                    image:[UIImage imageNamed:@"icon.png"] 
                                                  vcClass:[SelectViewController class]];
	[items addObject:item9];
	
	return items;
}


#pragma mark - View Lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = @"Main Menu";
	self.view.backgroundColor = [UIColor whiteColor];
}



/*
// return the picker frame based on its size
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect pickerRect = CGRectMake(	0.0, 78.0, size.width, size.height );
	return pickerRect;
}


- (void)createCustomPicker
{
	customPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	customPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	// setup the data source and delegate for this picker
	customPickerDataSource = [[CustomPickerDataSource alloc] init];
	customPickerDataSource.parent = self;
	customPickerView.dataSource = customPickerDataSource;
	customPickerView.delegate = customPickerDataSource;
	
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.
	//
	// position the picker at the bottom
	CGSize pickerSize = [customPickerView sizeThatFits:CGSizeZero];
	customPickerView.frame = [self pickerFrameWithSize:pickerSize];
	
	customPickerView.showsSelectionIndicator = YES;
	
	// add this picker to our view controller, initially hidden
	//customPickerView.hidden = YES;
	[self.view addSubview:customPickerView];
}


- (IBAction)cancel:(id)sender
//add value to be sent in
{
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 3) {
        [delegate didCancelNoteDelete];
        NSLog(@"Note Cancel Pressed!!!!!!!!!!!!");
    }
    
    if (pickerCategory == 0) {
        [delegate didCancelNote];
        NSLog(@"Trip Cancel Pressed!!!!!!!!!!!!");
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey: @"pickerCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (IBAction)save:(id)sender
{
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 0) {
        NSLog(@"Purpose Save button pressed");
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        TripDetailViewController *tripDetailViewController = [[storyboard
                                                               instantiateViewControllerWithIdentifier: @"TripDetail"] initWithNibName:@"TripDetail" bundle:nil];
        tripDetailViewController.delegate = self.delegate;
        
        [self presentViewController:tripDetailViewController animated:YES completion:nil];
        
        [delegate didPickPurpose:(unsigned int)row];
    }
    else if (pickerCategory == 1){
        NSLog(@"Issue Save button pressed");
        NSLog(@"detail");
        NSLog(@"INIT + PUSH");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        DetailViewController *detailViewController = [[storyboard instantiateViewControllerWithIdentifier:@"Detail"] initWithNibName:@"Detail" bundle:nil];
        detailViewController.delegate = self.delegate;
        
        [self presentViewController:detailViewController animated:YES completion:nil];
        //Note: get index of picker
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        [[NSUserDefaults standardUserDefaults] setInteger:row forKey: @"pickedNotedType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        NSLog(@"pickedNotedType is %ld", (long)pickedNotedType);
    }
    else if (pickerCategory == 2){
        NSLog(@"Asset Save button pressed");
        NSLog(@"detail");
        NSLog(@"INIT + PUSH");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        DetailViewController *detailViewController = [[storyboard instantiateViewControllerWithIdentifier:@"Detail"] initWithNibName:@"Detail" bundle:nil];
        detailViewController.delegate = self.delegate;
        
        [self presentViewController:detailViewController animated:YES completion:nil];
        //do something here: get index for later use.
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        [[NSUserDefaults standardUserDefaults] setInteger:row+6 forKey: @"pickedNotedType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        pickedNotedType = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickedNotedType"];
        
        NSLog(@"pickedNotedType is %ld", (long)pickedNotedType);
        
    }
    else if (pickerCategory == 3){
        NSLog(@"Note This Save button pressed");
        NSLog(@"detail");
        NSLog(@"INIT + PUSH");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        DetailViewController *detailViewController = [[storyboard instantiateViewControllerWithIdentifier:@"Detail"] initWithNibName:@"Detail" bundle:nil];
        
        detailViewController.delegate = self.delegate;
        
        [self presentViewController:detailViewController animated:YES completion:nil];
        
        //Note: get index of type
        NSInteger row = [customPickerView selectedRowInComponent:0];
        
        NSNumber *tempType = 0;
        
        if(row>=7){
            tempType = @(row-7);
        }
        else if (row<=5){
            tempType = @(11-row);
        }
        
        NSLog(@"tempType: %d", [tempType intValue]);
        
        [delegate didPickNoteType:tempType];
    }
}


- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	NSLog(@"initWithNibNamed");
    //NSLog(@"PickerViewController init");
	[self createCustomPicker];
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    if (pickerCategory == 0) {
        // picker defaults to top-most item => update the description
        [self pickerView:customPickerView didSelectRow:0 inComponent:0];
    }
    else if (pickerCategory == 3){
        // picker defaults to top-most item => update the description
        [self pickerView:customPickerView didSelectRow:6 inComponent:0];
    }
	return self;
}


- (id)initWithPurpose:(NSInteger)index
{
	if (self = [self init])
	{
		//NSLog(@"PickerViewController initWithPurpose: %d", index);
		
		// update the picker
		[customPickerView selectRow:index inComponent:0 animated:YES];
		
		pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
        if (pickerCategory == 0) {
            // picker defaults to top-most item => update the description
            [self pickerView:customPickerView didSelectRow:0 inComponent:0];
        }
        else if (pickerCategory == 3){
            // picker defaults to top-most item => update the description
            [self pickerView:customPickerView didSelectRow:6 inComponent:0];
        }
	}
	return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    NSLog(@"PickerCategory : %ld", (long)pickerCategory);
    
    if (pickerCategory == 0) {
        navBarItself.topItem.title = @"Trip Purpose";
        self.descriptionText.text = @"Please select your trip purpose & tap Save";
    }
    else if (pickerCategory == 1){
        navBarItself.topItem.title = @"Boo this...";
        self.descriptionText.text = @"Please select the issue type & tap Save";
    }
    else if (pickerCategory == 2){
        navBarItself.topItem.title = @"This is rad!";
        self.descriptionText.text = @"Please select the asset type & tap Save";
    }
    else if (pickerCategory == 3){
        navBarItself.topItem.title = @"Note This";
        self.descriptionText.text = @"Please select the type & tap Save";
        [self.customPickerView selectRow:6 inComponent:0 animated:NO];
        if ([self.customPickerView selectedRowInComponent:0] == 6) {
            navBarItself.topItem.rightBarButtonItem.enabled = NO;
        }
        else{
            navBarItself.topItem.rightBarButtonItem.enabled = YES;
        }
    }
    
    description = [[UITextView alloc] initWithFrame:CGRectMake( 18.0, 314.0, 284.0, 120.0 )];
	description.editable = NO;
    description.textColor = [UIColor darkGrayColor];
    
	description.font = [UIFont fontWithName:@"Helvetica" size:16];
	[self.view addSubview:description];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark UIPickerViewDelegate


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerCategory == 3){
        if ([self.customPickerView selectedRowInComponent:0] == 6) {
            navBarItself.topItem.rightBarButtonItem.enabled = NO;
        }
        else{
            navBarItself.topItem.rightBarButtonItem.enabled = YES;
        }
    }
	//NSLog(@"parent didSelectRow: %d inComponent:%d", row, component);
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    if (pickerCategory == 0) {
        switch (row) {
            case 0:
                description.text = kDescCommute;
                break;
            case 1:
                description.text = kDescSchool;
                break;
            case 2:
                description.text = kDescWork;
                break;
            case 3:
                description.text = kDescExercise;
                break;
            case 4:
                description.text = kDescSocial;
                break;
            case 5:
                description.text = kDescShopping;
                break;
            case 6:
                description.text = kDescErrand;
                break;
            default:
                description.text = kDescOther;
                break;
        }
    }
    
    else if (pickerCategory == 1){
        switch (row) {
            case 0:
                description.text = kIssueDescPavementIssue;
                break;
            case 1:
                description.text = kIssueDescTrafficSignal;
                break;
            case 2:
                description.text = kIssueDescEnforcement;
                break;
            case 3:
                description.text = kIssueDescNeedParking;
                break;
            case 4:
                description.text = kIssueDescBikeLaneIssue;
                break;
            default:
                description.text = kIssueDescNoteThisSpot;
                break;
        }
    }
    else if (pickerCategory == 2){
        switch (row) {
            case 0:
                description.text = kAssetDescBikeParking;
                break;
            case 1:
                description.text = kAssetDescBikeShops;
                break;
            case 2:
                description.text = kAssetDescPublicRestrooms;
                break;
            case 3:
                description.text = kAssetDescSecretPassage;
                break;
            case 4:
                description.text = kAssetDescWaterFountains;
                break;
            default:
                description.text = kAssetDescNoteThisSpot;
                break;
        }
    }
    else if (pickerCategory == 3){
        switch (row) {
            case 6:
                description.text = kDescNoteThis;
                break;
                
            case 0:
                description.text = kAssetDescNoteThisSpot;
                break;
            case 1:
                description.text = kAssetDescWaterFountains;
                break;
            case 2:
                description.text = kAssetDescSecretPassage;
                break;
            case 3:
                description.text = kAssetDescPublicRestrooms;
                break;
            case 4:
                description.text = kAssetDescBikeShops;
                break;
            case 5:
                description.text = kAssetDescBikeParking;
                break;
                
                
                
            case 7:
                description.text = kIssueDescPavementIssue;
                break;
            case 8:
                description.text = kIssueDescTrafficSignal;
                break;
            case 9:
                description.text = kIssueDescEnforcement;
                break;
            case 10:
                description.text = kIssueDescNeedParking;
                break;
            case 11:
                description.text = kIssueDescBikeLaneIssue;
                break;
            case 12:
                description.text = kIssueDescNoteThisSpot;
                break;
                
        }
    }
}


*/

@end

