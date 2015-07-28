//
//  RainViewController.m
//  ZDWater2
//
//  Created by teddy on 15/6/3.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "RainViewController.h"
#import "ChartViewController.h"
#import "SelectViewController.h"
#import "RainCell.h"
#import "RainObject.h"
#import "UIView+RootView.h"
#import "SVProgressHUD.h"
#import "CustomDateActionSheet.h"
#import "MyCell.h"
#import "HeaderView.h"
#import "MyTimeView.h"

@interface RainViewController ()<UITableViewDataSource,UITableViewDelegate,SelectItemsDelegate,UIActionSheetDelegate>
{
    NSArray *listData; //tableVIew的数据源
    NSMutableArray *sourceDatas;//所有的数据
    UITableView *_myTableView; //右侧列表
    NSArray *_headers;//列表头部数据源
    NSMutableArray *_stations;//站点tableView的数据源
    
    NSUInteger _kCount;
    BOOL ret;
}
@property (strong, nonatomic) UIView *myHeaderView;

@property (nonatomic, strong) MyTimeView *myTimeView;
@end

@implementation RainViewController

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
        [RainObject cancelRequest];
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
    _headers = @[@"行政区划名称",@"1h雨量(mm)",@"3h雨量(mm)",@"6h雨量(mm)",@"24h雨量(mm)",@"72h雨量",@"警戒雨量(mm)"];
    _kCount = _headers.count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"实时雨情";

    
    //初始化headerView
    [self initData];
    UIView *tableViewHeader = [[UIView alloc] initWithFrame:(CGRect){0,0,_kCount * kWidth, kHeight}];
    tableViewHeader.backgroundColor = BG_COLOR;
    self.myHeaderView = tableViewHeader;
    
    for (int i=0; i<_kCount; i++) {
        HeaderView *headerView = [[HeaderView alloc] initWithFrame:CGRectMake(i*kWidth, 0, kWidth, kHeight)];
        headerView.num = _headers[i];
        [tableViewHeader addSubview:headerView];
    }
    
    
    _myTableView = [[UITableView alloc] initWithFrame:(CGRect){0,0,self.myHeaderView.frame.size.width,kScreen_height-64} style:UITableViewStylePlain];
    _myTableView.rowHeight = 44;
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){kWidth, 0,kScreen_Width - kWidth , kScreen_height-64}];
    [scrollView addSubview:_myTableView];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.contentSize = CGSizeMake(self.myHeaderView.frame.size.width, 0);
    [self.view addSubview:scrollView];
    
    self.myTimeView = [[MyTimeView alloc] initWithFrame:(CGRect){0,0,kWidth,kScreen_height-64}];
    self.myTimeView.listData = _stations;//数据源
    self.myTimeView.headTitle = @"监测站名称";
    [self.view addSubview:self.myTimeView];
    [self initBar];
    
    NSDate *now = [NSDate date];
    NSString *date_str = [self requestDate:now];
    [self refresh:date_str];

}

