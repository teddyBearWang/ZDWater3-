//
//  LoginToken.m
//  ZDWater2
//
//  Created by teddy on 15/6/11.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "LoginToken.h"
#import <AFNetworking.h>

@implementation LoginToken

//http://101.69.249.206:82/webserzj/data.ashx?t=CheckUser&results=test$123$1.0.1

+(BOOL)fetchWithUser:(NSString *)user andPSW:(NSString *)psw withVersion:(NSString *)version
{
    BOOL ret = NO;
    
    NSString *str = [NSString stringWithFormat:@"%@$%@$%@",user,psw,version];
    NSDictionary *dic = @{@"t":@"CheckUser",
                          @"results":str};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    AFHTTPRequestOperation *operation = [manager POST:URL parameters:dic success:nil failure:nil];
    [operation waitUntilFinished];
    if (operation.responseData != 0) {
        data = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
        ret = YES;
    }
    return ret;
}

static NSArray *data = nil;
+ (NSArray *)requestData
{
    return data;
}


@end
