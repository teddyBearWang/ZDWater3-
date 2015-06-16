//
//  WaterSituation.m
//  ZDWater
//
//  Created by teddy on 15/5/26.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "WaterSituation.h"
#import <AFNetworking.h>

@implementation WaterSituation

static  AFHTTPRequestOperation *operation = nil;
+ (BOOL)fetchWithType:(NSString *)type area:(NSString *)adcd date:(NSString *)date start:(NSString *)start end:(NSString *)end
{
     BOOL ret = NO;
    NSString *result = [NSString stringWithFormat:@"%@$%@$%@$%@",adcd,date,start,end];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameter = @{@"t":type,
                                @"results":result};
    operation = [manager POST:URL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:nil];
    [operation waitUntilFinished];
    if (operation.responseData != nil) {
        ret = YES;
        waterData = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
    }
    
    return ret;
}

static NSArray *waterData = nil;
+ (NSArray *)requestWaterData
{
    return waterData;
}

+ (void)cancelRequest
{
    if (operation != nil) {
        [operation cancel];
    }
}
@end
