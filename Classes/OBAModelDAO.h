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


#import "OBARegionV2.h"
#import "OBAModelPersistenceLayer.h"

NS_ASSUME_NONNULL_BEGIN

@class OBAModelDAOUserPreferencesImpl;

@interface OBAModelDAO : NSObject
@property(nonatomic,strong) CLLocation *mostRecentLocation;
@property(nonatomic,strong,nullable) OBARegionV2 *region;
@property(nonatomic,strong,nullable) NSArray *allRegions;
@property(weak, nonatomic,readonly) NSArray * mostRecentCustomApiUrls;
@property(nonatomic,assign) BOOL hideFutureLocationWarnings;

- (instancetype)initWithModelPersistenceLayer:(id<OBAModelPersistenceLayer>)persistenceLayer;

- (BOOL) readSetRegionAutomatically;
- (void) writeSetRegionAutomatically:(BOOL)setRegionAutomatically;

- (NSString*) readCustomApiUrl;
- (void) writeCustomApiUrl:(NSString*)customApiUrl;

- (void) addCustomApiUrl:(NSString*)customApiUrl;

- (NSString*)normalizedAPIServerURL;
@end

NS_ASSUME_NONNULL_END