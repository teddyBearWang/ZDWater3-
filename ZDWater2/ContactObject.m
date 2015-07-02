//
//  ContactObject.m
//  ZDWater2
//
//  Created by teddy on 15/7/2.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "ContactObject.h"
#import <AFNetworking.h>

static AFHTTPRequestOperation *operation = nil;
@implementation ContactObject

+ (BOOL)fetch
{
    BOOL ret = YES;
    
    //http://101.69.249.206:82/webserzj/data.ashx?t=GetContacts
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *parameters = @{@"t":@"GetContacts"};
    operation = [manager POST:URL parameters:parameters success:nil failure:nil];
    [operation waitUntilFinished];
    if (operation.responseData != nil) {
        datas = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
        ret = YES;
    }
    
    return ret;
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
