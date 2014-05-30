//
//  Note.h
//  Cycle Atlanta
//
//  Created by Guo Anhong on 13-2-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Note : NSManagedObject

@property (nonatomic, strong) NSString * details;
@property (nonatomic, strong) NSNumber * speed;
@property (nonatomic, strong) NSNumber * vAccuracy;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSString * image_url;
@property (nonatomic, strong) NSNumber * note_type;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSNumber * hAccuracy;
@property (nonatomic, strong) NSDate * recorded;
@property (nonatomic, strong) NSNumber * altitude;
@property (nonatomic, strong) NSData * image_data;
@property (nonatomic, strong) NSData * thumbnail;
@property (nonatomic, strong) NSDate * uploaded;
@property (nonatomic, strong) User *user;

@end
