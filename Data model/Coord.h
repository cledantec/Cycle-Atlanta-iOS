//
//  Coord.h
//  Cycle Atlanta
//
//  Created by Guo Anhong on 13-2-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trip;

@interface Coord : NSManagedObject

@property (nonatomic, strong) NSNumber * hAccuracy;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSNumber * vAccuracy;
@property (nonatomic, strong) NSNumber * speed;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSDate * recorded;
@property (nonatomic, strong) NSNumber * altitude;
@property (nonatomic, strong) Trip *trip;

@end
