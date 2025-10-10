//
//  CreationViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/1.
//

#import "CreationViewController.h"
#import "VoiceStoryTableViewCell.h"
#import "VoiceStoryModel.h"
#import "AFStoryAPIManager.h"
#import "APIRequestModel.h"
#import "APIResponseModel.h"
#import "CreateStoryViewController.h"
#import <Masonry/Masonry.h>


@interface CreationViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *customNavBarView; // 自定义导航栏视图
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<VoiceStoryModel *> *dataSource;
@property (nonatomic, strong) UIView *emptyStateView;

// 下拉刷新
@property (nonatomic, strong) UIRefreshControl *refreshControl;

// 网络请求任务管理
@property (nonatomic, strong) NSURLSessionDataTask *currentLoadTask;
@property (nonatomic, strong) NSMutableArray<NSURLSessionDataTask *> *activeTasks;

// 编辑模式相关
@property (nonatomic, assign) BOOL isInEditingMode;
@property (nonatomic, strong) UIView *editingToolbar;
@property (nonatomic, strong) UIButton *deleteSelectedButton;

@end

@implementation CreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // 初始化任务管理
    self.activeTasks = [NSMutableArray array];
    
    // 初始化数据源为空数组，这样先显示空状态
    self.dataSource = [NSMutableArray array];
    
    [self setupNavigationBar];
    [self setupUI];
    [self setupTableViewConstraints]; // 单独设置 TableView 约束
    
    // 延迟加载数据，让用户先看到空状态效果
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadData];
    });
}

- (void)dealloc {
    // 取消所有进行中的网络请求
    [self cancelAllTasks];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 确保导航栏保持隐藏
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 如果正在编辑模式，退出编辑模式
    if (self.isInEditingMode) {
        [self cancelEditingMode];
    }
    
    // 如果需要的话，可以在这里恢复导航栏
    // [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)setupNavigationBar {
    // 隐藏默认导航栏元素
    self.title = @"";
    
    // 创建整个导航栏内容的容器视图
    self.customNavBarView = [[UIView alloc] init];
    self.customNavBarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.customNavBarView];
    
    // 创建标题标签
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Story Creation";
    titleLabel.font = [UIFont fontWithName:@"SFRounded-Bold" size:24] ?: [UIFont boldSystemFontOfSize:24];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.customNavBarView addSubview:titleLabel];
    
    // 创建声音按钮
    UIButton *soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [soundButton setImage:[UIImage systemImageNamed:@"speaker.wave.2.fill"] forState:UIControlStateNormal];
    soundButton.tintColor = [UIColor systemGrayColor];
    [soundButton addTarget:self action:@selector(soundButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addSubview:soundButton];
    
    // 创建添加按钮
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[UIImage systemImageNamed:@"plus.circle.fill"] forState:UIControlStateNormal];
    addButton.tintColor = [UIColor systemGrayColor];
    [addButton addTarget:self action:@selector(addButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addSubview:addButton];
    
    // 使用 Masonry 设置布局约束
    
    // 容器视图约束 - 在安全区域顶部
    [self.customNavBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.height.mas_equalTo(44); // 标准导航栏高度
    }];
    
    // 标题约束 - 距离左边16pt
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.customNavBarView).offset(16);
        make.centerY.equalTo(self.customNavBarView);
    }];
    
    // 添加按钮约束 - 距离右边16pt，尺寸28x28
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.customNavBarView).offset(-16);
        make.centerY.equalTo(self.customNavBarView);
        make.width.height.mas_equalTo(28);
    }];
    
    // 声音按钮约束 - 距离添加按钮21pt，尺寸28x28
    [soundButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(addButton.mas_left).offset(-21);
        make.centerY.equalTo(self.customNavBarView);
        make.width.height.mas_equalTo(28);
    }];
}

