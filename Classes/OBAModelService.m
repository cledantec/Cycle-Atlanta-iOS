#import "OBAModelService.h"
#import "OBAModelServiceRequest.h"
#import "OBASphericalGeometryLibrary.h"
#import "OBAURLHelpers.h"
#import "OBAMacros.h"

static const CLLocationAccuracy kSearchRadius = 400;
static const CLLocationAccuracy kBigSearchRadius = 15000;

@implementation OBAModelService

- (id<OBAModelServiceRequest>)requestRegions:(OBADataSourceCompletion)completion {
    return [self request:self.obaRegionJsonDataSource
                     url:@""
                    args:nil
                selector:@selector(getRegionsV2FromJson:error:)
         completionBlock:completion
           progressBlock:nil];
}

- (id<OBAModelServiceRequest>)requestAgenciesWithCoverage:(OBADataSourceCompletion)completion {
    return [self request:self.obaJsonDataSource
                     url:@"/api/where/agencies-with-coverage.json"
                    args:nil
                selector:@selector(getAgenciesWithCoverageV2FromJson:error:)
         completionBlock:completion
           progressBlock:nil];
}


- (OBAModelServiceRequest *)request:(OBAJsonDataSource *)source url:(NSString *)url args:(NSDictionary *)args selector:(SEL)selector completionBlock:(OBADataSourceCompletion)completion progressBlock:(OBADataSourceProgress)progress {
    OBAModelServiceRequest *request = [self request:source selector:selector];

    request.connection = [source requestWithPath:url withArgs:args completionBlock:^(id jsonData, NSUInteger responseCode, NSError *error) {
        [request processData:jsonData withError:error responseCode:responseCode completionBlock:completion];
    } progressBlock:progress];
    return request;
}

- (OBAModelServiceRequest *)request:(OBAJsonDataSource *)source selector:(SEL)selector {
    OBAModelServiceRequest *request = [[OBAModelServiceRequest alloc] init];

    request.modelFactory = _modelFactory;
    request.modelFactorySelector = selector;

    if (source != _obaJsonDataSource) {
        request.checkCode = NO;
    }

    NSObject<OBABackgroundTaskExecutor> *executor = [[self class] sharedBackgroundExecutor];
    
    if (executor) {
        request.bgTask = [executor beginBackgroundTaskWithExpirationHandler:^{
            if(request.cleanupBlock) {
                request.cleanupBlock(request.bgTask);
            }
        }];
        
        [request setCleanupBlock:^(UIBackgroundTaskIdentifier identifier) {
            return [executor endBackgroundTask:identifier];
        }];
    }
    
    return request;
}

- (CLLocation *)currentOrDefaultLocationToSearch {
    CLLocation *location = _locationManager.currentLocation;

    if (!location) {
        location = _modelDao.mostRecentLocation ?: [[CLLocation alloc] initWithLatitude:47.61229680032385 longitude:-122.3386001586914];
    }

    return location;
}

#pragma mark - OBABackgroundTaskExecutor

static NSObject<OBABackgroundTaskExecutor>* executor;

+ (NSObject<OBABackgroundTaskExecutor>*)sharedBackgroundExecutor {
    return executor;
}

+ (void)addBackgroundExecutor:(NSObject<OBABackgroundTaskExecutor>*)exc {
    executor = exc;
}

@end