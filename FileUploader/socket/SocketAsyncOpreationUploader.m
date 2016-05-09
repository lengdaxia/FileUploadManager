//
//  SocketAsyncOpreationUploader.m
//  FileManager
//
//  Created by Marlon on 16/4/11.
//  Copyright © 2016年 superman. All rights reserved.
//

#import "SocketAsyncOpreationUploader.h"
#import "AsyncSocket.h"

@interface SocketAsyncOpreationUploader()<AsyncSocketDelegate>

@property(nonatomic,strong) NSURL *URL;
@property(nonatomic,strong) NSMutableData *responseData;
@property(nonatomic,strong) NSError *error;
@property(nonatomic,assign) NSTimeInterval timeoutInterval;

@property(nonatomic, readwrite, copy) completionBlock completionBlock;

@property(nonatomic,strong) NSRecursiveLock *lock;

@property (nonatomic, strong) NSFileHandle  *fileHandler; //文件操作类
@property (nonatomic, strong) AsyncSocket *socket;
@property (nonatomic, strong) TaskInfo *task;
@property (nonatomic, strong) NSDictionary *infoDic;


@end

@implementation SocketAsyncOpreationUploader

-(instancetype)init{

    self = [super init];
    
    if (self) {
        
        self.lock = [[NSRecursiveLock alloc]init];
        self.lock.name = @"cjsc.ciej.lock";
        
        self.socket = [[AsyncSocket alloc]initWithDelegate:self];
        self.responseData = [NSMutableData data];
        self.fileHandler = [NSFileHandle fileHandleForReadingAtPath:
                            _task.filePath];
        
    }
    return self;
}
+ (void) __attribute__((noreturn)) networkEntry:(id)__unused object
{
    do {
        @autoreleasepool
        {
            [[NSRunLoop currentRunLoop] run];
            BOOL ret = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];

            NSLog(@"exit worker thread runloop");
        }
    } while (YES);
}

+ (NSThread *)networkThread
{
    static NSThread *_networkThread = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _networkThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkEntry:) object:nil];
        [_networkThread start];
    });
    
    return _networkThread;
}


- (void)setCompletionBlockWithSuccess:(void (^)(id responseData))success
                              failure:(void (^)(NSError *error))failure{

    [self.lock lock];
    __weak typeof(self) weakSelf = self;
    self.completionBlock = ^ {
        if (weakSelf.error) {
            if (failure) {
                failure(weakSelf.error);
            }
        } else {
            if (success) {
                success(weakSelf.responseData);
            }
        }
    };
    [self.lock unlock];
}

+(id)uploadFileWith:(TaskInfo *)task Success:(void (^)(id responseData))success
            failure:(void (^)(NSError *error))failure{
    
    
    SocketAsyncOpreationUploader *uploader = [[SocketAsyncOpreationUploader alloc]init];
    
    uploader.task = task;
    uploader.infoDic = nil;
    
    [uploader setCompletionBlockWithSuccess:success failure:failure];
    
    return uploader;
}

+(id)finalRequestToGetReturnURLWithInfoDIc:(NSDictionary *)dic Success:(void (^)(id responseData))success
                                   failure:(void (^)(NSError *error))failure{

    SocketAsyncOpreationUploader *uploader = [[SocketAsyncOpreationUploader alloc]init];

    uploader.infoDic = [NSDictionary dictionaryWithDictionary:dic];
    uploader.task = [[TaskInfo alloc]init];
    
    uploader.task.ip   = [dic objectForKey:@"ip"];
    uploader.task.port = [dic objectForKey:@"port"];
    
    [uploader setCompletionBlockWithSuccess:success failure:failure];
    
    return uploader;
}
-(void)start{

    [self.lock lock];
    
    if (self.isCancelled) {
        
        [self willChangeValueForKey:@"isFinished"];
        self.taskFinished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self performSelector:@selector(operationDidStart) onThread:[[self class] networkThread] withObject:nil waitUntilDone:NO];
    self.taskExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.lock unlock];
    
}

