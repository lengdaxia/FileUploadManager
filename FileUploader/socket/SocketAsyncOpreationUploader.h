//
//  SocketAsyncOpreationUploader.h
//  FileManager
//
//  Created by Marlon on 16/4/11.
//  Copyright © 2016年 superman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskInfo.h"

typedef void (^completionBlock)();

@interface SocketAsyncOpreationUploader : NSOperation

@property(atomic, assign) BOOL taskFinished;
@property(atomic, assign) BOOL taskExecuting;

+(id)uploadFileWith:(TaskInfo *)task Success:(void (^)(id responseData))success
            failure:(void (^)(NSError *error))failure;

//- (void)setCompletionBlockWithSuccess:(void (^)(id responseData))success
//                              failure:(void (^)(NSError *error))failure;

+(id)finalRequestToGetReturnURLWithInfoDIc:(NSDictionary *)dic Success:(void (^)(id responseData))success
                                   failure:(void (^)(NSError *error))failure;


@end
