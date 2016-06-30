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

#import "OBAModelFactory.h"
#import "OBALogger.h"

#import "OBAReferencesV2.h"
#import "OBAAgencyV2.h"

#import "OBAJsonDigester.h"
#import "OBASetCoordinatePropertyJsonDigesterRule.h"
#import "OBASetLocationPropertyJsonDigesterRule.h"
#import "OBASetDatePropertyJsonDigesterRule.h"

#import "OBARegionV2.h"
#import "OBARegionBoundsV2.h"

static NSString * const kReferences = @"references";

@interface OBAModelFactory (Private)

- (NSDictionary*) getDigesterParameters;

@end


@interface OBAJsonDigester (CustomDigesterRules)

- (void) addReferencesRulesWithPrefix:(NSString*)prefix;

- (void) addAgencyV2RulesWithPrefix:(NSString*)prefix;
- (void) addRouteV2RulesWithPrefix:(NSString*)prefix;
- (void) addStopV2RulesWithPrefix:(NSString*)prefix;
- (void) addTripV2RulesWithPrefix:(NSString*)prefix;
- (void) addSituationV2RulesWithPrefix:(NSString*)prefix;
- (void) addTripDetailsV2RulesWithPrefix:(NSString*)prefix;

- (void) addAgencyWithCoverageV2RulesWithPrefix:(NSString*)prefix;

- (void) addArrivalAndDepartureV2RulesWithPrefix:(NSString*)prefix;
- (void) addTripStatusV2RulesWithPrefix:(NSString*)prefix;
- (void) addFrequencyV2RulesWithPrefix:(NSString*)prefix;

- (void) addVehicleStatusV2RulesWithPrefix:(NSString*)prefix;

- (void) addAgencyToReferences:(id<OBAJsonDigesterContext>)context name:(NSString*)name value:(id)value;
- (void) addRouteToReferences:(id<OBAJsonDigesterContext>)context name:(NSString*)name value:(id)value;
- (void) addStopToReferences:(id<OBAJsonDigesterContext>)context name:(NSString*)name value:(id)value;
- (void) addTripToReferences:(id<OBAJsonDigesterContext>)context name:(NSString*)name value:(id)value;
- (void) addSituationToReferences:(id<OBAJsonDigesterContext>)context name:(NSString*)name value:(id)value;

- (void) setReferencesForContext:(id<OBAJsonDigesterContext>)context name:(NSString*)name value:(id)value;

- (void) addSetCoordinatePropertyRule:(NSString*)propertyName withPrefix:(NSString*)prefix method:(OBASetCoordinatePropertyMethod)method;
- (void) addSetLocationPropertyRule:(NSString*)propertyName withPrefix:(NSString*)prefix;
- (void) addSetDatePropertyRule:(NSString*)propertyName withPrefix:(NSString*)prefix;

- (void) addRegionV2RulesWithPrefix:(NSString*)prefix;
- (void) addRegionBoundsV2RulesWithPrefix:(NSString*)prefix;
@end


@implementation OBAModelFactory

