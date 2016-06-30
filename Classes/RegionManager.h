//
//  RegionManager.h
//  Cycle Atlanta
//
//  Created by Cagri Cetin on 7/8/16.
//
//

#import <Foundation/Foundation.h>
#import "OBARegionV2.h"

@interface RegionManager : NSObject

@property (nonatomic, retain) NSArray *allRegions;
@property(nonatomic, retain) OBARegionV2 *region;

+ (instancetype)sharedInstance;
- (void) saveSetRegionAuto: (BOOL) isAuto;
- (BOOL) isSetRegionAuto;

- (void) saveRegionName: (NSString*) regionName;
- (NSString*) getRegionName;

@end
