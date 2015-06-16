//
//  WaterQualityController.m
//  ZDWater2
//      ********水质***********
//  Created by teddy on 15/6/3.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "WaterQualityController.h"
#import "CustomHeaderView.h"
#import "WaterQuality.h"
#import "WaterCell.h"
#import "QualityDetailController.h"
#import "QualityDetaiObject.h"
#import "CustomDateActionSheet.h"
#import "ChartViewController.h"
#import "SVProgressHUD.h"

@interface WaterQualityController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    NSArray *listData;
}
@property (strong, nonatomic) UITableView *myTableView;

@end

@implementation WaterQualityController

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
        [WaterQuality cancelRequest];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"实时水质";
    
    self.myTableView = [[UITableView alloc] initWithFrame:(CGRect){0,0,self.view.frame.size.width,self.view.frame.size.height - 64} style:UITableViewStylePlain];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    NSDate *now = [NSDate date];
    self.myTableView.rowHeight = 44;
    [self.view addSubview:self.myTableView];
    NSArray *dates =(NSArray *)[self getRequestDates:now];
    
    //异步加载网络数据
    [self getWebData:dates];
    
    UIButton *selectTime_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectTime_btn.frame = (CGRect){0,0,20,20};
    selectTime_btn.backgroundColor = [UIColor clearColor];
    selectTime_btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [selectTime_btn setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
    [selectTime_btn addTarget:self action:@selector(selectTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:selectTime_btn];
    self.navigationItem.rightBarButtonItem = item;

}

static BOOL ret;
- (void)getWebData:(NSArray *)dates
{
    [SVProgressHUD showWithStatus:@"加载中.."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([WaterQuality FetchWithType:@"GetSzInfo" withStrat:[dates objectAtIndex:0] withEnd:[dates objectAtIndex:1]]) {
            //加载成功，主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                //进入到主线程中，更新UI
                [SVProgressHUD dismissWithSuccess:@"加载成功"];
                listData = [WaterQuality RequestData];
                ret = YES;
                [self.myTableView reloadData];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //获取网络数据失败
                [SVProgressHUD dismiss];
                //listData = [WaterQuality RequestData];
                listData = [NSArray arrayWithObject:@"当前无网络数据"];
               // [self.myTableView reloadData];
            });
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)getRequestDates:(NSDate *)nowDate
{
    NSMutableArray *dates = [NSMutableArray array];
    NSTimeInterval seconds = 24 * 60 *60;
    //当前时间的前一天
    NSDate *torrow = [nowDate dateByAddingTimeInterval:seconds];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //时间字符串
    NSString *now = [formatter stringFromDate:nowDate];
    NSString *torrTd = [formatter stringFromDate:torrow];
    [dates addObject:now];
    [dates addObject:torrTd];
    return dates;
}

- (NSDate *)getDateFromString:(NSString *)str
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:str];
    return date;
}

//时间选择
- (void)selectTimeAction:(id)sender
{
    CustomDateActionSheet *sheet = [[CustomDateActionSheet alloc] initWithTitle:@"时间选择" delegate:self];
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        CustomDateActionSheet *sheet = (CustomDateActionSheet *)actionSheet;
        
        NSDate *time = [self getDateFromString:sheet.selectedTime];
        NSArray *dates =(NSArray *)[self getRequestDates:time];
        [self getWebData:dates];
   }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (ret) {
        WaterCell *cell = (WaterCell *)[tableView dequeueReusableCellWithIdentifier:@"WaterCell"];
        if (cell == nil) {
            cell = (WaterCell *)[[[NSBundle mainBundle] loadNibNamed:@"WaterCell" owner:self options:nil] lastObject];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSDictionary *dic = [listData objectAtIndex:indexPath.row];
        cell.stationName.text = [[dic objectForKey:@"CZMC"] isEqual:@""] ? @"--" : [dic objectForKey:@"CZMC"];
        cell.lastestLevel.text = [[dic objectForKey:@"SZDJ"] isEqual:@""] ? @"--" : [dic objectForKey:@"JD"];
        cell.warnWater.text = [[dic objectForKey:@"WD1"] isEqual:@""] ? @"--" : [dic objectForKey:@"WD"];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyCell"];
        }
        cell.textLabel.text = listData[0];
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CustomHeaderView *view = [[CustomHeaderView alloc] initWithFirstLabel:@"站名" withSecond:@"水质等级" withThree:@"温度"];
    view.backgroundColor = BG_COLOR;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *now = [NSDate date];
    NSArray *dates =(NSArray *)[self getRequestDates:now]; //时间数组
    
    NSDictionary *dic = [listData objectAtIndex:indexPath.row];
    BOOL ret = [QualityDetaiObject fetchWithType:@"GetSzInfoView" start:[dates objectAtIndex:0] end:[dates objectAtIndex:1] stcd:[dic objectForKey:@"CZBH"]];
    if (ret) {
        QualityDetailController *quality = [[QualityDetailController alloc] init];
        //获取数据源
        quality.datas = [QualityDetaiObject requestDetailData];
        [self.navigationController pushViewController:quality animated:YES];
    }else{
        //获取数据失败
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