- (void)initBar
{
    UIView *leftView = [[UIView alloc] initWithFrame:(CGRect){0,0,70,20}];
    UIButton *filter_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    filter_btn.frame = (CGRect){0,0,20,20};
    [filter_btn setCorners:5.0];
    [filter_btn setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
    [filter_btn addTarget:self action:@selector(selectTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:filter_btn];
    
    //区域筛选
    UIButton *selct_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    selct_btn.frame = (CGRect){50,0,20,20};
    [selct_btn setCorners:5.0];
    [selct_btn setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [selct_btn addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
   // [leftView addSubview:selct_btn];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:filter_btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)refresh:(NSString *)date_str
{
 
    [SVProgressHUD showWithStatus:@"加载中..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if([RainObject fetchWithType:@"GetYqInfo" withArea:@"33" withDate:date_str withstart:@"0" withEnd:@"1100"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithSuccess:@"加载成功"];
                //将获取到得数据传递给tableView的数据源
                listData = [RainObject requestRainData];
                if (listData.count != 0) {
                    ret = YES;
                    sourceDatas = [NSMutableArray arrayWithArray:listData];
                    
                    _stations = [NSMutableArray arrayWithCapacity:sourceDatas.count];
                    for (NSDictionary *dic in sourceDatas) {
                        [_stations addObject:[dic objectForKey:@"Stnm"]];
                    }
                    //刷新左侧列表
                    [self.myTimeView refrushTableView:_stations];
                }
                [_myTableView reloadData];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithError:@"加载失败"];
                ret = NO;
            });
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - Private Method
//筛选按钮
- (void)filterAction:(UIButton *)button
{
    SelectViewController *select = [[SelectViewController alloc] init];
    select.delegate = self;
    [self.navigationController pushViewController:select animated:YES];
}

- (void)selectTimeAction:(UIButton *)btn
{
    CustomDateActionSheet *sheet = [[CustomDateActionSheet alloc] initWithTitle:@"时间选择" delegate:self];
    [sheet showInView:self.view];
}

//返回时间字符串
- (NSString *)requestDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date_str = [formatter stringFromDate:date];
    return date_str;
}



#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        CustomDateActionSheet *sheet = (CustomDateActionSheet *)actionSheet;
        [self refresh:sheet.selectedTime];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        RainCell *cell = (RainCell *)[[[NSBundle mainBundle] loadNibNamed:@"Rain" owner:self options:nil] lastObject];
        NSDictionary *dic = [listData objectAtIndex:indexPath.row];
        cell.stationName.text = [[dic objectForKey:@"Adnm"] isEqual:@""]?@"--" : [dic objectForKey:@"Stnm"];
        cell.oneHour.text = [[dic objectForKey:@"Last1Hours"] isEqual:@""] ? @"--" :[dic objectForKey:@"Last1Hours"];
        
        cell.threeHour.text = [[dic objectForKey:@"Last3Hours"] isEqual:@""] ? @"--" : [dic objectForKey:@"Last3Hours"];
        cell.sixHour.text = [[dic objectForKey:@"Last6Hours"] isEqual:@""] ? @"--" : [dic objectForKey:@"Last6Hours"];
        cell.threeDays.text = [[dic objectForKey:@"Last48Hours"] isEqual:@""] ? @"--" : [dic objectForKey:@"Last48Hours"];

        cell.today.text = [[dic objectForKey:@"Last24Hours"] isEqual:@""] ?@"--" : [dic objectForKey:@"Last24Hours"];
        cell.warn.text = [[dic objectForKey:@"WarningValue"] isEqual:@""] ?@"--" : [dic objectForKey:@"WarningValue"];
        return cell;
}

//这样的话，headView不随着cell滚动
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    UIView *headView = (UIView *)[[[NSBundle mainBundle] loadNibNamed:@"RainHeaderView" owner:self options:nil] lastObject];
//    headView.backgroundColor = BG_COLOR;
//    return headView;
    return self.myHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return kHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [listData objectAtIndex:indexPath.row];
    ChartViewController *chart = [[ChartViewController alloc] init];
    chart.title_name = dic[@"Stnm"];
    chart.stcd = dic[@"Stcd"];
    chart.requestType = @"GetStDayYL";
    chart.chartType = 2; //表示柱状图
    chart.functionType = FunctionSingleChart;
    [self.navigationController pushViewController:chart animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offSetY = _myTableView.contentOffset.y;//tableVIew的Y方向的偏移
    
    CGPoint timeOffSet = self.myTimeView.myTableView.contentOffset;
    
    timeOffSet.y = offSetY;
    
    self.myTimeView.myTableView.contentOffset = timeOffSet;
    if (offSetY == 0) {
        self.myTimeView.myTableView.contentOffset = CGPointZero;
    }
}

#pragma mark - SelectItemsDelegate

- (void)selectItemAction:(NSString *)area
{
    if ([area isEqualToString:@"全部"]) {
        //不做筛选
        listData = (NSArray *)sourceDatas;
    }else{
        NSMutableArray *countArr = [NSMutableArray array]; //重新复制一个可变数组，保证数组内部每个元素都可以循环到
        for (int i=0; i<sourceDatas.count; i++) {
            NSDictionary *dic = [sourceDatas objectAtIndex:i];
            NSString *str = [dic objectForKey:@"Adnm"];
            if ([str isEqualToString:area]) {
                [countArr addObject:dic];
            }
        }
        //将筛选好的数据赋值给tableView的数据源
        listData = (NSArray *)countArr;
    }
    
    [_myTableView reloadData];
}


@end
