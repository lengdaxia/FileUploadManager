//
//  TaskInfo.h
//  FileManager
//
//  Created by Marlon on 16/4/1.
//  Copyright © 2016年 superman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskInfo : NSObject

@property (nonatomic, assign) int taskNo; //对应线程编号
@property (nonatomic, assign) long len;     //文件切块长度
@property (nonatomic, assign) long startPos; //文件切块开始位置
@property (nonatomic, assign) long endPos; //文件切块结束位置
@property (nonatomic, strong) NSString *uploadTime; //上传时间
@property (nonatomic, assign) long wasteTime; //上传耗时
@property (nonatomic, assign) int  status; //线程状态 0:running 1 hold 2:error
@property (nonatomic, strong) NSString *resultErrMsg; //服务器写文件的错误信息.默认null

@property (nonatomic, strong) NSString *ip;         //dns返回的上传文件服务器ip
@property (nonatomic, assign) int port;             //dns返回的上传文件服务器端口号
@property (nonatomic, strong) NSString *fileName; //文件信息
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) long fileLength;
@property (nonatomic, strong) NSString *sourceId;  //dns返回的文件id
@property (nonatomic, assign) int totolNum;  //总任务个数
@property (nonatomic, assign) long skipSize;
@property (nonatomic, assign) NSInteger uploadUserId; //上传者ID

@property (nonatomic, assign) BOOL isFinished; //是否上传成功




@end
