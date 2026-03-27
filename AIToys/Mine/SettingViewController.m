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
@property (strong, nonatomic) UIView *languageOverlayView;
@property (strong, nonatomic) UIView *languageCardView;
@property (strong, nonatomic) UITableView *languageTableView;
@property (strong, nonatomic) NSArray<NSDictionary<NSString *, NSString *> *> *languageOptions;
@property (copy, nonatomic) NSString *pendingLanguageCode;
@property (copy, nonatomic) NSString *pendingLanguageName;
@property (strong, nonatomic) NSLayoutConstraint *languageTableHeightConstraint;
@property (assign, nonatomic) BOOL isApplyingLanguageChange;
@property (copy, nonatomic) NSString *previousLanguageCodeBeforeChange;
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
    [self setupLanguageOptions];
    [self loadData];
    [self setupUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.languageOverlayView && !self.languageOverlayView.hidden) {
        [self updateLanguageDialogLayout];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshLanguageSettingItem];
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
        @{@"title" : LocalString(@"切换语言"),@"value" :@"", @"toVC" : @"LanguageSelection"},
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

- (void)refreshLanguageSettingItem {
    [self.tableView reloadData];
}

- (void)setupLanguageOptions {
    self.languageOptions = @[
        @{@"code": @"zh-Hans", @"name": LocalString(@"简体中文"), @"flag": @"🇨🇳"},
        @{@"code": @"en", @"name": LocalString(@"英语"), @"flag": @"🇺🇸"},
        @{@"code": @"fr", @"name": LocalString(@"法语"), @"flag": @"🇫🇷"},
        @{@"code": @"de", @"name": LocalString(@"德语"), @"flag": @"🇩🇪"},
        @{@"code": @"es", @"name": LocalString(@"西班牙语"), @"flag": @"🇪🇸"},
        @{@"code": @"ar", @"name": LocalString(@"阿拉伯语"), @"flag": @"🇦🇪"}
    ];
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
                [SVProgressHUD showErrorWithStatus:LocalString(@"退出失败，请重试")];
            }];
        }
    }];
    
    //APP埋点：点击退出账户
            [[AnalyticsManager sharedManager]reportEventWithName:@"tap_account_logout" level1:kAnalyticsLevel1_Mine level2:@"" level3:@"" reportTrigger:@"点击退出账户时" properties:nil completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
}

