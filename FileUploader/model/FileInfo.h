//
//  FileInfo.h
//  FileManager
//
//  Created by Marlon on 16/3/31.
//  Copyright © 2016年 superman. All rights reserved.
//

//private String fileName;// 文件名称
//private String sourceId;// 上传唯一性的文件id
//private File file;// 需要上传文件的路径
//private int byteSize;// 字节数 1024
//private int actualMaxTaskSize;// 上传文件需要的最大线程数
//private int maxTaskSize;// 客服端可配置的的最大线程个数
//private long skipSize = 0;// 本次分块上传的大小(分块文件长度)，传输率
//private long fileLength;// 文件总长度
//private boolean isHolded = false;// 主进程是否暂停
//private String filePath;// 文件路径
//private String user;// 上传人
//private String ip;// 上传IP地址
//private int port;// port端口
//private String date;
////	private String fileAccessRight; //下载文件类型
//private String isMergeFile; //合并文件代码控制
////	private String tocken;
////	private String downAppId;
////	private String downTocken;

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
@property (nonatomic, strong) NSString *status;     //主进程是否暂停

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


