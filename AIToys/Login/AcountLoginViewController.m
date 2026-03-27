//
//  AcountLoginViewController.m
//  AIToys
//
//  Created by qdkj on 2025/6/20.
//

#import "AcountLoginViewController.h"
#import "RegistViewController.h"
#import "MyTabBarController.h"
#import "UserPermmitVC.h"
#import "ATFontManager.h"
#import "NegotiateViewController.h"
#import "ATLanguageHelper.h"

@interface AcountLoginViewController ()<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountLabH;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UILabel *pwdNameLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdLabH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBtnRight;

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIImageView *agreeImg;
@property (weak, nonatomic) IBOutlet UITextView *agreeTextView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetBtn;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;

@end

@implementation AcountLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    if (kMyUser.email) {
        self.accountTextField.text = kMyUser.email;
        self.accountNameLab.hidden = NO;
        self.accountLabH.constant = 15;
    }
//    if (kMyUser.passWord) {
//        self.pwdTextField.text = kMyUser.passWord;
//        self.pwdNameLab.hidden = NO;
//        self.pwdLabH.constant = 15;
//    }
    if(self.accountTextField.text.length > 0 && self.pwdTextField.text.length > 0){
        [PublicObj makeButtonEnable:self.loginBtn];
    }else{
        [PublicObj makeButtonUnEnable:self.loginBtn];
    }
}

-(void)setUpUI{
    BOOL isRTL = [ATLanguageHelper isRTLLanguage];
    self.accountTextField.delegate = self;
    self.pwdTextField.delegate = self;
    self.agreeTextView.delegate =  self;
    self.titleLabel.text = LocalString(@"登录");
    self.accountNameLab.text = LocalString(@"账号");
    self.accountTextField.placeholder = LocalString(@"账号");
    self.pwdNameLab.text = LocalString(@"密码");
    self.pwdTextField.placeholder = LocalString(@"密码");
    self.accountTextField.textAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.pwdTextField.textAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    [self.loginBtn setTitle:LocalString(@"登录") forState:0];
    [self.forgetBtn setTitle:LocalString(@"忘记密码") forState:0];
    
    self.agreeTextView.attributedText = [self agreementAttributedText];
    self.agreeTextView.editable = NO;
    self.agreeTextView.selectable = YES;
    [self setRightBtn];
    self.pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
}


- (NSAttributedString *)agreementAttributedText {
    NSString *languageCode = [NSLocale preferredLanguages].firstObject.lowercaseString ?: @"en";
    NSArray<NSDictionary<NSString *, NSString *> *> *segments = nil;
    if ([languageCode hasPrefix:@"fr"]) {
        segments = @[
            @{@"text": @"J'accepte la "},
            @{@"text": @"Politique de Confidentialité", @"link": @"privacyPolicy://"},
            @{@"text": @", l'"},
            @{@"text": @"Accord Utilisateur", @"link": @"userProtocol://"},
            @{@"text": @", l'"},
            @{@"text": @"Accord Enfant", @"link": @"ChildAgreement://"},
            @{@"text": @" et l'"},
            @{@"text": @"Accord de Création", @"link": @"creativeAgreement://"}
        ];
    } else if ([languageCode hasPrefix:@"de"]) {
        segments = @[
            @{@"text": @"Ich stimme der "},
            @{@"text": @"Datenschutzerklärung", @"link": @"privacyPolicy://"},
            @{@"text": @", der "},
            @{@"text": @"Nutzungsvereinbarung", @"link": @"userProtocol://"},
            @{@"text": @", der "},
            @{@"text": @"Kindervereinbarung", @"link": @"ChildAgreement://"},
            @{@"text": @" und der "},
            @{@"text": @"Kreativvereinbarung", @"link": @"creativeAgreement://"},
            @{@"text": @" zu"}
        ];
    } else {
        segments = @[
            @{@"text": @"同意"},
            @{@"text": LocalString(@"隐私政策") ?: @"", @"link": @"privacyPolicy://"},
            @{@"text": @"、"},
            @{@"text": LocalString(@"用户协议") ?: @"", @"link": @"userProtocol://"},
            @{@"text": @"、"},
            @{@"text": LocalString(@"儿童协议") ?: @"", @"link": @"ChildAgreement://"},
            @{@"text": @"、"},
            @{@"text": LocalString(@"创作协议") ?: @"", @"link": @"creativeAgreement://"}
        ];
        if ([languageCode hasPrefix:@"en"]) {
            segments = @[
                @{@"text": @"Agree to the "},
                @{@"text": @"Privacy Policy", @"link": @"privacyPolicy://"},
                @{@"text": @", "},
                @{@"text": @"User Agreement", @"link": @"userProtocol://"},
                @{@"text": @", "},
                @{@"text": @"Children's Agreement", @"link": @"ChildAgreement://"},
                @{@"text": @", and "},
                @{@"text": @"Creative Agreement", @"link": @"creativeAgreement://"}
            ];
        } else if ([languageCode hasPrefix:@"ar"]) {
            segments = @[
                @{@"text": @"الموافقة على "},
                @{@"text": @"سياسة الخصوصية", @"link": @"privacyPolicy://"},
                @{@"text": @" و"},
                @{@"text": @"اتفاقية المستخدم", @"link": @"userProtocol://"},
                @{@"text": @" و"},
                @{@"text": @"اتفاقية الطفل", @"link": @"ChildAgreement://"},
                @{@"text": @" و"},
                @{@"text": @"اتفاقية الإبداع", @"link": @"creativeAgreement://"}
            ];
        } else if ([languageCode hasPrefix:@"es"]) {
            segments = @[
                @{@"text": @"Acepto la "},
                @{@"text": @"Política de privacidad", @"link": @"privacyPolicy://"},
                @{@"text": @", el "},
                @{@"text": @"Acuerdo de usuario", @"link": @"userProtocol://"},
                @{@"text": @", el "},
                @{@"text": @"Acuerdo infantil", @"link": @"ChildAgreement://"},
                @{@"text": @" y el "},
                @{@"text": @"Acuerdo de creación", @"link": @"creativeAgreement://"}
            ];
        }
    }

    NSMutableString *fullText = [NSMutableString string];
    NSMutableArray<NSDictionary<NSString *, id> *> *linkRanges = [NSMutableArray array];
    for (NSDictionary<NSString *, NSString *> *segment in segments) {
        NSString *segmentText = segment[@"text"] ?: @"";
        NSRange range = NSMakeRange(fullText.length, segmentText.length);
        [fullText appendString:segmentText];
        if (segment[@"link"]) {
            [linkRanges addObject:@{@"range": [NSValue valueWithRange:range], @"link": segment[@"link"]}];
        }
    }

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:fullText];
    [attrStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGBA(000000, 0.5) range:NSMakeRange(0, fullText.length)];
    for (NSDictionary<NSString *, id> *item in linkRanges) {
        NSRange range = [item[@"range"] rangeValue];
        [attrStr addAttribute:NSForegroundColorAttributeName value:mainColor range:range];
        [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
        [attrStr addAttribute:NSLinkAttributeName value:item[@"link"] range:range];
    }
    return attrStr;
}

