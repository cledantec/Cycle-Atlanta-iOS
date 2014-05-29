//
//  Trip.h
//  Cycle Atlanta
//
//  Created by Guo Anhong on 13-2-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Coord, User;

@interface Trip : NSManagedObject

@property (nonatomic, strong) NSNumber * distance;
@property (nonatomic, strong) NSDate * start;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSDate * uploaded;
@property (nonatomic, strong) NSString * purpose;
@property (nonatomic, strong) NSNumber * duration;
@property (nonatomic, strong) NSDate * saved;
@property (nonatomic, strong) NSSet *coords;
@property (nonatomic, strong) NSData * thumbnail;
@property (nonatomic, strong) User *user;
@end

@interface Trip (CoreDataGeneratedAccessors)

- (void)addCoordsObject:(Coord *)value;
- (void)removeCoordsObject:(Coord *)value;
- (void)addCoords:(NSSet *)values;
- (void)removeCoords:(NSSet *)values;

@end
