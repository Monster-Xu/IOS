//
//  CreationViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/1.
//  Updated: 2025/10/16 - 集成骨架屏加载效果
//

#import "CreationViewController.h"
#import "VoiceStoryTableViewCell.h"
#import "VoiceManagementViewController.h"
#import "VoiceStoryModel.h"
#import "StoryBoundDoll.h"
#import "AFStoryAPIManager.h"
#import "APIRequestModel.h"
#import "APIResponseModel.h"
#import "CreateStoryViewController.h"
#import "SkeletonTableViewCell.h"
#import "CreateStoryWithVoiceViewController.h"
#import "AudioPlayerView.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "LGBaseAlertView.h"

static NSString *const kNormalCellIdentifier = @"NormalCell";
static NSString *const kSkeletonCellIdentifier = @"SkeletonCell";

@interface CreationViewController ()<UITableViewDelegate, UITableViewDataSource, AudioPlayerViewDelegate>

@property (nonatomic, strong) UIView *customNavBarView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<VoiceStoryModel *> *dataSource;
@property (nonatomic, strong) UIView *emptyStateView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSURLSessionDataTask *currentLoadTask;
@property (nonatomic, strong) NSMutableArray<NSURLSessionDataTask *> *activeTasks;
@property (nonatomic, assign) BOOL isLoading; // ✅ 加载状态
@property (nonatomic, assign) NSInteger skeletonRowCount; // ✅ 骨架屏行数
// ⭐️ 明确标记：是否处于单选编辑模式
@property (nonatomic, assign) BOOL isSingleEditingMode;

@property (nonatomic, strong) UIView *editingToolbar;
@property (nonatomic, strong) UIButton *deleteSelectedButton;
@property (nonatomic, assign) NSInteger selectedIndex; // 当前选中的索引（单选）

// 音频播放器
@property (nonatomic, strong) AudioPlayerView *currentAudioPlayer;
@property (nonatomic, assign) NSInteger currentPlayingIndex; // 记录当前播放的故事索引
@property (nonatomic, assign) NSInteger currentLoadingIndex; // 记录当前正在加载音频的故事索引

@end

@implementation CreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置整体背景色为 #F6F7FB
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.activeTasks = [NSMutableArray array];
    self.dataSource = [NSMutableArray array];
    
    // 初始化为非单选编辑模式
    self.isSingleEditingMode = NO;
    self.selectedIndex = -1; // 初始化为-1表示没有选中
    
    // 初始化播放状态
    self.currentPlayingIndex = -1; // -1 表示没有正在播放的音频
    self.currentLoadingIndex = -1; // -1 表示没有正在加载的音频
    
    // ✅ 初始化骨架屏相关属性
    self.isLoading = NO;
    self.skeletonRowCount = 5;  // 显示5行骨架屏
    
    [self setupNavigationBar];
    [self setupUI];
    [self setupTableViewConstraints];
    [self loadDataWithSkeleton];
    
}

- (void)dealloc {
    // 清理音频播放器
    if (self.currentAudioPlayer) {
        [self.currentAudioPlayer stop];
        self.currentAudioPlayer = nil;
    }
    
    if (self.editingToolbar.superview) {
        [self.editingToolbar removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    // 确保 TabBar 正常显示
    if (self.tabBarController && !self.isSingleEditingMode) {
        self.tabBarController.tabBar.hidden = NO;
        self.tabBarController.tabBar.alpha = 1.0;
        self.tabBarController.tabBar.userInteractionEnabled = YES;
    }
    
    // 页面将要出现时刷新数据（考虑条件刷新以优化性能）
    static BOOL firstTimeAppear = YES;
    if (firstTimeAppear || self.dataSource.count == 0) {
        // 首次出现或数据为空时才刷新
        [self loadDataWithSkeleton];
        firstTimeAppear = NO;
    } else {
        // 非首次出现，进行轻量级刷新（不显示骨架屏）
        [self refreshDataWithoutSkeleton];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isSingleEditingMode) {
        [self cancelSingleEditingMode];
    }
    
    // 清理音频播放器
    if (self.currentAudioPlayer) {
        [self.currentAudioPlayer stop];
    }
    
    // 隐藏加载指示器
    [SVProgressHUD dismiss];
    
    // 清除加载状态
    if (self.currentLoadingIndex >= 0) {
        [self updateLoadingStateForStory:self.currentLoadingIndex isLoading:NO];
        self.currentLoadingIndex = -1;
    }
    
    // ✅ 停止所有骨架屏动画
    for (SkeletonTableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[SkeletonTableViewCell class]]) {
            [cell stopSkeletonAnimation];
        }
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
    
    // ✅ 配置单选编辑模式
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    [self.tableView registerClass:[VoiceStoryTableViewCell class] forCellReuseIdentifier:@"VoiceStoryTableViewCell"];
    // ✅ 注册骨架屏 Cell
    [self.tableView registerClass:[SkeletonTableViewCell class] forCellReuseIdentifier:kSkeletonCellIdentifier];
    
    // 长按手势（单选编辑模式）
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:longPress];
    self.tableView.mj_header = [RYFGifHeader headerWithRefreshingBlock:^{
        [self refreshDataWithoutSkeleton];
    }];
    
    [self.view addSubview:self.tableView];
    
    [self setupEditingToolbar];
    [self setupEmptyStateView];
}

