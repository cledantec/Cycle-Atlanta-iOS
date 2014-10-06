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
//  RecordTripViewController.h
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/10/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>

#import <AudioToolbox/AudioServices.h>
#import <CoreLocation/CoreLocation.h>
#import "ActivityIndicatorDelegate.h"
#import <MapKit/MapKit.h>
#import "PersonalInfoDelegate.h"
#import "RecordingInProgressDelegate.h"
#import "TripPurposeDelegate.h"
#import "CycleAtlantaAppDelegate.h"
#import "Note.h"


@class ReminderManager;
@class TripManager;
@class NoteManager;

@interface RecordTripViewController : UIViewController 
	<CLLocationManagerDelegate,
	MKMapViewDelegate,
	UINavigationControllerDelegate, 
	UITabBarControllerDelegate, 
	PersonalInfoDelegate,
	RecordingInProgressDelegate,
	TripPurposeDelegate,
	UIActionSheetDelegate,
	UIAlertViewDelegate,
	UITextViewDelegate>
{
    NSManagedObjectContext *managedObjectContext;
	CycleAtlantaAppDelegate *appDelegate;
	BOOL				didUpdateUserLocation;
	IBOutlet MKMapView	*mapView;

	IBOutlet UIButton *startButton;
    IBOutlet UIButton *noteButton;
	
	IBOutlet UILabel *timeCounter;
	IBOutlet UILabel *distCounter;
	IBOutlet UILabel *speedCounter;
    UIActionSheet *saveActionSheet;
    
    CGFloat fieldNorm;
    IBOutlet UIButton *noteToDetailAlert;
    UILocalNotification *localNotification;

	NSTimer *__weak timer;
	
	UIView *opacityMask;
	UIView *parentView;
	
	BOOL recording;
	BOOL shouldUpdateCounter;
	BOOL userInfoSaved;
    NSInteger pickerCategory;
    
    CLLocation *myLocation;
    CLLocationManager* locationManager;
    
	TripManager	*tripManager;
    NoteManager *noteManager;
   
}


@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *noteButton;
@property (nonatomic, strong) UILabel *timeCounter;
@property (nonatomic, strong) UILabel *distCounter;
@property (nonatomic, strong) UIActionSheet *saveActionSheet;
@property (nonatomic, strong) UIButton *noteToDetailAlert;
@property (nonatomic, strong) UILocalNotification *localNotification;
@property (weak) NSTimer *timer;
@property (nonatomic, strong) UIView   *parentView;
@property (assign) BOOL recording;
@property (assign) BOOL shouldUpdateCounter;
@property (assign) BOOL userInfoSaved;
@property (nonatomic, strong) CycleAtlantaAppDelegate *appDelegate;
@property (nonatomic, strong) TripManager *tripManager;
@property (nonatomic, strong) NoteManager *noteManager;
@property (nonatomic,strong) CLLocationManager* locationManager;

- (void)save;
- (IBAction)start:(UIButton *)sender;
-(IBAction)notethis:(id)sender;

- (void)resetCounter;
- (void)resetRecordingInProgress;
- (void)setCounterTimeSince:(NSDate *)startDate distance:(CLLocationDistance)distance;
- (void)updateCounter:(NSTimer *)theTimer;

- (UIButton *)createStartButton;

- (void)initTripManager:(TripManager*)manager;
- (void)initNoteManager:(NoteManager*)manager;

-(void) fireNotif;


@end
