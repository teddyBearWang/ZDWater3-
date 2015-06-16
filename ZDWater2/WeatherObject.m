//
//  WeatherObject.m
//  ZDWater2
//  ***********天气预报***************
//  Created by teddy on 15/6/5.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "WeatherObject.h"
//#import "ASIHTTPRequest.h"
#import <AFNetworking.h>
@implementation WeatherObject

static AFHTTPRequestOperation *operation = nil;
+ (BOOL)fetchWithArea:(NSString *)area
{
     BOOL ret = NO;
    
  
    NSDictionary *parameter = @{@"t":@"GetSWeather",
                                @"results":area};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    operation = [manager POST:URL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:nil];
    [operation waitUntilFinished];
    if (operation.responseData != nil) {
        ret = YES;
        datas = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
    }
    
    return ret;
}

static NSArray *datas = nil;
+ (NSArray *)requestData
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
