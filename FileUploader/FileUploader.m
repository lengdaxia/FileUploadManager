//
//  FileUploader.m
//  FileManager
//
//  Created by Marlon on 16/3/29.
//  Copyright © 2016年 superman. All rights reserved.

#import "FileUploader.h"
#import "FileInfo.h"
#import "TaskInfo.h"
#import "HttpAsyncUploader.h"
#import "SocketAsyncOpreationUploader.h"
#import "FileSqlManager.h"

@interface FileUploader()

@property (nonatomic, strong) FileInfo *file;

@property (nonatomic, strong) NSFileManager *fileManager; //文件管理类

@property (nonatomic, strong) NSOperationQueue *taskQueue; //任务队列
@property (nonatomic, strong) NSMutableArray * successTaskArr;
@property (nonatomic, assign) BOOL isPaused;


@end

@implementation FileUploader

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //初始化的时候从数据库中读取未上传完的file
        self.fileManager = [NSFileManager defaultManager];
      
        self.file = [[FileInfo alloc]init];
        
    }
    return self;
}
/*======================公共API=======================*/
//进行公共上传
- (void)uploadFileWithFilePath:(NSString *)filePath andUserId:(NSInteger)userId progress:(ProgressBlock)progress{

    self.file.fileAccessRight = @"0";
    [self connectWithDNSServersWithFilePath:filePath andUserId:userId fileUploadType:@"0" downAppId:nil andDownToken:nil progress:progress];
}

//指定应用下载的上传
- (void)uploadFileWithFilePath:(NSString *)filePath andUserId:(NSInteger)userId andDownAppId:(NSString *)appId progress:(ProgressBlock)progress{
    
    self.file.fileAccessRight = @"1";
    self.file.downAppId = appId;
    [self connectWithDNSServersWithFilePath:filePath andUserId:userId fileUploadType:@"1" downAppId:appId andDownToken:nil progress:progress];
}

//设置密匙下载的上传
- (void)uploadFileWithFilePath:(NSString *)filePath andUserId:(NSInteger)userId andSecretKey:(NSString *)downKey progress:(ProgressBlock)progress{
    
    self.file.fileAccessRight = @"2";
    self.file.downKey = downKey;
    [self connectWithDNSServersWithFilePath:filePath andUserId:userId fileUploadType:@"3" downAppId:nil andDownToken:downKey progress:progress];
    
}
//暂停上传
- (void)pause{
    
    [self.taskQueue cancelAllOperations];
    self.isPaused = YES;
}

//继续上传
- (void)resume{
    
    /**
     *  继续上传只能在暂停之后调用
     */
    
    if (self.isPaused) {
        
        self.isPaused = NO;
        
        NSMutableArray *resumeArr = [self.file.taskInfoArr mutableCopy];
        
        if (resumeArr.count > 0) {
            
            for (TaskInfo *task in self.successTaskArr ) {
                [resumeArr removeObject:task];
            }
            [self asyncSocketBeginUploadWith:resumeArr andProgress:self.fileProgress];
        }
    }    
}

//断点续传
- (void)reloadWith:(NSString *)sourceId progress:(ProgressBlock)progress{
    
    /**
     *  通过sourceId查出相应的fileInfo 和taskinfo ，将已完成的task添加到self.successArr中
     */
    
    self.file = [[FileSqlManager getFileInfoWith:sourceId] firstObject];
    //包含已经完成和没有完成的task （status＝2成功其他失败）
    NSMutableArray *reloadTaskArr = [FileSqlManager queryOneUnfinishedFileWith:sourceId];
    
    [self.file.taskInfoArr removeAllObjects];
    [self.successTaskArr removeAllObjects];
    self.file.taskInfoArr = reloadTaskArr;
    
    NSMutableArray *reloadArr = [NSMutableArray array];
    
    for (TaskInfo *task in reloadTaskArr) {
        
        if (task.status == 1) {
            [self.successTaskArr addObject:task]; //添加到成功的数组
        }else{
        
            [reloadArr addObject:task]; //添加到待上传的数组
        }
    }
    
    //开始上传
    [self asyncSocketBeginUploadWith:reloadArr andProgress:progress];

}


/**
 *  请求DNS服务器,获取上传文件接口以及服务器ip和端口
 */

