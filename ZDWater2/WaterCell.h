//
//  WaterCell.h
//  ZDWater
//
//  Created by teddy on 15/5/18.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *areaName; //测站

@property (nonatomic, strong) IBOutlet UILabel *currentSpeed; //最新水位
@property (nonatomic, strong) IBOutlet UILabel *speed; //预警水位

@end