- (void)setupTableViewConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customNavBarView.mas_bottom).offset(5);
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
    emptyLabel.text = LocalString(@"No stories yet, please create one first");
    emptyLabel.font = [UIFont systemFontOfSize:16];
    emptyLabel.textColor = [UIColor systemGrayColor];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.emptyStateView addSubview:emptyLabel];
    
    UIButton *guideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [guideButton setTitle:@"View the Guide" forState:UIControlStateNormal];
    // 链接样式：更小的字体，下划线效果
    guideButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [guideButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [guideButton setTitleColor:[UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:0.6] forState:UIControlStateHighlighted];
    
    // 添加下划线效果，让它看起来更像链接
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] 
        initWithString:@"View the Guide" 
        attributes:@{
            NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
            NSForegroundColorAttributeName: [UIColor systemBlueColor],
            NSFontAttributeName: [UIFont systemFontOfSize:14]
        }];
    [guideButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    
    // 高亮状态的下划线效果
    NSAttributedString *highlightedTitle = [[NSAttributedString alloc] 
        initWithString:@"View the Guide" 
        attributes:@{
            NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
            NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:0.6],
            NSFontAttributeName: [UIFont systemFontOfSize:14]
        }];
    [guideButton setAttributedTitle:highlightedTitle forState:UIControlStateHighlighted];
    
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
    [self.deleteSelectedButton setTitle:@"Delete Stories" forState:UIControlStateNormal];
    [self.deleteSelectedButton setTitle:@"Delete Stories" forState:UIControlStateDisabled];
    
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
    
    // 只有在不是加载状态时才更新空状态
    if (!self.isLoading) {
        self.emptyStateView.hidden = !isEmpty;
        self.tableView.hidden = isEmpty;
        
        if (isEmpty) {
            // 确保空状态视图在最前面
            [self.view bringSubviewToFront:self.emptyStateView];
        }
    }
    
    // ✅ 更新导航栏按钮状态
    [self updateNavigationButtonsState];
}

/// ✅ 更新导航栏按钮状态，当达到限制时显示不同状态
- (void)updateNavigationButtonsState {
    BOOL isAtLimit = self.dataSource.count >= 10;
    
    // 更新导航栏中的添加按钮状态
    for (UIView *subview in self.customNavBarView.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            
            // 检查是否是添加按钮（通过图片名称或目标动作判断）
            NSArray *targets = [button allTargets].allObjects;
            for (id target in targets) {
                if (target == self) {
                    NSArray *actions = [button actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
                    if ([actions containsObject:@"addButtonTapped"]) {
                        // 这是添加按钮
                        if (isAtLimit) {
                            // 达到限制：半透明显示
                            button.alpha = 0.5;
                            button.tintColor = [UIColor systemGray3Color];
                        } else {
                            // 未达到限制：正常显示
                            button.alpha = 1.0;
                            button.tintColor = [UIColor systemGrayColor];
                        }
                        break;
                    }
                }
            }
        }
    }
    
    NSLog(@"📊 更新导航按钮状态 - 故事数量: %ld/10, 达到限制: %@", 
          (long)self.dataSource.count, isAtLimit ? @"是" : @"否");
}

#pragma mark - ✅ 数据加载（带骨架屏）

/// 加载故事列表，显示骨架屏加载效果
- (void)loadDataWithSkeleton {
    NSLog(@"[CreationVC] 开始加载数据，显示骨架屏...");
    
    // ✅ 显示骨架屏
    self.isLoading = YES;
    self.tableView.hidden = NO;
    self.emptyStateView.hidden = YES;
    [self.tableView reloadData];
    
    // 创建分页请求参数
    PageRequestModel *pageRequest = [[PageRequestModel alloc] initWithPageNum:1 pageSize:20];
    pageRequest.familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    
    // 发起网络请求
    __weak typeof(self) weakSelf = self;
    
    [[AFStoryAPIManager sharedManager] getStoriesWithPage:pageRequest success:^(StoryListResponseModel *response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"[CreationVC] 数据加载成功，共 %ld 条", (long)response.total);
        
        // ✅ 隐藏骨架屏
        strongSelf.isLoading = NO;
        
        // 更新数据源
        [strongSelf.dataSource removeAllObjects];
        [strongSelf.dataSource addObjectsFromArray:response.list];
        
        // 刷新 TableView，显示真实数据
        [strongSelf.tableView reloadData];
        [strongSelf updateEmptyState];
        
        NSLog(@"[CreationVC] TableView 已刷新，显示真实数据");
        
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"[CreationVC] 加载数据失败: %@", error.localizedDescription);
        
        // ✅ 隐藏骨架屏
        strongSelf.isLoading = NO;
        
        // 显示错误提示
//        [strongSelf showErrorAlert:error.localizedDescription];
        
        strongSelf.currentLoadTask = nil;
        
        // 如果没有数据，显示空状态
        [strongSelf updateEmptyState];
    }];
}

/// 轻量级刷新，不显示骨架屏
- (void)refreshDataWithoutSkeleton {
    NSLog(@"[CreationVC] 开始轻量级刷新...");
    
    // 创建分页请求参数
    PageRequestModel *pageRequest = [[PageRequestModel alloc] initWithPageNum:1 pageSize:20];
    pageRequest.familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    
    // 发起网络请求
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] getStoriesWithPage:pageRequest success:^(StoryListResponseModel *response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"[CreationVC] 轻量级刷新数据成功，共 %ld 条", (long)response.total);
        
        // 更新数据源
        [strongSelf.dataSource removeAllObjects];
        [strongSelf.dataSource addObjectsFromArray:response.list];
        
        // 刷新 TableView，显示真实数据
        [strongSelf.tableView reloadData];
        [strongSelf updateEmptyState];
         //结束刷新动画
        [strongSelf endRefreshingWithSuccess];
        
        strongSelf.currentLoadTask = nil;
        
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"[CreationVC] 轻量级刷新数据失败: %@", error.localizedDescription);
        
        // 静默处理错误，不显示提示
        //结束刷新动画
       [strongSelf endRefreshingWithSuccess];
       
       strongSelf.currentLoadTask = nil;
        // 如果没有数据，显示空状态
        [strongSelf updateEmptyState];
    }];
}

- (void)endRefreshingWithSuccess {
    if (self.tableView.mj_header.isRefreshing) {
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"
                                                                    attributes:@{
            NSForegroundColorAttributeName: [UIColor systemGrayColor],
            NSFontAttributeName: [UIFont systemFontOfSize:14]
        }];
//        self.tableView.mj_header.lastUpdatedTimeLabel. = title;
        
        [self.tableView.mj_header endRefreshing];
    }
}

