//
//  LoginToken.h
//  ZDWater2
//
//  Created by teddy on 15/6/11.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginToken : NSObject
+(BOOL)fetchWithUser:(NSString *)user andPSW:(NSString *)psw withVersion:(NSString *)version;

+ (NSArray *)requestData;
@end
