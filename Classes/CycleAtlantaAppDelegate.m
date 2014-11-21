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
//  CycleTracksAppDelegate.m
//  CycleTracks
//
//  Copyright 2009-2010 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/21/09.
//	For more information on the project, 
//	e-mail Billy Charlton at the SFCTA <billy.charlton@sfcta.org>

#import <CommonCrypto/CommonDigest.h>


#import "CycleAtlantaAppDelegate.h"
#import "PersonalInfoViewController.h"
#import "RecordTripViewController.h"
#import "SavedTripsViewController.h"
#import "SavedNotesViewController.h"
#import "TripManager.h"
#import "NSString+MD5Addition.h"
#import "UIDevice+IdentifierAddition.h"
#import "constants.h"
#import "DetailViewController.h"
#import "NoteManager.h"
#import <CoreData/NSMappingModel.h>
#import "ProgressView.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation CycleAtlantaAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize uniqueIDHash;
@synthesize isRecording;
@synthesize locationManager;
@synthesize storeLoadingView;
@synthesize managedObjectContext;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // init our unique ID hash
    /*
	[self initUniqueIDHash];
    
    self.storeLoadingView = [ProgressView progressViewInView: self.storeLoadingView messageString:nil progressTypePlain:NO] ;
    [window addSubview:self.storeLoadingView];
    
    [window makeKeyAndVisible];
    [self performSelectorInBackground:@selector(loadPersistentStore) withObject:nil];
     */
    
}

-(void)loadPersistentStore
{
    NSLog(@"loadPersistentStore!");
    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];
    [self performSelectorOnMainThread:@selector(persistentStoreLoaded:) withObject:coordinator waitUntilDone:YES];
}

-(void)persistentStoreLoaded: (NSPersistentStoreCoordinator *) coordinator;
{
    NSLog(@"persistentStoreLoaded.");
    [self.storeLoadingView removeFromSuperview];
    self.storeLoadingView = nil;
    CGRect frame    = [[UIScreen mainScreen] bounds];
    backgroundView = [[UIView alloc] initWithFrame:frame];
    backgroundView.backgroundColor = [UIColor colorWithRed:((float) 0 / 255.0f)
                                                           green:((float) 0 / 255.0f)
                                                           blue:((float) 0 / 255.0f)
                                                           alpha:1.0f];
    
    NSLog(@"persistentStoreLoaded...Context ?");
	
    NSManagedObjectContext *context = [self managedObjectContext: coordinator];
    if (!context) {
        NSLog(@"DEBUG: context error");
    }
    
    
    // TODO move in viewWillAppear ?
	TripManager *tripManager = [[TripManager alloc] initWithManagedObjectContext:context];
    NoteManager *noteManager = [[NoteManager alloc] initWithManagedObjectContext:context];
   
    int nav_controller=1;
    RecordTripViewController *recordVC;
    if(nav_controller==1)
    {
    UINavigationController* uinav=[[((UITabBarController *) self.window.rootViewController) viewControllers] objectAtIndex:0];
   recordVC=[uinav.viewControllers objectAtIndex:0];
    }
    else
    {
	//recordVC = [[((UITabBarController *) self.window.rootViewController) viewControllers] objectAtIndex:0];
    }
	[recordVC initTripManager:tripManager];
    [recordVC initNoteManager:noteManager];
    
	SavedTripsViewController *tripsVC	= [[((UITabBarController *) self.window.rootViewController) viewControllers] objectAtIndex:1];
	tripsVC.delegate					= recordVC;
	[tripsVC initTripManager:tripManager];
    
    
    SavedNotesViewController *notesVC = [[((UITabBarController *) self.window.rootViewController) viewControllers] objectAtIndex:2];
    [notesVC initNoteManager:noteManager];
    
	UINavigationController	*personalNav	= (UINavigationController*)[tabBarController.viewControllers
                                                                        objectAtIndex:3];
	PersonalInfoViewController *personalVC	= (PersonalInfoViewController *)[personalNav topViewController];
	personalVC.managedObjectContext			= context;}



