//
//  OBARegionBoundsV2.h
//  org.onebusaway.iphone
//
//  Created by chaya3 on 5/22/13.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OBARegionBoundsV2 : NSObject<NSCoding>

@property(nonatomic,assign) double lowerLeftLatitude;
@property(nonatomic,assign) double upperRightLatitude;
@property(nonatomic,assign) double lowerLeftLongitude;
@property(nonatomic,assign) double upperRightLongitude;
@end

NS_ASSUME_NONNULL_END