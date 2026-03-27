//
//  AppDelegate.m
//  AIToys
//
//  Created by qdkj on 2025/6/17.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MyTabBarController.h"
#import "GlobalBluetoothManager.h"
#import "ADImageView.h"
#import "BannerModel.h"
#import "FontValidationHelper.h"
#import <UserNotifications/UserNotifications.h>
#import <ThingSmartMiniAppBizBundle/ThingSmartMiniAppBizBundle.h>
#import <ThingModuleManager/ThingModuleManager.h>
#import "NavigateToNativePageAPI.h"
#import "getOTAInfo.h"
#import "UpgradeSwitchInfo.h"
#import "startFirmwareUpgrade.h"
#import "AnalyticsManager.h"
#import "LogManager.h"
#import "StarteBLEListening.h"
#import <AVFoundation/AVFoundation.h>
#import <ThingFoundationKit/ThingLanguageLoader.h>
#import "ATLanguageHelper.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    //刷新Token
//    [self refreshToken];
    // 验证SF Pro Rounded字体加载
    [FontValidationHelper validateFontsInAppDelegate];
    // RTL 全局配置
    [ATLanguageHelper applyGlobalRTLConfiguration];
    // ⭐️ 只需要这一行代码，即可开始全局自动记录 ⭐️
    [LogManager startAutoLogging];
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier ?: @"";
    BOOL isReleaseBundle = [bundleId isEqualToString:@"com.talenpal.talenpalapp"];
    NSString *appKey = isReleaseBundle ? Smart_APPID : Smart_APPIDDEV;
    NSString *appSecret = isReleaseBundle ? Smart_AppSecret : Smart_AppSecretDEV;
    [[ThingSmartSDK sharedInstance] startWithAppKey:appKey secretKey:appSecret];
    // App 启动时初始化涂鸦小程序
    [[ThingMiniAppClient initialClient] initialize];
    // 开启 vConsole 调试开关
    // [[ThingMiniAppClient debugClient] vConsoleDebugEnable:YES];
    // 注册自定义 API
    [self registerCustomMiniAppAPIs];
#ifdef DEBUG
    [[ThingSmartSDK sharedInstance] setDebugMode:YES];
#else
#endif
    [SVProgressHUD setSuccessImage:QD_IMG(@"hud_success")];
    [SVProgressHUD setErrorImage:QD_IMG(@"hud_error")];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    //蓝牙监听
    [GlobalBluetoothManager sharedManager];
    
    // 骨架屏加载
    [[TABAnimated sharedAnimated] initWithOnlySkeleton];
    [TABAnimated sharedAnimated].openLog = YES;
    
    //tuya消息推送
    [self setupPushNotification:application];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.semanticContentAttribute = [ATLanguageHelper isRTLLanguage] ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
    [self setUpRootVC];
    [self.window makeKeyAndVisible];
    // 配置音频会话（应用启动时设置一次）
    NSError *audioError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&audioError];
    if (audioError) {
        NSLog(@"AppDelegate: 音频会话设置失败: %@", audioError.localizedDescription);
    }
    
//    //友盟相关
//    [UMConfigure initWithAppkey:@"6908c3d08560e34872dd8dcf" channel:@"App Store"];
//    [UMConfigure setLogEnabled:YES];
//    [UMCommonLogManager setUpUMCommonLogManager];
    
    //启动广告图
    [self loadAD];
    
    return [[ThingModuleManager sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];

}

//涂鸦消息推送
-(void)setupPushNotification:(UIApplication *)application{
    [application registerForRemoteNotifications];
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
            //iOS10 需要加下面这段代码
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
            UNAuthorizationOptions types10 = UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
            [center requestAuthorizationWithOptions:types10 completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    //点击允许
                } else {
                    //点击不允许
                }
            }];
        }
}

-(void)setUpRootVC{
    if ([ThingSmartUser sharedInstance].isLogin) {
        MyTabBarController *tabbar = [MyTabBarController new];
        self.window.rootViewController = tabbar;
    }else{
        self.window.rootViewController = [[MyNavigationController alloc] initWithRootViewController:[LoginViewController new]];
    }

}

