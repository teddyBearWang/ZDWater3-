//
//  GateCell.h
//  ZDWater2
//
//  Created by teddy on 15/7/28.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GateCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;//测站名称

@property (nonatomic, weak) IBOutlet UILabel *kCountLabel;//闸口

@property (nonatomic, weak) IBOutlet UILabel *kOpenCountLabel;//已开个数

@end
