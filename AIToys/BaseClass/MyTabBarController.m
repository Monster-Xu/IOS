//
//  MyTabBarControllerViewController.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/18.
//

#import "MyTabBarController.h"
#import "HomeViewController.h"
#import "ContactViewController.h"
#import "CreationViewController.h"
#import "MineViewController.h"
#import "LoginViewController.h"
#import <ThingSmartMiniAppBizBundle/ThingSmartMiniAppBizBundle.h>

@interface MyTabBarController ()<UITabBarControllerDelegate>

@end

@implementation MyTabBarController

+ (void)initialize {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = generalTextColor;
    
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = mainColor;
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [item setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:KEY_ISFIRSTLAUNCH]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_ISFIRSTLAUNCH];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.tabBar.tintColor = mainColor;
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance * appearance = [UITabBarAppearance new];
        appearance.backgroundColor = [UIColor whiteColor];
        [appearance setShadowColor:nil];
        appearance.backgroundEffect = nil;
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, TabBar_Height);
        appearance.backgroundImage = [PublicObj imageWithUIView:effectView];//把毛玻璃View转成Image
        self.tabBar.scrollEdgeAppearance = appearance;
    }
    [self addAllChildViewController];
    //监听SDK会话是否超时
    [self loadNotification];
    //为了初始化网络监听
    [[APIManager shared] getCurrentViewController];
}

#pragma mark - Private Methods

- (void)addAllChildViewController {
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    [self addChildViewController:homeVC
                           image:@"tab_home"
                   selectedImage:@"tab_home_sel"
                           title:LocalString(@"首页")];
    
    CreationViewController *creationVC = [[CreationViewController alloc] init];
    [self addChildViewController:creationVC
                           image:@"tab_create"
                   selectedImage:@"tab_create_sel"
                           title:LocalString(@"创作")];
    
//    ContactViewController *contactVC = [[ContactViewController alloc] init];
//    [self addChildViewController:contactVC
//                           image:@"tab_contact"
//                   selectedImage:@"tab_contact_sel"
//                           title:LocalString(@"通讯")];
    
    MineViewController *mineVC = [[MineViewController alloc] init];
    [self addChildViewController:mineVC
                           image:@"tab_mine"
                   selectedImage:@"tab_mine_sel"
                           title:LocalString(@"我的")];
}

- (void)addChildViewController:(UIViewController *)vc
                         image:(NSString *)imgName
                 selectedImage:(NSString *)selImgName
                         title:(NSString *)title
{
    vc.tabBarItem.title = title;
    vc.title = title;
    vc.tabBarItem.image = [[UIImage imageNamed:imgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
}

//处理登录会话过期
- (void)loadNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInvalid) name:ThingSmartUserNotificationUserSessionInvalid object:nil];
}

- (void)sessionInvalid {
    [LGBaseAlertView showAlertWithTitle:@"" content:LocalString(@"登录信息已过期,请重新登录") cancelBtnStr:nil confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
        if (isValue){
            
        }
    }];
    [UserInfo clearMyUser];
    [CoreArchive removeStrForKey:KCURRENT_HOME_ID];
    [UserInfo showLogin];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ThingSmartUserNotificationUserSessionInvalid object:nil];
}

#pragma mark -- event method
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([viewController.tabBarItem.title isEqualToString:LocalString(@"创作")]) {
        NSString *currentHomeId = [CoreArchive strForKey:KCURRENT_HOME_ID];
        // 跳转小程序
        [[ThingMiniAppClient coreClient] openMiniAppByUrl:@"godzilla://ty7y8au1b7tamhvzij/pages/plush-toy/index" params:@{@"ownerId":currentHomeId?:@"",@"BearerId":(kMyUser.accessToken?:@""),@"langType":@"en"}];
        return NO;
    }
    return YES;
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