- (void)connectWithDNSServersWithFilePath:(NSString *)filePath andUserId:(NSInteger)userId fileUploadType:(NSString *)type downAppId:(NSString *)downAppId andDownToken:(NSString *)downKey progress:(ProgressBlock) progress{
    
    if (![self.fileManager fileExistsAtPath:filePath]) {
        return ;  //如果指定路径文件不存在,直接返回
    }
    
    //根据filepath获取文件名,文件大小
    NSString *fileName = [filePath lastPathComponent]; //文件名(注意-含中文的必须转成utf-8格式)
    fileName = [fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    long fileLenth = [self fileSizeAtPath:filePath];  //文件长度
    
    self.file.uploadUserId = userId;
    self.file.fileName = fileName;
    self.file.fileLength = fileLenth;
    self.file.filePath = filePath;
    
//    /Users/heyu/Library/Developer/CoreSimulator/Devices/45877CAB-33B0-45CE-921D-D3E6B8393E1B/data/Containers/Bundle/Application/45A8045C-29C6-414A-8F9F-9500ED0F167A/CJMobile.app/大文件.pdf
    NSURL *requestURL = [self getUrlWithFileName:fileName andFileLeneh:fileLenth andUserId:userId andFileType:type downAppId:downAppId andDownToken:downKey];
    
    //拼接url,使用http进行post请求
    [HttpAsyncUploader DNSHttpRequestWith:requestURL timeInterval:5 success:^(id responseData) {
        
        NSData *data = (NSData *)responseData;
        NSString *receiveInfo = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *arr = [NSArray arrayWithArray:[receiveInfo componentsSeparatedByString:@"&"]] ;
        NSRange range = NSMakeRange(0, 3);
        NSMutableString *URLStr;
        
        for (int i = 1; i < arr.count - 1; i ++) {
            
            if (i == 1) {
                range.length = 3;
            }
            URLStr = [NSMutableString stringWithString:arr[i]];
            
            switch (i) {
                case 1:
                    [URLStr deleteCharactersInRange:range];
                    self.file.serversID = URLStr;
                    
                    break;
                case 2:
                    [URLStr deleteCharactersInRange:range];
                    self.file.ip = URLStr;
                    
                    break;
                case 3:
                    range.length = 5;
                    [URLStr deleteCharactersInRange:range];
                    self.file.port = [URLStr intValue];
                    
                    break;
                case 4:
                    range.length = 9;
                    [URLStr deleteCharactersInRange:range];
                    self.file.sourceId = URLStr;
                    
                    break;
                case 5:
                    range.length = 14;
                    [URLStr deleteCharactersInRange:range];
                    self.file.uploadFileType = URLStr;
                    
                    break;
                default:
                    break;
            }
        }

        if ([self.file.uploadFileType isEqualToString:@"1"]) { //上传大文件
            
            [self uploadBigFile:progress];
            
        }else{ //上传小文件
            [self uploadSmallFile:progress];
        }

    } failure:^(NSError *error) {
        
        NSLog(@"%@",error);
    }];
}

//开始小文件上传流程
- (void)uploadSmallFile:(ProgressBlock)progress{
    
    NSString  *ip    = self.file.ip;
    int       port   = self.file.port + 10;
    NSString  *srcId = self.file.sourceId;
    double    lenth  = self.file.fileLength;
    NSInteger userId = self.file.uploadUserId;
    NSString  *type  = self.file.uploadFileType;
    NSData    *data  = [NSData dataWithContentsOfFile:self.file.filePath]; //二进制小文件
    
    //开始上传
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%d/up.jsp?id=%@&no=1&len=%.f&userId=%ld&appId=%@&tocken=%@&downAppId=&downTocken=&fileAccessRight=%@&blockFlag=false",ip,port,srcId,lenth,(long)userId,FILE_UPLOAD_APPID,FILE_UPLOAD_TOKEN,type];
    
    [HttpAsyncUploader uploadWithURL:[NSURL URLWithString:urlStr] file:self.file timeInterval:20 success:^(id responseData) {
        
        NSData *reciveData = (NSData *)responseData;
        
        //NSUTF8StringEncoding解码
        NSString *receiveInfo = [[NSString alloc]initWithData:reciveData encoding:NSUTF8StringEncoding];
        NSArray *receiveArr = [receiveInfo componentsSeparatedByString:@";"];

        NSString *subString = [receiveArr[1] substringFromIndex:10];
        //base64解密－－－－将string转成nsdata
        NSData *nsdataFromBase64String = [[NSData alloc]
                                          initWithBase64EncodedString:subString options:0];
        //utf8解码成url
        NSString *base64DecodedURL = [[NSString alloc]
                                   initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
        //分割url，解析返回信息
        NSString *success = [receiveArr[0]  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *errorNo = [success substringFromIndex:8];
        
        if ([errorNo isEqualToString:@"0"]) {
            
            //上传成功
            NSLog(@"小文件上传成功 returnURL = %@",base64DecodedURL);
        }else{
            //上传失败
            NSLog(@"小文件上传失败");
        }
        
    } failure:^(NSError *error) {
        
        NSLog(@"%@",error);
        
    } progress:^(float percent) {
        //回到主线程
        dispatch_sync(dispatch_get_main_queue(), ^{
           
            progress(percent);
        });
    }];
}
//开始大文件上传流程
- (void)uploadBigFile:(ProgressBlock)progress {
    
    //切割文件,分配切片信息
    [self dissectionFileWithFile];
    
    [self asyncSocketBeginUploadWith:self.file.taskInfoArr andProgress:progress];
    
}

- (void)asyncSocketBeginUploadWith:(NSMutableArray *)arr andProgress:(ProgressBlock)progress{

    NSUInteger count = arr.count;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 4;
    
    self.taskQueue = queue;
    
    for (int i = 0; i < count; i ++) {
        
            TaskInfo *task = arr[i];
            SocketAsyncOpreationUploader *uploader = [SocketAsyncOpreationUploader uploadFileWith:task Success:^(id responseData) {
                NSData * data = (NSData *)responseData;
                NSString *resStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                //成功的任务列表
            
                [self uploadSuccessProcessWith:task receiveStr:resStr andProgress:progress];
                
            } failure:^(NSError *error) {
                
                task.status = 2;
                
                //更新信息
                [FileSqlManager updateATaskInfoDataWithTask:task];
                
                NSLog(@"%@",error);
            }];
            
            [self.taskQueue addOperation:uploader];
    }
}

- (void)uploadSuccessProcessWith:(TaskInfo *)task receiveStr:(NSString *)resStr andProgress:(ProgressBlock)progress{

    if ([resStr containsString:@"切片成功"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.successTaskArr addObject:task];
            float percent = (float)self.successTaskArr.count / (float)self.file.taskInfoArr.count;
            progress(percent); //上传的进度条
            self.fileProgress = progress; //保存进度条信息
            task.status = 1; //表示上传成功
            
            //数据库更新信息
            [FileSqlManager updateATaskInfoDataWithTask:task];
            
            //如果全部传输成功，再次请求获取URL
            if (self.successTaskArr.count == self.file.taskInfoArr.count) {
                //清空数组
                [self.successTaskArr removeAllObjects];
                
                NSString *len = [NSString stringWithFormat:@"%ld",self.file.fileLength];
                NSString *skipSize = [NSString stringWithFormat:@"%ld",self.file.skipSize];
                NSString *actualSize = [NSString stringWithFormat:@"%d",self.file.uploadThreadNum];
                NSString *userId = [NSString stringWithFormat:@"%ld",self.file.uploadUserId];
                NSString *port = [NSString stringWithFormat:@"%d",self.file.port];
                NSString *fileAccessRight,*downAppId,*downkey;
                
                fileAccessRight = self.file.fileAccessRight;
                downAppId = self.file.downAppId;
                downkey = self.file.downKey;
                
                NSMutableDictionary *myDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.file.sourceId,@"id",self.file.fileName,@"name",len,@"len",skipSize,@"skipSize",actualSize,@"actualSize",skipSize,@"byteSize",userId,@"userId",FILE_UPLOAD_APPID,@"appId",downAppId,@"downAppId",fileAccessRight,@"fileAccessRight",FILE_UPLOAD_TOKEN,@"tocken",downkey,@"downTocken",@"3",@"type",self.file.ip,@"ip",port,@"port", nil];
                
                SocketAsyncOpreationUploader *finalOpreation = [SocketAsyncOpreationUploader finalRequestToGetReturnURLWithInfoDIc:myDic Success:^(id responseData) {
                    
                    NSData *reciveData = (NSData *)responseData;
                    
                    //NSUTF8StringEncoding解码
                    NSString *receiveInfo = [[NSString alloc]initWithData:reciveData encoding:NSUTF8StringEncoding];
                    NSArray *receiveArr = [receiveInfo componentsSeparatedByString:@";"];
                    
                    NSString *subString = [receiveArr[1] substringFromIndex:10];
                    //base64解密－－－－将string转成nsdata
                    NSData *nsdataFromBase64String = [[NSData alloc]
                                                      initWithBase64EncodedString:subString options:0];
                    //utf8解码成url
                    NSString *base64DecodedURL = [[NSString alloc]
                                                  initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
                    //分割url，解析返回信息
                    NSString *success = [receiveArr[0]  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSString *errorNo = [success substringFromIndex:8];
                    
                    if ([errorNo isEqualToString:@"0"]) {
                        //上传成功
                        NSLog(@"大文件上传成功 returnURL = %@",base64DecodedURL);
                        
                        [FileSqlManager deleteFileInfoDataWithTask:task]; //删除所有task信息
                        [FileSqlManager deleteFileInfoWith:self.file]; //删除fileinfo或者更新file的status
                        
                    }else{
                        //上传失败
                        NSLog(@"大文件上传失败");
                    }
                    
                } failure:^(NSError *error) {
                    NSLog(@"error == %@",error);
                }];
                
                [finalOpreation start];
            }
        });
    }
}

#pragma mark - helper method
-(NSMutableArray *)successTaskArr{

    if (!_successTaskArr) {
        _successTaskArr = [NSMutableArray array];
    }
    return _successTaskArr;
}

//拼接DNS服务器url
- (NSURL *)getUrlWithFileName:(NSString *)name andFileLeneh:(long)lenth andUserId:(NSInteger)userId andFileType:(NSString *)type downAppId:(NSString *)downAppId andDownToken:(NSString *)downKey{
    
    NSString *ip    = UPLOAD_SERVERS_IP;
    NSString *port  = UPLOAD_SERVERS_PORT;
    NSString *appId = FILE_UPLOAD_APPID;
    NSString *token = FILE_UPLOAD_TOKEN;
    NSString *clientIp = @"";
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/dns.jsp?userId=%ld&ip=%@&appId=%@&tocken=%@&len=%ld&name=%@&fileAccessRight=%@&downAppId=&downTocken=&os=ios",ip,port,userId,clientIp,appId,token,lenth,name,type];
    return [NSURL URLWithString:urlStr];
    
}



//根据文件路径获取文件大小
-(long) fileSizeAtPath:(NSString*)filePath{
    if ([self.fileManager fileExistsAtPath:filePath]){
        return [[self.fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//文件切割
-(void)dissectionFileWithFile{
    
    if ([self.fileManager fileExistsAtPath:self.file.filePath]) {
        
        long a = self.file.fileLength / self.file.skipSize; //分片个数
        
        for (int i = 0; i < a ; i ++) {
            
            TaskInfo *task = [[TaskInfo alloc]init];
            task.taskNo = i + 1;
            task.len = self.file.skipSize;
            task.startPos = i * self.file.skipSize;
            task.endPos = (i + 1) * self.file.skipSize;
            task.fileName = self.file.fileName;
            task.filePath = self.file.filePath;
            task.fileLength = self.file.fileLength;
            task.ip = self.file.ip;
            task.port = self.file.port;
            task.sourceId = self.file.sourceId;
            task.uploadUserId = self.file.uploadUserId;
            if (self.file.fileLength % self.file.skipSize != 0) {
                task.totolNum = a + 1;
            }else{
                task.totolNum = a;
            }
            
            [self.file.taskInfoArr addObject:task];
            [FileSqlManager insertATaskInfoDataWithTask:task];
        }
        
        if (self.file.fileLength % self.file.skipSize != 0) { //最后一片不是正好skipSize大小
            
            TaskInfo *oddTask = [[TaskInfo alloc]init];
            oddTask.taskNo = a + 1;
            oddTask.len = self.file.fileLength - a * self.file.skipSize;
            oddTask.startPos = a * self.file.skipSize;
            oddTask.endPos = self.file.fileLength;
            
            oddTask.fileName = self.file.fileName;
            oddTask.filePath = self.file.filePath;
            oddTask.fileLength = self.file.fileLength;
            oddTask.ip = self.file.ip;
            oddTask.port = self.file.port;
            oddTask.sourceId = self.file.sourceId;
            oddTask.totolNum = a + 1;
            oddTask.uploadUserId = self.file.uploadUserId;
            
            [self.file.taskInfoArr addObject:oddTask];
            [FileSqlManager insertATaskInfoDataWithTask:oddTask];

        }
     
        self.file.uploadThreadNum = self.file.taskInfoArr.count;
        
        //保存fileInfo到本地
        BOOL ret = [FileSqlManager insertAfileInfoWithInfo:self.file];
        
       NSMutableArray *fileArr =[NSMutableArray arrayWithArray:[FileSqlManager getAllFiles]];
        
        [FileSqlManager getFileInfoWith:@"136467"];
    }
    
 
}

@end
