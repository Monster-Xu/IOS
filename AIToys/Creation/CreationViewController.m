//
//  CreationViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/1.
//

#import "CreationViewController.h"
#import "VoiceStoryTableViewCell.h"
#import "VoiceManagementViewController.h"
#import "VoiceStoryModel.h"
#import "AFStoryAPIManager.h"
#import "APIRequestModel.h"
#import "APIResponseModel.h"
#import "CreateStoryViewController.h"
#import "SkeletonTableViewCell.h"
#import "RYFGifHeader.h"

static NSString *const kNormalCellIdentifier = @"NormalCell";
static NSString *const kSkeletonCellIdentifier = @"SkeletonCell";

@interface CreationViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *customNavBarView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<VoiceStoryModel *> *dataSource;
@property (nonatomic, strong) UIView *emptyStateView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSURLSessionDataTask *currentLoadTask;
@property (nonatomic, strong) NSMutableArray<NSURLSessionDataTask *> *activeTasks;
@property (nonatomic, assign) BOOL isLoading; // 加载状态
// ⭐️ 明确标记：是否处于批量编辑模式
@property (nonatomic, assign) BOOL isBatchEditingMode;

@property (nonatomic, strong) UIView *editingToolbar;
@property (nonatomic, strong) UIButton *deleteSelectedButton;

@end

@implementation CreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置整体背景色为 #F6F7FB
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.activeTasks = [NSMutableArray array];
    self.dataSource = [NSMutableArray array];
    
    // 初始化为非批量编辑模式
    self.isBatchEditingMode = NO;
    [self setupNavigationBar];
    [self setupUI];
    [self setupTableViewConstraints];
    [self loadData];
}

- (void)dealloc {
    
    
    if (self.editingToolbar.superview) {
        [self.editingToolbar removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    // 确保 TabBar 正常显示
    if (self.tabBarController && !self.isBatchEditingMode) {
        self.tabBarController.tabBar.hidden = NO;
        self.tabBarController.tabBar.alpha = 1.0;
        self.tabBarController.tabBar.userInteractionEnabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isBatchEditingMode) {
        [self cancelBatchEditingMode];
    }
}

- (void)setupNavigationBar {
    self.title = @"";
    
    self.customNavBarView = [[UIView alloc] init];
    self.customNavBarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.customNavBarView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Story Creation";
    titleLabel.font = [UIFont fontWithName:@"SFRounded-Bold" size:24] ?: [UIFont boldSystemFontOfSize:24];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.customNavBarView addSubview:titleLabel];
    
    UIButton *soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [soundButton setImage:[UIImage imageNamed:@"create_voice"] forState:UIControlStateNormal];
    soundButton.tintColor = [UIColor systemGrayColor];
    [soundButton addTarget:self action:@selector(soundButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addSubview:soundButton];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[UIImage imageNamed:@"create_add"] forState:UIControlStateNormal];
    addButton.tintColor = [UIColor systemGrayColor];
    [addButton addTarget:self action:@selector(addButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addSubview:addButton];
    
    [self.customNavBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.mas_equalTo(44);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.customNavBarView).offset(16);
        make.centerY.equalTo(self.customNavBarView);
    }];
    
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.customNavBarView).offset(-16);
        make.centerY.equalTo(self.customNavBarView);
        make.width.height.mas_equalTo(28);
    }];
    
    [soundButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(addButton.mas_left).offset(-21);
        make.centerY.equalTo(self.customNavBarView);
        make.width.height.mas_equalTo(28);
    }];
}

- (void)setupUI {
    // TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 设置 tableView 背景色为透明，显示父视图的背景色
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.hidden = YES;
    
    
    // 配置多选编辑
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    [self.tableView registerClass:[VoiceStoryTableViewCell class] forCellReuseIdentifier:@"VoiceStoryTableViewCell"];
    // 注册鱼骨效果cell
    [self.tableView registerClass:[SkeletonTableViewCell class] forCellReuseIdentifier:kSkeletonCellIdentifier];
    
    // 长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:longPress];
    self.tableView.mj_header =  [RYFGifHeader headerWithRefreshingBlock:^{
        [self loadData];
    }];
    
    [self.view addSubview:self.tableView];
    
    [self setupEditingToolbar];
    [self setupEmptyStateView];
}

- (void)setupTableViewConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customNavBarView.mas_bottom).offset(10);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
}

