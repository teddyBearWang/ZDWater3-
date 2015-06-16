//
//  GateObject.m
//  ZDWater
//
//  Created by teddy on 15/5/28.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "GateObject.h"
//#import "ASIFormDataRequest.h"
#import <AFNetworking.h>

@implementation GateObject

static  AFHTTPRequestOperation *operation = nil;
+ (BOOL)fetchWithType:(NSString *)type
{
    __block BOOL ret = NO;

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *parameters = @{@"t":type};
    operation = [manager POST:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:nil];
    [operation waitUntilFinished];
    if (operation.responseData != nil) {
        ret = YES;
        datas = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
    }
    return ret;
}


static NSArray *datas = nil;
+ (NSArray *)requestGateDatas
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
