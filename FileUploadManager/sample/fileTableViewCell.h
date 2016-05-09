//
//  fileTableViewCell.h
//  CJMobile
//
//  Created by Marlon on 16/4/15.
//  Copyright © 2016年 长江证券. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface fileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *resumeBtn;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property(nonatomic, strong) NSString * filePath;
@property(nonatomic, strong) NSString * sourceId;


@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileSize;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *percent;

@end