- (void)setupEmptyStateView {
    self.emptyStateView = [[UIView alloc] init];
    // 设置空状态视图背景色与整体背景色一致
    self.emptyStateView.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    self.emptyStateView.hidden = YES;
    [self.view addSubview:self.emptyStateView];
    
    UIImageView *emptyImageView = [[UIImageView alloc] init];
    emptyImageView.contentMode = UIViewContentModeScaleAspectFit;
    emptyImageView.tintColor = [UIColor colorWithWhite:0.85 alpha:1];
    emptyImageView.image = [UIImage imageNamed:@"create_empty"];
    [self.emptyStateView addSubview:emptyImageView];
    
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.text = @"暂无故事，请先创建";
    emptyLabel.font = [UIFont systemFontOfSize:16];
    emptyLabel.textColor = [UIColor systemGrayColor];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.emptyStateView addSubview:emptyLabel];
    
    UIButton *guideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [guideButton setTitle:@"View the Guide" forState:UIControlStateNormal];
    guideButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [guideButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [guideButton addTarget:self action:@selector(viewGuideButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyStateView addSubview:guideButton];
    
    UIButton *emptyMyVoiceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [emptyMyVoiceButton setTitle:@"My Voice" forState:UIControlStateNormal];
    [emptyMyVoiceButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    emptyMyVoiceButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    emptyMyVoiceButton.layer.borderColor = [UIColor systemBlueColor].CGColor;
    emptyMyVoiceButton.layer.borderWidth = 1.5;
    emptyMyVoiceButton.layer.cornerRadius = 18;
    emptyMyVoiceButton.backgroundColor = [UIColor whiteColor];
    [emptyMyVoiceButton addTarget:self action:@selector(myVoiceButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyStateView addSubview:emptyMyVoiceButton];
    
    UIButton *emptyCreateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [emptyCreateButton setTitle:@"Create Story" forState:UIControlStateNormal];
    [emptyCreateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    emptyCreateButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    emptyCreateButton.backgroundColor = [UIColor systemBlueColor];
    emptyCreateButton.layer.cornerRadius = 18;
    [emptyCreateButton addTarget:self action:@selector(createButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyStateView addSubview:emptyCreateButton];
    
    [self.emptyStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customNavBarView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
    [emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emptyStateView);
        make.centerY.equalTo(self.emptyStateView).offset(-80);
        make.width.height.mas_equalTo(120);
    }];
    
    [emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(emptyImageView.mas_bottom).offset(24);
        make.centerX.equalTo(self.emptyStateView);
        make.left.greaterThanOrEqualTo(self.emptyStateView).offset(16);
        make.right.lessThanOrEqualTo(self.emptyStateView).offset(-16);
    }];
    
    [guideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(emptyLabel.mas_bottom).offset(16);
        make.centerX.equalTo(self.emptyStateView);
    }];
    
    [emptyMyVoiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emptyStateView).multipliedBy(0.7);
        make.top.equalTo(guideButton.mas_bottom).offset(32);
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat myVoiceWidth = screenWidth <= 320 ? 70 : (screenWidth <= 375 ? 80 : (screenWidth <= 390 ? 85 : (screenWidth <= 414 ? 88 : 90)));
        make.width.mas_equalTo(myVoiceWidth);
        make.height.mas_equalTo(36);
    }];
    
    [emptyCreateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emptyStateView).multipliedBy(1.3);
        make.top.equalTo(guideButton.mas_bottom).offset(32);
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat createStoryWidth = screenWidth <= 320 ? 100 : (screenWidth <= 375 ? 110 : (screenWidth <= 390 ? 115 : (screenWidth <= 414 ? 120 : 122)));
        make.width.mas_equalTo(createStoryWidth);
        make.height.mas_equalTo(36);
    }];
}

- (void)setupEditingToolbar {
    // 创建工具栏但不添加到视图
    self.editingToolbar = [[UIView alloc] init];
    self.editingToolbar.backgroundColor = [UIColor whiteColor];
    self.editingToolbar.hidden = YES;
    self.editingToolbar.userInteractionEnabled = YES;
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    topLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self.editingToolbar addSubview:topLine];
    
    self.deleteSelectedButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.deleteSelectedButton setTitle:@"删除故事" forState:UIControlStateNormal];
    [self.deleteSelectedButton setTitle:@"删除故事" forState:UIControlStateDisabled];
    
    [self.deleteSelectedButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    [self.deleteSelectedButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateDisabled];
    
    self.deleteSelectedButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.deleteSelectedButton.layer.cornerRadius = 25;
    self.deleteSelectedButton.backgroundColor = [UIColor whiteColor];
    self.deleteSelectedButton.clipsToBounds = YES;
    self.deleteSelectedButton.enabled = NO;
    self.deleteSelectedButton.userInteractionEnabled = YES;
    
    [self.deleteSelectedButton addTarget:self action:@selector(deleteSelectedItems) forControlEvents:UIControlEventTouchUpInside];
    self.deleteSelectedButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.editingToolbar addSubview:self.deleteSelectedButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [topLine.topAnchor constraintEqualToAnchor:self.editingToolbar.topAnchor],
        [topLine.leadingAnchor constraintEqualToAnchor:self.editingToolbar.leadingAnchor],
        [topLine.trailingAnchor constraintEqualToAnchor:self.editingToolbar.trailingAnchor],
        [topLine.heightAnchor constraintEqualToConstant:0.5],
        
        [self.deleteSelectedButton.leadingAnchor constraintEqualToAnchor:self.editingToolbar.leadingAnchor constant:20],
        [self.deleteSelectedButton.trailingAnchor constraintEqualToAnchor:self.editingToolbar.trailingAnchor constant:-20],
        [self.deleteSelectedButton.topAnchor constraintEqualToAnchor:self.editingToolbar.topAnchor constant:15],
        [self.deleteSelectedButton.heightAnchor constraintEqualToConstant:50]
    ]];
    
    [self updateDeleteButtonState];
}

