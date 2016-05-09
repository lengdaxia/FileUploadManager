//
//  FileSqlManager.h
//  CJMobile
//
//  Created by Marlon on 16/4/14.
//  Copyright © 2016年 长江证券. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "TaskInfo.h"
#import "FileInfo.h"

@interface FileSqlManager : NSObject

//创建本地数据表
/**
 *
 这个类使用了fmdb和MJExtension两个第三方库，
 1 fmdb进行本地存储，使用该文件上传组件包的开发者可以根据自己工程的存储方案对这个类的实现进行相关改造，（如：存储路径）
 2 MJExtension字典转模型的第三方库，开发者可以保留也根据使用项目中相同功能的库替换掉
 *
 */

//***********************fileInfo***************************** //
//查询file列表，所有的file封装成fielinfo
+(NSMutableArray *) getAllFiles;

//根据sourceId获取fileInfo
+(NSMutableArray *) getFileInfoWith:(NSString *)sourceId;

//添加fileinfo条目
+ (BOOL)insertAfileInfoWithInfo:(FileInfo *)file;

//删除fileinfo条目
+(BOOL) deleteFileInfoWith:(NSString *)sourceId;

//更改file状态
+ (BOOL)updateFileStatusWith:(NSString *)sourceId;




//***********************taskInfo***************************** //

//批量file查询
+ (NSMutableArray *) queryAllUnfinishedUploadFiles;

//单条file查询
+ (NSMutableArray *) queryOneUnfinishedFileWith:(NSString *)sourceId;

//插入数据
+ (BOOL) insertATaskInfoDataWithTask:(TaskInfo *)task;

//更新数据
+ (BOOL) updateATaskInfoDataWithTask:(TaskInfo *)task;

//删除数据
+ (BOOL) deleteFileInfoDataWithTask:(TaskInfo *)task;


@end
