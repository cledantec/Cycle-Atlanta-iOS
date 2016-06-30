//
//  OBARegionBoundsV2.m
//  org.onebusaway.iphone
//
//  Created by chaya3 on 5/22/13.
//
//

#import "OBARegionBoundsV2.h"

@implementation OBARegionBoundsV2

static NSString * kLowerLeftLatitude = @"lowerLeftLatitude";
static NSString * kUpperRightLatitude = @"upperRightLatitude";
static NSString * kLowerLeftLongitude = @"lowerLeftLongitude";
static NSString * kUpperRightLongitude = @"upperRightLongitude";

#pragma mark - NSCoder

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];

    if (self) {
        self.lowerLeftLatitude = [decoder decodeDoubleForKey:kLowerLeftLatitude];
        self.upperRightLatitude = [decoder decodeDoubleForKey:kUpperRightLatitude];
        self.lowerLeftLongitude = [decoder decodeDoubleForKey:kLowerLeftLongitude];
        self.upperRightLongitude = [decoder decodeDoubleForKey:kUpperRightLongitude];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeDouble:self.lowerLeftLatitude forKey:kLowerLeftLatitude];
    [encoder encodeDouble:self.upperRightLatitude forKey:kUpperRightLatitude];
    [encoder encodeDouble:self.lowerLeftLongitude forKey:kLowerLeftLongitude];
    [encoder encodeDouble:self.upperRightLongitude forKey:kUpperRightLongitude];
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:self.class]) {
        return NO;
    }

    return self.lowerLeftLatitude == [object lowerLeftLatitude] &&
           self.upperRightLatitude == [object upperRightLatitude] &&
           self.lowerLeftLongitude == [object lowerLeftLongitude] &&
           self.upperRightLongitude == [object upperRightLongitude];
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%f_%f_%f_%f", self.lowerLeftLatitude, self.upperRightLatitude, self.lowerLeftLongitude, self.upperRightLongitude] hash];
}

#pragma mark - NSObject

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p> :: {lat: %@ +/- %@ :: lon: %@ +/- %@}", self.class, self, @(self.upperRightLatitude), @(self.lowerLeftLongitude), @(self.upperRightLongitude), @(self.upperRightLongitude)];
}

@end