- (void)setupUI {
    // TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tableView.hidden = YES; // 初始隐藏 TableView
    self.tableView.allowsMultipleSelectionDuringEditing = YES; // 允许编辑时多选
    [self.tableView registerClass:[VoiceStoryTableViewCell class] forCellReuseIdentifier:@"VoiceStoryTableViewCell"];
    
    // 添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5; // 长按0.5秒触发
    [self.tableView addGestureRecognizer:longPress];
    
    // 设置下拉刷新
    [self setupRefreshControl];
    
    [self.view addSubview:self.tableView];
    
    // 设置编辑工具栏
    [self setupEditingToolbar];
    
    // 空状态视图
    [self setupEmptyStateView];
}

- (void)setupTableViewConstraints {
    // 设置 TableView 约束
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customNavBarView.mas_bottom).offset(10);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
}

- (void)setupEmptyStateView {
    self.emptyStateView = [[UIView alloc] init];
    self.emptyStateView.backgroundColor = [UIColor whiteColor];
    self.emptyStateView.hidden = NO; // 初始显示空状态视图，等有数据时再隐藏
    [self.view addSubview:self.emptyStateView];
    
    // 图标 - 使用盒子图标
    UIImageView *emptyImageView = [[UIImageView alloc] init];
    emptyImageView.contentMode = UIViewContentModeScaleAspectFit;
    emptyImageView.tintColor = [UIColor colorWithWhite:0.85 alpha:1];
    // 使用系统的盒子图标
    emptyImageView.image = [UIImage systemImageNamed:@"shippingbox.fill"];
    [self.emptyStateView addSubview:emptyImageView];
    
    // 提示文字
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.text = @"暂无故事，请先创建";
    emptyLabel.font = [UIFont systemFontOfSize:16];
    emptyLabel.textColor = [UIColor systemGrayColor];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.emptyStateView addSubview:emptyLabel];
    
    // View the Guide 按钮 - 只在空状态时显示
    UIButton *guideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [guideButton setTitle:@"View the Guide" forState:UIControlStateNormal];
    guideButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [guideButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [guideButton addTarget:self action:@selector(viewGuideButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyStateView addSubview:guideButton];
    
    // My Voice 按钮 - 只在空状态时显示（左边 - 白底蓝边框）
    UIButton *emptyMyVoiceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [emptyMyVoiceButton setTitle:@"My Voice" forState:UIControlStateNormal];
    [emptyMyVoiceButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    emptyMyVoiceButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    emptyMyVoiceButton.layer.borderColor = [UIColor systemBlueColor].CGColor;
    emptyMyVoiceButton.layer.borderWidth = 1.5;
    emptyMyVoiceButton.layer.cornerRadius = 18; // 36/2 = 18
    emptyMyVoiceButton.backgroundColor = [UIColor whiteColor];
    [emptyMyVoiceButton addTarget:self action:@selector(myVoiceButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyStateView addSubview:emptyMyVoiceButton];
    
    // Create Story 按钮 - 只在空状态时显示（右边 - 蓝色填充）
    UIButton *emptyCreateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [emptyCreateButton setTitle:@"Create Story" forState:UIControlStateNormal];
    [emptyCreateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    emptyCreateButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    emptyCreateButton.backgroundColor = [UIColor systemBlueColor];
    emptyCreateButton.layer.cornerRadius = 18; // 36/2 = 18
    [emptyCreateButton addTarget:self action:@selector(createButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyStateView addSubview:emptyCreateButton];
    
    // 使用 Masonry 设置约束
    
    // 空状态视图约束 - 占据整个屏幕
    [self.emptyStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customNavBarView ? self.customNavBarView.mas_bottom : self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
    // 图标约束 - 稍微向上一点
    [emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emptyStateView);
        make.centerY.equalTo(self.emptyStateView).offset(-80);
        make.width.height.mas_equalTo(120);
    }];
    
    // 文字约束
    [emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(emptyImageView.mas_bottom).offset(24);
        make.centerX.equalTo(self.emptyStateView);
        make.left.greaterThanOrEqualTo(self.emptyStateView).offset(16);
        make.right.lessThanOrEqualTo(self.emptyStateView).offset(-16);
    }];
    
    // View the Guide 按钮约束
    [guideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(emptyLabel.mas_bottom).offset(16);
        make.centerX.equalTo(self.emptyStateView);
    }];
    
    // My Voice 按钮约束 - 在左半屏居中，根据设备调整宽度
    [emptyMyVoiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emptyStateView).multipliedBy(0.7);
        make.top.equalTo(guideButton.mas_bottom).offset(32);
        
        // 根据屏幕宽度动态调整按钮宽度
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat myVoiceWidth = screenWidth <= 320 ? 70 : (screenWidth <= 375 ? 80 : (screenWidth <= 390 ? 85 : (screenWidth <= 414 ? 88 : 90)));
        make.width.mas_equalTo(myVoiceWidth);
        make.height.mas_equalTo(36);
    }];
    
    // Create Story 按钮约束 - 在右半屏居中，根据设备调整宽度
    [emptyCreateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emptyStateView).multipliedBy(1.3);
        make.top.equalTo(guideButton.mas_bottom).offset(32);
        
        // 根据屏幕宽度动态调整按钮宽度
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat createStoryWidth = screenWidth <= 320 ? 100 : (screenWidth <= 375 ? 110 : (screenWidth <= 390 ? 115 : (screenWidth <= 414 ? 120 : 122)));
        make.width.mas_equalTo(createStoryWidth);
        make.height.mas_equalTo(36);
    }];
}