#pragma mark - UITableView DataSource

/// ✅ 加载中显示骨架屏行数，加载完成显示真实数据行数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isLoading) {
        return self.skeletonRowCount;
    }
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // ✅ 加载中返回骨架屏 Cell
    if (self.isLoading) {
        SkeletonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSkeletonCellIdentifier forIndexPath:indexPath];
        
        // 配置骨架屏样式（带头像样式）
        [cell configureWithStyle:SkeletonCellStyleWithAvatar];
        
        // 开始骨架屏动画
        [cell startSkeletonAnimation];
        
        return cell;
    }
    
    // ✅ 数据加载完成返回真实 Cell
    VoiceStoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoiceStoryTableViewCell" forIndexPath:indexPath];
    
    // ⭐️ 关键：设置 cell 的单选编辑标记
    cell.isBatchEditingMode = self.isSingleEditingMode;
    
    // ✅ 使用 section 而不是 row
    cell.model = self.dataSource[indexPath.section];
    
    // ✅ 设置cell的显示状态（编辑模式/正常模式）
    [self updateCellDisplayState:cell atIndexPath:indexPath];
    
    // ✅ 设置选择按钮点击事件（如果cell有选择按钮的话）
    if ([cell respondsToSelector:@selector(chooseButton)] && cell.chooseButton) {
        [cell.chooseButton addTarget:self action:@selector(cellChooseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    __weak typeof(self) weakSelf = self;
    
    // 编辑按钮点击事件 - 根据 storyStatus 跳转到不同的控制器
    cell.settingsButtonTapped = ^{
        [weakSelf handleEditButtonTappedAtIndex:indexPath.section];
    };
    
    cell.playButtonTapped = ^{
        [weakSelf playStoryAtIndex:indexPath.section];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isLoading) {
        // 骨架屏的高度可以根据样式调整
        return 76;
    } else {
        // ✅ 使用 section 而不是 row
        VoiceStoryModel *model = self.dataSource[indexPath.section];
        
        // 如果是生成中、音频生成中或失败状态，需要额外的空间显示状态提示
        if (model.storyStatus == 1 || model.storyStatus == 3 || model.storyStatus == 4 ||model.storyStatus==6){
            return 122; // 卡片内容高度，无上下边距
        }
        
        // 正常状态
        return 88; // 卡片内容高度，无上下边距
    }
}

// ✅ 添加：section 之间的间距（通过 footer 实现）
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 5 : 5; // 第一个 section 顶部间距大一些
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
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
    
    if (self.isSingleEditingMode) {
        // ✅ 单选编辑模式下的点击逻辑
        NSInteger previousSelectedIndex = self.selectedIndex;
        
        if (self.selectedIndex == indexPath.section) {
            // 如果点击的是当前选中的项目，取消选中
            self.selectedIndex = -1;
            [self updateDeleteButtonState];
            NSLog(@"❌ 取消选中项目 - section: %ld", (long)indexPath.section);
        } else {
            // 如果点击的是其他项目，选中该项目
            self.selectedIndex = indexPath.section;
            [self updateDeleteButtonState];
            NSLog(@"✅ 选中项目 - section: %ld", (long)indexPath.section);
        }
        
        // ✅ 更新之前选中的cell状态（如果有的话）
        if (previousSelectedIndex >= 0 && previousSelectedIndex < self.dataSource.count && previousSelectedIndex != indexPath.section) {
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:0 inSection:previousSelectedIndex];
            VoiceStoryTableViewCell *previousCell = [self.tableView cellForRowAtIndexPath:previousIndexPath];
            if ([previousCell isKindOfClass:[VoiceStoryTableViewCell class]]) {
                [self updateCellDisplayState:previousCell atIndexPath:previousIndexPath];
            }
        }
        
        // ✅ 更新当前点击的cell状态
        VoiceStoryTableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([currentCell isKindOfClass:[VoiceStoryTableViewCell class]]) {
            [self updateCellDisplayState:currentCell atIndexPath:indexPath];
        }
        
    } else {
        // 根据 storyStatus 跳转到不同的控制器
        [self handleCellTappedAtIndex:indexPath.section];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSingleEditingMode) {
        [self updateDeleteButtonState];
    }
}

#pragma mark - UITableView Editing Style

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSingleEditingMode) {
        // 单选编辑模式：返回 None，不显示删除按钮（通过自定义选择实现）
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
    // ✅ 加载中不允许编辑
    if (self.isLoading) {
        return NO;
    }
    return YES;
}

// 左滑删除时阻止单选编辑模式
- (BOOL)tableView:(UITableView *)tableView shouldBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    // 在单选编辑模式下，不允许左滑删除
    if (self.isSingleEditingMode) {
        return NO;
    }
    return YES;
}

// 自定义左滑删除按钮（iOS 11+）
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 加载中不显示删除操作
    if (self.isLoading) {
        return nil;
    }
    
    // 创建删除操作
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                               title:nil
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
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
    
    // 设置是否需要完全滑动才能触发（YES = 完全滑动才能触发）
    configuration.performsFirstActionWithFullSwipe = YES;
    
    return configuration;
}

// 保留此方法作为iOS 11以下的兼容
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteStoryAtIndex:indexPath.section];
    }
}

