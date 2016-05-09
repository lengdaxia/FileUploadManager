//
//  HttpAsyncUploader.m
//  FileManager
//
//  Created by Marlon on 16/4/11.
//  Copyright © 2016年 superman. All rights reserved.
//

#import "HttpAsyncUploader.h"

@interface HttpAsyncUploader()<NSURLConnectionDelegate>

@property(nonatomic,strong) NSURL *URL;
@property(nonatomic,strong) NSMutableData *responseData;
@property(nonatomic,strong) NSURLConnection *connection;
@property(nonatomic,assign) NSTimeInterval timeoutInterval;
@property(nonatomic,strong) NSError *error;
@property(nonatomic,assign) float percent;

@property(nonatomic,copy) completionBlock completionBlock;
@property(nonatomic,copy) progressBlock progressBlock;

@property(nonatomic, assign) BOOL isDNS;
@property(nonatomic, strong) FileInfo * file;

@end

@implementation HttpAsyncUploader

+(void )__attribute__((noreturn)) networkEntry:(id)__unused object{

    do{
    
        @autoreleasepool{
            
            [[NSRunLoop currentRunLoop] run];
            
            BOOL ret = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            
        }
        
        
    }while(YES);
}


+ (NSThread *)networkThread{

    static NSThread *_networkThread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _networkThread = [[NSThread alloc]initWithTarget:self selector:@selector(networkEntry:) object:nil];
        [_networkThread start];
    });
    
    return _networkThread;
}

+ (id)uploadWithURL:(NSURL *)URL file:(FileInfo *)file timeInterval:(NSTimeInterval)timeoutInterval success:(void (^)(id responseData))success failure:(void(^)(NSError *error))failure progress:(void(^)(float  percent))progress{
    
    
    HttpAsyncUploader *uploader = [[HttpAsyncUploader alloc]init];
    uploader.URL = URL;
    uploader.timeoutInterval = timeoutInterval;
    [uploader setCompletionBlockWithSuccess:success failure:failure];
    [uploader setProgressBlockWithprogress:progress];
    uploader.file = file;
    
    [uploader performSelector:@selector(start) onThread:[[self class] networkThread] withObject:nil waitUntilDone:NO];
    
    return uploader;
}


+ (id)DNSHttpRequestWith:(NSURL *)URL timeInterval:(NSTimeInterval)timeoutInterval success:(void (^)(id responseData))success failure:(void(^)(NSError *error))failure{
    
    HttpAsyncUploader *uploader = [[HttpAsyncUploader alloc]init];
    uploader.URL = URL;
    uploader.timeoutInterval = timeoutInterval;
    [uploader setCompletionBlockWithSuccess:success failure:failure];
    uploader.file = nil;
    
    [uploader performSelector:@selector(start) onThread:[[self class] networkThread] withObject:nil waitUntilDone:NO];
    
    
    return uploader;
}

- (void)start{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:self.URL];
    [request setTimeoutInterval:self.timeoutInterval];
    [request setHTTPMethod:@"POST"];
    
    if (self.file) {
        
        [request addValue:self.file.fileName forHTTPHeaderField:@"Attach-Name"];
        NSString *lenthStr = [NSString stringWithFormat:@"%ld",self.file.fileLength];
        [request addValue:lenthStr forHTTPHeaderField:@"Content-Length"];
        
        NSData    *data  = [NSData dataWithContentsOfFile:self.file.filePath]; //二进制小文件
        [request setHTTPBody:data];
    }
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self.connection start];
}

- (void)cancel{
    
    if (self.connection) {
        [self.connection cancel];
        self.connection = nil;
    }

}

- (void)setProgressBlockWithprogress:(void(^)(float percent))progress{

    __weak typeof(self)weakSelf = self;
    self.progressBlock = ^ {
    
        if (weakSelf.percent >= 0) {
            
            progress(weakSelf.percent);
        }
    };
}

- (void)setCompletionBlockWithSuccess:(void (^)(id responseData))success
                              failure:(void (^)(NSError *error))failure{
    
    __weak typeof(self)weakSelf = self;
    
    self.completionBlock = ^{
        if (weakSelf.error) {
            if (failure) {
                failure(weakSelf.error);
            }
        }else{
        
            if (success) {
                success(weakSelf.responseData);
            }
        }
    };
}

#pragma mark - urlconnection delegate

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response{

    if (![response respondsToSelector:@selector(statusCode)] || [((NSHTTPURLResponse *)response) statusCode] < 400)
    {
        NSUInteger expectedSize = response.expectedContentLength > 0 ? (NSUInteger)response.expectedContentLength : 0;
        self.responseData = [[NSMutableData alloc] initWithCapacity:expectedSize];
    }
    else
    {
        [aConnection cancel];
        
        NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                    code:[((NSHTTPURLResponse *)response) statusCode]
                                                userInfo:nil];
        self.error = error;
        self.connection = nil;
        self.responseData = nil;
        self.completionBlock();
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    self.connection = nil;
    self.responseData = nil;
    self.error = error;
    self.completionBlock();
    
}
- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    
    self.percent = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    if (self.percent >= 0) {
        self.progressBlock();
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    self.connection = nil;
    self.completionBlock();
}

@end
