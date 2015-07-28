//
//  WaterQualityCell.h
//  ZDWater2
//  *********水质**************
//  Created by teddy on 15/7/28.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterQualityCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *areaLabel;//行政区划

@property (nonatomic, weak) IBOutlet UILabel *level;//水质等级

@property (nonatomic, weak) IBOutlet UILabel *NHLabel;//氨氮

@property (nonatomic, weak) IBOutlet UILabel *pLabel;//总磷

@end
