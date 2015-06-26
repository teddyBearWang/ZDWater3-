//
//  Notification.m
//  ZDWater2
//
//  Created by teddy on 15/6/24.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "Notification.h"
#import <AFNetworking.h>

@implementation Notification

static AFHTTPRequestOperation *operation = nil;
+ (BOOL)fetch
{
    BOOL ret = NO;
    
    
    //http://101.69.249.206:82/webserzj/data.ashx?t=GetNewsList
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameter = @{@"t":@"GetNewsList"};
    operation = [manager POST:URL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:nil];
    [operation waitUntilFinished];
    if (operation.responseData != nil) {
        ret = YES;
        datas = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
    }
    return YES;
}

static NSArray *datas = nil;
+ (NSArray *)requestDatas
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