- (CGFloat)bottomSafeAreaInset {
    if (@available(iOS 11.0, *)) {
        UIView *parentView = self.tabBarController ? self.tabBarController.view : self.view;
        return parentView.safeAreaInsets.bottom;
    }
    return 0;
}



- (void)updateEmptyState {
    BOOL isEmpty = self.dataSource.count == 0;
    
    NSLog(@"更新空状态: 数据源数量 = %ld, isEmpty = %@", (long)self.dataSource.count, isEmpty ? @"YES" : @"NO");
    
    self.emptyStateView.hidden = !isEmpty;
    self.tableView.hidden = isEmpty;
}

#pragma mark - Data

- (void)loadData {
    NSLog(@"开始加载故事列表...");
    
    self.isLoading = YES;
    [self.tableView reloadData];
    
     //创建分页请求参数
    PageRequestModel *pageRequest = [[PageRequestModel alloc] initWithPageNum:1 pageSize:20];
    pageRequest.familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
//    pageRequest.storyStatus = 5;
    
    
    // 发起网络请求
    __weak typeof(self) weakSelf = self;
    
    [[AFStoryAPIManager sharedManager] getStoriesWithPage:pageRequest
                                                                          success:^(StoryListResponseModel *response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf.isLoading = NO;
        NSLog(@"✅ 获取故事列表成功，共 %ld 条", (long)response.total);
        [strongSelf.tableView.mj_header endRefreshing];
        // 更新数据源
        [strongSelf.dataSource removeAllObjects];
        [strongSelf.dataSource addObjectsFromArray:response.list];
        
        // 刷新界面
        [strongSelf.tableView reloadData];
        [strongSelf updateEmptyState];
        
        
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"❌ 获取故事列表失败: %@", error.localizedDescription);
        
        // 显示错误提示
        [strongSelf showErrorAlert:error.localizedDescription];
        
        // 如果没有数据，显示空状态
        [strongSelf updateEmptyState];
        
        strongSelf.currentLoadTask = nil;
    }];

    
}

- (void)refreshData {
    NSLog(@"开始刷新故事列表...");
    
    // 创建分页请求参数
    PageRequestModel *pageRequest = [[PageRequestModel alloc] initWithPageNum:1 pageSize:20];
    
    // 发起网络请求
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] getStoriesWithPage:pageRequest
                                                                          success:^(StoryListResponseModel *response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        weakSelf.isLoading = NO;
        NSLog(@"✅ 刷新故事列表成功，共 %ld 条", (long)response.total);
        
        // 更新数据源
        [strongSelf.dataSource removeAllObjects];
        [strongSelf.dataSource addObjectsFromArray:response.list];
        
        // 刷新界面
        [strongSelf.tableView reloadData];
        [strongSelf updateEmptyState];
        
        // 结束刷新动画
        [strongSelf endRefreshingWithSuccess];
        
        strongSelf.currentLoadTask = nil;
        
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"❌ 刷新故事列表失败: %@", error.localizedDescription);
        
        // 结束刷新动画
        [strongSelf endRefreshingWithSuccess];
        
        // 显示错误提示
        [strongSelf showErrorAlert:error.localizedDescription];
        
        // 如果没有数据，显示空状态
        [strongSelf updateEmptyState];
        
        strongSelf.currentLoadTask = nil;
    }];
}

- (void)endRefreshingWithSuccess {
    if (self.refreshControl.isRefreshing) {
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"下拉刷新"
                                                                    attributes:@{
            NSForegroundColorAttributeName: [UIColor systemGrayColor],
            NSFontAttributeName: [UIFont systemFontOfSize:14]
        }];
        self.refreshControl.attributedTitle = title;
        
        [self.refreshControl endRefreshing];
    }
}