- (void)operationDidStart{
    [self.lock lock];
    
    NSError *error;
    BOOL ret = [self.socket connectToHost:_task.ip onPort:_task.port error:&error];
    
    [self.socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    if (ret) {
        NSString *requestStr;
        if (self.infoDic) {
            
            NSString *srcID           = [self.infoDic valueForKey:@"id"];
            NSString *name            = [self.infoDic valueForKey:@"name"];
            NSString * len            = [self.infoDic valueForKey:@"len"];
            NSString * skipSize       = [self.infoDic valueForKey:@"skipSize"];
            NSString * actualSize     = [self.infoDic valueForKey:@"actualSize"];
            NSString * byteSize       = [self.infoDic valueForKey:@"byteSize"];
            NSString * userId         = [self.infoDic valueForKey:@"userId"];
            NSString *appId           = [self.infoDic valueForKey:@"appId"];
            NSString *downAppId       = [self.infoDic valueForKey:@"downAppId"];
            NSString *fileAccessRight = [self.infoDic valueForKey:@"fileAccessRight"];
            NSString *tocken          = [self.infoDic valueForKey:@"tocken"];
            NSString *downTocken      = [self.infoDic valueForKey:@"downTocken"];
            NSString *type            = [self.infoDic valueForKey:@"type"];
            
            requestStr = [NSString stringWithFormat:@"id=%@;name=%@;len=%@;skipSize=%@;actualSize=%@;byteSize=%@;userId=%@;appId=%@;downAppId=%@;fileAccessRight=%@;tocken=%@;downTocken=%@;type=%@;\n",srcID,name,len,skipSize,actualSize,byteSize,userId,appId,downAppId,fileAccessRight,tocken,downTocken,type];
        }else{
            //开始请求切片信息            
            requestStr = [NSString stringWithFormat:@"no=%d;id=%@;startPos=%ld;len=%ld;skipSize=%ld;byteSize=%ld;name=%@;mergeFile=1;type=2;\n",_task.taskNo,_task.sourceId,_task.startPos,_task.fileLength,_task.len,_task.len,_task.fileName];
            
            
//            no=1;id=136496;startPos=0;len=4961242;skipSize=262144;byteSize=262144;name=%E5%A4%A7%E6%96%87%E4%BB%B6.pdf;mergeFile=1;type=2;
//            no=8;id=136494;startPos=1835008;len=4961242;skipSize=262144;byteSize=262144;name=大文件.pdf;mergeFile=1;type=2;

        }
        
        NSData *requestData =[requestStr dataUsingEncoding:NSUTF8StringEncoding];
        
        //切片信息请求
        [_socket writeData:requestData withTimeout:-1 tag:0];
    }
    [self.lock unlock];
    
}

- (void)operationDidFinish
{
    [self.lock lock];
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    self.taskExecuting = NO;
    self.taskFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    [self.lock unlock];
}

-(void)cancel{

    [self.lock lock];
    
    [super cancel];

    self.socket = nil;
    
    [self.lock unlock];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return self.taskExecuting;
}

- (BOOL)isFinished {
    return self.taskFinished;
}



#pragma mark - socket delegate

-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    
    [_socket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{

    self.error = err;
    self.responseData = nil;
    [self operationDidFinish];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    NSLog(@"==%s==%d==", __func__,__LINE__);

    //处理数据
    NSString *response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    if (self.infoDic) {
        
        [self.responseData appendData:data];
        self.error = nil;
        [self destroySocket];
        [self operationDidFinish];
        
    }else{
    
        if ([response containsString:@"文件切片请准备"]) {    //上传文件
            [self beginUploadFiledata];
            
        }else if([response containsString:@"切片成功"]){   // 改变状态
            _task.isFinished = YES;
            
            [self.responseData appendData: data];
            self.error = nil;
            [self destroySocket];
            [self operationDidFinish];
        }
    }
    
    //持续接受服务器返回的数据
    [_socket readDataWithTimeout:-1 tag:0];
}

-(void)beginUploadFiledata{
    
    [self.fileHandler seekToFileOffset:_task.startPos];
    //切片读取
    NSData *uplaodData = [self.fileHandler readDataOfLength:_task.len];
    
    [_socket writeData:uplaodData withTimeout:-1 tag: _task.taskNo];
}


- (NSFileHandle *)fileHandler{
    
    if (!_fileHandler) {
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
       BOOL ret = [manager fileExistsAtPath:_task.filePath];
        if (ret) {
            _fileHandler = [NSFileHandle fileHandleForReadingAtPath:self.task.filePath];

        }
    }
    return _fileHandler;
}

- (void)destroySocket{
    _socket.delegate = nil;
    [_socket disconnect];
    _socket = nil;
}

@end