#pragma mark - Batch Editing Mode

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        // 检查是否有 cell 正在左滑删除状态，如果有则阻止进入单选编辑
        if ([self isAnyRowInSwipeDeleteState]) {
            NSLog(@"⚠️ 检测到左滑删除状态，阻止进入单选编辑模式");
            return;
        }
        
        // 加载中不允许长按进入编辑模式
        if (self.isLoading) {
            NSLog(@"⚠️ 正在加载数据，不允许进入编辑模式");
            return;
        }
        
        // 如果数据源为空，不允许进入编辑模式
        if (self.dataSource.count == 0) {
            NSLog(@"⚠️ 数据源为空，不允许进入编辑模式");
            return;
        }
        
        CGPoint location = [gesture locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        
        if (indexPath && !self.isSingleEditingMode) {
            NSLog(@"✅ 长按触发单选编辑模式，索引: %ld", (long)indexPath.section);
            
            // 提供触觉反馈
            if (@available(iOS 10.0, *)) {
                UIImpactFeedbackGenerator *feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
                [feedbackGenerator prepare];
                [feedbackGenerator impactOccurred];
            }
            
            // 进入单选编辑模式并自动选中长按的项目
            [self enterSingleEditingModeWithSelectedIndex:indexPath.section];
            
            NSLog(@"✅ 单选编辑模式已激活，已选中第 %ld 个项目", (long)indexPath.section);
        }
    }
}

// 检查是否有 cell 在左滑删除状态
- (BOOL)isAnyRowInSwipeDeleteState {
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        VoiceStoryTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if ([cell isKindOfClass:[VoiceStoryTableViewCell class]]) {
            // 如果 cell 正在编辑状态，但不是单选编辑模式，说明是左滑删除
            if (cell.isEditing && !cell.isBatchEditingMode) {
                return YES;
            }
        }
    }
    
    return NO;
}

// 进入单选编辑模式
- (void)enterSingleEditingMode {
    [self enterSingleEditingModeWithSelectedIndex:-1];
}

// 进入单选编辑模式并指定初始选中项
- (void)enterSingleEditingModeWithSelectedIndex:(NSInteger)selectedIndex {
    NSLog(@"🔵 === 进入单选编辑模式，初始选中索引: %ld ===", (long)selectedIndex);
    
    // 停止当前音频播放
    if (self.currentAudioPlayer) {
        [self.currentAudioPlayer stop];
        [self updatePlayingStateForStory:self.currentPlayingIndex isPlaying:NO];
        self.currentPlayingIndex = -1;
        self.currentAudioPlayer = nil;
    }
    
    // 清除加载状态
    if (self.currentLoadingIndex >= 0) {
        [SVProgressHUD dismiss];
        [self updateLoadingStateForStory:self.currentLoadingIndex isLoading:NO];
        self.currentLoadingIndex = -1;
    }
    
    // 1. 设置标记
    self.isSingleEditingMode = YES;
    // ✅ 设置初始选中索引
    self.selectedIndex = selectedIndex;
    
    // 2. TableView 不使用系统编辑模式，使用自定义单选逻辑
    // [self.tableView setEditing:YES animated:YES]; // 禁用系统编辑模式
    
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
    [self showEditingToolbar];
    
    // 6. 刷新所有可见 cells，确保它们知道当前是单选编辑模式
    [self reloadVisibleCellsEditingState];
    
    // 7. ✅ 特别处理：确保长按选中的cell立即显示选中状态
    if (selectedIndex >= 0 && selectedIndex < self.dataSource.count) {
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:selectedIndex];
        VoiceStoryTableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        if ([selectedCell isKindOfClass:[VoiceStoryTableViewCell class]]) {
            [self updateCellDisplayState:selectedCell atIndexPath:selectedIndexPath];
            NSLog(@"🎯 强制更新长按选中cell状态 - section: %ld", (long)selectedIndex);
        }
    }
    
    // 8. 更新删除按钮状态
    [self updateDeleteButtonState];
    
    NSLog(@"✅ 单选编辑模式激活完成，选中索引: %ld", (long)self.selectedIndex);
}

// 显示编辑工具栏
- (void)showEditingToolbar {
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
    
    // 强制布局
    [self.editingToolbar setNeedsLayout];
    [self.editingToolbar layoutIfNeeded];
    [parentView setNeedsLayout];
    [parentView layoutIfNeeded];
    
    // 更新 TableView 约束
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-80 - [self bottomSafeAreaInset]);
    }];
    
    // 动画显示
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.editingToolbar.alpha = 1.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.editingToolbar.userInteractionEnabled = YES;
        self.deleteSelectedButton.userInteractionEnabled = YES;
    }];
}

// 退出单选编辑模式
- (void)cancelSingleEditingMode {
    NSLog(@"🔴 === 退出单选编辑模式 ===");
    
    // 1. 清除标记
    self.isSingleEditingMode = NO;
    self.selectedIndex = -1;
    
    // 2. TableView 不使用系统编辑模式
    // [self.tableView setEditing:NO animated:YES]; // 不使用系统编辑模式
    
    // 3. 更新导航栏
    [self updateCustomNavBarForEditingMode:NO];
    
    // 4. 恢复 TableView 约束
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
    // 5. 隐藏工具栏
    [self hideEditingToolbar];
    
    // 6. 重置按钮状态
    self.deleteSelectedButton.enabled = NO;
    [self updateDeleteButtonState];
    
    // 7. 刷新所有可见 cells，确保它们知道已退出单选编辑模式
    [self reloadVisibleCellsEditingState];
    
    NSLog(@"✅ 单选编辑模式退出完成");
}

// 隐藏编辑工具栏
- (void)hideEditingToolbar {
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
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
}

/// ✅ 处理cell中选择按钮的点击事件
- (void)cellChooseButtonTapped:(UIButton *)sender {
    // 找到按钮所属的cell
    UIView *view = sender.superview;
    while (view && ![view isKindOfClass:[UITableViewCell class]]) {
        view = view.superview;
    }
    
    if ([view isKindOfClass:[VoiceStoryTableViewCell class]]) {
        // 获取cell的indexPath
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(VoiceStoryTableViewCell *)view];
        if (indexPath) {
            NSLog(@"🔘 选择按钮点击 - section: %ld", (long)indexPath.section);
            // 触发didSelectRowAtIndexPath逻辑
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
    }
}

