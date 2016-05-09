//
//  HttpAsyncUploader.h
//  FileManager
//
//  Created by Marlon on 16/4/11.
//  Copyright © 2016年 superman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileInfo.h"

typedef void (^completionBlock)();
typedef void (^progressBlock)();

@interface HttpAsyncUploader : NSObject

+ (id)uploadWithURL:(NSURL *)URL file:(FileInfo*)file timeInterval:(NSTimeInterval)timeoutInterval success:(void (^)(id responseData))success failure:(void(^)(NSError *error))failure progress:(void(^)(float percent))progress;


+ (id)DNSHttpRequestWith:(NSURL *)URL timeInterval:(NSTimeInterval)timeoutInterval success:(void (^)(id responseData))success failure:(void(^)(NSError *error))failure;

- (void)start;

- (void)cancel;
- (void)setCompletionBlockWithSuccess:(void (^)(id responseData))success
                              failure:(void (^)(NSError *error))failure;

@end
