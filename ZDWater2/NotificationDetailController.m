//
//  NotificationDetailController.m
//  ZDWater2
//
//  Created by teddy on 15/6/24.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "NotificationDetailController.h"

@interface NotificationDetailController ()<UITextViewDelegate>

@end

@implementation NotificationDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = self.title_name;
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    UIView *lable_view = [[UIView alloc] initWithFrame:(CGRect){-5,0,self.view.frame.size.width+10,50}];
    lable_view.backgroundColor = BG_COLOR;
    lable_view.layer.borderColor = [UIColor blackColor].CGColor;
    lable_view.layer.borderWidth = 1.0;
    [self.view addSubview:lable_view];
    
    UILabel *title_label = [[UILabel alloc] initWithFrame:(CGRect){30,10,self.view.frame.size.width,30}];
    title_label.text = [NSString stringWithFormat:@"发布人: %@  发布时间: %@",self.user,self.time];
    title_label.font = [UIFont systemFontOfSize:14];
    [lable_view addSubview:title_label];
    
    UITextView *detail_text = [[UITextView alloc] initWithFrame:(CGRect){5,lable_view.frame.size.height,[UIScreen mainScreen].bounds.size.width - 10,[UIScreen mainScreen].bounds.size.height - lable_view.frame.size.height-64}];
    detail_text.backgroundColor = BG_COLOR;
    detail_text.showsVerticalScrollIndicator = YES;
    detail_text.scrollEnabled = YES;
    detail_text.text = self.conetnt;
    [self.view addSubview:detail_text];
    
    //获取内容高度
    CGSize size = [detail_text.text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 10, 9999999.0f) lineBreakMode:NSLineBreakByClipping];
    [detail_text setContentSize:size];
    if (detail_text.contentSize.height >= detail_text.frame.size.height) {
        detail_text.userInteractionEnabled = YES;

    }
}


@end
