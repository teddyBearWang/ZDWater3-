//
//  WaterLevelController.m
//  ZDWater2
//  ************水位**************
//  Created by teddy on 15/6/3.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "WaterLevelController.h"
#import "CustomHeaderView.h"
#import "WaterSituation.h"
#import "WaterLevelCell.h"
#import "ChartViewController.h"
#import "SVProgressHUD.h"
#import "CustomDateActionSheet.h"
#import "MyTimeView.h"
#import "HeaderView.h"

//因为最后一个时间lable的宽度为120 ，前面的label宽度为100，因此需要额外加上20
#define TimeOverWidth 20

@interface WaterLevelController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
{
    NSArray *waterLevels; //水情数据源
    NSArray *_headers;//列表头部数据源
    NSMutableArray *_stations;// 站点tableVIew的数据源
    
    NSUInteger _kCount;
    
    UITableView *_myTableView;
}
@property (strong, nonatomic)  UIView *myHeaderVIew;

@property (strong, nonatomic) MyTimeView *myStationView;//左侧站点列表

@end

@implementation WaterLevelController

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
        [WaterSituation cancelRequest];
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
    _headers = @[@"行政区划",@"8时水位(m)",@"当前水位(m)",@"当前水位时间"];
    _kCount = _headers.count;
}

static BOOL ret = NO;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"实时水位";
    
    [self initData];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0,0,_kCount*kWidth + TimeOverWidth,kHeight}];
    tableHeaderView.backgroundColor = BG_COLOR;
    self.myHeaderVIew = tableHeaderView;
    
    for (int i=0; i<_kCount; i++) {
        HeaderView *headerView = [[HeaderView alloc] initWithFrame:(CGRect){i*kWidth,0,kWidth,kHeight}];
        headerView.num = _headers[i];
        [tableHeaderView addSubview:headerView];
    }
    
    
    
    _myTableView = [[UITableView alloc] initWithFrame:(CGRect){0,0,self.myHeaderVIew.frame.size.width + TimeOverWidth,kScreen_height - 64} style:UITableViewStylePlain];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
//    [self.view addSubview:_myTableView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){kWidth+20,0,kScreen_Width - kWidth,kScreen_height - 64}];
    [scrollView addSubview:_myTableView];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.contentSize = CGSizeMake(self.myHeaderVIew.frame.size.width + TimeOverWidth, 0);
    [self.view addSubview:scrollView];
    
    self.myStationView = [[MyTimeView alloc] initWithFrame:(CGRect){0,0,kWidth+20,kScreen_height - 64}];
    self.myStationView.listData = _stations;//数据源
    self.myStationView.headTitle = @"监测站";
    [self.view addSubview:self.myStationView];
    
    UIButton *select_time = [UIButton buttonWithType:UIButtonTypeCustom];
    select_time.frame = (CGRect){0,0,20,20};
    select_time.backgroundColor = [UIColor clearColor];
    select_time.titleLabel.font = [UIFont systemFontOfSize:14];
    [select_time setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
    [select_time addTarget:self action:@selector(selectTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:select_time];
    self.navigationItem.rightBarButtonItem = item;

    NSDate *now = [NSDate date];
    NSString *date_str = [self getStringWithDate:now];
    [self refresh:date_str];
}

- (void)selectTimeAction:(UIButton *)btn
{
    CustomDateActionSheet *sheet = [[CustomDateActionSheet alloc] initWithTitle:@"时间选择" delegate:self];
    [sheet showInView:self.view];
}

- (void)refresh:(NSString *)date
{
    [SVProgressHUD showWithStatus:@"加载中.."];
    //创建一个队列
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([WaterSituation fetchWithType:@"GetSqInfo" area:@"33" date:date start:@"0" end:@"10000"]) {
            //请求网络成功之后，在主线程更新UI
            [self updateUI];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //进入到主线程，更新UI
                [SVProgressHUD dismissWithError:@"加载失败"];
                ret = NO;
            });
        }
    });
}

//主线程更新UI
- (void)updateUI
{
    [SVProgressHUD dismissWithSuccess:@"加载成功"];
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        waterLevels = [WaterSituation requestWaterData];
        if (waterLevels.count != 0) {
            ret = YES;
            _stations = [NSMutableArray arrayWithCapacity:waterLevels.count];
            for (NSDictionary *dic in waterLevels) {
                [_stations addObject:[dic objectForKey:@"Stnm"]];
            }
            [self.myStationView refrushTableView:_stations];
        }else{
            
            ret = NO;
            waterLevels = [NSArray arrayWithObject:@"当前暂无水情数据"];
        }
        [_myTableView reloadData];
    });
}

//根据时间格式化时间字符串
- (NSString *)getStringWithDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *date_str = [formatter stringFromDate:date];
    return date_str;
}

//格式化选择时间字符串
- (NSString *)getStringWithSelectDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [formatter stringFromDate:date];
    NSString *date_str = [NSString stringWithFormat:@"%@ 23:59:59",str];
    return date_str;
}

//将时间字符串格式化为时间
- (NSDate *)dateFromDateString:(NSString *)dateStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:dateStr];
    return date;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        CustomDateActionSheet *sheet = (CustomDateActionSheet *)actionSheet;
        NSDate *date = [self dateFromDateString:sheet.selectedTime];
        NSString *str_time = [self getStringWithSelectDate:date];
        [self refresh:str_time];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return waterLevels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(ret)
    {
        //有数据的时候
        WaterLevelCell *cell = (WaterLevelCell *)[tableView dequeueReusableCellWithIdentifier:@"WaterLevel"];
        if (cell == nil) {
            cell = (WaterLevelCell *)[[[NSBundle mainBundle] loadNibNamed:@"WaterLevel" owner:self options:nil] lastObject];
        }
        NSDictionary *dic = [waterLevels objectAtIndex:indexPath.row];
        cell.areaLabel.text = [[dic objectForKey:@"Adnm"] isEqual:@""] ? @"--" : [dic objectForKey:@"Adnm"];
        cell.eightLabel.text = [[dic objectForKey:@"EighthValue"] isEqual:@""] ? @"--" : [dic objectForKey:@"EighthValue"];
        cell.currentLabel.text = [[dic objectForKey:@"NowValue"] isEqual:@""] ? @"--" : [dic objectForKey:@"NowValue"];
        cell.currentTime.text = [[dic objectForKey:@"NowTime"] isEqual:@""] ? @"--" : [dic objectForKey:@"NowTime"];
        return cell;
    }else{
        //无数据
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = [waterLevels objectAtIndex:0];
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    return self.myHeaderVIew;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [waterLevels objectAtIndex:indexPath.row];
    ChartViewController *chart = [[ChartViewController alloc] init];
    chart.title_name = dic[@"Stnm"];
    chart.requestType = @"GetStDaySW";
    chart.stcd = dic[@"Stcd"];
    chart.chartType = 1;
    chart.functionType = FunctionSingleChart;
    [self.navigationController pushViewController:chart animated:YES];
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