- (void)setupEditingToolbar {
    // 创建编辑工具栏
    self.editingToolbar = [[UIView alloc] init];
    self.editingToolbar.backgroundColor = [UIColor whiteColor];
    self.editingToolbar.hidden = YES; // 初始隐藏
    [self.view addSubview:self.editingToolbar];
    
    // 添加顶部分割线
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.editingToolbar addSubview:topLine];
    
    // 删除选中项按钮 - 设计为红色圆角按钮
    self.deleteSelectedButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.deleteSelectedButton setTitle:@"删除故事" forState:UIControlStateNormal];
    [self.deleteSelectedButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    [self.deleteSelectedButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateDisabled];
    self.deleteSelectedButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.deleteSelectedButton.layer.borderColor = [UIColor systemRedColor].CGColor;
    self.deleteSelectedButton.layer.borderWidth = 1.5;
    self.deleteSelectedButton.layer.cornerRadius = 25; // 圆角按钮
    self.deleteSelectedButton.backgroundColor = [UIColor whiteColor];
    self.deleteSelectedButton.enabled = NO; // 初始禁用
    [self.deleteSelectedButton addTarget:self action:@selector(deleteSelectedItems) forControlEvents:UIControlEventTouchUpInside];
    [self.editingToolbar addSubview:self.deleteSelectedButton];
    
    // 设置约束
    [self.editingToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.height.mas_equalTo(80); // 增加高度以容纳圆角按钮
    }];
    
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.editingToolbar);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.deleteSelectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.editingToolbar).offset(20);
        make.right.equalTo(self.editingToolbar).offset(-20);
        make.centerY.equalTo(self.editingToolbar);
        make.height.mas_equalTo(50);
    }];
}





#pragma mark - Setup Refresh Control

