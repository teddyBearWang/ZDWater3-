//
//  WaterYield.m
//  ZDWater
//
//  Created by teddy on 15/5/28.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "WaterYield.h"
#import <AFNetworking.h>

@implementation WaterYield

static AFHTTPRequestOperation *operation = nil;
+ (BOOL)fetchWithType:(NSString *)type date:(NSString *)date
{
     BOOL ret;

    
    NSDictionary *parameters = @{@"t":type,
                                 @"results":date};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    operation = [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:nil];
    [operation waitUntilFinished];
    if (operation.responseData != nil) {
        ret = YES;
        datas = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
    }
    return ret;
    
}

static NSArray *datas = nil;
+ (NSArray *)requestWithDatas
{
    return datas;
}

+ (void)cancelRequest
{
    if (operation != nil) {
        [operation cancel];
    }
}

@end
