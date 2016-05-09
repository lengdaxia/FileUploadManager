//
//  FileSqlManager.m

//
//  Created by Marlon on 16/4/14.
//  Copyright © 2016年 长江证券. All rights reserved.
//

#import "FileSqlManager.h"
#import "Database.h"
#import "FMDB.h"
#import "MJExtension.h"

//定义常用的字符串函数
#define ZYIsNullOrEmpty(str)            ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1)
#define ZYReplaceNULL2Empty(str)        ((nil == (str)) ? @"" : (str))
#define ZYReplaceEmpty2NULL(str)        ((nil == (str)) ? [NSNull null] : (str))
#define ZYReplaceNULL2HoriLine(str)     ((nil == (str)) ? @"--" : (str))

@implementation FileSqlManager
//创建本地数据表单
+ (BOOL)createFileAndTaskTables{

    
    NSString *fileTableSql = @"CREATE TABLE IF NOT EXISTS T_UPLOADFILETABLE(sourceId TEXT PRIMARY KEY NOT NULL, uploadUserId TEXT, date  TEXT, clientIp  TEXT,fileName TEXT,filePath TEXT, fileLength TEXT, skipSize TEXT,uploadThreadNum  TEXT, threadLimitNum TEXT, status TEXT,ip  TEXT,port TEXT,serversID TEXT,uploadFileType TEXT, byteSize TEXT, isMergeFile TEXT, downAppId TEXT,downKey TEXT, fileAccessRight TEXT)";
    NSString *taskTableSql = @"CREATE TABLE IF NOT EXISTS T_UPLOADTASKTABLE( TASK_ID  TEXT PRIMARY KEY NOT NULL,  taskNo TEXT, totolNum   TEXT, len  TEXT, startPos TEXT,endPos TEXT,uploadTime TEXT,wasteTime TEXT,status              TEXT, resultErrMsg  TEXT, sourceId TEXT, uploadUserId TEXT, clientIp TEXT, fileName TEXT, filePath TEXT, fileLength TEXT, skipSize TEXT, uploadThreadNum  TEXT,threadLimitNum TEXT,isHolded  TEXT, ip  TEXT,  port                TEXT, serversID TEXT,byteSize TEXT, isMergeFile TEXT)";
    return YES;
}

//查询file列表，所有的file封装成fielinfo

+(NSMutableArray *) getAllFiles{
    
    NSString *sql = @"select * from T_UPLOADFILETABLE";
    
    FileSqlManager *manager = [[FileSqlManager alloc]init];
  
    NSMutableArray *retArr =  [manager executeQuery:sql withArray:nil];
    
    NSMutableArray *fileInfoArr = [FileInfo mj_objectArrayWithKeyValuesArray:retArr];
    
    return fileInfoArr;
}

//根据sourceId获取fileInfo
+(NSMutableArray *) getFileInfoWith:(NSString *)sourceId{
    
    NSString *sql = @"select * from T_UPLOADFILETABLE WHERE sourceId = ?";
    
    NSArray *inputarray = [NSArray arrayWithObjects:sourceId, nil];
    
    FileSqlManager *manager = [[FileSqlManager alloc]init];
    
    NSMutableArray *retArr =  [manager executeQuery:sql withArray:inputarray];
    
    return [FileInfo mj_objectArrayWithKeyValuesArray:retArr];
}

//添加fileinfo条目
+ (BOOL)insertAfileInfoWithInfo:(FileInfo *)file{
    
    NSString * insertSql = @"replace into T_UPLOADFILETABLE (sourceId,uploadUserId,date,clientIp,fileName,filePath,fileLength,skipSize,uploadThreadNum,threadLimitNum,status,ip,port,serversID,uploadFileType,byteSize,isMergeFile,downAppId,downKey,fileAccessRight) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    
    NSArray *inputArray = [NSArray arrayWithObjects:file.sourceId,
                           [NSString stringWithFormat:@"%ld",file.uploadUserId],
                           ZYReplaceEmpty2NULL(file.date),
                           ZYReplaceEmpty2NULL(file.clientIp),
                           ZYReplaceEmpty2NULL(file.fileName),
                           ZYReplaceEmpty2NULL(file.filePath),
                           [NSString stringWithFormat:@"%ld",file.fileLength],
                           [NSString stringWithFormat:@"%ld",file.skipSize],
                           [NSString stringWithFormat:@"%d",file.uploadThreadNum],
                           [NSString stringWithFormat:@"%d",file.threadLimitNum],
                           ZYReplaceEmpty2NULL(file.status),
                           ZYReplaceEmpty2NULL(file.ip),
                           [NSString stringWithFormat:@"%d",file.port],
                           ZYReplaceEmpty2NULL(file.serversID),
                           ZYReplaceEmpty2NULL(file.uploadFileType),
                           [NSString stringWithFormat:@"%d",file.byteSize],
                           ZYReplaceEmpty2NULL(file.isMergeFile),
                           ZYReplaceEmpty2NULL(file.downAppId),
                           ZYReplaceEmpty2NULL(file.downKey),
                           ZYReplaceEmpty2NULL(file.fileAccessRight),
                           nil];
    FileSqlManager *manager = [[FileSqlManager alloc]init];
    BOOL ret = [manager executeUpdate:insertSql withArray:inputArray];
    
    return  ret;
}