/// ✅ 自定义更新cell的显示状态（不依赖系统editing模式）
- (void)updateCellDisplayState:(VoiceStoryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (!cell || !indexPath) {
        return;
    }
    
    // 设置cell的编辑模式状态
    cell.isBatchEditingMode = self.isSingleEditingMode;
    
    if (self.isSingleEditingMode) {
        // ✅ 单选编辑模式：显示选择按钮，设置选中状态
        BOOL isSelected = (self.selectedIndex == indexPath.section);
        cell.isCustomSelected = isSelected;
        
        // ✅ 先调用setEditing来切换UI状态
        [cell setEditing:YES animated:YES];
        
        // ✅ 然后更新选择状态
        [cell updateSelectionState:isSelected];
        
        NSLog(@"📝 更新cell显示状态 - section: %ld, 选中状态: %@", 
              (long)indexPath.section, isSelected ? @"是" : @"否");
    } else {
        // ✅ 正常模式：隐藏选择按钮，退出编辑状态
        cell.isCustomSelected = NO;
        
        // ✅ 退出编辑状态
        [cell setEditing:NO animated:YES];
        
        // ✅ 确保选择状态为未选中
        [cell updateSelectionState:NO];
    }
}

// 刷新可见 cells 的编辑状态（自定义单选模式）
- (void)reloadVisibleCellsEditingState {
    NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        VoiceStoryTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[VoiceStoryTableViewCell class]]) {
            // 更新 cell 的单选编辑标记
            cell.isBatchEditingMode = self.isSingleEditingMode;
            
            // ✅ 手动调用setEditing方法来更新cell状态
            [cell setEditing:self.isSingleEditingMode animated:YES];
            
            // ✅ 自定义更新cell的显示状态
            [self updateCellDisplayState:cell atIndexPath:indexPath];
            
            NSLog(@"🔄 刷新cell编辑状态 - section: %ld, 编辑模式: %@, 选中状态: %@", 
                  (long)indexPath.section, 
                  self.isSingleEditingMode ? @"是" : @"否",
                  (self.selectedIndex == indexPath.section) ? @"是" : @"否");
        }
    }
}

- (void)updateCustomNavBarForEditingMode:(BOOL)isEditing {
    for (UIView *subview in self.customNavBarView.subviews) {
        [subview removeFromSuperview];
    }
    
    if (isEditing) {
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [cancelButton addTarget:self action:@selector(cancelSingleEditingMode) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:cancelButton];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"Delete Story";
        titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.customNavBarView addSubview:titleLabel];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [doneButton addTarget:self action:@selector(cancelSingleEditingMode) forControlEvents:UIControlEventTouchUpInside];
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
        [soundButton setImage:[UIImage imageNamed:@"create_voice"] forState:UIControlStateNormal];
        soundButton.tintColor = [UIColor systemGrayColor];
        [soundButton addTarget:self action:@selector(soundButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:soundButton];
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setImage:[UIImage imageNamed:@"create_add"] forState:UIControlStateNormal];
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
    BOOL hasSelection = (self.selectedIndex >= 0);
    
    self.deleteSelectedButton.enabled = hasSelection;
    
    if (hasSelection) {
        [self.deleteSelectedButton setTitle:@"Delete Story" forState:UIControlStateNormal];
        [self.deleteSelectedButton setTitle:@"Delete Story" forState:UIControlStateDisabled];
        
        // ✅ 设置红色字体白色底，边框为1的红色
        [self.deleteSelectedButton setTitleColor:[UIColor colorWithRed:0xEA/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.deleteSelectedButton setBackgroundColor:[UIColor whiteColor]];
        self.deleteSelectedButton.layer.borderColor = [UIColor colorWithRed:0xEA/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:1.0].CGColor;
        self.deleteSelectedButton.layer.borderWidth = 1.5;
    } else {
        [self.deleteSelectedButton setTitle:@"Delete Story" forState:UIControlStateNormal];
        [self.deleteSelectedButton setTitle:@"Delete Story" forState:UIControlStateDisabled];
        
        // ✅ 设置禁用状态的样式
        [self.deleteSelectedButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateDisabled];
        [self.deleteSelectedButton setBackgroundColor:[UIColor whiteColor]];
        self.deleteSelectedButton.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1].CGColor;
        self.deleteSelectedButton.layer.borderWidth = 1.5;
    }
}

- (void)deleteSelectedItems {
    if (self.selectedIndex < 0 || self.selectedIndex >= self.dataSource.count) {
        return;
    }
    
    VoiceStoryModel *model = self.dataSource[self.selectedIndex];
    
    // ✅ 检查故事是否已绑定公仔
    if ([self checkStoryBoundDoll:model]) {
        // 已绑定公仔，显示特殊确认弹窗
        [self showBoundDollDeletionConfirmForModel:model atIndex:self.selectedIndex];
        return;
    }
    
    // 正常删除确认流程
    NSString *title = @"Confirm Deletion";
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete the story '%@'?", model.storyName ?: @"Untitled Story"];
    
    __weak typeof(self) weakSelf = self;
    [LGBaseAlertView showAlertWithTitle:title
                                content:message
                             cancelBtnStr:@"Cancel"
                            confirmBtnStr:@"Delete"
                            confirmBlock:^(BOOL is_value, id obj) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && is_value) { // 用户点击了"Delete"按钮
            [strongSelf performSingleDeleteAtIndex:strongSelf.selectedIndex];
        }
        // is_value == NO 是"Cancel"按钮，无需处理
    }];
}

