//
//  SettingViewController.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/13.
//

#import "SettingViewController.h"
#import "SettingCell.h"
#import "ATFontManager.h"
#import "LogManager.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource,RYFTableViewDelegate>
@property (nonatomic, strong)RYFTableView *tableView;
@property (nonatomic, strong) NSMutableArray *itemArray;
@end

@implementation SettingViewController

-(NSMutableArray *)itemArray{
    if (!_itemArray) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

- (RYFTableView *)tableView{
    if (!_tableView) {
        _tableView = [[RYFTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.tableViewDelegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 64;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 12)];
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 12;
        _tableView.backgroundColor = tableBgColor;
        [_tableView registerNib:[UINib nibWithNibName:@"SettingCell" bundle:nil] forCellReuseIdentifier:@"SettingCell"];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self setupUI];
}

-(void)setupUI{
    self.title = LocalString(@"设置");
    self.tableView.loadState = RYFCanLoadNone;
    self.tableView.tableFooterView = [self setupfooterView];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

-(void)loadData{
    [self.itemArray removeAllObjects];
    NSArray *arr1 = @[
        @{@"title" : LocalString(@"个人信息"),@"value" :@"", @"toVC" : @"PersonalInformationVC"},
        @{@"title" : LocalString(@"账号与安全"),@"value" :@"", @"toVC" : @"AccountSecurityVC"},
        ];
    [self.itemArray addObject:[MineItemModel mj_objectArrayWithKeyValuesArray:arr1]];
    
//    NSArray *arr2 = @[
//        @{@"title" : LocalString(@"APP消息通知"),@"value" :@"", @"toVC" : @""}
//        ];
//    [self.itemArray addObject:[MineItemModel mj_objectArrayWithKeyValuesArray:arr2]];
    
    NSArray *arr3 = @[
        @{@"title" : LocalString(@"关于"),@"value" :@"", @"toVC" : @"AboutUsViewController"},
        @{@"title" : LocalString(@"隐私设置"),@"value" :@"", @"toVC" : @"PrivateSettingViewController"},
        @{@"title" : LocalString(@"隐私政策管理"),@"value" :@"", @"toVC" : @"PrivacyPolicyManagementVC"}
        ];
    [self.itemArray addObject:[MineItemModel mj_objectArrayWithKeyValuesArray:arr3]];
    
    
    
    NSArray *arr4 = @[
        @{@"title" : LocalString(@"WiFi列表"),@"value" :@"", @"toVC" : @"WiFiListViewController"},
        @{@"title" : LocalString(@"导出日志"),@"value" :@"", @"toVC" : @"WiFiListViewController"}
        ];
    [self.itemArray addObject:[MineItemModel mj_objectArrayWithKeyValuesArray:arr4]];
    
    
    
    NSArray *arr5 = @[
        @{@"title" : LocalString(@"清理缓存"),@"value" :[NSString stringWithFormat:@"%.2fM",[PublicObj readCacheSize]], @"toVC" : @""}
        ];
    [self.itemArray addObject:[MineItemModel mj_objectArrayWithKeyValuesArray:arr5]];
}

- (UIView *)setupfooterView {
    CGFloat btnViewH =  64;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, btnViewH)];
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    exitBtn.titleLabel.font = [ATFontManager systemFontOfSize:16 weight:600];
    exitBtn.backgroundColor = UIColor.whiteColor;
    exitBtn.layer.cornerRadius = 16;
    exitBtn.layer.masksToBounds = YES;
    [exitBtn setTitle:LocalString(@"退出登录") forState:0];
    [exitBtn setTitleColor:UIColorHex(0xFF4444) forState:0];
    [exitBtn addTarget:self action:@selector(exitLogin) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:exitBtn];
    [exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(footer);
        make.left.equalTo(footer).offset(15);
        make.right.equalTo(footer).offset(-15);
    }];
    return footer;
}

//退出登录
-(void)exitLogin{
//    WEAK_SELF
    
    [LGBaseAlertView showAlertWithTitle:LocalString(@"确定要退出吗?") content:nil cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
        if (isValue){
            [SVProgressHUD showWithStatus:LocalString(@"正在安全退出，请稍后…")];
            //APP埋点：账户已退出
                    [[AnalyticsManager sharedManager]reportEventWithName:@"account_logged_out" level1:kAnalyticsLevel1_Mine level2:@"" level3:@"" reportTrigger:@"完成账户退出时" properties:nil completion:^(BOOL success, NSString * _Nullable message) {
                            
                    }];
            [[ThingSmartUser sharedInstance] loginOut:^{
                [SVProgressHUD dismiss];
                [UserInfo clearMyUser];
                [CoreArchive removeStrForKey:KCURRENT_HOME_ID];
                [UserInfo showLogin];
                
                
            } failure:^(NSError *error) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:@"Failed to Logout."];
            }];
        }
    }];
    
    //APP埋点：点击退出账户
            [[AnalyticsManager sharedManager]reportEventWithName:@"tap_account_logout" level1:kAnalyticsLevel1_Mine level2:@"" level3:@"" reportTrigger:@"点击退出账户时" properties:nil completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
}

