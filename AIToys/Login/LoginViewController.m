//
//  LoginViewController.m
//  AIToys
//
//  Created by qdkj on 2025/6/17.
//

#import "LoginViewController.h"
#import "AcountLoginViewController.h"
#import "RegistViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@property (weak, nonatomic) IBOutlet UILabel *slogoLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hj_NavIsHidden = YES;
    self.bgImgView.image = [PublicObj createImageSize:self.bgView.size gradientColors:@[UIColorFromRGB(0x1EAAFD),UIColorFromRGB(0xD1EEFF),UIColorFromRGB(0xFFFFFF)] percentage:@[@(0),@(0.71),@(1)] gradientType:GradientFromTopToBottom];
    [self.loginBtn setTitle:NSLocalizedString(@"登录", @"") forState:0];
    [self.registerBtn setTitle:NSLocalizedString(@"注册", @"") forState:0];
    self.slogoLabel.text = LocalString(@"专注蒙氏教育，发掘孩子独特天赋");
    if([CoreArchive boolForKey:KACCOUNT_ISCANCEL]){
        [LGBaseAlertView showAlertWithTitle:@"" content:LocalString(@"账号已删除，请重新登录") cancelBtnStr:nil confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
            if (isValue){
                [CoreArchive setBool:NO key:KACCOUNT_ISCANCEL];
            }
        }];
    }
}

//登录
- (IBAction)loginBtnClick:(UIButton *)sender {
    AcountLoginViewController *VC = [AcountLoginViewController new];
    [self.navigationController pushViewController:VC animated:YES];
    
//    //埋点：点击登录
//    [[AnalyticsManager sharedManager]reportEventWithName:@"tap_login" level1:@"LoginVC" level2:@"" level3:@"" reportTrigger:@"" properties:nil completion:^(BOOL success, NSString * _Nullable message) {
//            
//    }];
}

//注册
- (IBAction)registerBtnClick:(UIButton *)sender {
    RegistViewController *VC = [RegistViewController new];
    VC.type = EmailType_regist;
    [self.navigationController pushViewController:VC animated:YES];
//    //埋点：点击注册
//    [[AnalyticsManager sharedManager]reportEventWithName:@"tap_register" level1:@"LoginVC" level2:@"" level3:@"" reportTrigger:@"" properties:@{@"accessEntrance":@"startPage"} completion:^(BOOL success, NSString * _Nullable message) {
//            
//    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent; // 或UIStatusBarStyleDefault
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
