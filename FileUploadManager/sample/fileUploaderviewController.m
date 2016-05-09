//
//  fileUploaderviewController.m
//  CJMobile
//
//  Created by Marlon on 16/4/15.
//  Copyright © 2016年 长江证券. All rights reserved.
//

#import "fileUploaderviewController.h"
#import "FileSqlManager.h"
#import "FileUploader.h"
#import "fileTableViewCell.h"

@interface fileUploaderviewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation fileUploaderviewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"上传管理器";
    
    [self loadDataSource];
    
    self.table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.rowHeight = 85;
    self.table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.table.backgroundColor = [UIColor colorWithRed:1.0 green:0.9251 blue:0.7407 alpha:1.0];
    
    
    [self.view addSubview:self.table];
}

- (void)loadDataSource{
    
    self.dataSource = [NSMutableArray array];
    
    NSMutableArray *smallFileArray = [[NSMutableArray alloc]init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"小文件.docx" ofType:nil];
    NSString *name = [path lastPathComponent];
    
    FileInfo *smallFile = [[FileInfo alloc]init];
    smallFile.filePath = path;
    smallFile.fileName = name;
    smallFile.fileLength = @"";
    smallFile.sourceId = @"1234";
    smallFile.percent = 0;
    
    [smallFileArray addObject:smallFile];
    [self.dataSource addObject:smallFileArray];

    
    NSMutableArray *bigFileArr = [[NSMutableArray alloc]init];
    
    NSString *bigpath = [[NSBundle mainBundle] pathForResource:@"大文件.pdf" ofType:nil];
    NSString *bigname = [bigpath lastPathComponent];
    
    FileInfo *bigFile = [[FileInfo alloc]init];
    bigFile.filePath = bigpath;
    bigFile.fileName = bigname;
    bigFile.fileLength = @"";
    bigFile.sourceId = @"1234";
    bigFile.percent = 0;
    
    [bigFileArr addObject:bigFile];
    [self.dataSource addObject:bigFileArr];
    
//    从本地数据库中读取大文件的上传信息，恢复上传现场
    [self.dataSource addObject:[FileSqlManager getAllUnFinishedFiles]];

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSMutableArray *arr = self.dataSource[section];
    return arr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSMutableArray *arr = self.dataSource[indexPath.section];
    
    FileInfo *file = arr[indexPath.row];
    
    fileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell"];
    
    if (cell == nil) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"fileTableViewCell" owner:self options:nil] lastObject];
        
        NSString *name = file.fileName;
        
        
        cell.fileName.text = name;
        cell.filePath = file.filePath;
        cell.sourceId = file.sourceId;
        cell.percent.text = [NSString stringWithFormat:@"%.2f ％",file.percent * 100];
    
        
        if (indexPath.section == 0) {
            
            [cell.pauseBtn setTitle:@"" forState:UIControlStateNormal];
            [cell.resumeBtn setTitle:@"" forState:UIControlStateNormal];
            
            cell.pauseBtn = nil;
            cell.resumeBtn = nil;
        }
        
        if (indexPath.section == 2) {
            
            [cell.startBtn setTitle:@"continue" forState:UIControlStateNormal];
            
            if (file.percent == 1) {
                [cell.startBtn setTitle:@"finished" forState:UIControlStateNormal];
                cell.startBtn.enabled = NO;
            }
        }
        
    
    }
    
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    if (section == 0) {
    
        return @"小文件(1M以下)；不支持暂停和继续，可高并发上传小文件";
    }else if(section == 1){
        
        return @"大文件：有开始，暂停和继续，支持同时上传多个大文件";
    }else{
    
        return @"大文件支持离线的断点续传";
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
