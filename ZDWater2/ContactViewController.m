//
//  ContactViewController.m
//  ZDWater2
//   *********联系人************
//  Created by teddy on 15/6/3.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactCell.h"
#import "ContactObject.h"
#import "SVProgressHUD.h"

@interface ContactViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *contactList; //列表
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation ContactViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        //取消请求
        [ContactObject cancelRequest];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"联系人";
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.rowHeight = 50;
    
    [self getContact];
    
}

- (void)getContact
{
    [SVProgressHUD showErrorWithStatus:@"加载中..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([ContactObject fetch]) {
            [self updateUI];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithError:@"加载失败"];
            });
        }
    });
}

- (void)updateUI
{
    [SVProgressHUD dismissWithSuccess:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        contactList = [ContactObject requestDatas];
        [self.myTableView reloadData];
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableVIewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contactList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"contactCell";
    
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = (ContactCell *)[[[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:nil options:nil] lastObject];
    }
    NSDictionary *dic = contactList[indexPath.row];
    cell.user.text = [dic objectForKey:@"YHMC"];
    cell.phone.text = [dic objectForKey:@"TEL"];
    cell.img.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic objectForKey:@"imgurl"]]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *phone = [contactList[indexPath.row] objectForKey:@"TEL"];
    [self takePhone:phone];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)takePhone:(NSString *)phone
{
    if (phone.length != 0) {
        NSString *str = [NSString stringWithFormat:@"tel://%@",phone];
        NSURL *url = [NSURL URLWithString:str];
        
        UIWebView *callView = [[UIWebView alloc] init];
        
        [callView loadRequest:[NSURLRequest requestWithURL:url]];
        
        [self.view addSubview:callView];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"你选择的号码是空号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end
