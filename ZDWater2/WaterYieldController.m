//
//  WaterYieldController.m
//  ZDWater2
//  *********水量************
//  Created by teddy on 15/6/3.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "WaterYieldController.h"
#import "WaterYield.h"
#import "CustomHeaderView.h"
#import "WaterCell.h"
#import "UUChart.h"
#import "SVProgressHUD.h"
#import "HeaderView.h"
#import "MyTimeView.h"

@interface WaterYieldController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *listData;
    UUChart *chartView;
    UIView *chart_bg_view; //存在chart的视图
    
    UITableView *_myTableView;
    NSArray *_headers;//列表头部
    NSMutableArray *_stations;//站点tableView数据源
    
    NSUInteger _kCount;
    
    
}
@property (strong, nonatomic)  UIButton *chartBtn;
@property (weak, nonatomic) IBOutlet UIButton *tableBtn;
@property (strong, nonatomic) UIView *myHeaderView;

@property (nonatomic, strong) MyTimeView *myStationView;//左侧列表
- (IBAction)tableSelectedAction:(id)sender;
- (IBAction)chartSelectedAction:(id)sender;

@end

@implementation WaterYieldController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [_myTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]) {
        [WaterYield cancelRequest];
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
    _headers = @[@"行政区划",@"当前流量(m³)",@"流速(m/s)"];
    _kCount = _headers.count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"实时水量";
    
    [self initData];
    
    UIView *tableViewHeaderView = [[UIView alloc] initWithFrame:(CGRect){0,0,_kCount*kWidth,kHeight}];
    tableViewHeaderView.backgroundColor = BG_COLOR;
    self.myHeaderView = tableViewHeaderView;
    
    for (int i=0; i<_kCount; i++) {
        HeaderView *header = [[HeaderView alloc] initWithFrame:(CGRect){i*kWidth,0,kWidth,kHeight}];
        header.num = _headers[i];
        [tableViewHeaderView addSubview:header];
    }
    
    _myTableView = [[UITableView alloc] initWithFrame:(CGRect){0,0,self.myHeaderView.frame.size.width,kScreen_height - 64} style:UITableViewStylePlain];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){kWidth,0,kScreen_Width - kWidth,kScreen_height - 64}];
    [scrollView addSubview:_myTableView];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.contentSize = CGSizeMake(self.myHeaderView.frame.size.width, 0);
    [self.view addSubview:scrollView];
    
    self.myStationView = [[MyTimeView alloc] initWithFrame:(CGRect){0,0,kWidth,kScreen_height}];
    self.myStationView.listData = _stations;//数据源
    self.myStationView.headTitle = @"监测站";
    [self.view addSubview:self.myStationView];
    
    self.tableBtn.selected = YES;//默认是选择状态的
    
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[@"水量列表",@"水量图表"]];
    seg.segmentedControlStyle = UISegmentedControlStyleBar;
    seg.selectedSegmentIndex = 0;
    seg.multipleTouchEnabled = NO;
    [seg addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    seg.apportionsSegmentWidthsByContent = YES;
    self.navigationItem.titleView = seg;
    
    [self getWebData];
}

static  BOOL ret;
//异步加载网络数据
- (void)getWebData
{
    NSDate *data = [NSDate date];
    NSString *date_str = [self getStringWithDate:data];
    [SVProgressHUD showWithStatus:@"加载中.."];
    //创建队列，进行异步加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([WaterYield fetchWithType:@"GetSlInfo" date:date_str]) {
            //进入到主线程进行更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithSuccess:@"加载成功"];
                listData = [WaterYield requestWithDatas];
                if(listData.count != 0){
                    ret = YES;
                    _stations = [NSMutableArray arrayWithCapacity:listData.count];
                    for (NSDictionary *dic in listData) {
                        [_stations addObject:[dic objectForKey:@"Stnm"]];
                    }
                    [self.myStationView refrushTableView:_stations];
                    //当数据源不为0的时候划折线图
                    [self initChartView];
                    
                }else{
                    ret = NO;
                    listData = [NSArray arrayWithObject:@"当前无数据"];
                }
                [_myTableView reloadData];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithError:@"加载失败"];
            });
        }
    });
}

//根据时间格式化时间字符串
- (NSString *)getStringWithDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date_str = [formatter stringFromDate:date];
    return date_str;
}

//切换
- (void)segmentAction:(UISegmentedControl *)seg
{
    if (seg.selectedSegmentIndex == 0) {
        //列表
        self.chartBtn.selected = NO;
        chart_bg_view.hidden = YES;
        _myTableView.hidden = NO;
    }else{
        //图表
        self.tableBtn.selected = NO;
        _myTableView.hidden = YES;
        chart_bg_view.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//创建chartVIew
- (void)initChartView
{
    
    chart_bg_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 10)];
    [self.view addSubview:chart_bg_view];
    if (chartView) {
        [chartView removeFromSuperview];
        chartView = nil;
    }
    
    chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 10,
                                                                    chart_bg_view.frame.size.width-10, chart_bg_view.frame.size.height - 30)
                                              withSource:self
                                               withStyle: UUChartBarStyle];
    [chartView showInView:chart_bg_view];
    chart_bg_view.hidden = YES;
    
    UILabel *explanLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, chart_bg_view.frame.size.height - 20, chart_bg_view.frame.size.width, 20)];
    explanLabel.layer.borderWidth = 1.0;
    explanLabel.layer.borderColor = [UIColor blackColor].CGColor;
    explanLabel.text = @"  红色:表示计划水量；绿色:表示实际水量";
    explanLabel.font = [UIFont systemFontOfSize:14];
    [chart_bg_view addSubview:explanLabel];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(ret)
    {
        //有数据的时候
        WaterCell *cell = (WaterCell *)[tableView dequeueReusableCellWithIdentifier:@"WaterCell"];
        if (cell == nil) {
            cell = (WaterCell *)[[[NSBundle mainBundle] loadNibNamed:@"WaterCell" owner:nil options:nil] lastObject];
        }
        NSDictionary *dic = [listData objectAtIndex:indexPath.row];
        cell.areaName.text = [[dic objectForKey:@"Adnm"] isEqual:@""] ? @"--" : [dic objectForKey:@"Adnm"];
        cell.speed.text = [[dic objectForKey:@"planVal"] isEqual:@""] ? @"--" : [dic objectForKey:@"planVal"];
        cell.currentSpeed.text = [[dic objectForKey:@"realVal"] isEqual:@""] ? @"--" : [dic objectForKey:@"realVal"];
        return cell;
    }else{
        //无数据
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = [listData objectAtIndex:0];
        return cell;
    }

}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return self.myHeaderView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UUChartDataSource

//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    NSMutableArray *x_labels = [NSMutableArray arrayWithCapacity:listData.count];
    for (int i=0; i<listData.count; i++) {
        NSDictionary *dic = [listData objectAtIndex:i];
        [x_labels addObject:[dic objectForKey:@"Stnm"]];
    }
    
    return x_labels;
}

//数值多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
        NSMutableArray *y_realAry = [NSMutableArray arrayWithCapacity:listData.count];
        NSMutableArray *y_planAry = [NSMutableArray arrayWithCapacity:listData.count];
        for (int i=0; i<listData.count; i++) {
            NSDictionary *dic = [listData objectAtIndex:i];
            [y_realAry addObject:[dic objectForKey:@"realVal"]];
            [y_planAry addObject:[dic objectForKey:@"planVal"]];
        }
        return @[y_realAry,y_planAry];
}

//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UUGreen,UURed,UUBrown];
}


@end
