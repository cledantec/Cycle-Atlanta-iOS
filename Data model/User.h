//
//  User.h
//  Cycle Atlanta
//
//  Created by Guo Anhong on 13-2-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note, Trip;

@interface User : NSManagedObject

@property (nonatomic, strong) NSNumber * age;
@property (nonatomic, strong) NSNumber * cyclingFreq;
@property (nonatomic, strong) NSNumber * rider_history;
@property (nonatomic, strong) NSNumber * rider_type;
@property (nonatomic, strong) NSNumber * income;
@property (nonatomic, strong) NSNumber * ethnicity;
@property (nonatomic, strong) NSString * homeZIP;
@property (nonatomic, strong) NSString * schoolZIP;
@property (nonatomic, strong) NSString * workZIP;
@property (nonatomic, strong) NSNumber * gender;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSSet *notes;
@property (nonatomic, strong) NSSet *trips;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

- (void)addTripsObject:(Trip *)value;
- (void)removeTripsObject:(Trip *)value;
- (void)addTrips:(NSSet *)values;
- (void)removeTrips:(NSSet *)values;

@end
