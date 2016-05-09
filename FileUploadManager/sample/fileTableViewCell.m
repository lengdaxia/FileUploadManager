//
//  fileTableViewCell.m
//  CJMobile
//
//  Created by Marlon on 16/4/15.
//  Copyright © 2016年 长江证券. All rights reserved.
//

#import "fileTableViewCell.h"
#import "FileUploader.h"

@interface fileTableViewCell()
@property(nonatomic, strong) FileUploader *uploader;


@end

@implementation fileTableViewCell


- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.uploader = [[FileUploader alloc]init];
    
}
- (IBAction)start:(id)sender {
    
    
    if (self.progress.progress != 0) {
        
        /**
         *  未完成的上传文件调用reload的接口，继续上传
         */
        [self.uploader reloadWith:self.sourceId progress:^(float percent) {
            
            self.progress.progress = percent;
            self.percent.text = [NSString stringWithFormat:@"%.2f ％",percent * 100];
        }];
        
    }else{ //新的上传文件调用upload－－－ 调用下面的接口
    
    [self.uploader uploadFileWithFilePath:self.filePath andUserId:4334 progress:^(float percent) {
        
        self.progress.progress = percent;
        self.percent.text = [NSString stringWithFormat:@"%.2f ％",percent * 100];
    }];
    
    }
}
- (IBAction)pause:(id)sender {
    
    [self.uploader pause];
    
}
- (IBAction)resume:(id)sender {
    
    [self.uploader resume];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
