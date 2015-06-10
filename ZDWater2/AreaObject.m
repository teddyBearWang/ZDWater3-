//
//  AreaObject.m
//  ZDWater
//
//  Created by teddy on 15/5/26.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "AreaObject.h"
//#import "ASIHTTPRequest.h"
#import <AFNetworking.h>

@implementation AreaObject


+ (BOOL) fetch
{
    __block BOOL ret = NO;
    
   // NSString *str = @"http://115.236.2.245:38027/Data.ashx?t=GetAdcdInfo";
//    NSURL *url = [NSURL URLWithString:str];
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    
//    [request setCompletionBlock:^{
//        //成功
//        if (request.responseStatusCode == 200) {
//            ret = YES;
//            NSData *data = request.responseData;
//            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//            areas = arr;
//        }
//    }];
//    
//    [request startSynchronous];
    
    NSDictionary *parameters = @{@"t":@"GetAdcdInfo"};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    AFHTTPRequestOperation *operation = [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
    } failure:nil];
    [operation waitUntilFinished];
    if (operation.responseData != nil) {
        ret = YES;
        areas = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
    }
    
    return ret;
}


static NSArray *areas = nil;
+ (NSArray *)requestDatas
{
    return areas;
}

@end
