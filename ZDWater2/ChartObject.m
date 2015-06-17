
//
//  ChartObject.m
//  ZDWater
//
//  Created by teddy on 15/5/28.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "ChartObject.h"
//#import "ASIFormDataRequest.h"
#import <AFNetworking.h>

//http://115.236.2.245:38027/data.ashx?t=GetStDayYL&results=8217$2015-04-27%2016:35:25

@implementation ChartObject

/*
 *type: 请求方式
 *stcd: 测站编号
 *date:查询时间
 */
+ (BOOL)fetcChartDataWithType:(NSString *)type stcd:(NSString *)stcd WithDate:(NSString *)date
{
    __block BOOL ret = NO;
    
    NSString *str = [NSString stringWithFormat:@"%@$%@",stcd,date];
    NSDictionary *parameters = @{@"t":type,
                                 @"results":str};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestOperation *operation = [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //成功
    } failure:nil];
    [operation waitUntilFinished];
    
    if (operation.responseData != nil) {
        ret = YES;
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        
        if (x_Labels == nil) {
            x_Labels = [NSMutableArray array];
        }else if(x_Labels.count != 0){
            [x_Labels removeAllObjects];
        }
        
        if (y_values == nil) {
            y_values = [NSMutableArray array];
        }else if (y_values.count != 0){
            [y_values removeAllObjects];
        }
        for (int i=0; i<arr.count; i++) {
            NSDictionary *dic = [arr objectAtIndex:i];
            [x_Labels addObject:[dic objectForKey:@"time"]];
            [y_values addObject:[dic objectForKey:@"value"]];
        }
    }

    return ret;
}

/*
 *获取X轴上的数据数组
 */

static NSMutableArray *x_Labels = nil;
+ (NSMutableArray *)requestXLables
{
    return x_Labels;
}

/*
 *获取Y轴上的数据数组
 */

static NSMutableArray *y_values = nil;
+ (NSMutableArray *)requestYValues
{
    return y_values;
}

@end