- (void)setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor systemBlueColor];
    
    // 设置下拉刷新的文字
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"下拉刷新"
                                                                attributes:@{
        NSForegroundColorAttributeName: [UIColor systemGrayColor],
        NSFontAttributeName: [UIFont systemFontOfSize:14]
    }];
    self.refreshControl.attributedTitle = title;
    
    [self.refreshControl addTarget:self
                            action:@selector(handleRefresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    self.tableView.refreshControl = self.refreshControl;
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    NSLog(@"开始下拉刷新");
    
    // 更新刷新状态文字
    NSAttributedString *refreshingTitle = [[NSAttributedString alloc] initWithString:@"正在刷新..."
                                                                          attributes:@{
        NSForegroundColorAttributeName: [UIColor systemBlueColor],
        NSFontAttributeName: [UIFont systemFontOfSize:14]
    }];
    refreshControl.attributedTitle = refreshingTitle;
    
    // 执行刷新数据操作
    [self refreshData];
}

- (void)updateEmptyState {
    BOOL isEmpty = self.dataSource.count == 0;
    
    NSLog(@"更新空状态: 数据源数量 = %ld, isEmpty = %@", (long)self.dataSource.count, isEmpty ? @"YES" : @"NO");
    
    // 控制空状态视图的显示（包含 My Voice、Create Story 和 View the Guide 按钮）
    self.emptyStateView.hidden = !isEmpty;
    
    // 控制列表视图的显示
    self.tableView.hidden = isEmpty;
}

#pragma mark - Data

- (void)cancelAllTasks {
    // 取消当前加载任务
    [self.currentLoadTask cancel];
    self.currentLoadTask = nil;
    
    // 取消所有活跃任务
    for (NSURLSessionDataTask *task in self.activeTasks) {
        [task cancel];
    }
    [self.activeTasks removeAllObjects];
}

// 使用 AFNetworking 的 AFStoryAPIManager
- (void)loadDataWithAFManager {
    // 取消之前的请求
    [self.currentLoadTask cancel];
    
    self.dataSource = [NSMutableArray array];
    
    PageRequestModel *pageRequest = [[PageRequestModel alloc] initWithPageNum:1 pageSize:20];
    
    // AFNetworking 会返回 NSURLSessionDataTask，可以用于取消请求
    self.currentLoadTask = [[AFStoryAPIManager sharedManager] getStoriesWithPage:pageRequest success:^(StoryListResponseModel *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:response.list];
            [self.tableView reloadData];
            [self updateEmptyState];
            [self endRefreshingWithSuccess];
        });
        
        // 请求完成，清除任务引用
        self.currentLoadTask = nil;
        
    } failure:^(NSError *error) {
        NSLog(@"使用AFNetworking加载故事列表失败: %@", error.localizedDescription);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 显示空状态视图
            [self updateEmptyState];
            [self endRefreshingWithSuccess];
        });
        
        // 请求失败，清除任务引用
        self.currentLoadTask = nil;
    }];
    
    // 将任务添加到活跃任务列表
    if (self.currentLoadTask) {
        [self.activeTasks addObject:self.currentLoadTask];
    }
}

// 当前使用模拟数据方式
- (void)loadData {
    [self loadMockData];
}

#pragma mark - Refresh Data

// 刷新数据方法
- (void)refreshData {
    // 使用模拟数据
    [self loadMockDataForRefresh];
}

// 结束刷新状态
- (void)endRefreshingWithSuccess {
    if (self.refreshControl.isRefreshing) {
        // 恢复默认标题
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"下拉刷新"
                                                                    attributes:@{
            NSForegroundColorAttributeName: [UIColor systemGrayColor],
            NSFontAttributeName: [UIFont systemFontOfSize:14]
        }];
        self.refreshControl.attributedTitle = title;
        
        // 结束刷新动画
        [self.refreshControl endRefreshing];
    }
}

// 显示错误提示的便利方法
- (void)showErrorAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

//- (void)loadData {
//    self.dataSource = [NSMutableArray array];
//    
//    // 使用 API 管理器获取故事列表
//    PageRequestModel *pageRequest = [[PageRequestModel alloc] initWithPageNum:1 pageSize:20];
//    
//    [[StoryAPIManager sharedManager] getStoriesWithPage:pageRequest success:^(StoryListResponseModel *response) {
//        [self.dataSource removeAllObjects];
//        [self.dataSource addObjectsFromArray:response.list];
//        [self.tableView reloadData];
//        [self updateEmptyState];
//    } failure:^(NSError *error) {
//        NSLog(@"加载故事列表失败: %@", error.localizedDescription);
//        
//        // 失败时使用模拟数据（可选）
//        // [self loadMockData];
//        [self updateEmptyState];
//    }];
//}