#pragma mark - ----------------------- 启动广告图 -----------------------
#pragma mark 加载远程广告
- (void)loadAD {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"loading.png"]];
    NSString *modelPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"adModel"]];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isExit = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    
    // 安全地反序列化模型数据
    BannerModel *adModel = nil;
    @try {
        if ([fileManager fileExistsAtPath:modelPath]) {
            adModel = [NSKeyedUnarchiver unarchiveObjectWithFile:modelPath];
        }
    } @catch (NSException *exception) {
        NSLog(@"⚠️ [AppDelegate] 广告模型反序列化失败: %@", exception.reason);
        // 清除损坏的缓存文件
        [fileManager removeItemAtPath:modelPath error:nil];
    }
    
    //url是否已被缓存
    if (isExit && adModel){
        WEAK_SELF
        //自定义广告ImageView
        ADImageView *launch = [[ADImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        launch.image = [UIImage imageWithContentsOfFile:filePath];
        //广告点击跳转
        launch.adPicTapClick = ^{
            [weakSelf jumpToAdView:adModel];
        };
        //设置window层级
        [weakSelf.window addSubview:launch];
    }
    [self asyncInit];
}

//获取网络数据
-(void)asyncInit{
    NSLog(@"🚀 [AppDelegate] 启动时异步获取网络启动图数据");
    WEAK_SELF
    [[APIManager shared] GET:[APIPortConfiguration getSplashScreenUrl] parameter:nil success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg)  {

        NSArray *dataArr = @[];
        if ([data isKindOfClass:NSArray.class]){
            dataArr = (NSArray *)data;
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"loading.png"]];
        NSString *modelPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"adModel"]];

        NSLog(@"📡 [AppDelegate] 网络启动图API请求成功，返回数据数量: %lu", (unsigned long)dataArr.count);

        if (dataArr.count > 0)
        {
            NSDictionary *firstObject = [dataArr firstObject];
            if ([firstObject isKindOfClass:[NSDictionary class]]) {
                BannerModel *adModel = [BannerModel mj_objectWithKeyValues:firstObject];
                if (adModel) {
                    NSLog(@"📋 [AppDelegate] 解析到网络启动图: %@", adModel.imageUrl);
                    // 安全地序列化模型数据
                    @try {
                        [NSKeyedArchiver archiveRootObject:adModel toFile:modelPath];
                    } @catch (NSException *exception) {
                        NSLog(@"⚠️ [AppDelegate] 广告模型序列化失败: %@", exception.reason);
                    }
                    //异步下载并缓存以供下次直接读取
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        if (adModel.imageUrl.length>0) {
                            NSLog(@"🔄 [AppDelegate] 开始下载网络启动图进行缓存更新");
                            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:adModel.imageUrl]];
                            if (data) {
                                UIImage *image = [UIImage imageWithData:data];
                                if (image) {
                                    BOOL success = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
                                    if (success) {
                                        NSLog(@"✅ [AppDelegate] 网络启动图缓存更新成功 (%.2f KB)", (double)data.length / 1024.0);
                                    } else {
                                        NSLog(@"❌ [AppDelegate] 网络启动图缓存写入失败");
                                    }
                                } else {
                                    NSLog(@"❌ [AppDelegate] 网络启动图数据转换失败");
                                }
                            } else {
                                NSLog(@"❌ [AppDelegate] 网络启动图下载失败");
                            }
                        }
                    });
                } else {
                    NSLog(@"⚠️ [AppDelegate] 广告模型解析失败");
                }
            } else {
                NSLog(@"⚠️ [AppDelegate] 网络启动图数据格式错误");
            }
        }else{
            NSLog(@"⚠️ [AppDelegate] 网络启动图数据为空，5秒后清理旧缓存");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BOOL isDir = FALSE;
                BOOL isExit = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
                if (isExit) {
                    NSError *error;
                    [[NSFileManager defaultManager]removeItemAtPath:filePath error:&error];

                    if (error)
                    {
                      // file deletion failed
                        NSLog(@"❌ [AppDelegate] 启动图缓存清除失败: %@", error.localizedDescription);
                    } else {
                        NSLog(@"🗑️ [AppDelegate] 启动图缓存已清除");
                    }
                }
            });

        }
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg){
       NSLog(@"❌ [AppDelegate] 网络启动图API请求失败: %@", msg);
    }];
}

#pragma mark 启动广告图的点击跳转
- (void)jumpToAdView:(BannerModel *)adModel
{
    if (adModel.linkUrl.length == 0) {
        return;
    }
    MyWebViewController *VC = [MyWebViewController new];
    VC.mainUrl =  adModel.linkUrl;
    [[PublicObj getCurrentViewController].navigationController pushViewController:VC animated:YES];
}

//注册 Push ID
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [ThingSmartSDK sharedInstance].deviceToken = deviceToken;
}

//接收通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"收到通知 ==== %@",userInfo);
}

#pragma mark - 自定义 MiniApp API 注册