// 保留作为测试用途的模拟数据方法
- (void)loadMockDataForTesting {
    NSLog(@"开始加载模拟数据...");
    
    NSArray *storyNames = @[
        @"小红帽的奇幻冒险之旅",
        @"勇敢的小猪三兄弟",
        @"森林里的秘密花园",
        @"太空探险家的星际旅行",
        @"魔法城堡里的公主救援",
        @"深海世界的美人鱼奇遇"
    ];
    
    NSArray *voices = @[@"Dad", @"Mom", @"--", @"Grandma", @"Dad", @"Mom"];
    NSArray *statuses = @[@"completed", @"completed", @"generating", @"failed", @"completed", @"completed"];
    NSArray *isNewFlags = @[@YES, @NO, @NO, @NO, @YES, @NO];
    NSArray *playingStates = @[@NO, @YES, @NO, @NO, @NO, @NO];
    
    if (!self.dataSource) {
        self.dataSource = [NSMutableArray array];
    }
    [self.dataSource removeAllObjects];
    
    for (int i = 0; i < 6; i++) {
        VoiceStoryModel *model = [[VoiceStoryModel alloc] init];
        model.storyId = i + 1;
        model.storyName = storyNames[i];
        model.voiceName = voices[i];
        model.status = statuses[i];
        model.isNew = [isNewFlags[i] boolValue];
        model.isPlaying = [playingStates[i] boolValue];
        
        NSArray *illustrationUrls = @[
            @"/illustration/redhood.png",
            @"/illustration/threepigs.png",
            @"/illustration/garden.png",
            @"/illustration/space.png",
            @"/illustration/castle.png",
            @"/illustration/mermaid.png"
        ];
        model.illustrationUrl = illustrationUrls[i];
        
        NSDate *now = [NSDate date];
        NSTimeInterval offset = -i * 24 * 60 * 60;
        NSDate *createDate = [now dateByAddingTimeInterval:offset];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        model.createTime = [formatter stringFromDate:createDate];
        
        if ([statuses[i] isEqualToString:@"generating"]) {
            model.statusDesc = @"Story Generation...";
        } else if ([statuses[i] isEqualToString:@"failed"]) {
            model.statusDesc = @"Generation Failed, Please Try Again";
        } else {
            NSInteger duration = 120 + arc4random_uniform(180);
            model.statusDesc = [NSString stringWithFormat:@"时长 %ld:%02ld", (long)(duration/60), (long)(duration%60)];
        }
        
        [self.dataSource addObject:model];
    }
    
    [self.tableView reloadData];
    [self updateEmptyState];
    
    NSLog(@"加载了基础模拟数据: %ld 个故事", (long)self.dataSource.count);
}

