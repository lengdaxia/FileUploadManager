//
//  TaskInfo.m
//  FileManager
//
//  Created by Marlon on 16/4/1.
//  Copyright © 2016年 superman. All rights reserved.
//

#import "TaskInfo.h"

@implementation TaskInfo

-(instancetype)init{

    self = [super init];
    if (self) {
        
        self.status = 0;
        self.skipSize = 256 * 1024;  //默认切片大小256 KB
        self.resultErrMsg = @"";
    }
    return self;
}
@end
