//
//  RainCell.h
//  ZDWater2
//
//  Created by teddy on 15/6/3.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RainCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *stationName;//测站名字
@property (weak, nonatomic) IBOutlet UILabel *oneHour;//1h雨量
@property (weak, nonatomic) IBOutlet UILabel *threeHour;//3h雨量
@property (weak, nonatomic) IBOutlet UILabel *sixHour;//6h雨量
@property (weak, nonatomic) IBOutlet UILabel *today;//24小时雨量
@property (weak, nonatomic) IBOutlet UILabel *threeDays;//72小时雨量
@property (weak, nonatomic) IBOutlet UILabel *warn;//警戒雨量


@end
