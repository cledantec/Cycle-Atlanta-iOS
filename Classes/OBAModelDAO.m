/**
 * Copyright (C) 2009 bdferris <bdferris@onebusaway.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "OBAModelDAO.h"
#import "OBACommon.h"
#import "OBACommonV1.h"
#import "OBAMacros.h"
#import "OBAModelDAOUserPreferencesImpl.h"

const NSInteger kMaxEntriesInMostRecentList = 10;

@interface OBAModelDAO ()
@property(nonatomic,strong) id<OBAModelPersistenceLayer> preferencesDao;
@end

@implementation OBAModelDAO {
    CLLocation * _mostRecentLocation;
    NSMutableSet * _visitedSituationIds;
    NSMutableArray * _mostRecentCustomApiUrls;
}
@dynamic hideFutureLocationWarnings;

- (instancetype)initWithModelPersistenceLayer:(id<OBAModelPersistenceLayer>)persistenceLayer {
    self = [super init];

    if (self) {
        _preferencesDao = persistenceLayer;
        _mostRecentLocation = [_preferencesDao readMostRecentLocation];
        _visitedSituationIds = [[NSMutableSet alloc] initWithSet:[_preferencesDao readVisistedSituationIds]];
        _region = [_preferencesDao readOBARegion];
        _mostRecentCustomApiUrls = [[NSMutableArray alloc] initWithArray:[_preferencesDao readMostRecentCustomApiUrls]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewedArrivalsAndDeparturesForStop:) name:OBAViewedArrivalsAndDeparturesForStopNotification object:nil];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OBAViewedArrivalsAndDeparturesForStopNotification object:nil];
}

#pragma mark - Recent

- (NSArray*) mostRecentCustomApiUrls {
    return _mostRecentCustomApiUrls;
}

- (CLLocation*) mostRecentLocation {
    return _mostRecentLocation;
}

- (void) setMostRecentLocation:(CLLocation*)location {
    _mostRecentLocation = location;
    [_preferencesDao writeMostRecentLocation:location];
}

#pragma mark - Regions

- (void)setRegion:(OBARegionV2 *)region {
    if (_region == region) {
        return;
    }

    _region = region;
    [_preferencesDao writeOBARegion:region];
}

- (BOOL) readSetRegionAutomatically {
    return [_preferencesDao readSetRegionAutomatically];
}

- (void) writeSetRegionAutomatically:(BOOL)setRegionAutomatically {
    [_preferencesDao writeSetRegionAutomatically:setRegionAutomatically];
}


#pragma mark - Custom API Server

- (void)addCustomApiUrl:(NSString *)customApiUrl {

    if (!customApiUrl) {
        return;
    }

    NSString *existingCustomApiUrl = nil;

    for (NSString *recentCustomApiUrl in _mostRecentCustomApiUrls) {
        if ([recentCustomApiUrl isEqualToString:customApiUrl]) {
            existingCustomApiUrl = customApiUrl;
            break;
        }
    }

    if (existingCustomApiUrl) {
        [_mostRecentCustomApiUrls removeObject:existingCustomApiUrl];
        [_mostRecentCustomApiUrls insertObject:existingCustomApiUrl atIndex:0];
    }
    else {
        [_mostRecentCustomApiUrls insertObject:customApiUrl atIndex:0];
    }

    NSInteger over = [_mostRecentCustomApiUrls count] - kMaxEntriesInMostRecentList;
    for (NSInteger i=0; i<over; i++) {
        [_mostRecentCustomApiUrls removeObjectAtIndex:_mostRecentCustomApiUrls.count - 1];
    }

    [_preferencesDao writeMostRecentCustomApiUrls:_mostRecentCustomApiUrls];
}

- (NSString*)normalizedAPIServerURL {
    NSString *apiServerName = nil;

    if (self.readCustomApiUrl.length > 0) {
        if ([self.readCustomApiUrl hasPrefix:@"http://"] || [self.readCustomApiUrl hasPrefix:@"https://"]) {
            apiServerName = self.readCustomApiUrl;
        }
        else {
            apiServerName = [NSString stringWithFormat:@"http://%@", self.readCustomApiUrl];
        }
    }
    else if (self.region) {
        apiServerName = self.region.baseUrl;
    }

    if ([apiServerName hasSuffix:@"/"]) {
        apiServerName = [apiServerName substringToIndex:apiServerName.length - 1];
    }

    return apiServerName;
}

- (NSString*)readCustomApiUrl {
    return [_preferencesDao readCustomApiUrl];
}

- (void)writeCustomApiUrl:(NSString*)customApiUrl {
    [_preferencesDao writeCustomApiUrl:customApiUrl];
}

@end