- (void)loadMockData {
    NSLog(@"开始加载模拟数据...");
    
    // 基础模拟数据（用于测试），符合设计图要求
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
    
    // 初始化数据源
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
        
        // 设置不同的插图
        NSArray *illustrationUrls = @[
            @"/illustration/redhood.png",
            @"/illustration/threepigs.png",
            @"/illustration/garden.png",
            @"/illustration/space.png",
            @"/illustration/castle.png",
            @"/illustration/mermaid.png"
        ];
        model.illustrationUrl = illustrationUrls[i];
        
        // 设置创建时间
        NSDate *now = [NSDate date];
        NSTimeInterval offset = -i * 24 * 60 * 60; // 每个故事相差一天
        NSDate *createDate = [now dateByAddingTimeInterval:offset];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        model.createTime = [formatter stringFromDate:createDate];
        
        // 设置不同状态的描述
        if ([statuses[i] isEqualToString:@"generating"]) {
            model.statusDesc = @"Story Generation...";
        } else if ([statuses[i] isEqualToString:@"failed"]) {
            model.statusDesc = @"Generation Failed, Please Try Again";
        } else {
            // 完成状态显示时长
            NSInteger duration = 120 + arc4random_uniform(180); // 2-5分钟
            model.statusDesc = [NSString stringWithFormat:@"时长 %ld:%02ld", (long)(duration/60), (long)(duration%60)];
        }
        
        [self.dataSource addObject:model];
    }
    
    [self.tableView reloadData];
    [self updateEmptyState];
    
    NSLog(@"加载了基础模拟数据: %ld 个故事", (long)self.dataSource.count);
}

// 增强的模拟数据方法（用于刷新时）
- (void)loadMockDataForRefresh {
    // 更丰富的模拟数据，包含更多样的故事类型和状态
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
    
    // 随机选择故事数量（5-10个）
    NSInteger storyCount = 5 + arc4random_uniform(6);
    
    // 初始化数据源
    if (!self.dataSource) {
        self.dataSource = [NSMutableArray array];
    }
    [self.dataSource removeAllObjects];
    
    for (int i = 0; i < storyCount; i++) {
        VoiceStoryModel *model = [[VoiceStoryModel alloc] init];
        model.storyId = i + 100; // 使用不同的ID范围
        model.storyName = storyTitles[i % storyTitles.count];
        model.voiceName = voiceTypes[i % voiceTypes.count];
        model.status = storyStatuses[i % storyStatuses.count];
        model.isNew = [newFlags[i % newFlags.count] boolValue];
        model.isPlaying = [playStates[i % playStates.count] boolValue];
        
        // 设置插图URL
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
        
        // 设置创建时间（最近几天的随机时间）
        NSDate *now = [NSDate date];
        NSTimeInterval randomOffset = -arc4random_uniform(7 * 24 * 60 * 60); // 最近7天内
        NSDate *createDate = [now dateByAddingTimeInterval:randomOffset];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        model.createTime = [formatter stringFromDate:createDate];
        
        // 设置不同状态的描述
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
            // 完成状态可以设置时长等信息
            NSInteger duration = 90 + arc4random_uniform(240); // 90-330秒
            model.statusDesc = [NSString stringWithFormat:@"时长 %ld:%02ld", (long)(duration/60), (long)(duration%60)];
        }
        
        [self.dataSource addObject:model];
    }
    
    // 按创建时间排序（最新的在前面）
    [self.dataSource sortUsingComparator:^NSComparisonResult(VoiceStoryModel *obj1, VoiceStoryModel *obj2) {
        return [obj2.createTime compare:obj1.createTime];
    }];
    
    [self.tableView reloadData];
    [self updateEmptyState];
    [self endRefreshingWithSuccess]; // 结束刷新动画
    
    NSLog(@"刷新加载了 %ld 个模拟故事数据", (long)self.dataSource.count);
}

#pragma mark - Editing Mode

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [gesture locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        
        if (indexPath && !self.isInEditingMode) {
            // 进入编辑模式
            [self enterEditingMode];
            
            // 选中长按的行
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self updateDeleteButtonState];
        }
    }
}