//删除fileinfo条目
+(BOOL) deleteFileInfoWith:(NSString *)sourceId{
    
    NSString *sql = @"delete  from T_UPLOADFILETABLE WHERE sourceId = ?";
    
    NSArray *inputarray = [NSArray arrayWithObjects:sourceId, nil];
    
    FileSqlManager *manager = [[FileSqlManager alloc]init];
    
    NSMutableArray *retArr =  [manager executeQuery:sql withArray:inputarray];
    
    return [FileInfo mj_objectArrayWithKeyValuesArray:retArr];
}

//更改file状态
+ (BOOL)updateFileStatusWith:(NSString *)sourceId{
    NSString *sql = @"update T_UPLOADFILETABLE set status = ? WHERE sourceId = ?";
    
    NSArray *inputarray = [NSArray arrayWithObjects:@"1",sourceId, nil];

    FileSqlManager *manager = [[FileSqlManager alloc]init];
    BOOL ret = [manager executeUpdate:sql withArray:inputarray];
    
    return  ret;
}

/**
 *  查询所有未完成的file信息
 *
 *  @return 数组里面存放多条file，每个file包括多条task
 */

+ (NSMutableArray *) queryAllUnfinishedUploadFiles{

    NSString *sql = @"select t.sourceId, t.fileName, t.filePath, t.fileLength, t.totolNum, count(t.sourceId || t.status) filenum from T_UPLOADTASKTABLE t where t.status = 1 group by t.sourceId, t.fileName, t.filePath, t.fileLength,t.totolNum";
    
    FileSqlManager *manager = [[FileSqlManager alloc]init];
    
    NSMutableArray *resultArr = [manager executeQuery:sql withArray:nil];

    return resultArr;
}

+ (NSMutableArray *) queryOneUnfinishedFileWith:(NSString *)sourceId{
    
    NSString *queryOneUnfinishedFileSql = @"select * from T_UPLOADTASKTABLE WHERE sourceId = ?";
    
    NSArray *inputArray = [NSArray arrayWithObjects:sourceId, nil];
    
    FileSqlManager *manager = [[FileSqlManager alloc]init];
    
    NSMutableArray *resultArr = [manager executeQuery:queryOneUnfinishedFileSql withArray:inputArray];
    
    return [TaskInfo mj_objectArrayWithKeyValuesArray:resultArr];;
    
}

//插入数据
+ (BOOL) insertATaskInfoDataWithTask:(TaskInfo *)task{
  
     NSString * insertTaskInfoSql = @"replace into T_UPLOADTASKTABLE (TASK_ID,taskNo,totolNum,len,startPos,endPos,status,resultErrMsg,sourceId,uploadUserId,fileName,filePath,fileLength,skipSize,ip,port) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    
    NSString *taskId = [NSString stringWithFormat:@"%@+%d",task.sourceId,task.taskNo];
    NSString *taskNo = [NSString stringWithFormat:@"%d",task.taskNo];
    
    NSArray *inputArray = [NSArray arrayWithObjects:taskId,
                           taskNo,
                           [NSString stringWithFormat:@"%d",task.totolNum],
                           [NSString stringWithFormat:@"%ld",task.len],
                           [NSString stringWithFormat:@"%ld",task.startPos],
                           [NSString stringWithFormat:@"%ld",task.endPos],
                           [NSString stringWithFormat:@"%d",task.status],
                           task.resultErrMsg,
                           task.sourceId,
                           [NSString stringWithFormat:@"%ld",task.uploadUserId],
                           task.fileName ,
                           task.filePath,
                           [NSString stringWithFormat:@"%ld", task.fileLength],
                           [NSString stringWithFormat:@"%ld", task.skipSize],
                           task.ip,
                           [NSString stringWithFormat:@"%d",task.port],
                           nil];
    
    FileSqlManager *manager = [[FileSqlManager alloc]init];
    
    BOOL ret = [manager executeUpdate:insertTaskInfoSql withArray:inputArray];
    return ret;
    
}

+ (BOOL)updateATaskInfoDataWithTask:(TaskInfo *)task{

    NSString *updateSql =[NSString stringWithFormat:@"update T_UPLOADTASKTABLE set status = %d WHERE sourceId = %@ AND taskNo =%d",task.status,task.sourceId,task.taskNo];
    
    FileSqlManager *manager = [[FileSqlManager alloc]init];
    
    BOOL ret =[manager executeUpdate:updateSql withArray:nil];
    
    return  ret;
}

//删除file数据
+ (BOOL) deleteFileInfoDataWithTask:(TaskInfo *)task{
    
    NSString *updateTaskInfoSql = [NSString stringWithFormat:@"DELETE FROM T_UPLOADTASKTABLE WHERE sourceId = %@",task.sourceId];
    
    FileSqlManager *manager = [[FileSqlManager alloc]init];
    
    BOOL ret = [manager executeUpdate:updateTaskInfoSql withArray:nil];
    
    [self queryOneUnfinishedFileWith:task.sourceId];
    
    return ret;
}

//执行查询
- (NSMutableArray *)executeQuery:(NSString *)sqlString withArray:(NSArray *)array{

    Database *db = [[Database alloc]init];
    
   return [db executeQuery:sqlString withArray:array];
}

//执行更新
- (BOOL)executeUpdate:(NSString *)sqlString withArray:(NSArray *)array{

    Database *db = [[Database alloc]init];
    
    return [db executeUpdate:sqlString withArray:array];
}
@end