/**
 * 注册自定义 MiniApp API
 */
- (void)registerCustomMiniAppAPIs {
    NSLog(@"========== 开始注册自定义 MiniApp API ==========");

    // 注册原生页面跳转 API
    NSLog(@"创建 NavigateToNativePageAPI 实例...");
    NavigateToNativePageAPI *navigateAPI = [[NavigateToNativePageAPI alloc] init];
    getOTAInfo * otaInfoAPI = [[getOTAInfo alloc]init];
    UpgradeSwitchInfo * UpgradeSwitchInfoAPI = [[UpgradeSwitchInfo alloc]init];
    startFirmwareUpgrade * startFirmwareUpgradeAPI = [[startFirmwareUpgrade alloc]init];
    StarteBLEListening *StarteBLEListeningAPI = [[StarteBLEListening alloc]init];
    NSLog(@"NavigateToNativePageAPI 实例创建成功: %@,%@,%@", navigateAPI,UpgradeSwitchInfoAPI,startFirmwareUpgradeAPI);

    NSLog(@"获取 ThingMiniAppClient developClient...");
    id<ThingMiniAppDevelopProtocol> developClient = [ThingMiniAppClient developClient];
    NSLog(@"developClient: %@", developClient);

    NSLog(@"注册 API 到 developClient...");
    [developClient addExtApiImpl:navigateAPI];
    [developClient addExtApiImpl:otaInfoAPI];
    [developClient addExtApiImpl:UpgradeSwitchInfoAPI];
    [developClient addExtApiImpl:startFirmwareUpgradeAPI];
    [developClient addExtApiImpl:StarteBLEListeningAPI];

    NSLog(@"✅ 自定义 MiniApp API 注册完成!");
    NSLog(@"API 名称: %@", navigateAPI.apiName);
    NSLog(@"API 是否可用: %@", [navigateAPI canIUseExtApi] ? @"YES" : @"NO");
    NSLog(@"API 名称: %@", otaInfoAPI.apiName);
    NSLog(@"API 是否可用: %@", [otaInfoAPI canIUseExtApi] ? @"YES" : @"NO");
    NSLog(@"API 名称: %@", UpgradeSwitchInfoAPI.apiName);
    NSLog(@"API 是否可用: %@", [UpgradeSwitchInfoAPI canIUseExtApi] ? @"YES" : @"NO");
    NSLog(@"API 名称: %@", startFirmwareUpgradeAPI.apiName);
    NSLog(@"API 是否可用: %@", [startFirmwareUpgradeAPI canIUseExtApi] ? @"YES" : @"NO");
    NSLog(@"========== 自定义 MiniApp API 注册结束 ==========");
}
// 处理远程控制事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
//    if (event.type == UIEventTypeRemoteControl) {
//        switch (event.subtype) {
//            case UIEventSubtypeRemoteControlPlay:
//                // 播放命令 - 可以通过通知中心通知播放器
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlPlay" object:nil];
//                break;
//            case UIEventSubtypeRemoteControlPause:
//                // 暂停命令
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlPause" object:nil];
//                break;
//            case UIEventSubtypeRemoteControlTogglePlayPause:
//                // 切换播放/暂停
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlTogglePlayPause" object:nil];
//                break;
//            case UIEventSubtypeRemoteControlNextTrack:
//                // 下一曲
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlNextTrack" object:nil];
//                break;
//            case UIEventSubtypeRemoteControlPreviousTrack:
//                // 上一曲
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlPreviousTrack" object:nil];
//                break;
//            default:
//                break;
//        }
//    }
}
-(void)applicationDidEnterBackground:(UIApplication *)application{
    //APP埋点：进入后台
    [self refreshToken];
    [[AnalyticsManager sharedManager]reportEventWithName:@"close_app" level1:kAnalyticsLevel1_Home level2:@"" level3:@"" reportTrigger:@"切到后台时" properties:@{@"closeType":@"background"} completion:^(BOOL success, NSString * _Nullable message) {
            
    }];
}
-(void)refreshToken{
    if (kMyUser.refreshToken) {
        [[APIManager shared]POST:[NSString stringWithFormat:@"%@?refreshToken=%@",[APIPortConfiguration getRefreshTokenUrl],kMyUser.refreshToken] parameter:@{} success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
            
            if (data) {
                kMyUser.accessToken  = data[@"accessToken"];
                kMyUser.refreshToken = data[@"refreshToken"];
                [UserInfo saveMyUser];
            }
            
            } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
                
            }];
    }
    
}

@end
