//
//  DeviceConnectFailedViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/19.
//

#import "DeviceConnectFailedViewController.h"
#import "ATLanguageHelper.h"

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
    BOOL isRTL = [ATLanguageHelper isRTLLanguage];
    self.view.semanticContentAttribute = isRTL ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.causeTitleLabel.numberOfLines = 0;
    self.causeTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.retryBtn.titleLabel.numberOfLines = 2;
    self.retryBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.retryBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.exitBtn.titleLabel.numberOfLines = 2;
    self.exitBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.exitBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.text = LocalString(@"设备添加失败");
    self.causeTitleLabel.text = LocalString(@"配网失败的常见原因：");
    NSString *reasonText = [LocalString(@"1.请选择2.4g的wifi，请不要选择5G的wifi \\n2.核对wifi密码是否填写正确 \\n3.请确认设备是否进入配网状态，并显示4位数字 \\n4.请检查wifi路由状态，是否可以正常联网") stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8.0;
    paragraphStyle.alignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.reasonOneLabel.attributedText = [[NSAttributedString alloc] initWithString:reasonText attributes:@{
        NSParagraphStyleAttributeName: paragraphStyle,
        NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7],
        NSFontAttributeName: [UIFont fontWithName:@"SFProRounded-Regular" size:14] ?: [UIFont systemFontOfSize:14]
    }];
    self.reasonOneLabel.numberOfLines = 0;
    self.reasonOneLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.reasonTwoLabel.hidden = YES;
    self.reasonThreeLabel.hidden = YES;
    self.reasonFourLabel.hidden = YES;
    [self.retryBtn setTitle:LocalString(@"重试") forState:UIControlStateNormal];
    [self.exitBtn setTitle:LocalString(@"退出配网") forState:UIControlStateNormal];
    [self applyLayoutForCurrentLanguage];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)applyLayoutForCurrentLanguage
{
    BOOL isRTL = [ATLanguageHelper isRTLLanguage];
    NSTextAlignment contentAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.causeTitleLabel.textAlignment = contentAlignment;
    self.retryBtn.contentHorizontalAlignment = isRTL ? UIControlContentHorizontalAlignmentRight : UIControlContentHorizontalAlignmentCenter;
    self.retryBtn.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
    self.exitBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.exitBtn.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12);
    if (@available(iOS 15.0, *)) {
        self.retryBtn.configuration.title = LocalString(@"重试");
        self.exitBtn.configuration.title = LocalString(@"退出配网");
    }
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
