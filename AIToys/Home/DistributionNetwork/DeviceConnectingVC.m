//
//  DeviceConnectingVC.m
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "DeviceConnectingVC.h"
#import "ExitView.h"
#import "DeviceConnectSuccessViewController.h"
#import "DeviceConnectFailedViewController.h"

@interface DeviceConnectingVC ()<ThingSmartBLEWifiActivatorDelegate,ThingSmartHomeDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic,strong)NSString * token;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic,strong)NSString * wifiName;
@property (nonatomic,strong)NSString * wifiPassword;

@end

@implementation DeviceConnectingVC
-(void)setConnectDeviceInfo:(NSDictionary *)connectDeviceInfo{
    _connectDeviceInfo = [NSDictionary dictionaryWithDictionary:connectDeviceInfo];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.fd_prefersNavigationBarHidden = YES;
    [self getToken];
    

}


//开始配网
- (void)deviceConnectStart:(NSDictionary *)connectDeviceInfo {
    NSString *uuid = connectDeviceInfo[@"uuid"];
    NSString *ssid = connectDeviceInfo[@"ssid"];
    NSString *pwd = connectDeviceInfo[@"pwd"];
    self.wifiName = ssid;
    self.wifiPassword = pwd;
    [ThingSmartBLEWifiActivator sharedInstance].bleWifiDelegate = self;
    [[ThingSmartBLEWifiActivator sharedInstance] pairDeviceWithUUID:uuid token:self.token ssid:ssid pwd:pwd timeout:60];
    [self setupTimer];
}

-(void)setupTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    self.status = AddStatusType_progress;
}

//更新进度条
- (void)updateProgress {
    if (self.progressView.progress < 0.9) {
        self.progressView .progress+= 0.05;
    } else {
        self.progressView.progress = 0.9;
        [self.timer invalidate];
    }
//    [self.tableView reloadData];
}
//获取配网token
- (void)getToken {
    WEAK_SELF
    ThingSmartActivator *ezActivator = [[ThingSmartActivator alloc] init];
    [ezActivator getTokenWithHomeId:[[CoreArchive strForKey:KCURRENT_HOME_ID]integerValue] success:^(NSString *token) {
        NSLog(@"getToken success: %@", token);
        weakSelf.token = token;
        [self deviceConnectStart:self.connectDeviceInfo];
    } failure:^(NSError *error) {
        NSLog(@"getToken failure: %@", error.localizedDescription);
    }];
}


//关闭按钮
- (IBAction)closeBtnClcik:(id)sender {
    
    WEAK_SELF
    if(self.status == AddStatusType_success){
        //在配网结束后调用
        [[ThingSmartBLEWifiActivator sharedInstance] stopDiscover];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        ExitView *view = [[ExitView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        view.sureBlock = ^{
            //在配网结束后调用
            [[ThingSmartBLEWifiActivator sharedInstance] stopDiscover];
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            
        };
        
        [view show];
    }
    
}

#pragma mark -- ThingSmartBLEWifiActivatorDelegate

- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator didReceiveBLEWifiConfigDevice:(nullable ThingSmartDeviceModel *)deviceModel error:(nullable NSError *)error{
    
    if(!error){
        //配网成功
        
        // 保存Wi-Fi密码到本地，以Wi-Fi名称作为key
        if (self.wifiName && self.wifiPassword) {
            [[NSUserDefaults standardUserDefaults] setObject:self.wifiPassword forKey:self.wifiName];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"Wi-Fi密码已保存: %@ -> %@", self.wifiName, self.wifiPassword);
        }
        
        DeviceConnectSuccessViewController * successVC = [[DeviceConnectSuccessViewController alloc]init];
        successVC.wifiName = self.wifiName;
        successVC.deviceModel = deviceModel;
        [self.navigationController pushViewController:successVC animated:YES];
        
        
        
        
        //埋点：添加设备结果(成功)
        [[AnalyticsManager sharedManager]reportEventWithName:@"device_adding_result" level1:kAnalyticsLevel1_Home level2:@"" level3:@"" reportTrigger:@"设备添加返回结果时" properties:@{@"deviceAddResult":@"success",@"deviceModel":@"TalenpalPlayer",@"addPath":[[NSUserDefaults standardUserDefaults] objectForKey:@"isHomefun"]?@"1":@"0"} completion:^(BOOL success, NSString * _Nullable message) {
                
        }];
//
        self.status = AddStatusType_success;
//        [PublicObj makeButtonEnable:self.doneBtn];
        //在配网结束后调用
        [[ThingSmartBLEWifiActivator sharedInstance] stopDiscover];

    }else{
        
        DeviceConnectFailedViewController * successVC = [[DeviceConnectFailedViewController alloc]init];
        [self.navigationController pushViewController:successVC animated:YES];
        
        //error.code 1.设备接收的数据包格式错误 2.设备找不到路由器
        //埋点：添加设备结果(失败)
        [[AnalyticsManager sharedManager]reportEventWithName:@"device_adding_result" level1:kAnalyticsLevel1_Home level2:@"" level3:@"" reportTrigger:@"设备添加返回结果时" properties:@{@"deviceAddResult":[NSString stringWithFormat:@"fail:%ld",(long)error.code],@"addPath":[[NSUserDefaults standardUserDefaults] objectForKey:@"isHomefun"]?@"1":@"0"} completion:^(BOOL success, NSString * _Nullable message) {
                
        }];

        if(error.code == 3){
            //Wi-Fi 密码错误
//            [SVProgressHUD showErrorWithStatus:LocalString(@"您输入的WiFi密码错误，请您核对后再试一次。")];
//            self.ispwdError = YES;
        }else if(error.code == 4 || error.code == 2){
            //设备连不上路由器
//            [SVProgressHUD showErrorWithStatus:@"网络信号连接不佳，请将设备和手机尽量靠近路由器。"];
        }else{
//            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }

        self.status = AddStatusType_fail;
        NSLog(@"配网失败");
    }
    
}

@end