// 保留作为测试用途的刷新模拟数据方法
- (void)loadMockDataForRefreshTesting {
    NSArray *storyTitles = @[
        @"小红帽的奇幻冒险之旅程",
        @"勇敢的小猪三兄弟建造梦想家园",
        @"森林里的秘密花园探索记",
        @"太空探险家的星际旅行日记",
        @"魔法城堡里的公主救援任务",
        @"深海世界的美人鱼奇遇记",
        @"超级英雄拯救城市的故事",
        @"时光机器带来的未来科幻冒险",
        @"动物王国里的友谊传说",
        @"神奇宝盒里的童话世界"
    ];
    
    NSArray *voiceTypes = @[@"Dad", @"Mom", @"Grandma", @"Robot", @"Princess", @"Hero", @"--", @"Dad", @"Mom", @"Custom"];
    NSArray *storyStatuses = @[@"completed", @"completed", @"generating", @"completed", @"failed", @"completed", @"generating", @"completed", @"generating", @"failed"];
    NSArray *newFlags = @[@YES, @NO, @YES, @NO, @NO, @YES, @NO, @NO, @YES, @NO];
    NSArray *playStates = @[@NO, @NO, @NO, @YES, @NO, @NO, @NO, @NO, @NO, @NO];
    
    NSInteger storyCount = 5 + arc4random_uniform(6);
    
    if (!self.dataSource) {
        self.dataSource = [NSMutableArray array];
    }
    [self.dataSource removeAllObjects];
    
    for (int i = 0; i < storyCount; i++) {
        VoiceStoryModel *model = [[VoiceStoryModel alloc] init];
        model.storyId = i + 100;
        model.storyName = storyTitles[i % storyTitles.count];
        model.voiceName = voiceTypes[i % voiceTypes.count];
        model.status = storyStatuses[i % storyStatuses.count];
        model.isNew = [newFlags[i % newFlags.count] boolValue];
        model.isPlaying = [playStates[i % playStates.count] boolValue];
        
        NSArray *illustrationUrls = @[
            @"/illustration/fairy_tale.png",
            @"/illustration/adventure.png",
            @"/illustration/forest.png",
            @"/illustration/space.png",
            @"/illustration/castle.png",
            @"/illustration/ocean.png",
            @"/illustration/superhero.png",
            @"/illustration/scifi.png",
            @"/illustration/animal.png",
            @"/illustration/magic.png"
        ];
        model.illustrationUrl = illustrationUrls[i % illustrationUrls.count];
        
        NSDate *now = [NSDate date];
        NSTimeInterval randomOffset = -arc4random_uniform(7 * 24 * 60 * 60);
        NSDate *createDate = [now dateByAddingTimeInterval:randomOffset];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        model.createTime = [formatter stringFromDate:createDate];
        
        if ([model.status isEqualToString:@"generating"]) {
            NSArray *generatingMessages = @[
                @"Story Generation...",
                @"AI正在创作中...",
                @"语音合成进行中...",
                @"故事内容生成中..."
            ];
            model.statusDesc = generatingMessages[arc4random_uniform((uint32_t)generatingMessages.count)];
        } else if ([model.status isEqualToString:@"failed"]) {
            NSArray *failureMessages = @[
                @"Generation Failed, Please Try Again",
                @"网络连接失败，请重试",
                @"AI服务暂时不可用",
                @"语音合成失败，请重试"
            ];
            model.statusDesc = failureMessages[arc4random_uniform((uint32_t)failureMessages.count)];
        } else {
            NSInteger duration = 90 + arc4random_uniform(240);
            model.statusDesc = [NSString stringWithFormat:@"时长 %ld:%02ld", (long)(duration/60), (long)(duration%60)];
        }
        
        [self.dataSource addObject:model];
    }
    
    [self.dataSource sortUsingComparator:^NSComparisonResult(VoiceStoryModel *obj1, VoiceStoryModel *obj2) {
        return [obj2.createTime compare:obj1.createTime];
    }];
    
    [self.tableView reloadData];
    [self updateEmptyState];
    [self endRefreshingWithSuccess];
    
    NSLog(@"刷新加载了 %ld 个模拟故事数据", (long)self.dataSource.count);
}

#pragma mark - Batch Editing Mode

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        // ⭐️ 关键检查：如果有 cell 正在左滑删除状态，不允许进入批量编辑
        if ([self isAnyRowInSwipeDeleteState]) {
            NSLog(@"⚠️ 检测到左滑删除状态，阻止进入批量编辑模式");
            return;
        }
        
        CGPoint location = [gesture locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        
        if (indexPath && !self.isBatchEditingMode) {
            [self enterBatchEditingMode];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self updateDeleteButtonState];
        }
    }
}

// ⭐️ 新增方法：检查是否有 cell 在左滑删除状态
- (BOOL)isAnyRowInSwipeDeleteState {
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        VoiceStoryTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if ([cell isKindOfClass:[VoiceStoryTableViewCell class]]) {
            // 如果 cell 正在编辑状态，但不是批量编辑模式，说明是左滑删除
            if (cell.isEditing && !cell.isBatchEditingMode) {
                return YES;
            }
        }
    }
    
    return NO;
}

// ⭐️ 进入批量编辑模式
- (void)enterBatchEditingMode {
    NSLog(@"🔵 === 进入批量编辑模式 ===");
    
    // 1. 设置标记
    self.isBatchEditingMode = YES;
    
    // 2. TableView 进入编辑模式
    [self.tableView setEditing:YES animated:YES];
    
    // 3. 隐藏 TabBar
    if (self.tabBarController) {
        [UIView animateWithDuration:0.25 animations:^{
            self.tabBarController.tabBar.alpha = 0;
        } completion:^(BOOL finished) {
            self.tabBarController.tabBar.hidden = YES;
            self.tabBarController.tabBar.userInteractionEnabled = NO;
        }];
    }
    
    // 4. 更新导航栏
    [self updateCustomNavBarForEditingMode:YES];
    
    // 5. 添加并显示工具栏
    UIView *parentView = self.tabBarController ? self.tabBarController.view : self.view;
    if (self.editingToolbar.superview == nil) {
        [parentView addSubview:self.editingToolbar];
        
        self.editingToolbar.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.editingToolbar.leadingAnchor constraintEqualToAnchor:parentView.leadingAnchor],
            [self.editingToolbar.trailingAnchor constraintEqualToAnchor:parentView.trailingAnchor],
            [self.editingToolbar.bottomAnchor constraintEqualToAnchor:parentView.bottomAnchor],
            [self.editingToolbar.heightAnchor constraintEqualToConstant:80 + [self bottomSafeAreaInset]]
        ]];
    }
    
    self.editingToolbar.hidden = NO;
    self.editingToolbar.alpha = 0;
    self.editingToolbar.userInteractionEnabled = YES;
    
    // 6. 强制布局
    [self.editingToolbar setNeedsLayout];
    [self.editingToolbar layoutIfNeeded];
    [parentView setNeedsLayout];
    [parentView layoutIfNeeded];
    
    // 7. 更新 TableView 约束
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-80 - [self bottomSafeAreaInset]);
    }];
    
    // 8. 动画显示
    [UIView animateWithDuration:0.3 animations:^{
        self.editingToolbar.alpha = 1.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        NSLog(@"批量编辑模式动画完成");
        self.editingToolbar.userInteractionEnabled = YES;
        self.deleteSelectedButton.userInteractionEnabled = YES;
    }];
    
    // 9. 刷新所有可见的 cells，确保它们知道当前是批量编辑模式
    [self reloadVisibleCellsEditingState];
}

