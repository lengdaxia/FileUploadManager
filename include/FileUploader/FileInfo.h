//
//  FileInfo.h
//  FileManager
//
//  Created by Marlon on 16/3/31.
//  Copyright © 2016年 superman. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface FileInfo : NSObject

@property (nonatomic, assign) NSInteger uploadUserId; //上传者ID
@property (nonatomic, strong) NSString *date;         //上传日期
@property (nonatomic, strong) NSString *clientIp;     //上传客户端ip

@property (nonatomic, strong) NSString *fileName; //文件信息
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) long fileLength;

@property (nonatomic, assign) long skipSize;      //切片大小byte
@property (nonatomic, assign) int uploadThreadNum;  //实际上传线程数量
@property (nonatomic, assign) int threadLimitNum; //可开启的最大线程数量
@property (nonatomic, strong) NSString *status;     //file状态（0；未开始 1 正在上传 2 已结束）
@property (nonatomic, assign) float percent;        //完成任务的百分比

@property (nonatomic, strong) NSString *sourceId;  //dns返回的文件id
@property (nonatomic, strong) NSString *ip;         //dns返回的上传文件服务器ip
@property (nonatomic, assign) int port;             //dns返回的上传文件服务器端口号
@property (nonatomic, strong) NSString *serversID;  //上传文件服务器编号

@property (nonatomic, strong) NSString *uploadFileType; //上传文件类型(1:大文件 2:小文件)
@property (nonatomic, strong) NSMutableArray *taskInfoArr; //存放大文件每个section的分块信息

@property (nonatomic, assign) int byteSize;         //暂不清楚
@property (nonatomic, strong) NSString *isMergeFile; //是否合并文件(暂时不用)

@property (nonatomic, strong) NSString *downAppId;
@property (nonatomic, strong) NSString *downKey;
@property (nonatomic, strong) NSString *fileAccessRight;

@end


