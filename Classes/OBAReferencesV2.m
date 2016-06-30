#import "OBAReferencesV2.h"
#import "OBAAgencyV2.h"

@implementation OBAReferencesV2

-(id) init {
    self = [super init];
    if( self ) {
        _agencies = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void) addAgency:(OBAAgencyV2*)agency {
    _agencies[agency.agencyId] = agency;
}

- (OBAAgencyV2*) getAgencyForId:(NSString*)agencyId {
    return _agencies[agencyId];
}

- (NSDictionary*) getAllAgencies {
    return [NSDictionary dictionaryWithDictionary:_agencies];;
}

- (void) clear {
    [_agencies removeAllObjects];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ agencies:%lu routes:%lu stops:%lu trips:%lu situations:%lu",
            [super description],
            (unsigned long)[_agencies count]];
}

@end
