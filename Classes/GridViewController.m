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
@synthesize delegate;
@synthesize backImage;
@synthesize trips;

- (id)initWithDelegate:(id<TripPurposeDelegate>)Del
 {
	self = [super init];
     self.delegate=Del;
	if (self) {
 NSArray* items=[self createMenuItems];
 [self setMenuItems:items];
	}
	
	return self;
 }

/*
- (id)init
{
	self = [super init];
	
	if (self) {
        NSArray* items=[self createMenuItems];
		[self setMenuItems:items];
	}
	
	return self;
}
*/
- (void)viewWillAppear:(BOOL)animated

{
    /*UIBarButtonItem *boton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(mySelector:)];
    self.navigationItem.backBarButtonItem  = boton;
     //[self.navigationController setNavigationBarHidden:NO];*/
   // NSLog(@"Title is %@" , self.navigationItem.hidesBackButton);
   // self.navigationItem.hidesBackButton=true;
      // [self.navigationController setNavigationBarHidden:NO animated:YES];
    //
    
}
#pragma mark - Local Methods

- (NSArray *)createMenuItems {
    
    gridCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"gridCategory"];
    
    NSLog(@"PickerCategory : %ld", (long)gridCategory);
    
    NSMutableDictionary* itemDict=[[NSMutableDictionary alloc]init];
    int no_items;
    if(gridCategory==3)
        {
            no_items=13;
            for (int row=0;row<no_items;row++)
                {
                    NSMutableDictionary* itemVals=[[NSMutableDictionary alloc]init];

                switch (row) {
                    case 0:
                        [itemVals setObject:kAssetDescNoteThisSpot forKey:@"desc"];
                        [itemVals setObject:@"Note this asset" forKey:@"title"];
                        [itemVals setObject:@"0" forKey:@"isIssue"];
                        [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 1:
                        [itemVals setObject:kAssetDescWaterFountains forKey:@"desc"];
                        [itemVals setObject:@"Water fountains" forKey:@"title"];
                        [itemVals setObject:@"0" forKey:@"isIssue"];
                        [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 2:
                        [itemVals setObject:kAssetDescSecretPassage forKey:@"desc"];
                        [itemVals setObject:@"Secret passage" forKey:@"title"];
                        [itemVals setObject:@"0" forKey:@"isIssue"];
                        [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 3:
                        [itemVals setObject:kAssetDescPublicRestrooms forKey:@"desc"];
                        [itemVals setObject:@"Public restrooms" forKey:@"title"];
                        [itemVals setObject:@"0" forKey:@"isIssue"];
                        [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 4:
                        [itemVals setObject:kAssetDescBikeShops forKey:@"desc"];
                        [itemVals setObject:@"Bike shops" forKey:@"title"];
                        [itemVals setObject:@"0" forKey:@"isIssue"];
                        [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 5:
                        [itemVals setObject:kAssetDescBikeParking forKey:@"desc"];
                        [itemVals setObject:@"Bike parking" forKey:@"title"];
                        [itemVals setObject:@"0" forKey:@"isIssue"];
                        [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 6:
                        [itemVals setObject:kDescNoteThis forKey:@"desc"];
                        [itemVals setObject:@"Note This Issue" forKey:@"title"];
                        [itemVals setObject:@"1" forKey:@"isIssue"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 7:
                        [itemVals setObject:kIssueDescPavementIssue forKey:@"desc"];
                        [itemVals setObject:@"Pavement issue" forKey:@"title"];
                        [itemVals setObject:@"1" forKey:@"isIssue"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 8:
                        [itemVals setObject:kIssueDescTrafficSignal forKey:@"desc"];
                        [itemVals setObject:@"Traffic signal" forKey:@"title"];
                        [itemVals setObject:@"1" forKey:@"isIssue"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 9:
                        [itemVals setObject:kIssueDescEnforcement forKey:@"desc"];
                        [itemVals setObject:@"Enforcement" forKey:@"title"];
                        [itemVals setObject:@"1" forKey:@"isIssue"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 10:
                        [itemVals setObject:kAssetDescSecretPassage forKey:@"desc"];
                        [itemVals setObject:@"Secret passage" forKey:@"title"];
                        [itemVals setObject:@"1" forKey:@"isIssue"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 11:
                        [itemVals setObject:kIssueDescBikeLaneIssue forKey:@"desc"];
                        [itemVals setObject:@"Bike Lane Issue" forKey:@"title"];
                        [itemVals setObject:@"1" forKey:@"isIssue"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                    case 12:
                        [itemVals setObject:kIssueDescNoteThisSpot forKey:@"desc"];
                        [itemVals setObject:@"Note this issue" forKey:@"title"];
                        [itemVals setObject:@"1" forKey:@"isIssue"];
                        [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                        break;
                }
            }
            
            NSMutableArray *items = [[NSMutableArray alloc] init];
            for(int key=0;key<no_items;key++)
            {
                NSString* title=[[itemDict objectForKey:[NSNumber numberWithInt:key]]objectForKey:@"title"];
                NSString* description=[[itemDict objectForKey:[NSNumber numberWithInt:key]]objectForKey:@"desc"];
                NSString* isIssue=[[itemDict objectForKey:[NSNumber numberWithInt:key]]objectForKey:@"isIssue"];
                UIImage* image;
                // Set the images
                if([isIssue isEqualToString:@"1"])
                    {
                         image = [UIImage imageNamed:kNoteThisIssue];
                    }
                else
                {
                    image=[UIImage imageNamed:kNoteThisAsset];
                }
                NAMenuItem* item=[[NAMenuItem alloc]initWithTitle:title image:image purposeType:@"Note" desc:description issueBool:isIssue row_no:key delegate:self.delegate];
                [items addObject:item];
            }
            return items;

            
    }
    else if(gridCategory==0)
    {
        no_items=8;
        for (int row=0;row<no_items;row++)
        {
            NSMutableDictionary* itemVals=[[NSMutableDictionary alloc]init];

            switch (row) {
                case 0:
                    [itemVals setObject:kDescCommute forKey:@"desc"];
                    [itemVals setObject:@"Commute" forKey:@"title"];
                    [itemVals setObject:@"0" forKey:@"isIssue"];
                    [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                    break;
                case 1:
                    [itemVals setObject:kDescSchool forKey:@"desc"];
                    [itemVals setObject:@"School" forKey:@"title"];
                    [itemVals setObject:@"0" forKey:@"isIssue"];
                    [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                    break;
                case 2:
                    [itemVals setObject:kDescWork forKey:@"desc"];
                    [itemVals setObject:@"Work" forKey:@"title"];
                    [itemVals setObject:@"0" forKey:@"isIssue"];
                    [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                    break;
                case 3:
                    [itemVals setObject:kDescExercise forKey:@"desc"];
                    [itemVals setObject:@"Exercise" forKey:@"title"];
                    [itemVals setObject:@"0" forKey:@"isIssue"];
                    [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                    break;
                case 4:
                    [itemVals setObject:kDescSocial forKey:@"desc"];
                    [itemVals setObject:@"Social" forKey:@"title"];
                    [itemVals setObject:@"0" forKey:@"isIssue"];
                    [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                    break;
                case 5:
                    [itemVals setObject:kDescShopping forKey:@"desc"];
                    [itemVals setObject:@"Shopping" forKey:@"title"];
                    [itemVals setObject:@"0" forKey:@"isIssue"];
                    [itemDict setObject:itemVals  forKey:[NSNumber numberWithInt:row]];
                    break;
                case 6:
                    [itemVals setObject:kDescErrand forKey:@"desc"];
                    [itemVals setObject:@"Errand" forKey:@"title"];
                    [itemVals setObject:@"0" forKey:@"isIssue"];
                    [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                    break;
                case 7:
                    [itemVals setObject:kDescOther forKey:@"desc"];
                    [itemVals setObject:@"Other" forKey:@"title"];
                    [itemVals setObject:@"0" forKey:@"isIssue"];
                    [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                    break;
                case 8:
            // Work on fetching last trip!
                    [itemVals setObject:kDescOther forKey:@"desc"];
                    [itemVals setObject:@"Last Trip" forKey:@"title"];
                    [itemVals setObject:@"0" forKey:@"isIssue"];
                    [itemDict setObject:itemVals forKey:[NSNumber numberWithInt:row]];
                    break;
                           }
        }
    
	NSMutableArray *items = [[NSMutableArray alloc] init];
    for(int key=0;key<no_items;key++)
    {
        NSString* title=[[itemDict objectForKey:[NSNumber numberWithInt:key]]objectForKey:@"title"];
        NSString* description=[[itemDict objectForKey:[NSNumber numberWithInt:key]]objectForKey:@"desc"];
        NSString* isIssue=[[itemDict objectForKey:[NSNumber numberWithInt:key]]objectForKey:@"isIssue"];
          UIImage* image;
        // Set the images
        switch ( key ) {
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
        NAMenuItem* item=[[NAMenuItem alloc]initWithTitle:title image:image purposeType:@"Trip" desc:description issueBool:isIssue row_no:key delegate:self.delegate];
        [items addObject:item];
    }
        return items;
    }

	
    return nil;
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
     //NSLog(@"Title is %@" , self.navigationItem.backBarButtonItem);
    
    gridCategory = [[NSUserDefaults standardUserDefaults] integerForKey:@"gridCategory"];
    
    NSLog(@"PickerCategory : %ld", (long)gridCategory);
    
    if (gridCategory == 0) {
        self.navigationItem.title = @"Trip Purpose";
        
    }
    else if (gridCategory == 1){
        self.navigationItem.title = @"Boo this...";
      
    }
    else if (gridCategory == 2){
        self.navigationItem.title= @"This is rad!";
        
    }
    else if (gridCategory == 3){
        self.navigationItem.title = @"Make a note";
       
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:self.backImage];

}
@end