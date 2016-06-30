//
//  OBARegionHelper.m
//  org.onebusaway.iphone
//
//  Created by Sebastian Kießling on 11.08.13.
//  Copyright (c) 2013 OneBusAway. All rights reserved.
//

#import "OBARegionHelper.h"
#import "CycleAtlantaAppDelegate.h"
#import "OBAApplication.h"
#import "OBAMacros.h"
#import "RegionManager.h"

@interface OBARegionHelper ()
@property (nonatomic) NSMutableArray *regions;
@property (nonatomic) CLLocation *location;
@end

@implementation OBARegionHelper

- (void)updateNearestRegion {
    [self updateRegion];
    OBALocationManager *lm = [OBAApplication sharedApplication].locationManager;
    [lm addDelegate:self];
    [lm startUpdatingLocation];
}

- (void)updateRegion {
    [[OBAApplication sharedApplication].modelService requestRegions:^(id responseData, NSUInteger responseCode, NSError *error) {
        if (error && !responseData) {
            responseData = [self loadDefaultRegions];
        }
        [self processRegionData:responseData];
     }];
}

- (OBAListWithRangeAndReferencesV2*)loadDefaultRegions {

    NSLog(@"Unable to retrieve regions file. Loading default regions from the app bundle.");

    OBAModelFactory *factory = [OBAApplication sharedApplication].modelService.modelFactory;
    NSError *error = nil;

    NSData *data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"regions-v3" ofType:@"json"]];

    if (!data) {
        NSLog(@"Unable to load regions from app bundle.");
        return nil;
    }

    id defaultJSONData = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&error];

    if (!defaultJSONData) {
        NSLog(@"Unable to convert bundled regions into an object. %@", error);
        return nil;
    }

    OBAListWithRangeAndReferencesV2 *references = [factory getRegionsV2FromJson:defaultJSONData error:&error];

    if (error) {
        NSLog(@"Issue parsing bundled JSON data: %@", error);
    }

    return references;
}

- (void)processRegionData:(id)regionData {
    OBAListWithRangeAndReferencesV2 *list = regionData;

    self.regions = [[NSMutableArray alloc] initWithArray:list.values];
    
    [RegionManager sharedInstance].allRegions = [NSArray arrayWithArray:self.regions];

    if ([[RegionManager sharedInstance] isSetRegionAuto] && [OBAApplication sharedApplication].locationManager.locationServicesEnabled) {
        [self setNearestRegion];
    }
    else {
        [self setRegion];
    }
}

- (void)setNearestRegion {
    if (self.regions && self.location) {

        OBALocationManager *lm = [OBAApplication sharedApplication].locationManager;
        CLLocation *newLocation = lm.currentLocation;

        NSMutableArray *regionsToRemove = [NSMutableArray array];

        for (OBARegionV2 *region in self.regions) {
            CLLocationDistance distance = [region distanceFromLocation:newLocation];

            if (distance > 160934) { // 100 miles
                [regionsToRemove addObject:region];
            }
        }

        [self.regions removeObjectsInArray:regionsToRemove];

        if (self.regions.count == 0) {
            [[RegionManager sharedInstance] saveSetRegionAuto:NO];
            [[OBAApplication sharedApplication].locationManager removeDelegate:self];
            [self showRegionSelectMessage];
            return;
        }

        NSString *oldRegion = @"null";

        if ([OBAApplication sharedApplication].modelDao.region != nil) {
            oldRegion = [OBAApplication sharedApplication].modelDao.region.regionName;
        }

        [OBAApplication sharedApplication].modelDao.region = self.regions[0];
        [[OBAApplication sharedApplication] refreshSettings];
        [[OBAApplication sharedApplication].locationManager removeDelegate:self];
        [[RegionManager sharedInstance] saveSetRegionAuto:YES];
    } else if (self.location == nil && self.regions != nil){
        [self showRegionSelectMessage];
    }
}

- (void)setRegion {
    NSString *regionName = [[RegionManager sharedInstance] getRegionName];

    if (regionName) {
        for (OBARegionV2 *region in self.regions) {
            if ([region.regionName isEqualToString:regionName]) {
                [OBAApplication sharedApplication].modelDao.region = region;
                break;
            }
        }
    }
    else {
//        [APP_DELEGATE showRegionListViewController];
        [self showRegionSelectMessage];
    }
}

#pragma mark OBALocationManagerDelegate Methods


- (void)locationManager:(OBALocationManager *)manager didUpdateLocation:(CLLocation *)location {
    self.location = [OBAApplication sharedApplication].locationManager.currentLocation;
    if ([[RegionManager sharedInstance] isSetRegionAuto]) {
        [self setNearestRegion];
    }
    
}

- (void)locationManager:(OBALocationManager *)manager didFailWithError:(NSError *)error {
    if (![OBAApplication sharedApplication].modelDao.region) {
        [self showRegionSelectMessage];
    }

    [[OBAApplication sharedApplication].locationManager removeDelegate:self];
}

- (void) showRegionSelectMessage {
    CycleAtlantaAppDelegate *appDelegate = (CycleAtlantaAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showRegionSelectMessage];
}

@end
