//
//  JsonUrlFetcherImpl.m
//  OneBusAwaySDK
//
//  Created by Aaron Brethorst on 12/16/15.
//  Copyright © 2015 One Bus Away. All rights reserved.
//

#import "JsonUrlFetcherImpl.h"

@interface JsonUrlFetcherImpl ()
@property(nonatomic,strong) NSURLSessionDataTask *task;
@end

@implementation JsonUrlFetcherImpl

- (instancetype)initWithCompletionBlock:(OBADataSourceCompletion)completion progressBlock:(OBADataSourceProgress)progress {
    self = [super init];

    if (self) {
        _completionBlock = completion;
        _progressBlock = progress;
    }

    return self;
}

- (void)loadRequest:(NSURLRequest *)request {

    self.task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        id responseObject = nil;
        
        NSURL *url = [NSURL URLWithString:@"https://script.google.com/macros/s/AKfycbxpN47XZQGAoh-N5wQtBETp51tznG3JnOrWsAVNy0xGJOkD8ibS/exec"];
        NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:url];
        NSURLResponse * response2;
        data = [NSURLConnection sendSynchronousRequest:request2 returningResponse:&response error:&error];

        if (data.length) {
            NSError *jsonError = nil;
            responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];

            if (!responseObject && jsonError) {
                error = jsonError;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(responseObject, ((NSHTTPURLResponse*)response).statusCode, error);
        });
    }];
    
    
    
    [self.task resume];
}

- (void)cancel {
    [self.task cancel];
}

@end
