//
//  OBARegionV2.m
//  org.onebusaway.iphone
//
//  Created by chaya3 on 5/22/13.
//
//

#import "OBARegionV2.h"
#import "OBARegionBoundsV2.h"
#import "NSArray+OBAAdditions.h"

static NSString * kSiriBaseUrl = @"siriBaseUrl";
static NSString * kObaVersionInfo = @"obaVersionInfo";
static NSString * kSupportsSiriRealtimeApis = @"supportsSiriRealtimeApis";
static NSString * kLanguage = @"language";
static NSString * kSupportsObaRealtimeApis = @"supportsObaRealtimeApis";
static NSString * kBounds = @"bounds";
static NSString * kSupportsObaDiscoveryApis = @"supportsObaDiscoveryApis";
static NSString * kContactEmail = @"contactEmail";
static NSString * kTwitterUrl = @"twitterUrl";
static NSString * kFacebookUrl = @"facebookUrl";
static NSString * kActive = @"active";
static NSString * kExperimental = @"experimental";
static NSString * kBaseUrl = @"baseUrl";
static NSString * kIdentifier = @"id_number";
static NSString * kRegionName = @"regionName";
static NSString * kTutorialUrl = @"tutorialUrl";

@implementation OBARegionV2

- (id)init {
    self = [super init];
    if (self) {
        _bounds = @[];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.siriBaseUrl forKey:kSiriBaseUrl];
    [encoder encodeObject:self.obaVersionInfo forKey:kObaVersionInfo];
    [encoder encodeBool:self.supportsSiriRealtimeApis forKey:kSupportsSiriRealtimeApis];
    [encoder encodeObject:self.language forKey:kLanguage];
    [encoder encodeBool:self.supportsObaRealtimeApis forKey:kSupportsObaRealtimeApis];
    [encoder encodeObject:self.bounds forKey:kBounds];
    [encoder encodeBool:self.supportsObaDiscoveryApis forKey:kSupportsObaDiscoveryApis];
    [encoder encodeObject:self.contactEmail forKey:kContactEmail];
    [encoder encodeObject:self.twitterUrl forKey:kTwitterUrl];
    [encoder encodeObject:self.facebookUrl forKey:kFacebookUrl];
    [encoder encodeBool:self.active forKey:kActive];
    [encoder encodeBool:self.experimental forKey:kExperimental];
    [encoder encodeObject:self.baseUrl forKey:kBaseUrl];
    [encoder encodeInteger:self.identifier forKey:kIdentifier];
    [encoder encodeObject:self.regionName forKey:kRegionName];
    [encoder encodeObject:self.tutorialUrl forKey:kTutorialUrl];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];

    if (self) {
        _siriBaseUrl = [decoder decodeObjectForKey:kSiriBaseUrl];
        _obaVersionInfo = [decoder decodeObjectForKey:kObaVersionInfo];
        _supportsSiriRealtimeApis = [decoder decodeBoolForKey:kSupportsSiriRealtimeApis];
        _language = [decoder decodeObjectForKey:kLanguage];
        _supportsObaRealtimeApis = [decoder decodeBoolForKey:kSupportsObaRealtimeApis];
        _bounds = [NSArray arrayWithArray:[decoder decodeObjectForKey:kBounds]];
        _supportsObaDiscoveryApis = [decoder decodeBoolForKey:kSupportsObaDiscoveryApis];
        _contactEmail = [decoder decodeObjectForKey:kContactEmail];
        _twitterUrl = [decoder decodeObjectForKey:kTwitterUrl];
        _facebookUrl = [decoder decodeObjectForKey:kFacebookUrl];
        _active = [decoder decodeBoolForKey:kActive];
        _experimental = [decoder decodeBoolForKey:kExperimental];
        _baseUrl = [decoder decodeObjectForKey:kBaseUrl];
        _identifier = [decoder decodeIntegerForKey:kIdentifier];
        _regionName = [decoder decodeObjectForKey:kRegionName];
        _tutorialUrl = [decoder decodeObjectForKey:kTutorialUrl];
    }

    return self;
}

#pragma mark - Public Methods

- (void)addBound:(OBARegionBoundsV2*)bound {
    self.bounds = [self.bounds arrayByAddingObject:bound];
}

- (CLLocationDistance)distanceFromLocation:(CLLocation*)location {
    double distance = DBL_MAX;
    double lat = location.coordinate.latitude;
    double lon = location.coordinate.longitude;
    
    for (OBARegionBoundsV2 * bound in _bounds) {
        
        double lon1 = bound.upperRightLongitude * M_PI / 180;
        double lon2 = bound.lowerLeftLongitude * M_PI / 180;
        
        double lat1 = bound.upperRightLatitude * M_PI / 180;
        double lat2 = bound.lowerLeftLatitude * M_PI / 180;
        
        double dLon = lon2 - lon1;
        
        double x = cos(lat2) * cos(dLon);
        double y = cos(lat2) * sin(dLon);
        
        double lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) );
        double lon3 = lon1 + atan2(y, cos(lat1) + x);
        
        CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:lat3 * 180 / M_PI longitude:lon3 * 180 / M_PI];
        CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        double thisDistance = [startLocation distanceFromLocation:endLocation];
        
        if (thisDistance < distance) {
            distance = thisDistance;
        }
    }
    
    return distance;
}

- (MKMapRect)serviceRect {
    double minX = DBL_MAX;
    double minY = DBL_MAX;
    double maxX = DBL_MIN;
    double maxY = DBL_MIN;
//    for (OBARegionBoundsV2 *bounds in self.bounds) {
//        MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(bounds.lat + bounds.latSpan / 2,
//                                                                          bounds.lon - bounds.lonSpan / 2));
//        MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(bounds.lat - bounds.latSpan / 2,
//                                                                          bounds.lon + bounds.lonSpan / 2));
//        minX = MIN(minX, MIN(a.x, b.x));
//        minY = MIN(minY, MIN(a.y, b.y));
//        maxX = MAX(maxX, MAX(a.x, b.x));
//        maxY = MAX(maxY, MAX(a.y, b.y));
//    }
    return MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
}

#pragma mark - NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"<%@: %p> :: {%@ - obaBaseUrl: %@, bounds: %@, experimental: %@}", self.class, self, self.regionName, self.baseUrl, self.bounds, self.experimental ? @"YES" : @"NO"];
}

@end