// ⭐️ 退出批量编辑模式
- (void)cancelBatchEditingMode {
    NSLog(@"🔴 === 退出批量编辑模式 ===");
    
    // 1. 清除标记
    self.isBatchEditingMode = NO;
    
    // 2. TableView 退出编辑模式
    [self.tableView setEditing:NO animated:YES];
    
    // 3. 更新导航栏
    [self updateCustomNavBarForEditingMode:NO];
    
    // 4. 恢复 TableView 约束
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
    // 5. 隐藏工具栏
    [UIView animateWithDuration:0.3 animations:^{
        self.editingToolbar.alpha = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.editingToolbar.hidden = YES;
        
        // 从视图移除
        [self.editingToolbar removeFromSuperview];
        
        // 恢复 TabBar
        if (self.tabBarController) {
            self.tabBarController.tabBar.hidden = NO;
            self.tabBarController.tabBar.userInteractionEnabled = YES;
            [UIView animateWithDuration:0.25 animations:^{
                self.tabBarController.tabBar.alpha = 1.0;
            }];
        }
    }];
    
    // 6. 重置按钮状态
    self.deleteSelectedButton.enabled = NO;
    [self updateDeleteButtonState];
    
    // 7. 刷新所有可见的 cells，确保它们知道已退出批量编辑模式
    [self reloadVisibleCellsEditingState];
}

// ⭐️ 刷新可见 cells 的编辑状态
- (void)reloadVisibleCellsEditingState {
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        VoiceStoryTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[VoiceStoryTableViewCell class]]) {
            // 更新 cell 的批量编辑标记
            cell.isBatchEditingMode = self.isBatchEditingMode;
            
            // 触发 setEditing 方法更新按钮状态
            [cell setEditing:cell.isEditing animated:YES];
        }
    }
    
    NSLog(@"已刷新 %ld 个可见 cells 的编辑状态", (long)visibleIndexPaths.count);
}

- (void)updateCustomNavBarForEditingMode:(BOOL)isEditing {
    for (UIView *subview in self.customNavBarView.subviews) {
        [subview removeFromSuperview];
    }
    
    if (isEditing) {
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [cancelButton addTarget:self action:@selector(cancelBatchEditingMode) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:cancelButton];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"故事删除";
        titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.customNavBarView addSubview:titleLabel];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [doneButton addTarget:self action:@selector(cancelBatchEditingMode) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:doneButton];
        
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.customNavBarView).offset(16);
            make.centerY.equalTo(self.customNavBarView);
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self.customNavBarView);
        }];
        
        [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.customNavBarView).offset(-16);
            make.centerY.equalTo(self.customNavBarView);
        }];
        
    } else {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"Story Creation";
        titleLabel.font = [UIFont fontWithName:@"SFRounded-Bold" size:20] ?: [UIFont boldSystemFontOfSize:20];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.customNavBarView addSubview:titleLabel];
        
        UIButton *soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [soundButton setImage:[UIImage systemImageNamed:@"speaker.wave.2.fill"] forState:UIControlStateNormal];
        soundButton.tintColor = [UIColor systemGrayColor];
        [soundButton addTarget:self action:@selector(soundButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:soundButton];
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setImage:[UIImage systemImageNamed:@"plus.circle.fill"] forState:UIControlStateNormal];
        addButton.tintColor = [UIColor systemGrayColor];
        [addButton addTarget:self action:@selector(addButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:addButton];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.customNavBarView).offset(16);
            make.centerY.equalTo(self.customNavBarView);
        }];
        
        [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.customNavBarView).offset(-16);
            make.centerY.equalTo(self.customNavBarView);
            make.width.height.mas_equalTo(28);
        }];
        
        [soundButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(addButton.mas_left).offset(-21);
            make.centerY.equalTo(self.customNavBarView);
            make.width.height.mas_equalTo(28);
        }];
    }
}