- (void)performSingleDeleteAtIndex:(NSInteger)index {
    NSLog(@"🗑️ 开始删除第 %ld 个故事", (long)index);
    
    if (index < 0 || index >= self.dataSource.count) {
        NSLog(@"❌ 删除索引越界: %ld", (long)index);
        return;
    }
    
    VoiceStoryModel *model = self.dataSource[index];
    NSString *storyName = model.storyName ?: @"Untitled Story";
    
    // 如果有正在播放的音频，且要删除的是正在播放的项目，则停止播放
    if (self.currentPlayingIndex == index) {
        [self.currentAudioPlayer stop];
        self.currentPlayingIndex = -1;
        self.currentAudioPlayer = nil;
    }
    
    // 先从 UI 中移除
    [self.dataSource removeObjectAtIndex:index];
    
    // 删除对应的 section
    NSIndexSet *sectionsToDelete = [NSIndexSet indexSetWithIndex:index];
    [self.tableView deleteSections:sectionsToDelete withRowAnimation:UITableViewRowAnimationFade];
    
    // 退出单选编辑模式
    [self cancelSingleEditingMode];
    
    // 更新空状态
    [self updateEmptyState];
    
    // 调用后台删除 API
    [[AFStoryAPIManager sharedManager] deleteStoryWithId:model.storyId success:^(APIResponseModel * _Nonnull response) {
        NSLog(@"✅ 故事删除成功: %@", storyName);
        
        // 显示删除成功提示
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *successMessage = [NSString stringWithFormat:@"Story '%@' has been successfully deleted.", storyName];
            [LGBaseAlertView showAlertWithContent:successMessage confirmBlock:^(BOOL is_value, id obj) {
                // 用户点击确定按钮，无需额外处理
            }];
        });
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"❌ 故事删除失败: %@", error.localizedDescription);
        
        // 删除失败时显示错误提示并重新加载数据
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString *errorMessage = [NSString stringWithFormat:@"Failed to delete story '%@'. %@", storyName, error.localizedDescription ?: @"Please try again later."];
//            [LGBaseAlertView showAlertWithContent:errorMessage confirmBlock:^(BOOL is_value, id obj) {
//                // 重新加载数据以确保数据一致性
//                [self loadDataWithSkeleton];
//            }];
//        });
    }];
    
    NSLog(@"✅ 单个删除完成");
}

#pragma mark - Story Navigation Methods

/// 处理编辑按钮点击事件 - 根据 storyStatus 跳转到不同的控制器
- (void)handleEditButtonTappedAtIndex:(NSInteger)index {
    if (index >= self.dataSource.count) {
        return;
    }
    
    VoiceStoryModel *model = self.dataSource[index];
    NSLog(@"编辑按钮点击 - 故事: %@, status: %ld", model.storyName, (long)model.storyStatus);
    
    [self navigateToEditControllerWithModel:model];
}

/// 处理 cell 点击事件 - 根据 storyStatus 跳转到不同的控制器
- (void)handleCellTappedAtIndex:(NSInteger)index {
    if (index >= self.dataSource.count) {
        return;
    }
    
    VoiceStoryModel *model = self.dataSource[index];
    NSLog(@"Cell 点击 - 故事: %@, status: %ld", model.storyName, (long)model.storyStatus);
    
    [self navigateToEditControllerWithModel:model];
}

/// 根据模型状态导航到对应的编辑控制器
- (void)navigateToEditControllerWithModel:(VoiceStoryModel *)model {
    switch (model.storyStatus) {
        case 2: // 跳转到 CreateStoryWithVoiceVC
        {
            CreateStoryWithVoiceViewController *voiceVC = [[CreateStoryWithVoiceViewController alloc] initWithEditMode:NO];
            voiceVC.storyId = model.storyId;
            [self.navigationController pushViewController:voiceVC animated:YES];
            NSLog(@"✅ 跳转到 CreateStoryWithVoiceViewController，storyId: %ld", (long)model.storyId);
            break;
        }
        case 5: // 跳转到 CreateStoryWithVoiceVC（播放按钮可用）
        {
            CreateStoryWithVoiceViewController *voiceVC = [[CreateStoryWithVoiceViewController alloc] initWithEditMode:YES];
            voiceVC.storyId = model.storyId;
            [self.navigationController pushViewController:voiceVC animated:YES];
            NSLog(@"✅ 跳转到 CreateStoryWithVoiceViewController，storyId: %ld", (long)model.storyId);
            break;
        }
        case 6: // 跳转到 CreateStoryWithVoiceVC（播放按钮不可用）
        {
            CreateStoryWithVoiceViewController *voiceVC = [[CreateStoryWithVoiceViewController alloc] initWithEditMode:YES];
            voiceVC.storyId = model.storyId;
            [self.navigationController pushViewController:voiceVC animated:YES];
            NSLog(@"✅ 跳转到 CreateStoryWithVoiceViewController，storyId: %ld", (long)model.storyId);
            break;
        }
        case 3: // 跳转到 CreateStoryVC，传递故事数据用于编辑
        {
            CreateStoryViewController *createVC = [[CreateStoryViewController alloc] init];
            // ✅ 传递故事模型数据，用于预填充表单
            createVC.storyModel = model;
            [self.navigationController pushViewController:createVC animated:YES];
            NSLog(@"✅ 跳转到 CreateStoryViewController（生成失败重新编辑），storyId: %ld", (long)model.storyId);
            break;
        }
        default:
            // 其他状态下编辑按钮不显示，理论上不会到这里
            NSLog(@"⚠️ 故事状态 %ld 不支持编辑", (long)model.storyStatus);
            break;
    }
    
    
}

#pragma mark - Actions

- (void)soundButtonTapped {
    NSLog(@"点击了声音按钮");
    //埋点：点击进入声音复刻功能入口
    [[AnalyticsManager sharedManager]reportEventWithName:@"voice_clone_entry_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"点击“声音复刻”功能按钮时" properties:nil completion:^(BOOL success, NSString * _Nullable message) {
            
    }];
    
    VoiceManagementViewController *voiceVC = [[VoiceManagementViewController alloc] init];
    [self.navigationController pushViewController:voiceVC animated:YES];
}

- (void)addButtonTapped {
    NSLog(@"点击了添加按钮");
    [self createButtonTapped];
}

- (void)viewGuideButtonTapped {
    NSLog(@"点击了查看指南按钮");
    // TODO: 实现查看指南功能
        MyWebViewController* VC  = [[ MyWebViewController alloc] init];
         VC.changeNavColor = YES;
//       [VC setNavigationBarColor:[UIColor redColor]];
        VC.title =@"View the Guide";
        VC.mainUrl = @"https://app-pre.talenpalussaastest.com/static/Guidingdiagram.png";
        [self.navigationController pushViewController:VC animated:YES];
    // 可以跳转到教程页面或显示使用说明
}

