//
//  ContactObject.h
//  ZDWater2
//  **********联系人***************
//  Created by teddy on 15/7/2.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactObject : NSObject

+ (BOOL)fetch;

+ (NSArray *)requestDatas;

+ (void)cancelRequest;

@end
