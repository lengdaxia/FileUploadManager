//
//  FileInfo.m
//  FileManager
//
//  Created by Marlon on 16/3/31.
//  Copyright © 2016年 superman. All rights reserved.

#import "FileInfo.h"
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation FileInfo



- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.taskInfoArr = [NSMutableArray array];
        self.skipSize = 256 * 1024;  //默认切片大小256 KB
        self.clientIp = [self localWiFiIPAddress];
        self.downKey = @"";
        self.downAppId = @"";
        self.fileAccessRight = @"";
        
    }
    return self;
}
- (NSString *) localWiFiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}



@end
