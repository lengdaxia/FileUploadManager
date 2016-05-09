//
//  FileUploader.h
//  FileManager
//
//  Created by Marlon on 16/3/29.
//  Copyright © 2016年 superman. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UPLOAD_SERVERS_IP   @"202.103.39.205"  // @"172.16.126.199"//上传dns服务器ip地址
#define UPLOAD_SERVERS_PORT @"7001"           //上传服务器端口号
#define FILE_UPLOAD_APPID   @"11"              //上传文件的应用id (长江e家指定 11)
#define FILE_UPLOAD_TOKEN   @"111111"         //上传文件令牌

typedef void(^ProgressBlock)(float percent);

@interface FileUploader : NSObject<NSURLConnectionDelegate>

@property(nonatomic ,copy) ProgressBlock fileProgress; //进度条

//进行公共上传
- (void)uploadFileWithFilePath:(NSString *)filePath andUserId:(NSInteger )userId progress:(ProgressBlock)progress;

//指定应用下载的上传
- (void)uploadFileWithFilePath:(NSString *)filePath andUserId:(NSInteger)userId andDownAppId:(NSString *)appId progress:(ProgressBlock)progress;

//设置文件密匙下载的上传
- (void)uploadFileWithFilePath:(NSString *)filePath andUserId:(NSInteger)userId andSecretKey:(NSString *)downKey progress:(ProgressBlock)progress;

//大文件上传暂停
- (void)pause;

//继续上传
- (void)resume;

//断点续传（从本地数据库拿到文件信息）
- (void)reloadWith:(NSString *)sourceId progress:(ProgressBlock)progress;

@end
