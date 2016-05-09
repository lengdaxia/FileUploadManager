//
//  Database.h
//  FMDBTest
//
//  Created by  on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@class FMDatabase;
@class FMDatabaseQueue;

@interface Database : NSObject {
    
    FMDatabase *m_db;
    FMDatabaseQueue *dbQueue;
}

//执行查询
- (NSMutableArray *)executeQuery:(NSString *)sqlString withArray:(NSArray *)array;

//执行更新
- (BOOL)executeUpdate:(NSString *)sqlString withArray:(NSArray *)array;

//在事务中更新
- (BOOL)executeUpdateInTransaction:(NSString *)sqlString withArray:(NSArray *)array;

//重置数据库
+ (void)reset;

@end