- (void)enterEditingMode {
    self.isInEditingMode = YES;
    [self.tableView setEditing:YES animated:YES];
    
    // 隐藏 TabBar
    if (self.tabBarController) {
        [self.tabBarController.tabBar setHidden:YES];
    }
    
    // 更新自定义导航栏为编辑模式
    [self updateCustomNavBarForEditingMode:YES];
    
    // 显示编辑工具栏
    self.editingToolbar.hidden = NO;
    
    // 更新 TableView 底部约束，为工具栏留出空间
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.editingToolbar.mas_top);
    }];
    
    // 动画显示工具栏
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)cancelEditingMode {
    self.isInEditingMode = NO;
    [self.tableView setEditing:NO animated:YES];
    
    // 恢复自定义导航栏
    [self updateCustomNavBarForEditingMode:NO];
    
    // 显示 TabBar
    if (self.tabBarController) {
        [self.tabBarController.tabBar setHidden:NO];
    }
    
    // 隐藏编辑工具栏
    self.editingToolbar.hidden = YES;
    
    // 恢复 TableView 底部约束
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];
    
    // 动画隐藏工具栏
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    // 重置删除按钮状态
    self.deleteSelectedButton.enabled = NO;
    [self.deleteSelectedButton setTitle:@"删除故事" forState:UIControlStateNormal];
}

- (void)updateCustomNavBarForEditingMode:(BOOL)isEditing {
    // 移除现有的导航栏内容
    for (UIView *subview in self.customNavBarView.subviews) {
        [subview removeFromSuperview];
    }
    
    if (isEditing) {
        // 编辑模式：取消按钮
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [cancelButton addTarget:self action:@selector(cancelEditingMode) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:cancelButton];
        
        // 编辑模式：标题
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"故事删除";
        titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.customNavBarView addSubview:titleLabel];
        
        // 编辑模式：完成按钮
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [doneButton addTarget:self action:@selector(cancelEditingMode) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:doneButton];
        
        // 设置约束
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
        // 正常模式：恢复原来的导航栏布局
        // 创建标题标签
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"Story Creation";
        titleLabel.font = [UIFont fontWithName:@"SFRounded-Bold" size:20] ?: [UIFont boldSystemFontOfSize:20]; // 调整字体大小适应44pt高度
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.customNavBarView addSubview:titleLabel];
        
        // 创建声音按钮
        UIButton *soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [soundButton setImage:[UIImage systemImageNamed:@"speaker.wave.2.fill"] forState:UIControlStateNormal];
        soundButton.tintColor = [UIColor systemGrayColor];
        [soundButton addTarget:self action:@selector(soundButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:soundButton];
        
        // 创建添加按钮
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addButton setImage:[UIImage systemImageNamed:@"plus.circle.fill"] forState:UIControlStateNormal];
        addButton.tintColor = [UIColor systemGrayColor];
        [addButton addTarget:self action:@selector(addButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBarView addSubview:addButton];
        
        // 设置约束
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
    
    // 更新按钮样式
    if (selectedCount > 0) {
        // 有选中项时，使按钮更明显
        self.deleteSelectedButton.layer.borderColor = [UIColor systemRedColor].CGColor;
        [self.deleteSelectedButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
        self.deleteSelectedButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.95 blue:0.95 alpha:1.0]; // 浅红背景
    } else {
        // 无选中项时，显示为禁用状态
        self.deleteSelectedButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self.deleteSelectedButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.deleteSelectedButton.backgroundColor = [UIColor whiteColor];
    }
    
    // 保持固定的文字，不显示数量
    [self.deleteSelectedButton setTitle:@"删除故事" forState:UIControlStateNormal];
}



