//
//  AppDelegate.m
//  FileUploadManager
//
//  Created by Marlon on 16/4/21.
//  Copyright © 2016年 superman. All rights reserved.
//

#import "AppDelegate.h"
#import "fileUploaderviewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    _window.rootViewController = [[fileUploaderviewController alloc]init];
    
    [_window makeKeyAndVisible];
    
    return YES;
}

@end