- (void)myVoiceButtonTapped {
    NSLog(@"点击了 My Voice 按钮");
    VoiceManagementViewController *voiceVC = [[VoiceManagementViewController alloc] init];
    [self.navigationController pushViewController:voiceVC animated:YES];
    //APP埋点：点击创建音色
        [[AnalyticsManager sharedManager]reportEventWithName:@"voice_clone_entry_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"点击“声音复刻”功能按钮时" properties:nil completion:^(BOOL success, NSString * _Nullable message) {
                
        }];
}

- (void)createButtonTapped {
    NSLog(@"点击了 Create Story 按钮");
    
    // 检查故事数量是否超过限制
    if (self.dataSource.count >= 10) {
        [self showStoryLimitAlert];
        return;
    }
    
    // 正常创建流程
    CreateStoryViewController *createStoryVC = [[CreateStoryViewController alloc] init];
    [self.navigationController pushViewController:createStoryVC animated:YES];
    
    //APP埋点：点击进入故事创作功能
        [[AnalyticsManager sharedManager]reportEventWithName:@"create_story_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"点击故事创作的“+”功能按钮、以及故事清单为空创建故事时" properties:nil completion:^(BOOL success, NSString * _Nullable message) {
                
        }];
}

- (void)deleteStoryAtIndex:(NSInteger)index {
    if (index >= self.dataSource.count) {
        return;
    }
    
    VoiceStoryModel *model = self.dataSource[index];
    NSLog(@"点击删除第 %ld 个故事: %@", (long)index, model.storyName);
    
    // ✅ 检查故事是否已绑定公仔
    if ([self checkStoryBoundDoll:model]) {
        // 已绑定公仔，显示特殊确认弹窗
        [self showBoundDollDeletionConfirmForModel:model atIndex:index];
        return;
    }
    
    // 正常删除确认流程
    NSString *title = @"Confirm Deletion";
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete the story '%@'?", model.storyName ?: @"Untitled Story"];
    
    __weak typeof(self) weakSelf = self;
    [LGBaseAlertView showAlertWithTitle:title
                                content:message
                             cancelBtnStr:@"Cancel"
                            confirmBtnStr:@"Delete"
                            confirmBlock:^(BOOL is_value, id obj) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && is_value) { // 用户点击了"Delete"按钮
            [strongSelf performSingleDelete:index];
        }
        // is_value == NO 是"Cancel"按钮，无需处理
    }];
}

- (void)performSingleDelete:(NSInteger)index {
    VoiceStoryModel *model = self.dataSource[index];
    
    [[AFStoryAPIManager sharedManager] deleteStoryWithId:model.storyId success:^(APIResponseModel * _Nonnull response) {
        
        [self refreshDataWithoutSkeleton];
    } failure:^(NSError * _Nonnull error) {
//        [self showErrorAlert:error.localizedDescription];
    }];
}

- (void)playStoryAtIndex:(NSInteger)index {
    VoiceStoryModel *model = self.dataSource[index];
    
    // 只有 status = 5 时播放按钮才可用
    if (model.storyStatus == 5) {
        NSLog(@"点击播放第 %ld 个故事: %@", (long)index, model.storyName);
        
        // 如果已有播放器在播放其他音频，先停止
        if (self.currentAudioPlayer && self.currentPlayingIndex != index) {
            [self.currentAudioPlayer stop];
            [self updatePlayingStateForStory:self.currentPlayingIndex isPlaying:NO];
            
            // 如果之前有加载状态，清除它
            if (self.currentLoadingIndex >= 0 && self.currentLoadingIndex != index) {
                [SVProgressHUD dismiss];
                [self updateLoadingStateForStory:self.currentLoadingIndex isLoading:NO];
            }
        }
        
        // 如果点击的是当前正在播放的故事
        if (self.currentPlayingIndex == index && self.currentAudioPlayer) {
            if ([self.currentAudioPlayer isPlaying]) {
                // 当前正在播放，暂停
                [self.currentAudioPlayer stop];
                model.isPlaying = NO;
            } else {
                // 当前暂停，继续播放
                [self.currentAudioPlayer play];
                model.isPlaying = YES;
            }
        } else {
            // 播放新的音频
            [self playNewAudioForModel:model atIndex:index];
        }
        
        // 刷新对应的 cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    } else {
        NSLog(@"⚠️ 故事状态 %ld 不支持播放", (long)model.storyStatus);
    }
}

/// 播放新的音频
- (void)playNewAudioForModel:(VoiceStoryModel *)model atIndex:(NSInteger)index {
    NSLog(@"🎵 尝试播放音频 - 故事: %@, audioUrl: %@", model.storyName, model.audioUrl);
    
    // 检查音频URL
    if (!model.audioUrl || model.audioUrl.length == 0) {
        NSLog(@"⚠️ 音频URL为空，无法播放");
        return;
    }
    
    // 设置当前正在加载的索引
    self.currentLoadingIndex = index;
    
    // 显示加载中
    [SVProgressHUD showWithStatus:@"Loading audio..."];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    // 更新 cell 状态为加载中
    [self updateLoadingStateForStory:index isLoading:YES];
    
    // 设置超时处理，防止长时间加载
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && strongSelf.currentLoadingIndex == index) {
            NSLog(@"⚠️ 音频加载超时");
            [SVProgressHUD showErrorWithStatus:@"Loading timeout, please try again"];
            [strongSelf updateLoadingStateForStory:index isLoading:NO];
            strongSelf.currentLoadingIndex = -1;
        }
    });
    
    // 创建新的音频播放器（后台播放模式，不显示UI）
    self.currentAudioPlayer = [[AudioPlayerView alloc] initWithAudioURL:model.audioUrl backgroundPlay:YES];
    self.currentAudioPlayer.delegate = self;
    
    // 直接在后台播放，不显示UI
    [self.currentAudioPlayer playInBackground];
    
    // 更新状态
    self.currentPlayingIndex = index;
    model.isPlaying = YES;
    
    NSLog(@"✅ 开始播放音频（后台模式）: %@", model.audioUrl);
}

