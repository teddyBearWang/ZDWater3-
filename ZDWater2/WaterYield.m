//
//  WaterYield.m
//  ZDWater
//
//  Created by teddy on 15/5/28.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "WaterYield.h"
//#import "ASIHTTPRequest.h"
#import <AFNetworking.h>

@implementation WaterYield


+ (BOOL)fetchWithType:(NSString *)type date:(NSString *)date
{
    __block BOOL ret;
    
    /*
    NSString *str = [NSString stringWithFormat:@"%@t=%@&results=%@",URL,type,date];
    
    NSURL *url = [NSURL URLWithString:str];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        //成功
        if (request.responseStatusCode == 200) {
            ret = YES;
            NSData *data = request.responseData;
            NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            datas = arr;
        }
    }];
    
    [request setFailedBlock:^{
        //失败
        ret = NO;
    }];
    [request startSynchronous];
    */
    
    NSDictionary *parameters = @{@"t":type,
                                 @"results":date};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    AFHTTPRequestOperation *operation = [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

@end
