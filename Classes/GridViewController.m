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
        NSArray* items=[self createMenuItems];
		[self setMenuItems:items];
	}
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated

{
    [self.navigationController setNavigationBarHidden:NO];
}
#pragma mark - Local Methods

- (NSArray *)createMenuItems {
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    NSLog(@"PickerCategory : %ld", (long)pickerCategory);
    
    NSMutableDictionary* itemDict=[[NSMutableDictionary alloc]init];
    int no_items=9;
    
    for (int row=0;row<no_items;i++)
    {
        
    
        if(pickerCategory==0)
            {
                switch (row) {
                        
                        
                    case 0:
                        [itemDict setObject:kAssetDescNoteThisSpot  forKey:[NSNumber numberWithInt:row]];
                     
                        break;
                    case 1:
                        [itemDict setObject:kAssetDescWaterFountains  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 2:
                        [itemDict setObject:kAssetDescSecretPassage  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 3:
                        [itemDict setObject:kAssetDescPublicRestrooms  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 4:
                        [itemDict setObject:kAssetDescBikeShops  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 5:
                        
                        [itemDict setObject:kAssetDescBikeParking  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 6:
                        [itemDict setObject:kDescNoteThis forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 7:
                        [itemDict setObject:kIssueDescPavementIssue forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 8:
                        [itemDict setObject:kIssueDescTrafficSignal forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 9:
                        [itemDict setObject:kIssueDescEnforcement forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 10:
                        [itemDict setObject:kIssueDescNeedParking forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 11:
                        [itemDict setObject:kIssueDescBikeLaneIssue forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 12:
                        [itemDict setObject:kIssueDescNoteThisSpot forKey:[NSNumber numberWithInt:row]];
                        break;
            }
    }
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

/*- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = @"Main Menu";
	self.view.backgroundColor = [UIColor whiteColor];
}*/


- (void)viewDidLoad
{
    [super viewDidLoad];
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"pickerCategory"];
    
    NSLog(@"PickerCategory : %ld", (long)pickerCategory);
    
    if (pickerCategory == 0) {
        self.navigationItem.title = @"Trip Purpose";
        
    }
    else if (pickerCategory == 1){
        self.navigationItem.title = @"Boo this...";
      
    }
    else if (pickerCategory == 2){
        self.navigationItem.title= @"This is rad!";
        
    }
    else if (pickerCategory == 3){
        self.navigationItem.title = @"Make a note";
       
    }
    self.view.backgroundColor = [UIColor whiteColor];
}
@end