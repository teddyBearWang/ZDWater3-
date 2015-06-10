//
//  WaterQuality.m
//  ZDWater
//
//  Created by teddy on 15/5/25.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "WaterQuality.h"
#import <AFNetworking.h>

//#define URL @"http://115.236.2.245:38027/Data.ashx?t=GetSzInfo&results=2015-04-25$2015-04-26"

@implementation WaterQuality


//是否获取数据成功
+ (BOOL )FetchWithType:(NSString *)type withStrat:(NSString *)start withEnd:(NSString *)end;
{
    __block BOOL ret = 0;
   // NSString *url_str = [NSString stringWithFormat:@"%@t=%@&results=%@$%@",URL,type,start,end];
    NSString *str = [NSString stringWithFormat:@"%@$%@",start,end];
    
    /*
    NSURL *url = [NSURL URLWithString:url_str];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        //成功
        if (request.responseStatusCode == 200) {
            ret = YES;
            NSData *json = (NSData *)request.responseData;
            NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableLeaves error:nil];
            _waterData = jsonArr;

        }
        
    }];
    
    [request setFailedBlock:^{
        //失败
        ret = NO;
    }];
    
    [request startSynchronous];
    */
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameter = @{@"t":type,
                                @"results":str};
    AFHTTPRequestOperation *operation = [manager POST:URL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:nil];
    [operation waitUntilFinished];
    if (operation.responseData != 0) {
        ret = YES;
        _waterData = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
    }
    
    return ret;
}


static NSArray *_waterData = nil;
+ (NSArray *)RequestData
{
    return _waterData;
}

@end
