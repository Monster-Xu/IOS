//
//  LoginViewController.m
//  AIToys
//
//  Created by qdkj on 2025/6/17.
//

#import "LoginViewController.h"
#import "AcountLoginViewController.h"
#import "RegistViewController.h"

@interface LoginViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@property (weak, nonatomic) IBOutlet UILabel *slogoLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIView *selectLanguageView;
@property (weak, nonatomic) IBOutlet UILabel *languageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageValueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *languageFlagImageView;
@property (strong, nonatomic) UILabel *languageFlagEmojiLabel;
@property (strong, nonatomic) UIView *languageOverlayView;
@property (strong, nonatomic) UIView *languageCardView;
@property (strong, nonatomic) UITableView *languageTableView;
@property (strong, nonatomic) UILabel *languageDialogTitleLabel;
@property (strong, nonatomic) UIButton *languageCancelButton;
@property (strong, nonatomic) UIButton *languageConfirmButton;
@property (strong, nonatomic) NSArray<NSDictionary<NSString *, NSString *> *> *languageOptions;
@property (copy, nonatomic) NSString *pendingLanguageCode;
@property (copy, nonatomic) NSString *pendingLanguageName;
@property (strong, nonatomic) NSLayoutConstraint *languageTableHeightConstraint;
@property (assign, nonatomic) BOOL isApplyingLanguageChange;
@property (copy, nonatomic) NSString *previousLanguageCodeBeforeChange;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hj_NavIsHidden = YES;
    self.bgImgView.image = [PublicObj createImageSize:self.bgView.size gradientColors:@[UIColorFromRGB(0x1EAAFD),UIColorFromRGB(0xD1EEFF),UIColorFromRGB(0xFFFFFF)] percentage:@[@(0),@(0.71),@(1)] gradientType:GradientFromTopToBottom];
    [self.loginBtn setTitle:NSLocalizedString(@"登录", @"") forState:0];
    [self.registerBtn setTitle:NSLocalizedString(@"注册", @"") forState:0];
    self.slogoLabel.text = LocalString(@"专注蒙氏教育，发掘孩子独特天赋");
    [self setupLanguageSelector];
    [self setupLanguageOptions];
    if([CoreArchive boolForKey:KACCOUNT_ISCANCEL]){
        [LGBaseAlertView showAlertWithTitle:@"" content:LocalString(@"账号已删除，请重新登录") cancelBtnStr:nil confirmBtnStr:LocalString(@"确定") confirmBlock:^(BOOL isValue, id obj) {
            if (isValue){
                [CoreArchive setBool:NO key:KACCOUNT_ISCANCEL];
            }
        }];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.languageOverlayView && !self.languageOverlayView.hidden) {
        [self updateLanguageDialogLayout];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateLanguageValueLabel];
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

- (void)setupLanguageSelector {
    self.selectLanguageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLanguageTap:)];
    [self.selectLanguageView addGestureRecognizer:tap];
    [self setupLanguageFlagEmojiView];
    [self updateLanguageValueLabel];
}

- (void)handleLanguageTap:(UITapGestureRecognizer *)gesture {
    [self showLanguageDialog];
}

- (void)applyLanguageCode:(NSString *)languageCode displayName:(NSString *)displayName {
    NSArray<NSString *> *languages = @[languageCode];
    [[NSUserDefaults standardUserDefaults] setObject:languages forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] setObject:languageCode forKey:@"AppleLocale"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    self.languageValueLabel.text = displayName;
}

- (void)updateLanguageValueLabel {
    self.languageTitleLabel.text = LocalString(@"语言");
    NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject ?: @"en";
    NSString *languageCode = [preferredLanguage componentsSeparatedByString:@"-"].firstObject ?: @"en";
    NSDictionary<NSString *, NSString *> *displayNames = @{
        @"zh": LocalString(@"简体中文"),
        @"en": LocalString(@"英语"),
        @"de": LocalString(@"德语"),
        @"fr": LocalString(@"法语"),
        @"es": LocalString(@"西班牙语"),
        @"ar": LocalString(@"阿拉伯语")
    };
    NSString *displayName = displayNames[languageCode] ?: LocalString(@"英语");
    self.languageValueLabel.text = displayName;
    self.languageFlagEmojiLabel.text = [self languageFlagEmojiForCode:languageCode];
}

