//
//  GateViewController.m
//  ZDWater2
//  **********闸门开度**************
//  Created by teddy on 15/6/3.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "GateViewController.h"
#import "CustomHeaderView.h"
#import "GateObject.h"
#import "ChartViewController.h"
#import "SVProgressHUD.h"
#import "GateCell.h"

@interface GateViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *listData;
}
@property (strong, nonatomic)  UITableView *myTableView;

@end

@implementation GateViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //强制屏幕横屏
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [GateObject cancelRequest];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"实时闸门开度";
    
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
    self.myTableView.rowHeight = 44;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.view addSubview:self.myTableView];
    
    [SVProgressHUD showWithStatus:@"加载中.."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([GateObject fetchWithType:@"GetZmInfo"]) {
            //获取网络数据成功
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithSuccess:@"加载成功"];
                listData = [GateObject requestGateDatas];
                [self.myTableView reloadData];
            });
        }else{
            //获取网络数据失败
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithError:@"加载失败"];
            });
        }
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //有数据的时候
    GateCell *cell = (GateCell *)[tableView dequeueReusableCellWithIdentifier:@"GateCell"];
    if (cell == nil) {
        cell = (GateCell *)[[[NSBundle mainBundle] loadNibNamed:@"Gate" owner:nil options:nil] lastObject];
    }
    NSDictionary *dic = [listData objectAtIndex:indexPath.row];
    cell.nameLabel.text = [[dic objectForKey:@"Stnm"] isEqual:@""] ? @"--" : [dic objectForKey:@"Stnm"];
    cell.kCountLabel.text = [[dic objectForKey:@"ZkCount"] isEqual:@""] ? @"--" : [dic objectForKey:@"ZkCount"];
    cell.kOpenCountLabel.text = [[dic objectForKey:@"ZkOpenCount"] isEqual:@""] ? @"--" : [dic objectForKey:@"ZkOpenCount"];
    return cell;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CustomHeaderView *headview = [[CustomHeaderView alloc] initWithFirstLabel:@"闸门名称" withSecond:@"闸孔数量(个)" withThree:@"已开启个数(个)"];
    headview.backgroundColor = BG_COLOR;
    return headview;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [listData objectAtIndex:indexPath.row];
    ChartViewController *chart = [[ChartViewController alloc] init];
    chart.requestType = @"GetZmChart";
    chart.chartType = 1;//折线图
    chart.title_name = dic[@"Stnm"];
    chart.stcd = dic[@"Stcd"];
    chart.functionType = FunctionDoubleChart;
    [self.navigationController pushViewController:chart animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
