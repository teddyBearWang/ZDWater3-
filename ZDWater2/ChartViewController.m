//
//  ChartViewController.m
//  ZDWater2
//
//  Created by teddy on 15/6/3.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "ChartViewController.h"
#import "UUChart.h"
#import "ChartObject.h"
#import "DoubleChartObject.h"
#import "SVProgressHUD.h"

@interface ChartViewController ()<UUChartDataSource>
{
    UUChart *chartView;
    NSArray *x_Labels;
    NSArray *y_Values;
    UILabel *_showTimeLabel;// 显示时间label
    int screen_heiht; //屏幕高度
}

@end

@implementation ChartViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //强制屏幕横屏
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    
    //保存下屏幕竖着的时候的高度
    screen_heiht = self.view.frame.size.height;
    if (y_Values.count == 0 || x_Labels.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前没有可以显示的图表数据" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    [self initChartView];
    
}

//创建chartVIew
- (void)initChartView
{
    if (chartView) {
        [chartView removeFromSuperview];
        chartView = nil;
    }
    
    chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 40,
                                                                    screen_heiht, 240)
                                              withSource:self
                                               withStyle:self.chartType == 1?UUChartLineStyle: UUChartBarStyle];
    [chartView showInView:self.view];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置标题
    self.title = self.title_name;
    
    UIView *dateView = [self createSelectTimeView];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:dateView];
    self.navigationItem.rightBarButtonItem = item;
    
    NSString *date_str = [self requestDate:[NSDate date]];
    if (self.functionType == FunctionDoubleChart) {
        //表示折线图上多条线
        if ([DoubleChartObject fetchDOubleChartDataWithType:self.requestType stcd:self.stcd WithDate:date_str]) {
            x_Labels = [NSArray arrayWithArray:[DoubleChartObject requestXLables]];
            y_Values = [NSArray arrayWithArray:(NSArray *)[DoubleChartObject requestYValues]];
        }
    }else{
        //表示折线图上单条线
        if ([ChartObject fetcChartDataWithType:self.requestType stcd:self.stcd WithDate:date_str]) {
            x_Labels = [NSArray arrayWithArray:[ChartObject requestXLables]];
            y_Values = [NSArray arrayWithArray:(NSArray *)[ChartObject requestYValues]];
        }
    }
    
}

/*
//画单线
- (void)refreshUIWithSingleChartDate:(NSString *)date
{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([ChartObject fetcChartDataWithType:self.requestType stcd:self.stcd WithDate:date]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //
                [SVProgressHUD dismiss];
                x_Labels = [NSArray arrayWithArray:[DoubleChartObject requestXLables]];
                y_Values = [NSArray arrayWithArray:(NSArray *)[DoubleChartObject requestYValues]];
                
            });
        }else{
          dispatch_async(dispatch_get_main_queue(), ^{
              [SVProgressHUD dismissWithError:nil];
          });
        }
    });
}

//画双线
- (void)refreshDoubleDate:(NSString *)date
{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([DoubleChartObject fetchDOubleChartDataWithType:self.requestType stcd:self.stcd WithDate:date]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //
                [SVProgressHUD dismiss];
                x_Labels = [NSArray arrayWithArray:[DoubleChartObject requestXLables]];
                y_Values = [NSArray arrayWithArray:(NSArray *)[DoubleChartObject requestYValues]];
                [self initChartView];

            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithError:nil];
            });
        }
    });
}
 
 */

- (UIView *)createSelectTimeView
{
    UIView *bg_view = [[UIView alloc] initWithFrame:(CGRect){0,0,120,30}];
    bg_view.backgroundColor = [UIColor clearColor];
    UIButton *back_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    back_btn.frame = (CGRect){0,5,10,20};
    [back_btn setBackgroundImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    back_btn.tag = 201;
    [back_btn addTarget:self action:@selector(selectDateAction:) forControlEvents:UIControlEventTouchUpInside];
    [bg_view addSubview:back_btn];
    
    UIButton *next_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    next_btn.frame = (CGRect){110,5,10,20};
    [next_btn setBackgroundImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    next_btn.tag = 202;
    [next_btn addTarget:self action:@selector(selectDateAction:) forControlEvents:UIControlEventTouchUpInside];
    [bg_view addSubview:next_btn];
    
    _showTimeLabel = [[UILabel alloc] initWithFrame:(CGRect){20,0,80,30}];
    _showTimeLabel.backgroundColor = [UIColor clearColor];
    _showTimeLabel.textColor = [UIColor whiteColor];
    _showTimeLabel.text = [self requestDate:[NSDate date]];
    _showTimeLabel.font = [UIFont systemFontOfSize:15];
    [bg_view addSubview:_showTimeLabel];
    
    return bg_view;
}

//返回时间字符串
- (NSString *)requestDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date_str = [formatter stringFromDate:date];
    return date_str;
    
}

//返回时间字符串
- (NSDate *)requestDateFromString:(NSString *)date_str
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:date_str];
    return date;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//时间选择
- (void)selectDateAction:(UIButton *)btn
{
    NSDate *current = [self requestDateFromString:_showTimeLabel.text];
    if (btn.tag == 201) {
        //时间往前推一天
        NSDate *back_date = [current dateByAddingTimeInterval:-60*60*24];
        _showTimeLabel.text = [self requestDate:back_date];
    }else{
        //时间往后推一天
        NSDate *next_date = [current dateByAddingTimeInterval:60*60*24];
        _showTimeLabel.text = [self requestDate:next_date];
    }
    
    if (self.functionType == FunctionDoubleChart) {
        //表示折线图上多条线
        if ([DoubleChartObject fetchDOubleChartDataWithType:self.requestType stcd:self.stcd WithDate:_showTimeLabel.text]) {
            x_Labels = [NSArray arrayWithArray:[DoubleChartObject requestXLables]];
            y_Values = [NSArray arrayWithArray:(NSArray *)[DoubleChartObject requestYValues]];
        }
    }else{
        //表示折线图上单条线
        if ([ChartObject fetcChartDataWithType:self.requestType stcd:self.stcd WithDate:_showTimeLabel.text]) {
            x_Labels = [NSArray arrayWithArray:[ChartObject requestXLables]];
            y_Values = [NSArray arrayWithArray:(NSArray *)[ChartObject requestYValues]];
        }
    }

}

#pragma mark - UUChartDataSource

//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    return x_Labels;
}

//数值多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    @try {
        if (self.functionType == FunctionDoubleChart) {
            return y_Values;
        }else{
            //单条线
            return @[y_Values];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
}

#pragma mark 折线图专享功能
//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    if (index == 4) {
        return YES;
    }else{
        return NO;
    }
    
}

//判断显示竖线条
- (BOOL)UUChart:(UUChart *)chart ShowVericationLineAtIndex:(NSInteger)index
{
    if (index == 0) {
        return YES;
    }else{
        return NO;
    }
}

//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UUGreen,UURed,UUBrown];
}

@end