- (void)setupLanguageFlagEmojiView {
    if (self.languageFlagEmojiLabel) {
        return;
    }
    UILabel *flagLabel = [[UILabel alloc] init];
    flagLabel.translatesAutoresizingMaskIntoConstraints = NO;
    flagLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightRegular];
    flagLabel.textAlignment = NSTextAlignmentCenter;
    flagLabel.textColor = UIColorFromRGB(0x333333);
    [self.selectLanguageView addSubview:flagLabel];
    self.languageFlagEmojiLabel = flagLabel;

    if (self.languageFlagImageView) {
        self.languageFlagImageView.hidden = YES;
        [NSLayoutConstraint activateConstraints:@[
            [flagLabel.centerXAnchor constraintEqualToAnchor:self.languageFlagImageView.centerXAnchor],
            [flagLabel.centerYAnchor constraintEqualToAnchor:self.languageFlagImageView.centerYAnchor],
            [flagLabel.widthAnchor constraintEqualToAnchor:self.languageFlagImageView.widthAnchor],
            [flagLabel.heightAnchor constraintEqualToAnchor:self.languageFlagImageView.heightAnchor]
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [flagLabel.leadingAnchor constraintEqualToAnchor:self.selectLanguageView.leadingAnchor constant:16.0],
            [flagLabel.centerYAnchor constraintEqualToAnchor:self.selectLanguageView.centerYAnchor],
            [flagLabel.widthAnchor constraintEqualToConstant:24.0],
            [flagLabel.heightAnchor constraintEqualToConstant:24.0]
        ]];
    }
}

- (NSString *)languageFlagEmojiForCode:(NSString *)languageCode {
    if ([languageCode hasPrefix:@"zh"]) {
        return @"🇨🇳";
    }
    if ([languageCode hasPrefix:@"en"]) {
        return @"🇺🇸";
    }
    if ([languageCode hasPrefix:@"fr"]) {
        return @"🇫🇷";
    }
    if ([languageCode hasPrefix:@"de"]) {
        return @"🇩🇪";
    }
    if ([languageCode hasPrefix:@"es"]) {
        return @"🇪🇸";
    }
    if ([languageCode hasPrefix:@"ar"]) {
        return @"🇦🇪";
    }
    return @"🇺🇸";
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
    self.languageDialogTitleLabel = titleLabel;

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.dataSource = (id<UITableViewDataSource>)self;
    tableView.delegate = (id<UITableViewDelegate>)self;
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
    self.languageCancelButton = cancelButton;

    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [confirmButton setTitle:LocalString(@"确定") forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [confirmButton setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmLanguageSelection) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:confirmButton];
    self.languageConfirmButton = confirmButton;

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
    CGFloat topPadding = 0.0;
    CGFloat titleHeight = 48.0;
    CGFloat titleBottom = 0.0;
    CGFloat separatorHeight = 0.5;
    CGFloat buttonHeight = 48.0;
    CGFloat availableTableHeight = cardHeight - topPadding - titleHeight - titleBottom - separatorHeight - buttonHeight;
    CGFloat rowHeight = floor(availableTableHeight / self.languageOptions.count);
    rowHeight = MAX(rowHeight, 44.0);
    self.languageTableView.rowHeight = rowHeight;
    self.languageTableHeightConstraint.constant = availableTableHeight;
    [self.languageCardView layoutIfNeeded];
}

- (void)showRestartAlertWithLanguageCode:(NSString *)languageCode {
    NSString *resolvedCode = languageCode ?: @"en";
    NSString *message = [self localizedStringForKey:@"切换多语言后，APP将会重启，是否继续？" languageCode:resolvedCode];
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
    [self updateLanguageValueLabel];
    [self showRestartAlertWithLanguageCode:self.previousLanguageCodeBeforeChange];
}

- (void)restoreLanguageSelectionBeforeChange {
    if (self.previousLanguageCodeBeforeChange.length == 0) {
        [self updateLanguageValueLabel];
        return;
    }
    NSString *previous = self.previousLanguageCodeBeforeChange;
    [[NSUserDefaults standardUserDefaults] setObject:@[previous] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] setObject:previous forKey:@"AppleLocale"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setupLanguageOptions];
    [self preloadPendingLanguage];
    [self updateLanguageValueLabel];
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
    self.pendingLanguageName = @"英语";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.languageOptions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.rowHeight > 0 ? tableView.rowHeight : 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        UIImage *checkImage = [UIImage systemImageNamed:@"checkmark"];
        checkView.image = checkImage;
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

    NSString *flag = option[@"flag"] ?: @"";
    NSString *name = option[@"name"] ?: @"";
    flagLabel.text = flag;
    nameLabel.text = name;

    BOOL isSelected = [self.pendingLanguageCode isEqualToString:option[@"code"]];
    nameLabel.textColor = isSelected ? UIColorFromRGB(0x2D8CFF) : UIColorFromRGB(0x333333);
    checkView.hidden = !isSelected;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *option = self.languageOptions[indexPath.row];
    self.pendingLanguageCode = option[@"code"];
    self.pendingLanguageName = option[@"name"];
    [tableView reloadData];
}

@end
