//
//  QiXiangObject.m
//  ZDWater2
//
//  Created by teddy on 15/6/8.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "QiXiangObject.h"
//#import "ASIFormDataRequest.h"
//#import "ASIHTTPRequest.h"
#import <AFNetworking.h>

@implementation QiXiangObject

static AFHTTPRequestOperation *operation = nil;
+ (BOOL)fetchWithType:(NSString *)type
{
     BOOL ret = NO;

    
    //http://101.69.249.206:82/webserzj/data.ashx?t=GetHtmlSource&results=wxyt$
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameter = @{@"t":@"GetHtmlSource",
                                @"results":type};
    operation = [manager POST:Weather_url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
