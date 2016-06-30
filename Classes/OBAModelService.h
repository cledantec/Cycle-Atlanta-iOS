#import "OBAModelDAO.h"
#import "OBAModelFactory.h"
#import "OBAJsonDataSource.h"
#import "OBALocationManager.h"

#import "OBAReferencesV2.h"
#import <PromiseKit/PromiseKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OBAModelServiceRequest <NSObject>
- (void)cancel;
@end

/**
 * This protocol mimics the functionality of UIApplication.  It is placed here to get around Extension only API limitation.
 */
@protocol OBABackgroundTaskExecutor <NSObject>
- (UIBackgroundTaskIdentifier) beginBackgroundTaskWithExpirationHandler:(void(^)(void))handler;
- (UIBackgroundTaskIdentifier) endBackgroundTask:(UIBackgroundTaskIdentifier) task;
@end

@interface OBAModelService : NSObject
@property (nonatomic, strong) OBAReferencesV2 *references;
@property (nonatomic, strong) OBAModelDAO *modelDao;
@property (nonatomic, strong) OBAModelFactory *modelFactory;
@property (nonatomic, strong) OBAJsonDataSource *obaJsonDataSource;
@property (nonatomic, strong) OBAJsonDataSource *obaRegionJsonDataSource;
@property (nonatomic, strong) OBAJsonDataSource *googleMapsJsonDataSource;
@property (nonatomic, strong) OBAJsonDataSource *googlePlacesJsonDataSource;
@property (nonatomic, strong) OBALocationManager *locationManager;

/**
 * Registers a background executor to be used by all services.  This method should not be used by extensions.
 */
+(void) addBackgroundExecutor:(NSObject<OBABackgroundTaskExecutor>*) executor;


/**
 *  Makes an asynchronous request to fetch all available OBA regions, including experimental and inactive
 *
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestRegions:(OBADataSourceCompletion)completion;


@end

NS_ASSUME_NONNULL_END