//
//  FileUploadDB.m
//  FileUploader
//
//  Created by Marlon on 16/4/22.
//  Copyright © 2016年 superman. All rights reserved.
//

#import "FileUploadDB.h"
//定义常用的字符串函数
#define ZYIsNullOrEmpty(str)            ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1)
#define ZYReplaceNULL2Empty(str)        ((nil == (str)) ? @"" : (str))
#define ZYReplaceEmpty2NULL(str)        ((nil == (str)) ? [NSNull null] : (str))
#define ZYReplaceNULL2HoriLine(str)     ((nil == (str)) ? @"--" : (str))

static FMDatabaseQueue * g_dbQueue = nil;

@implementation FileUploadDB
- (id)init{
    self = [super init];
    if ( self ){
        
        
        NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"fileDB.sqlite"];
        
        if (!g_dbQueue) {
            g_dbQueue = [ FMDatabaseQueue databaseQueueWithPath:dbPath];
        }
        dbQueue = g_dbQueue;
        
        
        NSString *fileTableSql = @"CREATE TABLE IF NOT EXISTS T_UPLOADFILETABLE(sourceId TEXT PRIMARY KEY NOT NULL, uploadUserId TEXT, date  TEXT, clientIp  TEXT,fileName TEXT,filePath TEXT, fileLength TEXT, skipSize TEXT,uploadThreadNum  TEXT, threadLimitNum TEXT, status TEXT,ip  TEXT,port TEXT,serversID TEXT,uploadFileType TEXT, byteSize TEXT, isMergeFile TEXT, downAppId TEXT,downKey TEXT, fileAccessRight TEXT,percent TEXT)";
        
        NSString *taskTableSql = @"CREATE TABLE IF NOT EXISTS T_UPLOADTASKTABLE( TASK_ID  TEXT PRIMARY KEY NOT NULL,  taskNo TEXT, totolNum   TEXT, len  TEXT, startPos TEXT,endPos TEXT,uploadTime TEXT,wasteTime TEXT,status              TEXT, resultErrMsg  TEXT, sourceId TEXT, uploadUserId TEXT, clientIp TEXT, fileName TEXT, filePath TEXT, fileLength TEXT, skipSize TEXT, uploadThreadNum  TEXT,threadLimitNum TEXT,isHolded  TEXT, ip  TEXT,  port                TEXT, serversID TEXT,byteSize TEXT, isMergeFile TEXT)";
        
        [dbQueue inDatabase:^(FMDatabase *db) {
            //创建本地数据表
            [db executeUpdate:fileTableSql];
            [db executeUpdate:taskTableSql];
        }];
        
    }
    return self;
}


//执行查询
- (NSMutableArray *)executeQuery:(NSString *)sqlString withArray:(NSArray *)array{
    
    __block NSMutableArray *arr = [NSMutableArray array];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sqlString withArgumentsInArray:array];
        while ([rs next]) {
            [arr addObject:[rs resultDictionary]];
        }
        [rs close];
    }];
    
    return arr;
}


//执行更新
- (BOOL)executeUpdate:(NSString *)sqlString withArray:(NSArray *)array{
    
    __block BOOL ret = NO;
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        ret = [db executeUpdate:sqlString withArgumentsInArray:array];
    }];
    
    return ret;
}


//在事务中更新
- (BOOL)executeUpdateInTransaction:(NSString *)sqlString withArray:(NSArray *)array {
    
    __block BOOL resultState = YES;
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback){
        for (NSArray *arrItem in array) {
            BOOL res = [db executeUpdate:sqlString withArgumentsInArray:arrItem];
            if (!res) {
                resultState = res;
                *rollback = YES;
                break;
            }
        }
    }];
    return resultState;
}


//重置数据库
+ (void)reset{
    [g_dbQueue close];
    g_dbQueue = nil;
}
@end
