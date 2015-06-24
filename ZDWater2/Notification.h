//
//  Notification.h
//  ZDWater2
//
//  Created by teddy on 15/6/24.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

+ (BOOL)fetch;

+ (NSArray *)requestDatas;

+ (void)cancelRequest;

@end
