//
//  NotificationDetailController.h
//  ZDWater2
//
//  Created by teddy on 15/6/24.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationDetailController : UIViewController

@property (nonatomic, strong) NSString *title_name;
@property (nonatomic, strong) NSString *time; //发布时间
@property (nonatomic, strong) NSString *user;//发布人
@property (nonatomic, strong) NSString *conetnt;//内容
@end