#pragma mark -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.languageTableView) {
        return 1;
    }
    return self.itemArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.languageTableView) {
        return self.languageOptions.count;
    }
    return [self.itemArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.languageTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LanguageCell" forIndexPath:indexPath];
        NSDictionary *option = self.languageOptions[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.separatorInset = UIEdgeInsetsZero;

        UILabel *flagLabel = [cell.contentView viewWithTag:101];
        UILabel *nameLabel = [cell.contentView viewWithTag:102];
        UIImageView *checkView = [cell.contentView viewWithTag:103];
        if (!flagLabel) {
            flagLabel = [[UILabel alloc] init];
            flagLabel.translatesAutoresizingMaskIntoConstraints = NO;
            flagLabel.tag = 101;
            flagLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
            [cell.contentView addSubview:flagLabel];
        }
        if (!nameLabel) {
            nameLabel = [[UILabel alloc] init];
            nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
            nameLabel.tag = 102;
            nameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
            nameLabel.textColor = UIColorFromRGB(0x333333);
            [cell.contentView addSubview:nameLabel];
        }
        if (!checkView) {
            checkView = [[UIImageView alloc] init];
            checkView.translatesAutoresizingMaskIntoConstraints = NO;
            checkView.tag = 103;
            checkView.image = [UIImage systemImageNamed:@"checkmark"];
            checkView.contentMode = UIViewContentModeScaleAspectFit;
            checkView.tintColor = UIColorFromRGB(0x2D8CFF);
            [cell.contentView addSubview:checkView];
        }
        if (![cell.contentView viewWithTag:999]) {
            [NSLayoutConstraint activateConstraints:@[
                [flagLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:20.0],
                [flagLabel.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
                [flagLabel.widthAnchor constraintEqualToConstant:22.0],
                
                [nameLabel.leadingAnchor constraintEqualToAnchor:flagLabel.trailingAnchor constant:10.0],
                [nameLabel.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
                
                [checkView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16.0],
                [checkView.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
                [checkView.widthAnchor constraintEqualToConstant:16.0],
                [checkView.heightAnchor constraintEqualToConstant:16.0],
                [checkView.leadingAnchor constraintGreaterThanOrEqualToAnchor:nameLabel.trailingAnchor constant:12.0]
            ]];
            UIView *marker = [[UIView alloc] init];
            marker.tag = 999;
            marker.hidden = YES;
            [cell.contentView addSubview:marker];
        }

        flagLabel.text = option[@"flag"] ?: @"";
        nameLabel.text = option[@"name"] ?: @"";
        BOOL isSelected = [self.pendingLanguageCode isEqualToString:option[@"code"]];
        nameLabel.textColor = isSelected ? UIColorFromRGB(0x2D8CFF) : UIColorFromRGB(0x333333);
        checkView.hidden = !isSelected;
        return cell;
    }

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
    if (tableView == self.languageTableView) {
        NSDictionary *option = self.languageOptions[indexPath.row];
        self.pendingLanguageCode = option[@"code"];
        self.pendingLanguageName = option[@"name"];
        [tableView reloadData];
        return;
    }
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
        [SVProgressHUD showWithStatus:LocalString(@"上传中")];
        
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
                
                
                
                NSString *message = [NSString stringWithFormat:LocalString(@"如果App出现异常、闪退等问题，请上传日志帮助我们更好地定位和解决问题。\nApp版本：%@\nSDK版本：6.7.0\nBuildID：%@\n环境：test\nClient ID：%@\n用户账号：%@\n日期：%ld.%ld.%ld"), [self getVersion], buildNumber, [ThingSmartUser sharedInstance].uid, kMyUser.email, year, month, day];
                
                NSString *encodedPath = [[fileURL path] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
                NSString *result = [NSString stringWithFormat:@"%@", encodedPath];
                
                
                
                [LGBaseAlertView showAlertWithTitle:LocalString(@"日志已成功导出") content:message cancelBtnStr:LocalString(@"取消") confirmBtnStr:LocalString(@"上传") confirmBlock:^(BOOL isValue, id obj) {
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
    else if ([title isEqualToString:LocalString(@"切换语言")]) {
        [self showLanguageDialog];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.languageTableView) {
        return tableView.rowHeight > 0 ? tableView.rowHeight : 44.0;
    }
    return 64.0;
}

- (NSString*)getVersion
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSString *versionNum = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    return versionNum;
    
}

- (void)showLanguageDialog {
    if (!self.languageOverlayView) {
        [self buildLanguageDialog];
    }
    [self preloadPendingLanguage];
    self.languageOverlayView.hidden = NO;
    self.languageOverlayView.alpha = 0.0;
    self.languageCardView.transform = CGAffineTransformMakeScale(0.96, 0.96);
    [self.view layoutIfNeeded];
    [self.languageOverlayView layoutIfNeeded];
    [self.languageCardView layoutIfNeeded];
    [self updateLanguageDialogLayout];
    [self.languageTableView reloadData];
    [self.languageTableView layoutIfNeeded];
    [UIView animateWithDuration:0.2 animations:^{
        self.languageOverlayView.alpha = 1.0;
        self.languageCardView.transform = CGAffineTransformIdentity;
    }];
}

- (void)buildLanguageDialog {
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectZero];
    overlay.translatesAutoresizingMaskIntoConstraints = NO;
    overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self.view addSubview:overlay];
    [NSLayoutConstraint activateConstraints:@[
        [overlay.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [overlay.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [overlay.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [overlay.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    self.languageOverlayView = overlay;
    self.languageOverlayView.hidden = YES;

    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 16.0;
    card.layer.masksToBounds = YES;
    [overlay addSubview:card];
    self.languageCardView = card;

    [NSLayoutConstraint activateConstraints:@[
        [card.leadingAnchor constraintEqualToAnchor:overlay.leadingAnchor constant:16.0],
        [card.trailingAnchor constraintEqualToAnchor:overlay.trailingAnchor constant:-16.0],
        [card.topAnchor constraintEqualToAnchor:overlay.topAnchor constant:174.0],
        [card.bottomAnchor constraintEqualToAnchor:overlay.bottomAnchor constant:-174.0]
    ]];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = LocalString(@"切换语言");
    titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    titleLabel.textColor = UIColorFromRGB(0x222222);
    [card addSubview:titleLabel];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorInset = UIEdgeInsetsZero;
    tableView.separatorColor = UIColorFromRGB(0xEFEFEF);
    tableView.layoutMargins = UIEdgeInsetsZero;
    tableView.tableFooterView = [UIView new];
    tableView.scrollEnabled = NO;
    [tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"LanguageCell"];
    [card addSubview:tableView];
    self.languageTableView = tableView;

    UIView *buttonSeparator = [[UIView alloc] init];
    buttonSeparator.translatesAutoresizingMaskIntoConstraints = NO;
    buttonSeparator.backgroundColor = UIColorFromRGB(0xE6E6E6);
    [card addSubview:buttonSeparator];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cancelButton setTitle:LocalString(@"取消") forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    [cancelButton setTitleColor:UIColorFromRGB(0x8A8A8A) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(dismissLanguageDialog) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:cancelButton];

    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [confirmButton setTitle:LocalString(@"确定") forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [confirmButton setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmLanguageSelection) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:confirmButton];

    UIView *middleSeparator = [[UIView alloc] init];
    middleSeparator.translatesAutoresizingMaskIntoConstraints = NO;
    middleSeparator.backgroundColor = UIColorFromRGB(0xE6E6E6);
    [card addSubview:middleSeparator];

    CGFloat rowHeight = 44.0;
    CGFloat tableHeight = rowHeight * self.languageOptions.count;
    self.languageTableHeightConstraint = [tableView.heightAnchor constraintEqualToConstant:tableHeight];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:card.topAnchor],
        [titleLabel.heightAnchor constraintEqualToConstant:48.0],
        [titleLabel.centerXAnchor constraintEqualToAnchor:card.centerXAnchor],

        [tableView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor],
        [tableView.leadingAnchor constraintEqualToAnchor:card.leadingAnchor],
        [tableView.trailingAnchor constraintEqualToAnchor:card.trailingAnchor],
        self.languageTableHeightConstraint,

        [buttonSeparator.topAnchor constraintEqualToAnchor:tableView.bottomAnchor],
        [buttonSeparator.leadingAnchor constraintEqualToAnchor:card.leadingAnchor],
        [buttonSeparator.trailingAnchor constraintEqualToAnchor:card.trailingAnchor],
        [buttonSeparator.heightAnchor constraintEqualToConstant:0.5],

        [cancelButton.topAnchor constraintEqualToAnchor:buttonSeparator.bottomAnchor],
        [cancelButton.leadingAnchor constraintEqualToAnchor:card.leadingAnchor],
        [cancelButton.heightAnchor constraintEqualToConstant:48.0],

        [confirmButton.topAnchor constraintEqualToAnchor:buttonSeparator.bottomAnchor],
        [confirmButton.trailingAnchor constraintEqualToAnchor:card.trailingAnchor],
        [confirmButton.leadingAnchor constraintEqualToAnchor:cancelButton.trailingAnchor],
        [confirmButton.widthAnchor constraintEqualToAnchor:cancelButton.widthAnchor],
        [confirmButton.heightAnchor constraintEqualToAnchor:cancelButton.heightAnchor],
        [confirmButton.bottomAnchor constraintEqualToAnchor:card.bottomAnchor],

        [middleSeparator.centerXAnchor constraintEqualToAnchor:card.centerXAnchor],
        [middleSeparator.topAnchor constraintEqualToAnchor:buttonSeparator.bottomAnchor],
        [middleSeparator.bottomAnchor constraintEqualToAnchor:card.bottomAnchor],
        [middleSeparator.widthAnchor constraintEqualToConstant:0.5]
    ]];

    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOverlayTap:)];
    dismissTap.cancelsTouchesInView = NO;
    [overlay addGestureRecognizer:dismissTap];
}

- (void)updateLanguageDialogLayout {
    if (!self.languageCardView || self.languageOptions.count == 0) {
        return;
    }
    CGFloat cardHeight = CGRectGetHeight(self.languageCardView.bounds);
    if (cardHeight <= 0) {
        [self.languageCardView layoutIfNeeded];
        cardHeight = CGRectGetHeight(self.languageCardView.bounds);
    }
    if (cardHeight <= 0) {
        return;
    }
    CGFloat availableTableHeight = cardHeight - 48.0 - 0.5 - 48.0;
    CGFloat rowHeight = floor(availableTableHeight / self.languageOptions.count);
    rowHeight = MAX(rowHeight, 44.0);
    self.languageTableView.rowHeight = rowHeight;
    self.languageTableHeightConstraint.constant = availableTableHeight;
    [self.languageCardView layoutIfNeeded];
}

- (void)applyLanguageCode:(NSString *)languageCode displayName:(NSString *)displayName {
    NSArray<NSString *> *languages = @[languageCode];
    [[NSUserDefaults standardUserDefaults] setObject:languages forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] setObject:languageCode forKey:@"AppleLocale"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)localizedStringForKey:(NSString *)key languageCode:(NSString *)languageCode {
    NSString *normalized = languageCode ?: @"en";
    if ([normalized hasPrefix:@"zh"]) {
        normalized = @"zh-Hans";
    } else if ([normalized hasPrefix:@"en"]) {
        normalized = @"en";
    } else if ([normalized hasPrefix:@"fr"]) {
        normalized = @"fr";
    } else if ([normalized hasPrefix:@"de"]) {
        normalized = @"de";
    } else if ([normalized hasPrefix:@"es"]) {
        normalized = @"es";
    } else if ([normalized hasPrefix:@"ar"]) {
        normalized = @"ar";
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:normalized ofType:@"lproj"];
    if (path.length == 0) {
        return LocalString(key);
    }
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    NSString *value = [bundle localizedStringForKey:key value:nil table:nil];
    return value.length > 0 ? value : LocalString(key);
}

- (void)showRestartAlertWithLanguageCode:(NSString *)languageCode {
    NSString *resolvedCode = languageCode ?: @"en";
    NSString *message = [self localizedStringForKey:@"切换多语言后，App将会重启，是否继续？" languageCode:resolvedCode];
    NSString *cancelTitle = [self localizedStringForKey:@"取消" languageCode:resolvedCode];
    NSString *confirmTitle = [self localizedStringForKey:@"确定" languageCode:resolvedCode];
    [LGBaseAlertView showAlertWithTitle:@""
                                content:message
                           cancelBtnStr:cancelTitle
                          confirmBtnStr:confirmTitle
                           confirmBlock:^(BOOL isValue, id obj) {
        if (isValue) {
            exit(0);
        } else {
            [self restoreLanguageSelectionBeforeChange];
        }
    }];
}

- (void)handleOverlayTap:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.languageCardView];
    if (CGRectContainsPoint(self.languageCardView.bounds, location)) {
        return;
    }
    [self dismissLanguageDialog];
}

- (void)dismissLanguageDialog {
    [UIView animateWithDuration:0.2 animations:^{
        self.languageOverlayView.alpha = 0.0;
        self.languageCardView.transform = CGAffineTransformMakeScale(0.96, 0.96);
    } completion:^(BOOL finished) {
        self.languageOverlayView.hidden = YES;
        self.languageCardView.transform = CGAffineTransformIdentity;
        if (!self.isApplyingLanguageChange) {
            [self preloadPendingLanguage];
        }
        self.isApplyingLanguageChange = NO;
    }];
}

- (void)confirmLanguageSelection {
    if (self.pendingLanguageCode.length == 0) {
        [self dismissLanguageDialog];
        return;
    }
    self.isApplyingLanguageChange = YES;
    [self dismissLanguageDialog];
    self.previousLanguageCodeBeforeChange = [NSLocale preferredLanguages].firstObject ?: @"en";
    [self applyLanguageCode:self.pendingLanguageCode displayName:self.pendingLanguageName ?: @""];
    [self refreshLanguageSettingItem];
    [self showRestartAlertWithLanguageCode:self.previousLanguageCodeBeforeChange];
}

- (void)restoreLanguageSelectionBeforeChange {
    if (self.previousLanguageCodeBeforeChange.length == 0) {
        [self refreshLanguageSettingItem];
        return;
    }
    NSString *previous = self.previousLanguageCodeBeforeChange;
    [[NSUserDefaults standardUserDefaults] setObject:@[previous] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] setObject:previous forKey:@"AppleLocale"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setupLanguageOptions];
    [self preloadPendingLanguage];
    [self refreshLanguageSettingItem];
    [self.languageTableView reloadData];
}

- (void)preloadPendingLanguage {
    NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject ?: @"en";
    NSString *languageCode = [preferredLanguage componentsSeparatedByString:@"-"].firstObject ?: @"en";
    for (NSDictionary *option in self.languageOptions) {
        NSString *code = option[@"code"];
        if ([code hasPrefix:languageCode]) {
            self.pendingLanguageCode = code;
            self.pendingLanguageName = option[@"name"];
            return;
        }
    }
    self.pendingLanguageCode = @"en";
    self.pendingLanguageName = LocalString(@"英语");
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