- (void)updateDeleteButtonState {
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSInteger selectedCount = selectedRows.count;
    
    self.deleteSelectedButton.enabled = selectedCount > 0;
    
    if (selectedCount > 0) {
        self.deleteSelectedButton.layer.borderColor = [UIColor systemRedColor].CGColor;
        self.deleteSelectedButton.layer.borderWidth = 1.5;
        self.deleteSelectedButton.backgroundColor = [UIColor whiteColor];
    } else {
        self.deleteSelectedButton.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1].CGColor;
        self.deleteSelectedButton.layer.borderWidth = 1.5;
        self.deleteSelectedButton.backgroundColor = [UIColor whiteColor];
    }
}

- (void)deleteSelectedItems {
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (selectedIndexPaths.count == 0) {
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"确定要删除选中的 %ld 个故事吗？", (long)selectedIndexPaths.count];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"删除"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self performBatchDelete:selectedIndexPaths];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)performBatchDelete:(NSArray<NSIndexPath *> *)indexPaths {
    // ✅ 使用 section 排序，从大到小删除
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath *obj2) {
        return obj2.section - obj1.section;
    }];
    
    // ✅ 使用 section 索引删除数据
    for (NSIndexPath *indexPath in sortedIndexPaths) {
        [self.dataSource removeObjectAtIndex:indexPath.section];
    }
    
    // ✅ 删除 sections 而不是 rows
    NSMutableIndexSet *sectionsToDelete = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in indexPaths) {
        [sectionsToDelete addIndex:indexPath.section];
    }
    [self.tableView deleteSections:sectionsToDelete withRowAnimation:UITableViewRowAnimationFade];
    
    [self cancelBatchEditingMode];
    [self updateEmptyState];
    
    NSLog(@"已删除 %ld 个故事", (long)indexPaths.count);
}

#pragma mark - UITableView DataSource

// ✅ 添加：每个 cell 作为一个独立的 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isLoading) {
            // 加载时显示5个鱼骨cell
            return 5;
        }
    
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1; // 每个 section 只有 1 行
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (self.isLoading) {
            // 显示鱼骨效果cell
            SkeletonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSkeletonCellIdentifier forIndexPath:indexPath];
            
            // 根据行号设置不同的样式，使效果更丰富
            SkeletonCellStyle style;
            if (indexPath.row % 3 == 0) {
                style = SkeletonCellStyleWithAvatar;
            } else if (indexPath.row % 3 == 1) {
                style = SkeletonCellStyleDetail;
            } else {
                style = SkeletonCellStyleDefault;
            }
            
            [cell configureWithStyle:style];
            [cell startSkeletonAnimation];
            
            return cell;
    } else{
        VoiceStoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoiceStoryTableViewCell" forIndexPath:indexPath];
        
        // ⭐️ 关键：设置 cell 的批量编辑标记
        cell.isBatchEditingMode = self.isBatchEditingMode;
        
        // ✅ 使用 section 而不是 row
        cell.model = self.dataSource[indexPath.section];
        
        __weak typeof(self) weakSelf = self;
        cell.settingsButtonTapped = ^{
            // [weakSelf showSettingsForIndex:indexPath.section];
        };
        
        cell.playButtonTapped = ^{
            [weakSelf playStoryAtIndex:indexPath.section];
        };
        
        return cell;
    }
      
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isLoading) {
            // 鱼骨cell的高度可以根据样式调整
            if (indexPath.row % 3 == 0) {
                return 64; // 带头像的样式
            } else if (indexPath.row % 3 == 1) {
                return 80; // 详情样式
            } else {
                return 60; // 默认样式
            }
    }else{
        // ✅ 使用 section 而不是 row
        VoiceStoryModel *model = self.dataSource[indexPath.section];
        
        // 如果是生成中或失败状态，需要额外的空间显示状态提示
        if (model.storyStatus ==1||model.storyStatus==3) {
            return 108; // 卡片内容高度，无上下边距
        }
        
        // 正常状态
        return 88; // 卡片内容高度，无上下边距
    }
    
    
    
}

// ✅ 添加：section 之间的间距（通过 footer 实现）
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 10 : 5; // 第一个 section 顶部间距大一些
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (self.isLoading) {
            return; // 加载期间不响应点击
        }
        
    
    
    
    if (self.isBatchEditingMode) {
        [self updateDeleteButtonState];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isBatchEditingMode) {
        [self updateDeleteButtonState];
    }
}

