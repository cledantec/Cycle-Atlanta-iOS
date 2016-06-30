//
//  RegionManager.m
//  Cycle Atlanta
//
//  Created by Cagri Cetin on 7/8/16.
//
//

#import "RegionManager.h"

@implementation RegionManager

@synthesize allRegions;
@synthesize region;

+ (instancetype)sharedInstance
{
    static RegionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RegionManager alloc] init];
    });
    return sharedInstance;
}

- (void) saveSetRegionAuto:(BOOL)isAuto {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setBool:isAuto forKey:@"setRegionAuto"];
    [preferences synchronize];
}

- (BOOL) isSetRegionAuto {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *currentLevelKey = @"setRegionAuto";
    if ([preferences objectForKey:currentLevelKey] == nil) {
        return YES;
    }
    else {
        return [preferences boolForKey:currentLevelKey];
    }
}

- (void) saveRegionName:(NSString *)regionName {
    [[NSUserDefaults standardUserDefaults] setObject:regionName forKey:@"regionName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) getRegionName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"regionName"];
}

@end
