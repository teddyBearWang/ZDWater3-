//
//  RainObject.m
//  ZDWater
//
//  Created by teddy on 15/5/25.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "RainObject.h"
//#import "ASIHTTPRequest.h"
#import <AFNetworking.h>
//#define  URL @"http://115.236.2.245:38027/data.ashx?t=GetYqInfo&results=33$2015-05-25$0$10000"

@implementation RainObject


+ (BOOL)fetchWithType:(NSString *)type withArea:(NSString *)adcd withDate:(NSString *)date withstart:(NSString *)start withEnd:(NSString *)end;
{
    __block BOOL ret = NO;
    
   // NSString *url_str = [NSString stringWithFormat:@"%@t=%@&results=%@$%@$%@$%@",URL,type,adcd,date,start,end];
    NSString *str = [NSString stringWithFormat:@"%@$%@$%@$%@",date,start,end];
   // NSURL *url = [NSURL URLWithString:url_str];
    
    /*
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        //成功
        if (request.responseStatusCode == 200) {
            ret = YES;
            NSData *json = (NSData *)request.responseData;
            NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableLeaves error:nil];
            
            //抛出去一个通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadCompleteNotification object:jsonArr];
        }
        
    }];
    
    [request setFailedBlock:^{
        //失败
    }];
    
    [request startAsynchronous];
    */
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *dic = @{@"t":type,
                          @"reeults":str};
    AFHTTPRequestOperation *operation = [manager POST:URL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:nil];
    [operation waitUntilFinished];
    if (operation.responseData != nil) {
        ret = YES;
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        
        //抛出去一个通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoadCompleteNotification object:jsonArr];
    }
    
    return ret;
}

@end
