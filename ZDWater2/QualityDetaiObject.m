//
//  QualityDetaiObject.m
//  ZDWater
//
//  Created by teddy on 15/5/26.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "QualityDetaiObject.h"
//#import "ASIHTTPRequest.h"
#import <AFNetworking.h>

//http://115.236.2.245:38027/Data.ashx?t=GetSzInfoView&results=2015-04-25$2015-04-26$8202

@implementation QualityDetaiObject

static AFHTTPRequestOperation *operation = nil;
+ (BOOL)fetchWithType:(NSString *)type start:(NSString *)start end:(NSString *)end stcd:(NSString *)stcd
{
    __block BOOL ret = NO;
    
    NSString *str = [NSString stringWithFormat:@"%@$%@$%@",start,end,stcd];
 
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *parameter = @{@"t":type,
                                @"results":str};
    operation = [manager POST:URL parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:nil];
    [operation waitUntilFinished];
    if (operation.responseData != nil) {
        _datas = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        ret = YES;

    }
    return  ret;
}

static NSArray *_datas = nil;
+ (NSArray *)requestDetailData
{
    return _datas;
}

+ (void)cancelRequest
{
    if (operation != nil) {
        [operation cancel];
    }
}

@end