/// 更新指定故事的播放状态
- (void)updatePlayingStateForStory:(NSInteger)index isPlaying:(BOOL)isPlaying {
    if (index >= 0 && index < self.dataSource.count) {
        VoiceStoryModel *model = self.dataSource[index];
        model.isPlaying = isPlaying;
        
        // 刷新对应的 cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

/// 更新指定故事的加载状态
- (void)updateLoadingStateForStory:(NSInteger)index isLoading:(BOOL)isLoading {
    if (index >= 0 && index < self.dataSource.count) {
        VoiceStoryModel *model = self.dataSource[index];
        model.isLoading = isLoading;
        
        // 刷新对应的 cell
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - AudioPlayerViewDelegate

- (void)audioPlayerDidStartPlaying {
    NSLog(@"🎵 音频开始播放");
    
    // 隐藏加载指示器
    [SVProgressHUD dismiss];
    
    // 清除加载状态
    if (self.currentLoadingIndex >= 0) {
        [self updateLoadingStateForStory:self.currentLoadingIndex isLoading:NO];
        self.currentLoadingIndex = -1;
    }
    
    [self updatePlayingStateForStory:self.currentPlayingIndex isPlaying:YES];
}

- (void)audioPlayerDidPause {
    NSLog(@"⏸️ 音频暂停");
    [self updatePlayingStateForStory:self.currentPlayingIndex isPlaying:NO];
}

- (void)audioPlayerDidFinish {
    NSLog(@"🏁 音频播放完成");
    [self updatePlayingStateForStory:self.currentPlayingIndex isPlaying:NO];
    self.currentPlayingIndex = -1;
    self.currentAudioPlayer = nil;
}

- (void)audioPlayerDidClose {
    NSLog(@"❌ 音频播放器关闭");
    
    // 隐藏加载指示器（如果正在显示）
    [SVProgressHUD dismiss];
    
    // 清除加载状态
    if (self.currentLoadingIndex >= 0) {
        [self updateLoadingStateForStory:self.currentLoadingIndex isLoading:NO];
        self.currentLoadingIndex = -1;
    }
    
    [self updatePlayingStateForStory:self.currentPlayingIndex isPlaying:NO];
    self.currentPlayingIndex = -1;
    self.currentAudioPlayer = nil;
}

- (void)audioPlayerDidUpdateProgress:(CGFloat)progress currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    // 可以在这里更新其他UI，如通知栏进度等
    NSLog(@"🔄 播放进度: %.2f%%, 当前时间: %.1fs/%.1fs", progress * 100, currentTime, totalTime);
}

#pragma mark - Helper Methods

/// ✅ 检查故事是否绑定了公仔
/// @param model 要检查的故事模型
/// @return YES 如果已绑定公仔，NO 如果未绑定
- (BOOL)checkStoryBoundDoll:(VoiceStoryModel *)model {
    // 直接检查 boundDolls 数组是否有数据
    if (model.boundDolls && model.boundDolls.count > 0) {
        NSLog(@"⚠️ 故事 '%@' 已绑定公仔", model.storyName);
        return YES; // 已绑定公仔
    }
    
    NSLog(@"✅ 故事 '%@' 未绑定公仔", model.storyName);
    return NO; // 未绑定公仔
}

/// ✅ 显示绑定公仔的删除确认弹窗
/// @param model 故事模型
/// @param index 故事索引
- (void)showBoundDollDeletionConfirmForModel:(VoiceStoryModel *)model atIndex:(NSInteger)index {
    // 获取第一个公仔的 customName
    StoryBoundDoll *firstDoll = model.boundDolls.firstObject;
    NSString *customName = firstDoll.customName ?: @"Unknown Doll";
    
    NSLog(@"⚠️ 故事 '%@' 已绑定公仔 '%@'，显示删除确认弹窗", model.storyName, customName);
    
    // 构建提示信息
    NSString *title = @"Delete Bound Story";
    NSString *message = [NSString stringWithFormat:@"This story is already associated with creative doll '%@'. Please place the doll back on the device to get the latest resources.\n\nAre you sure you want to delete this story?", customName];
    
    __weak typeof(self) weakSelf = self;
    [LGBaseAlertView showAlertWithTitle:title
                                content:message
                             cancelBtnStr:@"Cancel"
                            confirmBtnStr:@"Delete"
                            confirmBlock:^(BOOL is_value, id obj) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (is_value) { // 用户点击了"Delete"按钮
            NSLog(@"✅ 用户确认删除已绑定公仔的故事");
            // 根据删除方式调用对应的删除方法
            if (strongSelf.isSingleEditingMode && index == strongSelf.selectedIndex) {
                // 单选编辑模式删除
                [strongSelf performSingleDeleteAtIndex:index];
            } else {
                // 左滑删除
                [strongSelf performSingleDelete:index];
            }
        } else {
            NSLog(@"❌ 用户取消删除已绑定公仔的故事");
        }
    }];
}

- (void)showStoryLimitAlert {
    NSString *title = @"Story Limit Reached";
    NSString *message = @"You can create a maximum of 10 stories.\n\nTo create a new story, please delete some existing stories first.";
    
    [LGBaseAlertView showAlertWithContent:message confirmBlock:^(BOOL is_value, id obj) {
        // 用户点击确定按钮，无需额外处理
    }];
    
    NSLog(@"⚠️ 故事数量已达上限 (%ld/10)，显示限制提示", (long)self.dataSource.count);
}

- (void)showErrorAlert:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [LGBaseAlertView showAlertWithContent:errorMessage ?: @"Network request failed, please try again later" confirmBlock:^(BOOL is_value, id obj) {
            // 用户点击确定按钮，无需额外处理
        }];
    });
}

@end