//设置右侧按钮
-(void)setRightBtn{
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 40, 44)];
    [rightButton setTitle:LocalString(@"注册") forState:UIControlStateNormal];
    [rightButton setTitleColor:mainColor forState:UIControlStateNormal];
    rightButton.titleLabel.font = [ATFontManager systemFontOfSize:15];
    rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rightButton addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)regist{
    RegistViewController *VC = [RegistViewController new];
    VC.type = EmailType_regist;
    [self.navigationController pushViewController:VC animated:YES];
    //埋点：点击注册
//    [[AnalyticsManager sharedManager]reportEventWithName:@"tap_register" level1:@"LoginVC" level2:@"" level3:@"" reportTrigger:@"" properties:@{@"accessEntrance":@"loginPage"} completion:^(BOOL success, NSString * _Nullable message) {
//            
//    }];
}

//查看明文密码
- (IBAction)viewPwd:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.pwdTextField.secureTextEntry = !self.pwdTextField.secureTextEntry;
}

//同意协议
- (IBAction)agreeBtnClick:(UIButton *)sender {
    self.agreeImg.highlighted = !self.agreeImg.highlighted;
}

//登录
- (IBAction)loginBtnClick:(UIButton *)sender {
    if(!self.agreeImg.highlighted){
        [MBProgressHUD showTipMessageInView:LocalString(@"请勾选协议") ];
        return;
    }
    if(![self.accountTextField.text validateForRegex:[NSString emailRegex]]) {
        //格式错误
        [MBProgressHUD showErrorMessage:LocalString(@"请输入正确的邮箱地址")];
        return;
    }
    [self showHud];
    WEAK_SELF
    [[ThingSmartUser sharedInstance] loginByEmail:Country_Code email:self.accountTextField.text password:self.pwdTextField.text success:^{
        //登录平台账号
        [weakSelf loginSaas];
    } failure:^(NSError *error) {
        [weakSelf hiddenHud];
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
    
    
}

- (void)loginSaas{
    WEAK_SELF
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSString *uid = [ThingSmartUser sharedInstance].uid;
    [param setObject: uid forKey:@"username"];
    [param setObject: [[uid md5String] lowercaseString] forKey:@"password"];
    [param setObject: @(1) forKey:@"autoRegister"];
    [[APIManager shared] POSTJSON:[APIPortConfiguration getLoginUrl] parameter:param success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        [weakSelf hiddenHud];
//        [SVProgressHUD showSuccessWithStatus:@"Login Successfully"];

        // 埋点上报：登录结果
            [[AnalyticsManager sharedManager]reportEventWithName:@"login_result" level1:kAnalyticsLevel1_Home level2:@"" level3:@"" reportTrigger:@"返回登录结果时" properties:@{@"loginResult":@"success"} completion:^(BOOL success, NSString * _Nullable message) {
                            
                    }];

        kMyUser.email = weakSelf.accountTextField.text;
        kMyUser.passWord = weakSelf.pwdTextField.text;
        [UserInfo saveMyUser];
        //第一次启动app
        if (![[NSUserDefaults standardUserDefaults] boolForKey:KEY_ISFIRSTLAUNCH]) {
            //权限页
            UserPermmitVC *VC = [[UserPermmitVC alloc] init];
            [self.navigationController pushViewController:VC animated:YES];
        } else {
            //进入首页
            MyTabBarController *tabbar = [MyTabBarController new];
            [UIApplication sharedApplication].keyWindow.rootViewController = tabbar;
            [[AnalyticsManager sharedManager]reportEventWithName:@"enter_home" level1:kAnalyticsLevel1_Home level2:@"" level3:@"" reportTrigger:@"进入首页时" properties:nil completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
        }
        
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        [weakSelf hiddenHud];
    }];
}

//忘记密码
- (IBAction)forgetBtnClick:(UIButton *)sender {
    RegistViewController *VC = [RegistViewController new];
    VC.type = EmailType_forgetPwd;
    VC.numStr = self.accountTextField.text;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark -- UITextFieldDelegate

//账号输入改变
- (IBAction)accountTextFieldChanged:(UITextField *)sender {
    if(sender.text.length > 0){
        self.accountNameLab.hidden = NO;
        self.accountLabH.constant = 15;
        
    }else{
        self.accountNameLab.hidden = YES;
        self.accountLabH.constant = 0;
    }
}

//密码输入改变
- (IBAction)pwdTextFieldChanged:(UITextField *)sender {
    if(sender.text.length > 0){
        self.pwdNameLab.hidden = NO;
        self.pwdLabH.constant = 15;
        self.viewBtn.hidden = NO;
        
    }else{
        self.pwdNameLab.hidden = YES;
        self.pwdLabH.constant = 0;
        self.viewBtn.hidden = YES;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if([textField isEqual:self.pwdTextField]){
        self.viewBtn.hidden = textField.text.length == 0;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.viewBtn.hidden = YES;
    if(self.accountTextField.text.length > 0 && self.pwdTextField.text.length > 0) {
        [PublicObj makeButtonEnable:self.loginBtn];
    }else{
        [PublicObj makeButtonUnEnable:self.loginBtn];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    
    
    
    
    if ([URL.scheme isEqualToString:@"privacyPolicy"]) {
        //隐私政策
        NSLog(@"点击了隐私政策");
        [self pushToNegotiateVCWithTitle:NSLocalizedString(@"隐私政策", @"") type:0];
        //埋点：点击协议
        [[AnalyticsManager sharedManager]reportEventWithName:@"tap_check_agreement_doc" level1:@"AccountLoginVC" level2:@"" level3:@"" reportTrigger:@"点击查看协议文档时" properties:@{@"fileType":@1} completion:^(BOOL success, NSString * _Nullable message) {
                
        }];
        return NO;
        
    } else if ([URL.scheme isEqualToString:@"userProtocol"]) {
        //用户协议
        NSLog(@"点击了用户协议");
        [self pushToNegotiateVCWithTitle:NSLocalizedString(@"用户协议", @"") type:1];
        //埋点：点击协议
        [[AnalyticsManager sharedManager]reportEventWithName:@"tap_check_agreement_doc" level1:@"AccountLoginVC" level2:@"" level3:@"" reportTrigger:@"点击查看协议文档时" properties:@{@"fileType":@2} completion:^(BOOL success, NSString * _Nullable message) {
                
        }];
        return NO;
        
    } else if ([URL.scheme isEqualToString:@"ChildAgreement"]) {
        //儿童协议
        NSLog(@"点击了儿童协议");
        [self pushToNegotiateVCWithTitle:NSLocalizedString(@"儿童协议", @"") type:2];
        //埋点：点击协议
        [[AnalyticsManager sharedManager]reportEventWithName:@"tap_check_agreement_doc" level1:@"AccountLoginVC" level2:@"" level3:@"" reportTrigger:@"点击查看协议文档时" properties:@{@"fileType":@3} completion:^(BOOL success, NSString * _Nullable message) {
                
        }];
        return NO;
        
    } else if ([URL.scheme isEqualToString:@"creativeAgreement"]) {
        //创作协议
        NSLog(@"点击了创作协议");
        [self pushToNegotiateVCWithTitle:NSLocalizedString(@"创作协议", @"") type:3];
        //埋点：点击协议
        [[AnalyticsManager sharedManager]reportEventWithName:@"tap_check_agreement_doc" level1:@"AccountLoginVC" level2:@"" level3:@"" reportTrigger:@"点击查看协议文档时" properties:@{@"fileType":@4} completion:^(BOOL success, NSString * _Nullable message) {
                
        }];
        return NO;
    }
    
    return YES;
}
-(void)pushToNegotiateVCWithTitle:(NSString *)title type:(NSInteger)type{
    NegotiateViewController * neVC = [[NegotiateViewController alloc]init];
    neVC.title = title;
    neVC.type  = type;
    [self.navigationController pushViewController:neVC animated:YES];
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