#pragma mark -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.itemArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    NSArray *arr = self.itemArray[indexPath.section];
    MineItemModel *model = arr[indexPath.row];
    cell.indexPath = indexPath;
    cell.rowInSection = arr.count;
    cell.model = model;
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    kPreventRepeatClickTime(0.5);
    NSArray *arr = self.itemArray[indexPath.section];
    MineItemModel *model = arr[indexPath.row];
    NSString *title = model.title;
    NSString *str = model.toVC;
    if ([title isEqualToString:LocalString(@"清理缓存")]) {
        WEAK_SELF
        [LGBaseAlertView showAlertWithTitle:LocalString(@"确定清除缓存?") content:nil cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
            if (isValue){
                [SVProgressHUD showWithStatus:LocalString(@"清理中...")];
                
                // 异步执行缓存清理操作，避免阻塞主线程
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [PublicObj clearFile];
                    [[LogManager sharedManager]clearLogs];
                    
                    // 清理完成后回到主线程更新UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showSuccessWithStatus:LocalString(@"缓存清理成功")];
                        model.value = @"0.00M";
                        // 优化：只刷新当前行，而不是整个表格
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    });
                });
            }
        }];
        //APP埋点：点击清除缓存
                [[AnalyticsManager sharedManager]reportEventWithName:@"tap_clear_cache" level1:kAnalyticsLevel1_Mine level2:@"" level3:@"" reportTrigger:@"点击清除缓存时" properties:nil completion:^(BOOL success, NSString * _Nullable message) {
                        
                }];
    }
    else if ([title isEqualToString:LocalString(@"导出日志")]){
        WEAK_SELF
        [SVProgressHUD showWithStatus:LocalString(@"导出中...")];
        
        [[LogManager sharedManager] exportLogsWithCompletion:^(NSURL * _Nullable fileURL, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                
                if (error) {
                    [SVProgressHUD showErrorWithStatus:LocalString(@"导出失败")];
                    return;
                }
                
                // 显示导出成功提示，告知用户文件位置
//                NSString *fileName = fileURL.lastPathComponent;
                NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
                // 获取当前日期
                NSDate *currentDate = [NSDate date];

                // 创建日历对象
                NSCalendar *calendar = [NSCalendar currentCalendar];

                // 定义要获取的日期组件
                NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;

                // 获取日期组件
                NSDateComponents *components = [calendar components:unitFlags fromDate:currentDate];

                // 提取年月日
                NSInteger year = [components year];
                NSInteger month = [components month];
                NSInteger day = [components day];

                NSLog(@"当前日期: %ld年%ld月%ld日", (long)year, (long)month, (long)day);
                
                
                
                NSString *message = [NSString stringWithFormat:LocalString(@"If the App encounters anomalies, crashes, or other issues, please upload the logs to help us better locate and resolve the problem. \n App Version: %@ \n SDK Version: 6.7.0 \nBuildlD:%@ \nEnviorment:test\n Client lD: %@ \n UserAccount: %@\n Date:%ld.%ld.%ld"),[self getVersion],buildNumber,[ThingSmartUser sharedInstance].uid,kMyUser.email,year,month,day];
                
                NSString *encodedPath = [[fileURL path] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
                NSString *result = [NSString stringWithFormat:@"%@", encodedPath];
                
                
                
                [LGBaseAlertView showAlertWithTitle:LocalString(@"导出成功") content:message cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"上传") confirmBlock:^(BOOL isValue, id obj) {
                    if (isValue) {
                        
                        
                        
                        // 示例3：带额外参数
                        NSData *videoData = [NSData dataWithContentsOfFile:result];
                        NSDictionary *params = @{
                            @"directory": result,
                        };
                        [[APIManager shared]uploadSingleFile:[APIPortConfiguration getuploadUrl] fileData:videoData fileName:[NSString stringWithFormat:@"%ld_%ld_%ld_%@",(long)year,(long)month,day,kMyUser.email] parameters:params success:^(id  _Nonnull result) {
//                            [SVProgressHUD showWithStatus:@"日志上传成功"];
                                                } failure:^(NSError * _Nonnull error) {
//                                                    [SVProgressHUD showWithStatus:@"日志上传失败"];
                                                }];
                        
                        
                        
                        
//                        [SVProgressHUD showWithStatus:LocalString(@"上传中...")];
//                        [[APIManager shared]POST:[NSString stringWithFormat:@"%@?directory=%@",[APIPortConfiguration getuploadUrl],result] parameter:@{} success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
//                            [SVProgressHUD showWithStatus:@"日志上传成功"];
//                                            } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
//                                                [SVProgressHUD showWithStatus:@"日志上传失败"];
//                                            }];
                    }
                    
                    // 可选：导出成功后直接打开系统分享界面
                    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
                    
                    // 为iPad设置弹出位置
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                        activityVC.popoverPresentationController.sourceView = weakSelf.view;
                        activityVC.popoverPresentationController.sourceRect = CGRectMake(weakSelf.view.bounds.size.width/2, weakSelf.view.bounds.size.height/2, 1, 1);
                    }
                    
                    [weakSelf presentViewController:activityVC animated:YES completion:nil];
                }];
            });
        }];
    }
    else{
        UIViewController* vc = [NSString stringChangeToClass:str];
        vc.title = title;
        if (vc) {
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        if ([str isEqualToString:@"PersonalInformationVC"]) {
            //APP埋点：点击个人信息
                    [[AnalyticsManager sharedManager]reportEventWithName:@"tap_personal_information" level1:kAnalyticsLevel1_Mine level2:@"" level3:@"" reportTrigger:@"点击个人信息时" properties:nil completion:^(BOOL success, NSString * _Nullable message) {
                            
                    }];
        }else if([str isEqualToString:@"AccountSecurityVC"]){
            //APP埋点：点击账户与安全
                    [[AnalyticsManager sharedManager]reportEventWithName:@"tap_account_and_security" level1:kAnalyticsLevel1_Mine level2:@"" level3:@"" reportTrigger:@"点击账户与安全时" properties:nil completion:^(BOOL success, NSString * _Nullable message) {
                            
                    }];
        }else if([str isEqualToString:@"AccountSecurityVC"]){
            
        }
    }
}

- (NSString*)getVersion
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSString *versionNum = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    return versionNum;
    
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
