//
//  DeviceConnectFailedViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/19.
//

#import "DeviceConnectFailedViewController.h"

@interface DeviceConnectFailedViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *causeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonThreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonFourLabel;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;

@end

@implementation DeviceConnectFailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.titleLabel.text = LocalString(@"设备添加失败");
    self.causeTitleLabel.text = LocalString(@"配网失败的常见原因：");
    self.reasonOneLabel.text = LocalString(@"1.请选择 2.4G Wi-Fi，不要选择 5G Wi-Fi");
    self.reasonTwoLabel.text = LocalString(@"2.请检查 Wi-Fi 密码是否输入正确");
    self.reasonThreeLabel.text = LocalString(@"3.请确认设备已进入配网模式并显示 4 位数字");
    self.reasonFourLabel.text = LocalString(@"4.请检查 Wi-Fi 路由器状态是否允许正常联网");
    [self.retryBtn setTitle:LocalString(@"重试") forState:UIControlStateNormal];
    [self.exitBtn setTitle:LocalString(@"退出配网") forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)closeBtnClick:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)backBtnClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)restartClick:(id)sender {
    
    
    
    // 返回到FindDeviceViewController
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:NSClassFromString(@"FindDeviceViewController")]) {
           [[NSNotificationCenter defaultCenter] postNotificationName:@"faildBackChange" object:nil];
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    
    // 如果导航栈中没有找到FindDeviceViewController，则pop到根视图
    NSLog(@"⚠️ 未在导航栈中找到FindDeviceViewController，返回根视图");
    [self.navigationController popToRootViewControllerAnimated:YES];
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