- (void)initUniqueIDHash
{
    //if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        self.uniqueIDHash = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]; // save for later.
    //}
    
    //if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
    //     self.uniqueIDHash = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //    NSLog(@"iOS 7");
    //}
    
	NSLog(@"Hashed uniqueID: %@", uniqueIDHash);	
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 */
			NSLog(@"applicationWillTerminate: Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}

- (void)applicationDidEnterBackground:(UIApplication *) application
{
    CycleAtlantaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if(appDelegate.isRecording){
        NSLog(@"BACKGROUNDED and recording"); //set location service to startUpdatingLocation
        [appDelegate.locationManager startUpdatingLocation];
    } else {
        NSLog(@"BACKGROUNDED and sitting idle"); //set location service to startMonitoringSignificantLocationChanges
        [appDelegate.locationManager stopUpdatingLocation];
        //[appDelegate.locationManager startMonitoringSignificantLocationChanges];
    }
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"magnetometerIsOn"])
    {
        NSLog(@"BACKGROUNDED and keep watching magnetic field");
        [appDelegate.locationManager  startUpdatingHeading];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *) application
{
    //always turnon location updating when active.
    CycleAtlantaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.locationManager startUpdatingLocation];
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext: (NSPersistentStoreCoordinator *) coordinator {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    //NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CycleAtlanta" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 If it does exist, it tests for and then migrates the store as needed.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    NSError * error;
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    NSURL *storeURL;// = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CycleTracks.sqlite"]];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:
         [[NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CycleTracks.sqlite"]] path]] &&
        [fileManager fileExistsAtPath:
         [[NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CycleAtlanta.sqlite"]] path]])
    {
        //both existprevious migration failed, start over.
        if(![fileManager removeItemAtPath:[[NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CycleAtlanta.sqlite"]] path]
                                    error:&error])
        {
            NSLog(@"Remove file error %@", error );
        }
        storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CycleTracks.sqlite"]];
    }
    else if ([fileManager fileExistsAtPath:
                [[NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CycleTracks.sqlite"]] path]])
    {
        //old version store exists, need to migrate
        storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CycleTracks.sqlite"]];
    }
    else
    {
        //use current name.
        storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CycleAtlanta.sqlite"]];
    }
    
    // migrate the store if needed, returns the migrated storeURL
    storeURL = [self migratePersistentStore: storeURL];
    
    // create the coordinator
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
		//not the most sophisticated error handling
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}

- (NSURL *) migratePersistentStore: (NSURL *) sourceURL {
    BOOL result;
    NSError *error = nil;
    
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:sourceURL
                                                                                            error:&error];
    if(!sourceMetadata )//assume first run, so break w/o migrating anything.
        return sourceURL;
    
    NSURL *destinationURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CycleAtlanta.sqlite"]];
	NSManagedObjectModel *destinationModel = [self managedObjectModel];
        
    //do the migration. assuming one step here from previous to current model.
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil
                                                                    forStoreMetadata:sourceMetadata];
    
    NSMigrationManager *migrationManager =  [[NSMigrationManager alloc]
                                                     initWithSourceModel:sourceModel
                                                        destinationModel:destinationModel];
    
    
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                            forSourceModel:sourceModel
                                                          destinationModel:destinationModel];
    
    if (mappingModel == nil) {
        NSLog(@"DEBUG no mapping model, no need to migrate.");        
        return destinationURL; 
    }
    
    NSLog(@"DEBUG: start migration");
    //request migration task continue if the app is backgrounded.
    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
        // no-op. interrupted migration will simply start over next time.
    }];
    [self performSelectorOnMainThread:@selector(setUpgradeMessage) withObject:nil waitUntilDone:NO];

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [migrationManager addObserver:self.storeLoadingView forKeyPath:@"migrationProgress" options:0 context:NULL];
    
    result = [migrationManager migrateStoreFromURL:sourceURL
                                               type:NSSQLiteStoreType
                                            options:nil
                                   withMappingModel:mappingModel
                                   toDestinationURL:destinationURL
                                    destinationType:NSSQLiteStoreType
                                 destinationOptions:nil
                                              error:&error];
    
    NSLog(@"DEBUG: finish migration");
    if (taskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:taskId];
    }
    [migrationManager removeObserver:self.storeLoadingView forKeyPath:@"migrationProgress" ];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if(result)
    {
        //only remove the previous store if the migration succeeded.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager removeItemAtPath:[[NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CycleTracks.sqlite"]] path]
                                    error:&error])
        {
            NSLog(@"Remove file error %@", error );
        }
    }
    else
    {
        destinationURL = nil;
    }
        
    
    return destinationURL;
    
}

- (void)setUpgradeMessage{
        [self.storeLoadingView setVisible:TRUE messageString:kInitMessage ];
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *) applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    self.isRecording = nil;
    
    
    
}


@end

