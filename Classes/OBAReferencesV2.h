@import Foundation;
@class OBAAgencyV2;

NS_ASSUME_NONNULL_BEGIN

@interface OBAReferencesV2 : NSObject {
    NSMutableDictionary * _agencies;
}

- (void) addAgency:(OBAAgencyV2*)agency;
- (OBAAgencyV2*) getAgencyForId:(NSString*)agencyId;
- (NSDictionary*) getAllAgencies;


- (void) clear;
                             
@end

NS_ASSUME_NONNULL_END