//
//  WaterSituation.m
//  ZDWater
//
//  Created by teddy on 15/5/26.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "WaterSituation.h"
//#import "ASIHTTPRequest.h"
//#import "ASIFormDataRequest.h"
#import <AFNetworking.h>

@implementation WaterSituation


+ (BOOL)fetchWithType:(NSString *)type area:(NSString *)adcd date:(NSString *)date start:(NSString *)start end:(NSString *)end
{
    __block BOOL ret = NO;
  //  NSString *url_str = [NSString stringWithFormat:@"%@t=%@&results=%@$%@$%@$%@",URL,type,adcd,date,start,end];
    NSString *result = [NSString stringWithFormat:@"%@$%@$%@$%@",adcd,date,start,end];
    /*
    NSURL *url = [NSURL URLWithString:URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:type forKey:@"t"];
    [request setPostValue:result forKey:@"results"];
    
    [request setCompletionBlock:^{
        //成功
        if (request.responseStatusCode == 200) {
            ret = YES;
            NSData *json = (NSData *)request.responseData;
            NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableLeaves error:nil];
            waterData = jsonArr;
        }
        
    }];
    
    [request setFailedBlock:^{
        //失败
    }];
    
    [request startSynchronous];
    */
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameter = @{@"t":type,
                                @"results":result};
    AFHTTPRequestOperation *operation = [manager POST:URL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
@end