- (void)deleteSelectedItems {
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    if (selectedIndexPaths.count == 0) {
        return;
    }
    
    // 显示确认对话框
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
    // 按行号降序排列，从后往前删除，避免索引混乱
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath *obj2) {
        return obj2.row - obj1.row;
    }];
    
    // 收集要删除的故事模型
    NSMutableArray *modelsToDelete = [NSMutableArray array];
    for (NSIndexPath *indexPath in sortedIndexPaths) {
        VoiceStoryModel *model = self.dataSource[indexPath.row];
        [modelsToDelete addObject:model];
    }
    
    // 从数据源中移除
    for (NSIndexPath *indexPath in sortedIndexPaths) {
        [self.dataSource removeObjectAtIndex:indexPath.row];
    }
    
    // 更新UI
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    // 退出编辑模式
    [self cancelEditingMode];
    
    // 更新空状态
    [self updateEmptyState];
    
    // 这里可以添加网络请求来删除服务器上的数据
    // [self deleteModelsFromServer:modelsToDelete];
    
    NSLog(@"已删除 %ld 个故事", (long)indexPaths.count);
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"TableView 请求行数: %ld", (long)self.dataSource.count);
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"TableView 请求 cell, indexPath: %ld-%ld", (long)indexPath.section, (long)indexPath.row);
    VoiceStoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoiceStoryTableViewCell" forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    cell.settingsButtonTapped = ^{
//        [weakSelf showSettingsForIndex:indexPath.row];
    };
    
    cell.playButtonTapped = ^{
        [weakSelf playStoryAtIndex:indexPath.row];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isInEditingMode) {
        // 编辑模式下更新删除按钮状态
        [self updateDeleteButtonState];
    } else {
        // 非编辑模式下取消选中
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isInEditingMode) {
        // 编辑模式下更新删除按钮状态
        [self updateDeleteButtonState];
    }
}

#pragma mark - UITableView Swipe to Delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES; // 允许所有行都可以编辑（左滑删除）
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteStoryAtIndex:indexPath.row];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - Actions

- (void)soundButtonTapped {
    NSLog(@"点击了声音按钮");
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
    
    [alert addAction:[UIAlertAction actionWithTitle:@"加载测试数据"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self loadMockDataForRefresh];
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
}

- (void)createButtonTapped {
    NSLog(@"点击了 Create Storys 按钮");
    
    // 跳转到创建故事页面
    CreateStoryViewController *createStoryVC = [[CreateStoryViewController alloc] init];
    [self.navigationController pushViewController:createStoryVC animated:YES];
}

// 使用 AFNetworking 删除故事
- (void)deleteStoryAtIndex:(NSInteger)index {
    if (index >= self.dataSource.count) {
        return;
    }
    
    VoiceStoryModel *model = self.dataSource[index];
    NSLog(@"点击删除第 %ld 个故事: %@", (long)index, model.storyName);
    
    // 显示确认对话框
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
    
    // 先从数据源和UI中移除（乐观更新）
    [self.dataSource removeObjectAtIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self updateEmptyState];
    
    // 然后发起网络请求删除（可选，如果需要的话）
    // 使用 AFNetworking 进行删除请求
    NSURLSessionDataTask *deleteTask = [[AFStoryAPIManager sharedManager] deleteStoryWithId:model.storyId success:^(APIResponseModel *response) {
        if (response.isSuccess) {
            NSLog(@"服务器删除成功: %@", model.storyName);
        } else {
            // 服务器删除失败，可以考虑回滚或显示警告
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"服务器删除失败，但本地已删除: %@", response.errorMessage);
            });
        }
        
        // 从活跃任务列表中移除
        [self.activeTasks removeObject:deleteTask];
        
    } failure:^(NSError *error) {
        // 网络请求失败，但本地已删除
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"网络请求失败，但本地已删除: %@", error.localizedDescription);
        });
        
        // 从活跃任务列表中移除
        [self.activeTasks removeObject:deleteTask];
    }];
    
    // 添加到活跃任务列表
    if (deleteTask) {
        [self.activeTasks addObject:deleteTask];
    }
}

// 显示成功提示的便利方法
- (void)showSuccessAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
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

@end
