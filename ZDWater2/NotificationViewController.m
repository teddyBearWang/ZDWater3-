//
//  NotificationViewController.m
//  ZDWater2
//  *************通知公告***************
//  Created by teddy on 15/6/3.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationCell.h"
#import "NotificationDetailController.h"
#import "Notification.h"
#import "SVProgressHUD.h"

@interface NotificationViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *listData;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation NotificationViewController

 -(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [Notification cancelRequest];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"通知公告";
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.rowHeight = 60;
    
    [self getNews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getNews
{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([Notification fetch]) {
            //成功
            [SVProgressHUD dismissWithSuccess:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                listData = [Notification requestDatas];
                [self.myTableView reloadData];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithError:@"加载失败.."];
            });
        }
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"NotificationCell";
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = (NotificationCell *)[[[NSBundle mainBundle] loadNibNamed:@"Notification" owner:nil options:nil] lastObject];
    }
    NSDictionary *dic = listData[indexPath.row];
    cell.name.text = [[dic objectForKey:@"XWBT"] isEqual:@""] ? @"--" :[dic objectForKey:@"XWBT"];
    cell.date.text = [[dic objectForKey:@"ADD_TIME"] isEqual:@""] ? @"--" :[dic objectForKey:@"ADD_TIME"];
    cell.detail.text = [[dic objectForKey:@"ADD_USER"] isEqual:@""] ? @"--" :[NSString stringWithFormat:@"发布人: %@",[dic objectForKey:@"ADD_USER"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationDetailController *detail = [[NotificationDetailController alloc] init];
    NSDictionary *dic = listData[indexPath.row];
    detail.title_name = [dic objectForKey:@"XWBT"];
    detail.time = [dic objectForKey:@"ADD_TIME"];
    detail.conetnt = [dic objectForKey:@"XWNR"];
    detail.user = [dic objectForKey:@"ADD_USER"];
    [self.navigationController pushViewController:detail animated:YES];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"返回";
    self.navigationItem.backBarButtonItem = back;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

@end
