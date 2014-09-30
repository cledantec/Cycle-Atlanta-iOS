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
    
    pickerCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"gridCategory"];
    
    NSLog(@"PickerCategory : %ld", (long)pickerCategory);
    
    NSMutableDictionary* itemDict=[[NSMutableDictionary alloc]init];
    int no_items=12;
    
    for (int row=0;row<no_items;row++)
    {
        
        NSMutableDictionary* itemVals=[[NSMutableDictionary alloc]init];
        if(pickerCategory==3)
            {
                switch (row) {
                    case 0:
                        [itemVals setObject:kAssetDescNoteThisSpot forKey:@"desc"];
                        [itemVals setObject:@"Note this asset" forKey:@"title"];
                        [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 1:
                        [itemVals setObject:kAssetDescWaterFountains forKey:@"desc"];
                        [itemVals setObject:@"Water fountains" forKey:@"title"];
                        [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 2:
                        [itemVals setObject:kAssetDescSecretPassage forKey:@"desc"];
                        [itemVals setObject:@"Secret passage" forKey:@"title"];
                        [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 3:
                        [itemVals setObject:kAssetDescPublicRestrooms forKey:@"desc"];
                        [itemVals setObject:@"Public restrooms" forKey:@"title"];
                        [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 4:
                        [itemVals setObject:kAssetDescBikeShops forKey:@"desc"];
                        [itemVals setObject:@"Bike shops" forKey:@"title"];
                        [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 5:
                        [itemVals setObject:kAssetDescBikeParking forKey:@"desc"];
                        [itemVals setObject:@"Bike parking" forKey:@"title"];
                        [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 6:
                        [itemVals setObject:kDescNoteThis forKey:@"desc"];
                        [itemVals setObject:@"Note This" forKey:@"title"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 7:
                        [itemVals setObject:kIssueDescPavementIssue forKey:@"desc"];
                        [itemVals setObject:@"Pavement issue" forKey:@"title"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 8:
                        [itemVals setObject:kIssueDescTrafficSignal forKey:@"desc"];
                        [itemVals setObject:@"Traffic signal" forKey:@"title"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 9:
                        [itemVals setObject:kIssueDescEnforcement forKey:@"desc"];
                        [itemVals setObject:@"Enforcement" forKey:@"title"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 10:
                        [itemVals setObject:kAssetDescSecretPassage forKey:@"desc"];
                        [itemVals setObject:@"Secret passage" forKey:@"title"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 11:
                        [itemVals setObject:kIssueDescBikeLaneIssue forKey:@"desc"];
                        [itemVals setObject:@"Bike Lane Issue" forKey:@"title"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 12:
                        [itemVals setObject:kIssueDescNoteThisSpot forKey:@"desc"];
                        [itemVals setObject:@"Note this issue" forKey:@"title"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
            }
            }
    }
	NSMutableArray *items = [[NSMutableArray alloc] init];
    
    for(id key in itemDict)
    {
        NSString* title=[[itemDict objectForKey:key]objectForKey:@"title"];
        NSString* description=[[itemDict objectForKey:key]objectForKey:@"desc"];
        NAMenuItem* item=[[NAMenuItem alloc]initWithTitle:title image:[UIImage imageNamed:@"icon.png"] vcClass:[UIAlertView class] desc:description];
        [items addObject:item];
    }
	
	/*// First Item
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
	[items addObject:item9]; */
	
	return items;
}




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