- (id) initWithReferences:(OBAReferencesV2*)references {
    
    self = [super init];
    
    if( self ) {
        _references = references;
        _entityIdMappings = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (OBAListWithRangeAndReferencesV2*) getAgenciesWithCoverageV2FromJson:(id)jsonDictionary error:(NSError**)error {
    
    OBAListWithRangeAndReferencesV2 * list = [[OBAListWithRangeAndReferencesV2 alloc] initWithReferences:_references];
    
    OBAJsonDigester * digester = [[OBAJsonDigester alloc] init];
    [digester addReferencesRulesWithPrefix:@"/references"];
    [digester addAgencyWithCoverageV2RulesWithPrefix:@"/list/[]"];
    [digester addSetNext:@selector(addValue:) forPrefix:@"/list/[]"];
    
    [digester parse:jsonDictionary withRoot:list parameters:[self getDigesterParameters] error:error];
    
    return list;
}

- (OBAListWithRangeAndReferencesV2*) getRegionsV2FromJson:(id)jsonDictionary error:(NSError**)error {
    OBAListWithRangeAndReferencesV2 * list = [[OBAListWithRangeAndReferencesV2 alloc] initWithReferences:_references];
    
    jsonDictionary = jsonDictionary ?: [self.class staticRegionsJSON];
    
    OBAJsonDigester * digester = [[OBAJsonDigester alloc] init];
    [digester addRegionV2RulesWithPrefix:@"/list/[]"];
    [digester addSetNext:@selector(addValue:) forPrefix:@"/list/[]"];
    [digester parse:jsonDictionary withRoot:list parameters:[self getDigesterParameters] error:error];
    
    return list;
}

+ (id)staticRegionsJSON {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"regions-v3" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (NSString*) getShapeV2FromJSON:(NSDictionary*)json error:(NSError*)error {
    NSDictionary * entry = json[@"entry"];
    return entry[@"points"];
}

@end

@implementation OBAModelFactory (Private)

- (NSDictionary*) getDigesterParameters {
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[kReferences] = _references;
    return params;
}

@end


@implementation OBAJsonDigester (CustomDigesterRules)

- (void) addReferencesRulesWithPrefix:(NSString*)prefix {
    
    NSString * agencyPrefix = [self extendPrefix:prefix withValue:@"agencies/[]"];
    [self addAgencyV2RulesWithPrefix:agencyPrefix];
    
    NSString * routePrefix = [self extendPrefix:prefix withValue:@"routes/[]"];
    [self addRouteV2RulesWithPrefix:routePrefix];
    
    NSString * stopPrefix = [self extendPrefix:prefix withValue:@"stops/[]"];
    [self addStopV2RulesWithPrefix:stopPrefix];
    
    NSString * tripPrefix = [self extendPrefix:prefix withValue:@"trips/[]"];
    [self addTripV2RulesWithPrefix:tripPrefix];
    
    NSString * situationPrefix = [self extendPrefix:prefix withValue:@"situations/[]"];
    [self addSituationV2RulesWithPrefix:situationPrefix];
    
}

- (void) addAgencyV2RulesWithPrefix:(NSString*)prefix {
    [self addObjectCreateRule:[OBAAgencyV2 class] forPrefix:prefix];
    [self addSetPropertyRule:@"agencyId" forPrefix:[self extendPrefix:prefix withValue:@"id"]];
    [self addSetPropertyRule:@"name" forPrefix:[self extendPrefix:prefix withValue:@"name"]];
    [self addSetPropertyRule:@"url" forPrefix:[self extendPrefix:prefix withValue:@"url"]];
    [self addTarget:self selector:@selector(addAgencyToReferences:name:value:) forRuleTarget:OBAJsonDigesterRuleTargetEnd prefix:prefix];
}

- (void) addRegionV2RulesWithPrefix:(NSString*)prefix {
    [self addObjectCreateRule:[OBARegionV2 class] forPrefix:prefix];
    [self addSetPropertyRule:@"siriBaseUrl" forPrefix:[self extendPrefix:prefix withValue:@"siriBaseUrl"]];
    [self addSetPropertyRule:@"obaVersionInfo" forPrefix:[self extendPrefix:prefix withValue:@"obaVersionInfo"]];
    [self addSetPropertyRule:@"supportsSiriRealtimeApis" forPrefix:[self extendPrefix:prefix withValue:@"supportsSiriRealtimeApis"]];
    [self addSetPropertyRule:@"language" forPrefix:[self extendPrefix:prefix withValue:@"language"]];
    [self addSetPropertyRule:@"supportsObaRealtimeApis" forPrefix:[self extendPrefix:prefix withValue:@"supportsObaRealtimeApis"]];
    
    NSString * regionBoundsPrefix = [self extendPrefix:prefix withValue:@"bounds/[]"];
    [self addRegionBoundsV2RulesWithPrefix:regionBoundsPrefix];
    [self addSetNext:@selector(addBound:) forPrefix:regionBoundsPrefix];
    
    [self addSetPropertyRule:@"supportsObaDiscoveryApis" forPrefix:[self extendPrefix:prefix withValue:@"supportsObaDiscoveryApis"]];
    [self addSetPropertyRule:@"contactEmail" forPrefix:[self extendPrefix:prefix withValue:@"contactEmail"]];
    [self addSetPropertyRule:@"twitterUrl" forPrefix:[self extendPrefix:prefix withValue:@"twitterUrl"]];
    [self addSetPropertyRule:@"facebookUrl" forPrefix:[self extendPrefix:prefix withValue:@"facebookUrl"]];
    [self addSetPropertyRule:@"active" forPrefix:[self extendPrefix:prefix withValue:@"active"]];
    [self addSetPropertyRule:@"experimental" forPrefix:[self extendPrefix:prefix withValue:@"experimental"]];
    [self addSetPropertyRule:@"baseUrl" forPrefix:[self extendPrefix:prefix withValue:@"baseUrl"]];
    [self addSetPropertyRule:@"identifier" forPrefix:[self extendPrefix:prefix withValue:@"id"]];
    [self addSetPropertyRule:@"regionName" forPrefix:[self extendPrefix:prefix withValue:@"regionName"]];
    [self addSetPropertyRule:@"tutorialUrl" forPrefix:[self extendPrefix:prefix withValue:@"tutorialUrl"]];
}

- (void) addRegionBoundsV2RulesWithPrefix:(NSString*)prefix {
    [self addObjectCreateRule:[OBARegionBoundsV2 class] forPrefix:prefix];
    [self addSetPropertyRule:@"lowerLeftLatitude" forPrefix:[self extendPrefix:prefix withValue:@"lowerLeftLatitude"]];
    [self addSetPropertyRule:@"upperRightLatitude" forPrefix:[self extendPrefix:prefix withValue:@"upperRightLatitude"]];
    [self addSetPropertyRule:@"lowerLeftLongitude" forPrefix:[self extendPrefix:prefix withValue:@"lowerLeftLongitude"]];
    [self addSetPropertyRule:@"upperRightLongitude" forPrefix:[self extendPrefix:prefix withValue:@"upperRightLongitude"]];
}

- (void) setReferencesForContext:(id<OBAJsonDigesterContext>)context name:(NSString*)name value:(id)value {
    OBAHasReferencesV2 * top = [context peek:0];
    OBAReferencesV2 * refs = [context getParameterForKey:kReferences];
    top.references = refs;
}

- (void) addSetCoordinatePropertyRule:(NSString*)propertyName withPrefix:(NSString*)prefix method:(OBASetCoordinatePropertyMethod)method {
    OBASetCoordinatePropertyJsonDigesterRule * rule = [[OBASetCoordinatePropertyJsonDigesterRule alloc] initWithPropertyName:propertyName method:method];
    [self addRule:rule forPrefix:prefix];
}

- (void) addSetLocationPropertyRule:(NSString*)propertyName withPrefix:(NSString*)prefix {
    OBASetLocationPropertyJsonDigesterRule * rule = [[OBASetLocationPropertyJsonDigesterRule alloc] initWithPropertyName:propertyName];
    [self addRule:rule forPrefix:prefix];
}

- (void) addSetDatePropertyRule:(NSString*)propertyName withPrefix:(NSString*)prefix {
    OBASetDatePropertyJsonDigesterRule * rule = [[OBASetDatePropertyJsonDigesterRule alloc] initWithPropertyName:propertyName];
    [self addRule:rule forPrefix:prefix];
}

@end

