//
//  LoginViewController.m
//  ZDWater2
//
//  Created by teddy on 15/6/3.
//  Copyright (c) 2015年 teddy. All rights reserved.
//

#import "LoginViewController.h"
#import "MenuViewController.h"
#import "SVProgressHUD.h"
#import "LoginToken.h"

@interface LoginViewController ()
- (IBAction)loginAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *pswField;

- (IBAction)tapbackground:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"登陆";
    self.view.backgroundColor = BG_COLOR;
    
    self.pswField.secureTextEntry = YES;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)loginAction:(id)sender
{
    if (self.username.text.length == 0 || self.pswField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名或者密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        [self checkUserAction];
    }
}

- (void)checkUserAction
{
    [SVProgressHUD showWithStatus:@"登录中.."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([LoginToken fetchWithUser:self.username.text andPSW:self.pswField.text withVersion:@"1.0.1"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSArray *arr = [LoginToken requestData];
                    if (arr.count != 0) {
                        [SVProgressHUD dismissWithSuccess:nil];
                        [self loginAccess];
                    }else{
                        [SVProgressHUD dismissWithError:@"登录失败"];
                    }
                });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithError:@"登录失败"];
            });
        }
    });
}

- (void)loginAccess
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MenuViewController *menu = (MenuViewController *)[story instantiateViewControllerWithIdentifier:@"menu"];
    [self.navigationController pushViewController:menu animated:YES];
}

- (IBAction)tapbackground:(id)sender
{
    [self.username resignFirstResponder];
    [self.pswField resignFirstResponder];
}
@end
