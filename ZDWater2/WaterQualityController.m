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
#import "WaterQualityCell.h"
#import "QualityDetailController.h"
#import "QualityDetaiObject.h"
#import "CustomDateActionSheet.h"
#import "ChartViewController.h"
#import "SVProgressHUD.h"
#import "QuailtyChartController.h"
#import "MyTimeView.h"
#import "HeaderView.h"


@interface WaterQualityController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
    NSArray *listData;//数据源
    UITableView *_myTableView; //右侧列表
    
    NSArray *_headers;//列表顶部字段
    NSMutableArray *_stations;//站点tableView数据源
    
    NSUInteger _kCount;
}
@property (strong, nonatomic) UIView *myHeaderView;//顶部视图

@property (nonatomic, strong) MyTimeView *myStationView;//左侧站点列表

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

- (void)viewWillLayoutSubviews
{
    if ([_myTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_myTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    if ([_myTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_myTableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

- (void)initData
{
    _headers = @[@"行政区划",@"水质等级",@"氨氮(mg/L)",@"总磷(mg/l)"];
    
    _kCount = _headers.count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"实时水质";
    
    [self initData];
    UIView *tableViewHeader = [[UIView alloc] initWithFrame:(CGRect){0,0,_kCount*kWidth,kHeight}];
    tableViewHeader.backgroundColor = BG_COLOR;
    self.myHeaderView = tableViewHeader;
    
    for (int i=0; i<_kCount; i++) {
        HeaderView *header = [[HeaderView alloc] initWithFrame:(CGRect){i*kWidth,0,kWidth,kHeight}];
        header.num = _headers[i];
        [tableViewHeader addSubview:header];
    }
    
    _myTableView = [[UITableView alloc] initWithFrame:(CGRect){0,0,self.myHeaderView.frame.size.width,kScreen_height - 64} style:UITableViewStylePlain];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.bounces = NO;
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){kWidth,0,kScreen_Width - kWidth,kScreen_height - 64}];
    [scrollView addSubview:_myTableView];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.contentSize = CGSizeMake(self.myHeaderView.frame.size.width, 0);
    [self.view addSubview:scrollView];
    
    self.myStationView = [[MyTimeView alloc] initWithFrame:(CGRect){0,0,kWidth,kScreen_height - 64}];
    self.myStationView.listData = _stations;
    self.myStationView.headTitle = @"监测站";
    [self.view addSubview:self.myStationView];
    
    NSDate *now = [NSDate date];
    NSArray *dates =(NSArray *)[self getRequestDates:now];
    
    //异步加载网络数据
    [self getWebData:dates];
    
    UIView *select_view = [[UIView alloc] initWithFrame:(CGRect){0,0,70,20}];
    
    UIButton *selectTime_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectTime_btn.frame = (CGRect){50,0,20,20};
    selectTime_btn.backgroundColor = [UIColor clearColor];
    selectTime_btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [selectTime_btn setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
    [selectTime_btn addTarget:self action:@selector(selectTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    [select_view addSubview:selectTime_btn];
    
    UIButton *chart_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    chart_btn.frame = (CGRect){0,0,20,20};
    chart_btn.backgroundColor = [UIColor clearColor];
    chart_btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [chart_btn setBackgroundImage:[UIImage imageNamed:@"chart"] forState:UIControlStateNormal];
    [chart_btn addTarget:self action:@selector(showChartAction:) forControlEvents:UIControlEventTouchUpInside];
    [select_view addSubview:chart_btn];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:select_view];
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
                if (listData.count != 0) {
                    ret = YES;
                    _stations = [NSMutableArray arrayWithCapacity:listData.count];
                    for (NSDictionary *dic in listData) {
                        [_stations addObject:[dic objectForKey:@"Stnm"]];
                    }
                    [self.myStationView refrushTableView:_stations];
                }
                [_myTableView reloadData];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //获取网络数据失败
                [SVProgressHUD dismiss];
                listData = [NSArray arrayWithObject:@"当前无网络数据"];
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

- (void)showChartAction:(UIButton *)btn
{
    QuailtyChartController *chart = [[QuailtyChartController alloc] init];
    chart.datas = listData;
    [self.navigationController pushViewController:chart animated:YES];
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
        WaterQualityCell *cell = (WaterQualityCell *)[tableView dequeueReusableCellWithIdentifier:@"WaterQuality"];
        if (cell == nil) {
            cell = (WaterQualityCell *)[[[NSBundle mainBundle] loadNibNamed:@"quality" owner:self options:nil] lastObject];
        }
        NSDictionary *dic = [listData objectAtIndex:indexPath.row];
        cell.areaLabel.text = [[dic objectForKey:@"Adnm"] isEqualToString:@""] ? @"--" : [dic objectForKey:@"Adnm"];
        cell.level.text = [[dic objectForKey:@"Szdj"] isEqualToString:@""] ? @"--" : [dic objectForKey:@"Szdj"];
        cell.NHLabel.text = [[dic objectForKey:@"Ad"] isEqualToString:@""] ? @"--" : [dic objectForKey:@"Ad"];
        cell.pLabel.text = [[dic objectForKey:@"Zl"] isEqualToString:@""] ? @"--" : [dic objectForKey:@"Zl"];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return kHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return self.myHeaderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *now = [NSDate date];
    NSArray *dates =(NSArray *)[self getRequestDates:now]; //时间数组
    
    NSDictionary *dic = [listData objectAtIndex:indexPath.row];
    BOOL ret = [QualityDetaiObject fetchWithType:@"GetSzInfoView" start:[dates objectAtIndex:0] end:[dates objectAtIndex:1] stcd:[dic objectForKey:@"Stcd"] ascd:[dic objectForKey:@"Ascd"]];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offSetY = _myTableView.contentOffset.y;//tableVIew的Y方向的偏移
    
    CGPoint timeOffSet = self.myStationView.myTableView.contentOffset;
    
    timeOffSet.y = offSetY;
    
    self.myStationView.myTableView.contentOffset = timeOffSet;
    if (offSetY == 0) {
        self.myStationView.myTableView.contentOffset = CGPointZero;
    }
}
@end