#pragma mark - UITableView Editing Style

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isBatchEditingMode) {
        // 批量编辑模式：返回 None，显示多选框
        return UITableViewCellEditingStyleNone;
    } else {
        // 左滑删除：显示删除按钮
        return UITableViewCellEditingStyleDelete;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - UITableView Swipe to Delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // ⭐️ 关键：在批量编辑模式下，禁止左滑删除
    // 批量编辑模式下 canEdit 仍然返回 YES，但会通过 editingStyle 控制行为
    return YES;
}

// ⭐️ 新增方法：控制是否允许开始左滑删除
- (BOOL)tableView:(UITableView *)tableView shouldBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    // 在批量编辑模式下，不允许左滑删除
    if (self.isBatchEditingMode) {
        NSLog(@"⚠️ 批量编辑模式下，阻止左滑删除");
        return NO;
    }
    return YES;
}

// ⭐️ 自定义左滑删除按钮（iOS 11+）
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 创建删除操作
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal  // 改为 Normal 以便自定义背景
                                                                               title:nil
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        // ✅ 使用 section 而不是 row
        [self deleteStoryAtIndex:indexPath.section];
        completionHandler(YES);
    }];
    
    // 设置自定义图片 create_delete
    deleteAction.image = [UIImage imageNamed:@"create_delete"];
    
    // 设置背景色为 #EA0000，透明度 10%
    deleteAction.backgroundColor = [UIColor colorWithRed:0xEA/255.0
                                                   green:0x00/255.0
                                                    blue:0x00/255.0
                                                   alpha:0.1];
    
    // 创建配置
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    
    // 设置是否需要完全滑动才能触发（NO = 点击即可触发）
    configuration.performsFirstActionWithFullSwipe = YES;
    
    return configuration;
}

// 保留此方法作为iOS 11以下的兼容
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // ✅ 使用 section 而不是 row
        [self deleteStoryAtIndex:indexPath.section];
    }
}

#pragma mark - Actions

- (void)soundButtonTapped {
    NSLog(@"点击了声音按钮");
    VoiceManagementViewController * voiceVC= [[VoiceManagementViewController alloc]init];
    [self.navigationController pushViewController:voiceVC animated:YES];
}

- (void)addButtonTapped {
    NSLog(@"点击了添加按钮");
    [self createButtonTapped];
}

- (void)viewGuideButtonTapped {
    NSLog(@"点击了 View the Guide");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"使用指南"
                                                                   message:@"学习如何创作精彩的语音故事\n\n小提示：下拉可以刷新故事列表哦！"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"重新加载"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self loadData];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"加载测试数据"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self loadMockDataForRefreshTesting];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"清空数据"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        [self updateEmptyState];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)myVoiceButtonTapped {
    NSLog(@"点击了 My Voice 按钮");
    VoiceManagementViewController * voiceVC= [[VoiceManagementViewController alloc]init];
    [self.navigationController pushViewController:voiceVC animated:YES];
}

- (void)createButtonTapped {
    NSLog(@"点击了 Create Story 按钮");
    
    CreateStoryViewController *createStoryVC = [[CreateStoryViewController alloc] init];
    [self.navigationController pushViewController:createStoryVC animated:YES];
}

- (void)deleteStoryAtIndex:(NSInteger)index {
    if (index >= self.dataSource.count) {
        return;
    }
    
    VoiceStoryModel *model = self.dataSource[index];
    NSLog(@"点击删除第 %ld 个故事: %@", (long)index, model.storyName);
    
    NSString *message = [NSString stringWithFormat:@"确定要删除故事 %@ 吗？", model.storyName];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"删除"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self performSingleDelete:index];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)performSingleDelete:(NSInteger)index {
    VoiceStoryModel *model = self.dataSource[index];
    
    [self.dataSource removeObjectAtIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self updateEmptyState];
    
    NSLog(@"本地已删除故事: %@", model.storyName);
}

- (void)playStoryAtIndex:(NSInteger)index {
    VoiceStoryModel *model = self.dataSource[index];
    
    if (model.canPlay) {
        NSLog(@"点击播放第 %ld 个故事: %@", (long)index, model.storyName);
    } else if (model.isGenerating) {
        NSLog(@"点击播放第 %ld 个故事，但正在生成中", (long)index);
    } else {
        NSLog(@"点击播放第 %ld 个故事，但未就绪", (long)index);
    }
}

#pragma mark - Helper Methods

- (void)showErrorAlert:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:errorMessage ?: @"网络请求失败，请稍后重试"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    });
}

@end
