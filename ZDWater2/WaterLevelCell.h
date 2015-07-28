//
//  WaterLevelCell.h
//  ZDWater2
//
//  Created by teddy on 15/7/28.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterLevelCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *areaLabel;//行政区划

@property (nonatomic, weak) IBOutlet UILabel *eightLabel;//8时水位

@property (nonatomic, weak) IBOutlet UILabel *currentLabel;//当前水位

@property (nonatomic, weak) IBOutlet UILabel *currentTime;//当前时间

@end
