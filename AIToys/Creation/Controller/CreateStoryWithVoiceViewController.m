//
//  CreateStoryWithVoiceViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "CreateStoryWithVoiceViewController.h"
#import "CreateStoryWithVoiceTableViewCell.h"
#import "AudioPlayerView.h"
#import "AFStoryAPIManager.h"
#import "CreateVoiceViewController.h"
#import "SelectIllustrationVC.h"
#import "StoryBoundDoll.h"
#import "LGBaseAlertView.h"
#import "ATLanguageHelper.h"

@interface CreateStoryWithVoiceViewController ()<UITableViewDelegate, UITableViewDataSource, AudioPlayerViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *createImageView;
@property (weak, nonatomic) IBOutlet UILabel *storyStautsLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *storyTextField;
@property (weak, nonatomic) IBOutlet UILabel *chooseVoiceLabel;
@property (weak, nonatomic) IBOutlet UIButton *addNewVoiceBtn;
@property (weak, nonatomic) IBOutlet UITableView *voiceTabelView;
@property (weak, nonatomic) IBOutlet UIButton *saveStoryBtn;
@property (weak, nonatomic) IBOutlet UITextField *stroryThemeTextView;
@property (weak, nonatomic) IBOutlet UIButton *voiceHeaderImageBtn;
@property (weak, nonatomic) IBOutlet UIButton *deletHeaderBtn;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UILabel *emptyVoiceLabel;
@property (weak, nonatomic) IBOutlet UIView *storyThemeView;
@property (weak, nonatomic) IBOutlet UIView *voiceHeaderView;
@property (weak, nonatomic) IBOutlet UIView *storyView;
@property (weak, nonatomic) IBOutlet UIView *chooseVoiceView;
@property (weak, nonatomic) IBOutlet UIButton *deletBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storyViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceListViewHeight;
// 数据源
@property (nonatomic, strong) NSMutableArray *voiceListArray;  // 音色列表数据
@property (nonatomic, strong) VoiceStoryModel *currentStory;   // 当前故事模型
@property (nonatomic, assign) NSInteger selectedVoiceIndex;    // 选中的音色索引

// 音频播放相关
@property (nonatomic, strong) AudioPlayerView *audioPlayerView;
@property (nonatomic, assign) NSInteger currentPlayingIndex; // 当前正在播放的语音索引
@property (nonatomic, copy) NSString *currentPlayingAudioURL; // 当前播放的音频URL
//选择的图片
@property (nonatomic, copy) NSString *selectedIllustrationUrl;

// ✅ 编辑状态变更追踪 - 记录原始值用于比较
@property (nonatomic, copy) NSString *originalStoryName;      // 原始故事名称
@property (nonatomic, copy) NSString *originalStoryContent;   // 原始故事内容
@property (nonatomic, copy) NSString *originalIllustrationUrl; // 原始插画URL
@property (nonatomic, assign) NSInteger originalVoiceId;      // 原始音色ID
@property (nonatomic, assign) BOOL hasUnsavedChanges;        // 是否有未保存的更改
//所有音色数量
@property(nonatomic,assign)NSInteger voiceCount;

// ✅ 滚动视图属性
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIView *contentView;

// Loading View
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIView *failedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storyNameTop;


@end

@implementation CreateStoryWithVoiceViewController



#pragma mark - Lifecycle

- (instancetype)initWithEditMode:(BOOL)editMode {
    self = [super init];
    if (self) {
        _isEditMode = editMode;
        NSLog(@"🔧 initWithEditMode: 设置 isEditMode = %@", editMode ? @"YES" : @"NO");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL isRTL = [ATLanguageHelper isRTLLanguage];
    NSTextAlignment inputAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    NSTextAlignment labelAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.view.semanticContentAttribute = isRTL ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
    
    // ✅ 调试 isEditMode 的设置状态
    NSLog(@"🔧 viewDidLoad: isEditMode = %@", self.isEditMode ? @"YES" : @"NO");
    NSLog(@"🔧 viewDidLoad: storyId = %ld", (long)self.storyId);
    
    // 根据编辑模式设置标题
    self.title = self.isEditMode ? LocalString(@"编辑故事") : LocalString(@"创建故事");
    
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0]];
    
    self.storyStautsLabel.text = LocalString(@"故事生成中");
    self.storyNameLabel.text = LocalString(@"故事名称");
    self.chooseVoiceLabel.text = LocalString(@"选择音色");
    [self.addNewVoiceBtn setTitle:LocalString(@"新增音色") forState:UIControlStateNormal];
    [self.saveStoryBtn setTitle:LocalString(@"保存故事") forState:UIControlStateNormal];
    [self.deletBtn setTitle:LocalString(@"删除故事") forState:UIControlStateNormal];
    self.emptyVoiceLabel.text = LocalString(@"暂无音色，请先创建");
    self.storyStautsLabel.textAlignment = labelAlignment;
    self.storyNameLabel.textAlignment = labelAlignment;
    self.chooseVoiceLabel.textAlignment = labelAlignment;
    self.emptyVoiceLabel.textAlignment = labelAlignment;
    self.stroryThemeTextView.placeholder = LocalString(@"请输入故事名称");
    self.stroryThemeTextView.textAlignment = inputAlignment;
    self.storyTextField.textAlignment = inputAlignment;
    
    // ✅ 设置滚动视图
    [self setupScrollView];
    
    // ✅ 添加键盘通知监听
    [self setupKeyboardNotifications];
    
    self.voiceTabelView.delegate = self;
    self.voiceTabelView.dataSource = self;
    self.addNewVoiceBtn.borderWidth = 1;
    self.addNewVoiceBtn.borderColor = HexOf(0x1EAAFD);
    
    // 配置故事文本框
    [self configureStoryTextView];
    
    // 根据编辑模式设置文本框的可编辑状态
//    [self updateTextFieldsEditability];
    
    // 初始化数据源
    self.voiceListArray = [NSMutableArray array];
    self.selectedVoiceIndex = -1; // 默认未选中
    self.currentPlayingIndex = -1; // 没有正在播放的
    self.hasUnsavedChanges = NO; // 初始没有未保存的更改
    
    UINib *CreateStoryWithVoiceTableViewCell = [UINib nibWithNibName:@"CreateStoryWithVoiceTableViewCell" bundle:nil];
    [self.voiceTabelView registerNib:CreateStoryWithVoiceTableViewCell forCellReuseIdentifier:@"CreateStoryWithVoiceTableViewCell"];
    
    // 隐藏所有控件，显示加载状态
    [self hideAllContentViews];
    
    // ✅ 确保failedView初始状态为隐藏
    self.failedView.hidden = YES;
    self.storyNameTop.constant = 10.0; // 设置默认约束值
    
    [self showLoadingState];
    
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // ✅ 离开页面时停止音频播放
    if (self.audioPlayerView && self.audioPlayerView.isPlaying) {
        [self.audioPlayerView stop];
        NSLog(@"⏸️ 离开页面，暂停音频播放");
    }
    // ❌ 删除这行错误代码: self.isEditMode = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // ✅ 页面显示完成后再次更新滚动视图内容大小
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scheduleScrollViewContentSizeUpdate];
    });
}

/// ✅ 页面即将显示时刷新数据（从其他页面返回时）
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 如果已经加载过数据，检查是否需要刷新音色列表（可能添加了新音色）
    if (self.voiceListArray.count > 0) {
        [self refreshVoiceListIfNeeded];
    }
}



- (void)setStoryId:(NSInteger)storyId{
    _storyId = storyId;
    NSLog(@"🔧 setStoryId: storyId = %ld, isEditMode = %@", (long)storyId, self.isEditMode ? @"YES" : @"NO");
}

#pragma mark - Loading State Management

/// 隐藏所有内容视图
- (void)hideAllContentViews {
    NSLog(@"🙈 隐藏所有内容控件");
    
    // 隐藏主要内容区域
    self.storyThemeView.hidden = YES;
    self.voiceHeaderView.hidden = YES;
    self.storyView.hidden = YES;
    self.chooseVoiceView.hidden = YES;
    self.saveStoryBtn.hidden = YES;
    self.deletBtn.hidden = YES;
}

/// 显示加载状态
- (void)showLoadingState {
    NSLog(@"⏳ Showing loading state");
    
    // 可以在这里添加一个加载指示器
//    [SVProgressHUD showWithStatus:LocalString(@"加载中...")];
    [self showCustomLoadingView];
}

/// 显示所有内容视图（带动画）
- (void)showAllContentViewsWithAnimation {
    NSLog(@"✨ 显示所有内容控件");
    
    // ✅ 第一步：先显示所有控件（透明状态），这样可以参与布局计算
    self.storyThemeView.alpha = 0.0;
    self.voiceHeaderView.alpha = 0.0;
    self.storyView.alpha = 0.0;
    self.chooseVoiceView.alpha = 0.0;
    self.saveStoryBtn.alpha = 0.0;
    self.deletBtn.alpha = 0.0;
    
    self.storyThemeView.hidden = NO;
    self.voiceHeaderView.hidden = YES;  // ✅ 保持插画头部视图隐藏，不参与高度计算
    self.storyView.hidden = NO;
    self.chooseVoiceView.hidden = NO;
    
    
    // ✅ 第二步：强制布局，确保所有frame计算完成
//    [self.contentView layoutIfNeeded];
    
    // ✅ 第三步：更新scrollview的contentSize
    [self updateMainScrollViewContentSize];
    
    // ✅ 第四步：开始渐显动画
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.storyThemeView.alpha = 1.0;
        self.voiceHeaderView.alpha = 1.0;
        self.storyView.alpha = 1.0;
        self.chooseVoiceView.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"🎉 内容显示动画完成");
            
            // ✅ 第五步：渐显完成后，滚动到底部
            [self scrollToBottomAfterContentVisible];
        }
    }];
}

-(void)loadData{
    
    // ✅ 调试 loadData 时的状态
    NSLog(@"🚀 开始 loadData:");
    NSLog(@"   isEditMode = %@", self.isEditMode ? @"YES" : @"NO");
    NSLog(@"   storyId = %ld", (long)self.storyId);
    
    // 📝 编辑状态完全依赖外部传入的 isEditMode，不做自动修改
    
    // 发起网络请求
    __weak typeof(self) weakSelf = self;
    
    // 创建请求组来同步两个网络请求
    dispatch_group_t group = dispatch_group_create();
    
    // 请求1：获取故事详情
    dispatch_group_enter(group);
    [[AFStoryAPIManager sharedManager]getStoryDetailWithId:self.storyId success:^(VoiceStoryModel * _Nonnull story) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            dispatch_group_leave(group);
            return;
        }
        
        // 保存故事模型
        strongSelf.currentStory = story;
        strongSelf.selectedIllustrationUrl = story.illustrationUrl;
        
        // ✅ 记录原始数据用于变更追踪（仅编辑模式）
        if (strongSelf.isEditMode) {
            [strongSelf recordOriginalStoryData:story];
        }
        
        // 更新UI（在主线程）
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.stroryThemeTextView.text = story.storyName;
            [strongSelf.voiceHeaderImageBtn sd_setImageWithURL:[NSURL URLWithString:story.illustrationUrl] forState:UIControlStateNormal];
            strongSelf.storyTextField.text = story.storyContent;
            
            // ✅ 根据故事状态控制failedView显示和storyNameTop约束
            [strongSelf configureViewsForStoryStatus:story.storyStatus];
            
            // ✅ 故事内容加载完成后，动态调整高度
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf adjustStoryViewHeightOptimized];
            });
            
            // ✅ 编辑模式下设置文本变化监听
            if (strongSelf.isEditMode) {
                [strongSelf setupEditModeTextObservers];
            }
            
            // 确保文本充满整个视图并滚动到顶部
            [strongSelf.storyTextField scrollRangeToVisible:NSMakeRange(0, 0)];
        });
        
        dispatch_group_leave(group);
        
    } failure:^(NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            dispatch_group_leave(group);
            return;
        }
        
        
        
        dispatch_group_leave(group);
    }];
    
    // 请求2：获取音色列表
    dispatch_group_enter(group);
    [[AFStoryAPIManager sharedManager]getVoicesWithStatus:0 success:^(VoiceListResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            dispatch_group_leave(group);
            return;
        }
        
        // 保存音色列表数据
        if (response.list && response.list.count > 0) {
            [strongSelf.voiceListArray removeAllObjects];
            strongSelf.voiceCount  = response.list.count;
            for (VoiceModel * model in response.list) {
                if (model.cloneStatus==2) {
                    [strongSelf.voiceListArray addObject:model];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.emptyView.hidden = YES;
                
                // ✅ 编辑模式下设置当前选中的音色（如果有）
                if (strongSelf.isEditMode && strongSelf.currentStory.voiceId > 0) {
                    NSLog(@"🎯 编辑模式：准备匹配音色ID: %ld", (long)strongSelf.currentStory.voiceId);
                    NSLog(@"🎯 当前过滤后的音色数量: %ld", (long)strongSelf.voiceListArray.count);
                    
                    // ✅ 延迟执行匹配，确保数据加载完成
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf selectVoiceWithId:strongSelf.currentStory.voiceId];
                        
                        // ✅ 匹配完成后强制刷新TableView以显示选中状态
                        [strongSelf.voiceTabelView reloadData];
                        
                        // ✅ 匹配完成后检查结果
                        if (strongSelf.selectedVoiceIndex >= 0) {
                            NSLog(@"✅ 音色匹配成功，选中索引: %ld", (long)strongSelf.selectedVoiceIndex);
                            
                            // ✅ 额外确保选中状态正确显示
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [strongSelf.voiceTabelView reloadData];
                                NSLog(@"🔄 二次刷新TableView确保选中状态显示");
                            });
                        } else {
                            NSLog(@"❌ 音色匹配失败，可能原因:");
                            NSLog(@"   1. 音色ID %ld 不在可用列表中", (long)strongSelf.currentStory.voiceId);
                            NSLog(@"   2. 音色的 cloneStatus 不等于 2");
                            NSLog(@"   3. 数据同步问题");
                            
                            // ✅ 尝试备用匹配策略
                            [strongSelf tryFallbackVoiceSelection];
                        }
                    });
                }
                
                // 刷新TableView
                [strongSelf.voiceTabelView reloadData];
                
                // ✅ TableView数据变化后，动态调整高度（包括音色区域）
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf updateScrollViewContentSizeWithVoiceHeightRecalc:YES];
                });
                
                // ✅ 确保选中状态正确显示
                if (strongSelf.selectedVoiceIndex >= 0) {
                    NSLog(@"✅ 已选中音色索引: %ld", (long)strongSelf.selectedVoiceIndex);
                    [strongSelf debugCurrentSelectionState];
                } else if (strongSelf.isEditMode) {
                    NSLog(@"⚠️ 编辑模式但未找到匹配的音色ID: %ld", (long)strongSelf.currentStory.voiceId);
                    [strongSelf debugCurrentSelectionState];
                }
            });
            
            NSLog(@"✅ 成功加载 %ld 个音色", (long)strongSelf.voiceListArray.count);
        } else {
            NSLog(@"⚠️ 音色列表为空");
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.emptyView.hidden = NO;
                // ✅ 空数据时也要调整高度（包括音色区域）
                [strongSelf updateScrollViewContentSizeWithVoiceHeightRecalc:YES];
            });
        }
        
        dispatch_group_leave(group);
        
    } failure:^(NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            dispatch_group_leave(group);
            return;
        }
        
        NSLog(@"❌ 获取音色列表失败: %@", error.localizedDescription);
        
        
        dispatch_group_leave(group);
    }];
    
    // 当两个请求都完成后，显示内容
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        // ✅ 在显示内容前，确保编辑模式下的选中状态正确
        if (strongSelf.isEditMode && strongSelf.selectedVoiceIndex >= 0) {
            NSLog(@"🔄 确保音色选中状态在UI显示前正确设置，索引: %ld", (long)strongSelf.selectedVoiceIndex);
            // 再次刷新 TableView 确保选中状态显示
            [strongSelf.voiceTabelView reloadData];
        }
        
        // 延迟一点时间，让用户感受加载完成
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf showAllContentViewsWithAnimation];
            
            // ✅ 在动画完成后验证并修复音色选中状态
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf validateAndFixVoiceSelectionState];
                
                // ✅ 再次确保选中状态显示
                if (strongSelf.isEditMode && strongSelf.selectedVoiceIndex >= 0) {
                    [strongSelf.voiceTabelView reloadData];
                    NSLog(@"✅ 最终确认音色选中状态显示完成");
                }
                
                
            });
        });
    });
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.voiceListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 显示真实数据
    CreateStoryWithVoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateStoryWithVoiceTableViewCell" forIndexPath:indexPath];
    
    // 获取当前音色数据
    if (indexPath.row < self.voiceListArray.count) {
        VoiceModel *voiceModel = self.voiceListArray[indexPath.row];
        BOOL isSelected = (indexPath.row == self.selectedVoiceIndex);
        
        // ✅ 添加更详细的调试日志
        if (self.isEditMode) {
            NSLog(@"🎯 配置音色cell[%ld]: '%@' (ID: %ld), isSelected: %@, selectedIndex: %ld",
                  (long)indexPath.row,
                  voiceModel.voiceName ?: @"无名称",
                  (long)voiceModel.voiceId,
                  isSelected ? @"YES" : @"NO",
                  (long)self.selectedVoiceIndex);
        }
        
        // 使用配置方法设置cell数据
        [cell configureWithVoiceModel:voiceModel isSelected:isSelected];
        
        // ✅ 设置播放按钮的状态（根据是否正在播放）
        cell.playBtn.selected = (indexPath.row == self.currentPlayingIndex);
        
        // ✅ 使用block回调 - 播放按钮
        __weak typeof(self) weakSelf = self;
        cell.onPlayButtonTapped = ^(VoiceModel *voiceModel, BOOL isPlaying) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (isPlaying) {
                // 开始播放
                [strongSelf playVoice:voiceModel atIndex:indexPath.row];
            } else {
                // 暂停播放
                [strongSelf pauseCurrentPlaying];
            }
        };
        
        // ✅ 使用block回调 - 选择按钮
        cell.onSelectButtonTapped = ^(VoiceModel *voiceModel, BOOL isSelected) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (isSelected) {
                // 选中该音色
                strongSelf.selectedVoiceIndex = indexPath.row;
                
                // ✅ 编辑模式下检测音色变化
                if (strongSelf.isEditMode && voiceModel.voiceId != strongSelf.originalVoiceId) {
                    strongSelf.hasUnsavedChanges = YES;
                    NSLog(@"🔄 音色发生变更: %ld → %ld", (long)strongSelf.originalVoiceId, (long)voiceModel.voiceId);
                }
                
                NSLog(@"✅ 选中音色索引: %ld", (long)indexPath.row);
            } else {
                // 取消选中
                strongSelf.selectedVoiceIndex = -1;
                
                // ✅ 编辑模式下检测音色变化
                if (strongSelf.isEditMode && strongSelf.originalVoiceId > 0) {
                    strongSelf.hasUnsavedChanges = YES;
                    NSLog(@"🔄 音色被取消选中，原音色ID: %ld", (long)strongSelf.originalVoiceId);
                }
                
                NSLog(@"❌ 取消选中音色索引: %ld", (long)indexPath.row);
            }
            
            // 刷新TableView更新其他cell的状态
            [strongSelf.voiceTabelView reloadData];
            
            // ✅ 注释掉：选择音色时不需要调整ScrollView高度，因为内容数量没有变化
            // dispatch_async(dispatch_get_main_queue(), ^{
            //     [strongSelf updateScrollViewContentSize];
            // });
        };
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 获取选中的音色模型
    VoiceModel *voiceModel = self.voiceListArray[indexPath.row];
    
    // ✅ 如果点击的是已选中的行，则取消选择
    if (self.selectedVoiceIndex == indexPath.row) {
        self.selectedVoiceIndex = -1;
        
        // ✅ 编辑模式下检测音色变化
        if (self.isEditMode && self.originalVoiceId > 0) {
            self.hasUnsavedChanges = YES;
            NSLog(@"🔄 音色被取消选中，原音色ID: %ld", (long)self.originalVoiceId);
        }
        
        NSLog(@"❌ 取消选中音色索引: %ld", (long)indexPath.row);
    } else {
        self.selectedVoiceIndex = indexPath.row;
        
        // ✅ 编辑模式下检测音色变化
        if (self.isEditMode && voiceModel.voiceId != self.originalVoiceId) {
            self.hasUnsavedChanges = YES;
            NSLog(@"🔄 音色发生变更: %ld → %ld", (long)self.originalVoiceId, (long)voiceModel.voiceId);
        }
        
        NSLog(@"✅ 选中音色索引: %ld", (long)indexPath.row);
    }
    
    // 刷新tableView显示选中状态
    [tableView reloadData];
    
    // ✅ 注释掉：选择音色时不需要调整ScrollView高度，因为内容数量没有变化
    // dispatch_async(dispatch_get_main_queue(), ^{
    //     [self updateScrollViewContentSize];
    // });
}

#pragma mark - Audio Control Methods

/**
 播放指定音色
 */
- (void)playVoice:(VoiceModel *)voiceModel atIndex:(NSInteger)index {
    NSLog(@"🎵 开始播放音色: %@", voiceModel.voiceName);
    
    // 如果点击的是正在播放的音色，则暂停
    if (self.currentPlayingIndex == index && self.audioPlayerView && self.audioPlayerView.isPlaying) {
        [self.audioPlayerView stop];
        return;
    }
    
    // 停止之前的播放
    if (self.currentPlayingIndex >= 0 && self.currentPlayingIndex != index) {
        // 重置之前播放的cell的按钮状态
        [self resetPlayButtonAtIndex:self.currentPlayingIndex];
    }
    
    // 更新当前播放索引
    self.currentPlayingIndex = index;
    
    // 获取音频信息
    NSString *audioURL = voiceModel.sampleAudioUrl;
    NSString *coverImageURL = voiceModel.avatarUrl;
    NSString *title = voiceModel.voiceName;
    
    if (!audioURL || audioURL.length == 0) {
        NSLog(@"❌ 音频URL为空");
        [self showErrorAlert:LocalString(@"获取音频地址失败")];
        [self resetPlayButtonAtIndex:index];
        return;
    }
    
    NSLog(@"🎵 加载音频: %@", audioURL);
    
    // 创建或更新AudioPlayerView
    if (!self.audioPlayerView) {
        self.audioPlayerView = [[AudioPlayerView alloc] initWithAudioURL:audioURL backgroundPlay:YES];
        self.audioPlayerView.delegate = self;
    }
    
    // ✅ 显示播放器 - 现在在根视图上显示，不在滚动视图中
//    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
//    [self.audioPlayerView ];
    
    // 开始播放
    [self.audioPlayerView play];
}

/**
 暂停当前播放
 */
- (void)pauseCurrentPlaying {
    NSLog(@"⏸️ 暂停播放");
    
    if (self.audioPlayerView && self.audioPlayerView.isPlaying) {
        [self.audioPlayerView pause];
    }
}

/**
 重置指定索引cell的播放按钮
 */
- (void)resetPlayButtonAtIndex:(NSInteger)index {
    if (index >= 0 && index < self.voiceListArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        CreateStoryWithVoiceTableViewCell *cell = (CreateStoryWithVoiceTableViewCell *)[self.voiceTabelView cellForRowAtIndexPath:indexPath];
        if (cell) {
            cell.playBtn.selected = NO;
        }
    }
}

#pragma mark - CreateStoryWithVoiceTableViewCellDelegate (已删除)

// 已删除delegate方法，改用block回调

#pragma mark - AudioPlayerViewDelegate

- (void)audioPlayerDidStartPlaying {
    NSLog(@"▶️ 音频播放开始");
}

- (void)audioPlayerDidPause {
    NSLog(@"⏸️ 音频播放暂停");
    [self resetPlayButtonAtIndex:self.currentPlayingIndex];
}

- (void)audioPlayerDidFinish {
    NSLog(@"✅ 音频播放完成");
    [self resetPlayButtonAtIndex:self.currentPlayingIndex];
}

- (void)audioPlayerDidUpdateProgress:(CGFloat)progress currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    // 可以用来更新UI进度等
}

- (void)audioPlayerDidClose {
    NSLog(@"❌ 音频播放器关闭");
    [self resetPlayButtonAtIndex:self.currentPlayingIndex];
    [self.audioPlayerView stop];
    self.currentPlayingIndex = -1;
    self.audioPlayerView = nil;
}

#pragma mark - ScrollView Setup

/// ✅ 内容显示完成后滚动到底部（带动画）
- (void)scrollToBottomAfterContentVisible {
    NSLog(@"📱 内容显示完成，准备滚动到底部");
    
    if (!self.mainScrollView) {
        NSLog(@"⚠️ 主滚动视图未初始化，无法滚动");
        // 即使不能滚动，也要隐藏loading
        [self hideCustomLoadingView];
        return;
    }
    
    // ✅ 稍微延迟一下，让渲染完成
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 再次确保布局和contentSize是最新的
//        [self.contentView layoutIfNeeded];
//        [self updateMainScrollViewContentSize];
        
        CGSize contentSize = self.mainScrollView.contentSize;
        CGSize boundsSize = self.mainScrollView.bounds.size;
        
        // 如果内容高度大于可视区域高度，才需要滚动
        if (contentSize.height > boundsSize.height) {
            // 计算底部偏移量
            CGFloat bottomOffset = contentSize.height - boundsSize.height;
            CGPoint bottomPoint = CGPointMake(0, bottomOffset);
            
            NSLog(@"📱 开始滚动到底部：内容高度=%.1f, 可视高度=%.1f, 偏移量=%.1f",
                  contentSize.height, boundsSize.height, bottomOffset);
            
            // ✅ 带动画滚动到底部，让用户看到滚动过程
//            [self.mainScrollView setContentOffset:bottomPoint animated:YES];
            
            // ✅ 第六步：等待滚动动画完成后（约0.3秒），最后隐藏loading
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hideCustomLoadingView];
                NSLog(@"✅ 所有动作完成，loading已隐藏");
                self.saveStoryBtn.hidden = NO;
                self.deletBtn.hidden = NO;
                self.saveStoryBtn.alpha = 1.0;
                self.deletBtn.alpha = 1.0;
            });
        } else {
            NSLog(@"📱 内容未超出可视区域，无需滚动");
            // ✅ 不需要滚动时，也要隐藏loading
            [self hideCustomLoadingView];
            self.saveStoryBtn.hidden = NO;
            self.deletBtn.hidden = NO;
            self.saveStoryBtn.alpha = 1.0;
            self.deletBtn.alpha = 1.0;
            NSLog(@"✅ 所有动作完成，loading已隐藏");
        }
    });
}

/// ✅ 设置主滚动视图 - 将整个view包装到ScrollView中
- (void)setupScrollView {
    // 获取当前view的父视图
    UIView *parentView = self.view.superview;
    
    // 创建主滚动视图
    self.mainScrollView = [[UIScrollView alloc] init];
    self.mainScrollView.frame = self.view.frame;
    self.mainScrollView.backgroundColor = self.view.backgroundColor;
    self.mainScrollView.showsVerticalScrollIndicator = YES;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.bounces = YES;
    self.mainScrollView.alwaysBounceVertical = YES;
    self.mainScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag; // 拖动时隐藏键盘
    
    // 保存原有view作为内容视图
    self.contentView = self.view;
    
    // 创建新的根视图
    UIView *newRootView = [[UIView alloc] initWithFrame:self.view.frame];
    newRootView.backgroundColor = self.view.backgroundColor;
    
    // 将ScrollView添加到新的根视图中
    [newRootView addSubview:self.mainScrollView];
    
    // 将原有的view添加到ScrollView中
    [self.mainScrollView addSubview:self.contentView];
    
    // 替换视图控制器的view
    self.view = newRootView;
    
    // 设置ScrollView的frame填满新的根视图
    self.mainScrollView.frame = newRootView.bounds;
    self.mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // ✅ 延迟计算内容大小，让布局完成后再设置
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scheduleScrollViewContentSizeUpdate];
    });
    
    NSLog(@"✅ 滚动视图设置完成 - 保持原有XIB约束");
}


- (void)updateScrollViewContentSize {
    [self updateScrollViewContentSizeWithVoiceHeightRecalc:YES];
}

/// ✅ 更新滚动视图内容大小 - 控制是否重新计算音色区域高度
- (void)updateScrollViewContentSizeWithVoiceHeightRecalc:(BOOL)shouldRecalcVoiceHeight {
    if (!self.contentView) {
        return;
    }
    
    // 强制布局更新
    [self.contentView layoutIfNeeded];
    
    // ✅ 优化的动态调整故事内容区域的高度
    [self adjustStoryViewHeightOptimized];
    
    // ✅ 只有在必要时才重新计算音色选择区域的高度
    if (shouldRecalcVoiceHeight) {
        [self adjustVoiceSelectionViewHeight];
    }
    
    // 再次强制布局更新，确保约束变化生效
    [self.contentView layoutIfNeeded];
    
    // 延迟更新主滚动视图内容大小，避免重复计算
    [self scheduleScrollViewContentSizeUpdate];
}

/// ✅ 优化的动态调整故事内容区域的高度 - 使用约束
- (void)adjustStoryViewHeightOptimized {
    if (!self.storyViewHeight) {
        NSLog(@"⚠️ storyViewHeight约束未绑定");
        return;
    }
    
    // 获取故事内容
    NSString *storyContent = self.storyTextField.text ?: @"";
    if (storyContent.length == 0) {
        NSLog(@"📖 故事内容为空，使用默认高度");
        // 设置最小高度并更新滚动视图
        CGFloat minHeight = 120.0;
        if (self.storyViewHeight.constant != minHeight) {
            self.storyViewHeight.constant = minHeight;
            [self scheduleScrollViewContentSizeUpdate];
        }
        return;
    }
    
    // 计算文本所需的高度
    CGFloat textViewWidth = self.storyTextField.frame.size.width;
    if (textViewWidth <= 0) {
        textViewWidth = [UIScreen mainScreen].bounds.size.width - 32; // 默认宽度
    }
    
    // 减去内边距
    CGFloat contentWidth = textViewWidth - self.storyTextField.textContainerInset.left - self.storyTextField.textContainerInset.right;
    
    // 计算文本高度
    UIFont *font = self.storyTextField.font ?: [UIFont systemFontOfSize:16.0];
    CGRect textRect = [storyContent boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                              attributes:@{NSFontAttributeName: font}
                                                 context:nil];
    
    // 添加内边距和一些额外空间
    CGFloat requiredTextHeight = ceil(textRect.size.height);
    CGFloat topBottomPadding = self.storyTextField.textContainerInset.top + self.storyTextField.textContainerInset.bottom;
    CGFloat totalTextHeight = requiredTextHeight + topBottomPadding + 20; // 额外20pt空间
    
    // 设置最小和最大高度
    CGFloat minHeight = 120.0; // 最小高度
    CGFloat maxHeight = 400.0; // 最大高度，避免过高
    
    CGFloat newHeight = MAX(minHeight, MIN(totalTextHeight, maxHeight));
    
    // ✅ 只有在高度真的变化时才更新约束和滚动视图
    if (fabs(self.storyViewHeight.constant - newHeight) > 1.0) { // 允许1pt的误差
        CGFloat oldHeight = self.storyViewHeight.constant;
        self.storyViewHeight.constant = newHeight;
        
        // 动画更新布局
        [UIView animateWithDuration:0.3 animations:^{
            [self.contentView layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (finished) {
                // ✅ 布局完成后再更新滚动视图内容大小
                [self scheduleScrollViewContentSizeUpdate];
            }
        }];
        
        NSLog(@"📖 动态调整故事内容区域完成:");
        NSLog(@"   故事内容长度: %ld", (long)storyContent.length);
        NSLog(@"   计算文本高度: %.1f", requiredTextHeight);
        NSLog(@"   storyViewHeight约束: %.1f → %.1f", oldHeight, newHeight);
    } else {
        NSLog(@"📖 故事视图高度无需调整 (当前: %.1f, 计算: %.1f)", self.storyViewHeight.constant, newHeight);
    }
}

/// ✅ 添加延迟调整方法，避免频繁调用 - 优化版
- (void)scheduleOptimizedStoryHeightAdjustment {
    // 取消之前的调用
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(adjustStoryViewHeightOptimized) object:nil];
    
    // 延迟调用，避免频繁更新
    [self performSelector:@selector(adjustStoryViewHeightOptimized) withObject:nil afterDelay:0.2];
}

/// ✅ 延迟更新滚动视图内容大小 - 只在必要时计算
- (void)scheduleScrollViewContentSizeUpdate {
    // 取消之前的调用
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateMainScrollViewContentSize) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateMainScrollViewContentSizeWithExtraHeight) object:nil];
    
    // 延迟调用，避免频繁更新
    [self performSelector:@selector(updateMainScrollViewContentSize) withObject:nil afterDelay:0.1];
}

/// ✅ 延迟更新滚动视图内容大小（带额外高度）- 用于失败状态
- (void)scheduleScrollViewContentSizeUpdateWithExtraHeight:(CGFloat)extraHeight {
    // 取消之前的调用
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateMainScrollViewContentSize) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateMainScrollViewContentSizeWithExtraHeight) object:nil];
    
    // 保存额外高度到实例变量（如果需要的话）
    NSNumber *extraHeightNumber = @(extraHeight);
    
    // 延迟调用，避免频繁更新
    [self performSelector:@selector(updateMainScrollViewContentSizeWithExtraHeight:) withObject:extraHeightNumber afterDelay:0.1];
}

/// ✅ 优化的主滚动视图内容大小更新 - 避免重复计算
- (void)updateMainScrollViewContentSize {
    [self updateMainScrollViewContentSizeWithExtraHeight:@(20)];
}

/// ✅ 优化的主滚动视图内容大小更新（带额外高度）- 避免重复计算
- (void)updateMainScrollViewContentSizeWithExtraHeight:(NSNumber *)extraHeightNumber {
    if (!self.contentView || !self.mainScrollView) {
        return;
    }
    
    CGFloat extraHeight = extraHeightNumber.floatValue;
    
    // 强制布局更新，确保所有约束变化都已生效
    [self.contentView layoutIfNeeded];
    
    // 计算所有可见子视图的最大底部位置
    CGFloat maxY = 0;
    for (UIView *subview in self.contentView.subviews) {
        if (!subview.hidden && subview.alpha > 0) {
            CGFloat bottom = CGRectGetMaxY(subview.frame);
            if (bottom > maxY) {
                maxY = bottom;
            }
        }
    }
    
    // 添加适量底部边距，确保有足够的滚动空间
    maxY += 100;  // ✅ 底部边距统一设置为100pt
    
    // ✅ 为失败状态添加额外高度
    if (extraHeight > 0) {
        maxY += extraHeight;
        NSLog(@"📏 为失败状态添加额外高度: %.1f", extraHeight);
    }
    
    // ✅ 内容高度就是实际内容的高度，不强制增加到屏幕高度
    CGFloat contentHeight = maxY;
    
    // ✅ 只有在内容高度真的变化时才更新
    CGFloat currentContentHeight = self.mainScrollView.contentSize.height;
    if (fabs(currentContentHeight - contentHeight) > 5.0) { // 允许5pt的误差
        // 设置内容视图的frame大小
        CGRect contentFrame = self.contentView.frame;
        contentFrame.size.height = contentHeight;
        self.contentView.frame = contentFrame;
        
        // 设置ScrollView的内容大小
        self.mainScrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, contentHeight);
        
        NSLog(@"📏 优化滚动视图内容大小更新: %.1f → %.1f (最大Y: %.1f, 额外高度: %.1f)",
              currentContentHeight, contentHeight, maxY - extraHeight - 100, extraHeight);
    } else {
        NSLog(@"📏 滚动视图内容大小无需更新 (当前: %.1f, 计算: %.1f)", currentContentHeight, contentHeight);
    }
}

/// ✅ 动态调整音色选择区域的高度 - 使用约束
- (void)adjustVoiceSelectionViewHeight {
    if (!self.voiceListViewHeight) {
        NSLog(@"⚠️ voiceListViewHeight约束未绑定");
        return;
    }
    
    // 计算TableView需要的高度
    NSInteger cellCount = self.voiceListArray.count;
    CGFloat cellHeight = 64.0; // 每个cell的高度
    CGFloat newHeight = 0;
    
    if (cellCount > 0) {
        // 有数据时按cell数量计算高度
        newHeight = cellCount * cellHeight;
        
        // 设置一个最大高度限制，避免TableView过高
        CGFloat maxHeight = 5 * cellHeight; // 最多显示5个cell的高度
        newHeight = MIN(newHeight, maxHeight);
        
        // 添加一些内边距
        newHeight += 60.0; // 顶部和底部各20pt的边距
        
        self.emptyView.hidden = YES;
        NSLog(@"📊 有音色数据，计算高度: %.1f", newHeight);
    } else {
        // 没有数据时显示空视图，设置最小高度
        newHeight = 250.0; // 空状态的最小高度
        self.emptyView.hidden = NO;
        NSLog(@"📊 无音色数据，显示空视图，设置高度: %.1f", newHeight);
    }
    
    // 更新约束常量
    self.voiceListViewHeight.constant = newHeight;
    
    // 动画更新布局
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentView layoutIfNeeded];
    }];
    
    NSLog(@"📊 动态调整音色选择区域完成:");
    NSLog(@"   Cell数量: %ld", (long)cellCount);
    NSLog(@"   voiceListViewHeight约束: %.1f", newHeight);
}


#pragma mark - Keyboard Handling

/// ✅ 设置键盘通知监听
- (void)setupKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

/// ✅ 键盘将要显示
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSValue *keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    // 调整滚动视图的底部内边距
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:(UIViewAnimationOptions)animationCurve
                     animations:^{
        self.mainScrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        self.mainScrollView.scrollIndicatorInsets = self.mainScrollView.contentInset;
    } completion:nil];
    
    NSLog(@"⌨️ 键盘显示，高度: %.1f", keyboardHeight);
}

/// ✅ 键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    // 恢复滚动视图的内边距
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:(UIViewAnimationOptions)animationCurve
                     animations:^{
        self.mainScrollView.contentInset = UIEdgeInsetsZero;
        self.mainScrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    } completion:nil];
    
    NSLog(@"⌨️ 键盘隐藏");
}

/// ✅ 刷新音色列表（从其他页面返回时可能有新音色） - 改进版
- (void)refreshVoiceListIfNeeded {
    NSLog(@"🔄 检查是否需要刷新音色列表");
    
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] getVoicesWithStatus:0 success:^(VoiceListResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (response.list && response.list.count > 0) {
            // 过滤出已克隆成功的音色
            NSMutableArray *newVoiceList = [NSMutableArray array];
            strongSelf.voiceCount = response.list.count;
            
            for (VoiceModel *model in response.list) {
                if (model.cloneStatus == 2) {
                    [newVoiceList addObject:model];
                }
            }
            
            // ✅ 更详细的变化检测
            BOOL shouldUpdate = NO;
            NSString *changeReason = @"";
            
            if (newVoiceList.count != strongSelf.voiceListArray.count) {
                shouldUpdate = YES;
                changeReason = [NSString stringWithFormat:@"数量变化: %ld → %ld",
                               (long)strongSelf.voiceListArray.count, (long)newVoiceList.count];
            } else {
                // 检查音色ID是否有变化
                for (NSInteger i = 0; i < newVoiceList.count; i++) {
                    VoiceModel *newVoice = newVoiceList[i];
                    if (i < strongSelf.voiceListArray.count) {
                        VoiceModel *oldVoice = strongSelf.voiceListArray[i];
                        if (newVoice.voiceId != oldVoice.voiceId) {
                            shouldUpdate = YES;
                            changeReason = [NSString stringWithFormat:@"音色ID变化在位置%ld: %ld → %ld",
                                           (long)i, (long)oldVoice.voiceId, (long)newVoice.voiceId];
                            break;
                        }
                    }
                }
            }
            
            if (shouldUpdate) {
                NSLog(@"🆕 检测到音色列表变化: %@", changeReason);
                
                // ✅ 记录当前选中的音色ID (如果有)
                NSInteger currentSelectedVoiceId = 0;
                if (strongSelf.selectedVoiceIndex >= 0 && strongSelf.selectedVoiceIndex < strongSelf.voiceListArray.count) {
                    VoiceModel *currentSelected = strongSelf.voiceListArray[strongSelf.selectedVoiceIndex];
                    currentSelectedVoiceId = currentSelected.voiceId;
                }
                
                // 更新数据源
                [strongSelf.voiceListArray removeAllObjects];
                [strongSelf.voiceListArray addObjectsFromArray:newVoiceList];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 刷新UI
                    [strongSelf.voiceTabelView reloadData];
                    strongSelf.emptyView.hidden = (newVoiceList.count > 0);
                    
                    // ✅ 重新匹配音色选择
                    if (strongSelf.isEditMode && strongSelf.currentStory.voiceId > 0) {
                        NSLog(@"🔄 音色列表更新后，重新匹配编辑模式的音色");
                        [strongSelf selectVoiceWithId:strongSelf.currentStory.voiceId];
                        [strongSelf.voiceTabelView reloadData];
                    } else if (currentSelectedVoiceId > 0) {
                        // 尝试恢复之前选中的音色
                        NSLog(@"🔄 尝试恢复之前选中的音色ID: %ld", (long)currentSelectedVoiceId);
                        [strongSelf selectVoiceWithId:currentSelectedVoiceId];
                        [strongSelf.voiceTabelView reloadData];
                    }
                    
                    // 动态调整高度（音色列表有变化，需要重新计算）
                    [strongSelf updateScrollViewContentSizeWithVoiceHeightRecalc:YES];
                });
            } else {
                NSLog(@"✅ 音色列表无变化");
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"❌ 刷新音色列表失败: %@", error.localizedDescription);
    }];
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
- (void)showBoundDollDeletionConfirm {
    // 获取第一个公仔的 customName
    StoryBoundDoll *firstDoll = self.currentStory.boundDolls.firstObject;
    NSString *customName = firstDoll.customName ?: LocalString(@"未知公仔");
    
    NSLog(@"⚠️ 故事 '%@' 已绑定公仔 '%@'，显示删除确认弹窗", self.currentStory.storyName, customName);
    
    // 构建提示信息
    NSString *title = LocalString(@"删除已绑定故事");
    NSString *message = [NSString stringWithFormat:LocalString(@"该故事已关联公仔“%@”。请将公仔放回设备以获取最新资源。\n\n确定要删除该故事吗？"), customName];
    
    __weak typeof(self) weakSelf = self;
    [LGBaseAlertView showAlertWithTitle:title
                                content:message
                             cancelBtnStr:LocalString(@"取消")
                            confirmBtnStr:LocalString(@"删除")
                            confirmBlock:^(BOOL is_value, id obj) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (is_value) { // 用户点击了"Delete"按钮
            NSLog(@"✅ 用户确认删除已绑定公仔的故事");
            [strongSelf performDeleteStory];
        } else {
            NSLog(@"❌ 用户取消删除已绑定公仔的故事");
        }
    }];
}

- (void)configureStoryTextView {
    // 基础文字配置
    self.storyTextField.font = [UIFont systemFontOfSize:16.0];
    self.storyTextField.textColor = [UIColor blackColor];
    
    // 设置内边距，让文字充满背景
//    self.storyTextField.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
//    self.storyTextField.textContainer.lineFragmentPadding = 0; // 去除默认的左右边距
    
//    // ✅ 修改滚动配置，避免与主滚动视图冲突
//    self.storyTextField.scrollEnabled = YES; // 禁用内部滚动，使用主滚动视图
//    self.storyTextField.showsVerticalScrollIndicator = NO;
//    self.storyTextField.showsHorizontalScrollIndicator = NO;
//    self.storyTextField.bounces = NO;
    
    // 键盘和输入配置
//    self.storyTextField.returnKeyType = UIReturnKeyDefault;
//    self.storyTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
//    self.storyTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
//    self.storyTextField.spellCheckingType = UITextSpellCheckingTypeDefault;
    
    // 文本布局配置
    self.storyTextField.textAlignment = [ATLanguageHelper isRTLLanguage] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    // 圆角和边框（可选）
//    self.storyTextField.layer.cornerRadius = 8.0;
//    self.storyTextField.layer.masksToBounds = YES;
    
    // 确保文本容器充满整个视图
//    self.storyTextField.textContainer.widthTracksTextView = YES;
//    self.storyTextField.textContainer.heightTracksTextView = YES; // 让高度自动适应内容
//    self.storyTextField.textContainer.maximumNumberOfLines = 0; // 无限行数
    
    // 设置键盘外观
//    if (@available(iOS 13.0, *)) {
//        self.storyTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
//    }
    
    // ✅ 添加文本变化监听，用于实时调整高度
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storyTextDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self.storyTextField];
}

/// ✅ 故事文本变化监听器 - 实时调整高度
- (void)storyTextDidChange:(NSNotification *)notification {
    if (notification.object == self.storyTextField) {
        // ✅ 使用优化的延迟调整，避免频繁更新
        [self scheduleOptimizedStoryHeightAdjustment];
    }
}



- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    
//    // 如果视图已经加载，立即更新UI
//    if (self.isViewLoaded) {
//        self.title = isEditMode ? @"Edit Story" : @"Create Story";
////        [self updateTextFieldsEditability];
//    }
}

//- (IBAction)addHeaderImageBtnClick:(id)sender {
//    [self showIllustrationPicker];
//}
//- (void)showIllustrationPicker {
//    SelectIllustrationVC *vc = [[SelectIllustrationVC alloc] init];
//
//    // 设置当前已选择的图片URL，以便在选择器中显示选中状态
//    if (self.selectedIllustrationUrl && self.selectedIllustrationUrl.length > 0) {
//        vc.imgUrl = self.selectedIllustrationUrl;
//        NSLog(@"🖼️ 传递已选择的图片URL: %@", self.selectedIllustrationUrl);
//    }
//
//    // 设置回调
//    vc.sureBlock = ^(NSString *imgUrl) {
//        NSLog(@"选中的插画: %@", imgUrl);
//
//        // ✅ 检查插画是否真的有变更
//        NSString *currentUrl = imgUrl ?: @"";
//        NSString *originalUrl = self.originalIllustrationUrl ?: @"";
//
//        // 保存选中的插画URL
//        self.selectedIllustrationUrl = imgUrl;
//
//        // ✅ 编辑模式下检测插画变化
//        if (self.isEditMode && ![currentUrl isEqualToString:originalUrl]) {
//            self.hasUnsavedChanges = YES;
//            NSLog(@"🔄 插画发生变更: '%@' → '%@'", originalUrl, currentUrl);
//        }
//
//        // 使用插画URL设置按钮背景
//        [self.voiceHeaderImageBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl]
//                                             forState:UIControlStateNormal
//                                     placeholderImage:nil
//                                              options:SDWebImageRefreshCached
//                                            completed:nil];
//        self.deletHeaderBtn.hidden = NO;
//        NSLog(@"✅ 插画已选中，URL已保存");
//    };
//
//    // 显示
//    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    [self presentViewController:vc animated:NO completion:^{
//        [vc showView];
//    }];
//}

- (void)removeImageButtonTapped {
    // ✅ 编辑模式下检测插画变化
    if (self.isEditMode) {
        NSString *originalUrl = self.originalIllustrationUrl ?: @"";
        if (originalUrl.length > 0) {
            self.hasUnsavedChanges = YES;
            NSLog(@"🔄 插画被删除，原插画: '%@'", originalUrl);
        }
    }
    
    self.selectedIllustrationUrl = nil;
    [self.voiceHeaderImageBtn setImage:nil forState:UIControlStateNormal];
//    self.deletHeaderBtn.hidden = YES;
}




- (void)showErrorAlert:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalString(@"提示")
                                                                       message:errorMessage ?: LocalString(@"网络请求失败，请稍后重试")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:LocalString(@"确定")
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (IBAction)addNewVoice:(id)sender {
    if (self.voiceCount>=3) {
        [SVProgressHUD showErrorWithStatus:@"3 voices have been created, please delete before creating new ones"];
    }else{
        CreateVoiceViewController * vc = [[CreateVoiceViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
   
}

- (IBAction)saveStory:(id)sender {
    if (self.isEditMode) {
        // ✅ 编辑模式：调用编辑故事接口
        [self handleEditStory];
    } else {
        // 创建模式：调用合成音频接口（原有逻辑）
        [self handleCreateStory];
    }
    
    
}

/// ✅ 处理编辑故事
- (void)handleEditStory {
    NSLog(@"📝 开始编辑故事流程");
    
    // 检查是否有未保存的更改
    if (!self.hasUnsavedChanges && ![self detectAnyChanges]) {
        [self showErrorAlert:LocalString(@"未检测到修改")];
        //APP埋点：声音合成
            [[AnalyticsManager sharedManager]reportEventWithName:@"choose_voice_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"选择声音并保存时" properties:@{@"choosevoicesaveResult":[NSString stringWithFormat:@"Fail:(No changes detected)"]} completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
        return;
    }
    
    // 验证必要参数
    NSString *validationError = [self validateEditStoryParameters];
    if (validationError) {
        [self showErrorAlert:validationError];
        return;
    }
    
    // 获取选中的音色ID
    NSInteger currentVoiceId = [self getCurrentVoiceId];
    
    // ✅ 验证音色ID是否有效
    if (currentVoiceId <= 0) {
        NSLog(@"❌ 音色ID无效: %ld", (long)currentVoiceId);
        [self showErrorAlert:LocalString(@"请选择有效的音色")];
        return;
    }
    
    NSLog(@"🎵 编辑故事使用的音色ID: %ld", (long)currentVoiceId);
    
    // 检测所有变更
    NSDictionary *changes = [self detectAllStoryChanges];
    NSLog(@"🔍 检测到的变更: %@", changes);
    
    // 准备编辑请求参数
    NSDictionary *params = @{
        @"familyId": @([[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue]),
        @"storyId": @(self.storyId),
        @"storyName": self.stroryThemeTextView.text ?: @"",
        @"storyContent": self.storyTextField.text ?: @"",
        @"illustrationUrl": self.selectedIllustrationUrl ?: @"",
        @"voiceId": @(currentVoiceId)
    };
    
    NSLog(@"📤 开始编辑故事，完整参数:");
    NSLog(@"   familyId: %@", params[@"familyId"]);
    NSLog(@"   storyId: %@", params[@"storyId"]);
    NSLog(@"   storyName: %@", params[@"storyName"]);
    NSLog(@"   storyContent长度: %ld", [(NSString *)params[@"storyContent"] length]);
    NSLog(@"   illustrationUrl: %@", params[@"illustrationUrl"]);
    NSLog(@"   voiceId: %@ ✅", params[@"voiceId"]); // 特别标注音色ID
    
    // 显示加载提示
    [SVProgressHUD showWithStatus:LocalString(@"保存中...")];
    
    // 调用编辑故事接口
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] updateStory:[[UpdateStoryRequestModel alloc] initWithParams:params]
                                           success:^(APIResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [SVProgressHUD dismiss];
        
        NSLog(@"✅ 故事编辑成功: %@", response);
        
        //APP埋点：声音合成
            [[AnalyticsManager sharedManager]reportEventWithName:@"choose_voice_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"选择声音并保存时" properties:@{@"choosevoicesaveResult":@"success"} completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
        
        
        // ✅ 更新原始数据并清除未保存状态
        [strongSelf updateOriginalDataAfterSave];
        
        [LGBaseAlertView showAlertWithTitle:LocalString(@"保存成功")
                                    content:LocalString(@"故事已成功更新")
                               cancelBtnStr:nil
                              confirmBtnStr:LocalString(@"确定")
                               confirmBlock:^(BOOL isValue, id obj) {
            if (isValue) {
                
                
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
        
    } failure:^(NSError * _Nonnull error) {
        
        //APP埋点：声音合成
            [[AnalyticsManager sharedManager]reportEventWithName:@"choose_voice_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"选择声音并保存时" properties:@{@"choosevoicesaveResult":[NSString stringWithFormat:@"Fail:(%@)",error.localizedDescription]} completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [SVProgressHUD dismiss];
        
       
    }];
}

/// ✅ 处理创建故事（原有逻辑）
- (void)handleCreateStory {
    // 检查是否选择了音色
    if (self.selectedVoiceIndex < 0 || self.selectedVoiceIndex >= self.voiceListArray.count) {
        [self showErrorAlert:LocalString(@"请先选择音色")];
        //APP埋点：声音合成
            [[AnalyticsManager sharedManager]reportEventWithName:@"choose_voice_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"选择声音并保存时" properties:@{@"choosevoicesaveResult":[NSString stringWithFormat:@"Fail:(Please select a voice first)"]} completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
        return;
    }
    
    // 检查故事名称是否为空
    if (!self.stroryThemeTextView.text || self.stroryThemeTextView.text.length == 0) {
        [self showErrorAlert:LocalString(@"请输入故事名称")];
        //APP埋点：声音合成
            [[AnalyticsManager sharedManager]reportEventWithName:@"choose_voice_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"选择声音并保存时" properties:@{@"choosevoicesaveResult":[NSString stringWithFormat:@"Fail:(Please enter story name)"]} completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
        return;
    }
    
    // 获取选中的音色模型
    id selectedVoiceModel = self.voiceListArray[self.selectedVoiceIndex];
    
    // 获取 voiceId
    NSInteger voiceId = 0;
    if ([selectedVoiceModel respondsToSelector:@selector(voiceId)]) {
        voiceId = [[selectedVoiceModel valueForKey:@"voiceId"] integerValue];
    } else if ([selectedVoiceModel respondsToSelector:@selector(id)]) {
        voiceId = [[selectedVoiceModel valueForKey:@"id"] integerValue];
    }
    
    if (voiceId == 0) {
        [self showErrorAlert:LocalString(@"获取音色ID失败")];
        return;
    }
    
    // 准备请求参数
    NSString *storyContent = self.isEditMode ? self.storyTextField.text : self.currentStory.storyContent;
    
    NSDictionary *params = @{
        @"storyId": @(self.storyId),
        @"familyId":@([[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue]),
        @"voiceId": @(voiceId),
        @"storyName": self.stroryThemeTextView.text ?: @"",
        @"storyContent": storyContent ?: @"",
        @"illustrationUrl": self.selectedIllustrationUrl ?: @""
    };
    
    NSLog(@"📤 开始合成音频，参数: %@", params);
    
    // 显示加载提示
    [SVProgressHUD showWithStatus:LocalString(@"正在合成音频...")];
    
    // 调用音频合成接口
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] synthesizeStoryAudioWithParams:params
                                                              success:^(id _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [SVProgressHUD dismiss];
        
        NSLog(@"✅ 音频合成成功: %@", response);
        
        //APP埋点：声音合成
            [[AnalyticsManager sharedManager]reportEventWithName:@"choose_voice_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"选择声音并保存时" properties:@{@"choosevoicesaveResult":@"success"} completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
        
        [LGBaseAlertView showAlertWithTitle:LocalString(@"故事生成中，预计3-5分钟")
                                    content:LocalString(@"稍后可在故事列表查看")
                               cancelBtnStr:nil
                              confirmBtnStr:LocalString(@"确定")
                               confirmBlock:^(BOOL isValue, id obj) {
            if (isValue) {
                
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        
    } failure:^(NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [SVProgressHUD dismiss];
        
        NSLog(@"❌ 音频合成失败: %@", error.localizedDescription);
        //APP埋点：声音合成
            [[AnalyticsManager sharedManager]reportEventWithName:@"choose_voice_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"选择声音并保存时" properties:@{@"choosevoicesaveResult":[NSString stringWithFormat:@"Fail:(%@)",error.localizedDescription]} completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
        
    }];
}
- (IBAction)deletBtnClick:(id)sender {
    // ✅ 实现删除故事功能
    
    // ✅ 检查故事ID是否有效
    if (self.storyId <= 0) {
        NSLog(@"⚠️ 故事ID无效，无法删除");
        [self showErrorAlert:LocalString(@"删除失败：故事数据错误")];
        return;
    }
    
    // ✅ 检查故事是否已绑定公仔
    if ([self checkStoryBoundDoll:self.currentStory]) {
        // 已绑定公仔，显示特殊确认弹窗
        [self showBoundDollDeletionConfirm];
        return;
    }
    
    // 未绑定公仔，显示正常删除确认对话框
    [self showDeleteConfirmation];
}

#pragma mark - Delete Story Methods

/// 显示删除确认对话框
- (void)showDeleteConfirmation {
    // ✅ 获取故事名称用于确认对话框
    NSString *storyName = self.currentStory.storyName ?: self.stroryThemeTextView.text ?: LocalString(@"该故事");
    
    NSString *alertTitle = LocalString(@"删除故事");
    NSString *alertMessage = [NSString stringWithFormat:LocalString(@"确定要删除故事“%@”吗？此操作无法撤销。"), storyName];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // ✅ 取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LocalString(@"取消")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"📝 User cancelled story deletion: %@", storyName);
    }];
    
    // ✅ 删除按钮（使用危险样式）
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:LocalString(@"删除")
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"🗑️ User confirmed story deletion: %@, starting deletion", storyName);
        [self performDeleteStory];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    
    // ✅ 显示对话框
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

/// 执行删除故事操作
- (void)performDeleteStory {
    // ✅ 检查故事ID是否有效
    if (self.storyId <= 0) {
        NSLog(@"❌ 故事ID无效: %ld", (long)self.storyId);
        [self showErrorAlert:LocalString(@"删除失败：故事ID无效")];
        return;
    }
    
    NSLog(@"🗑️ 开始删除故事，ID: %ld", (long)self.storyId);
    
    // ✅ 显示加载提示
    [SVProgressHUD showWithStatus:LocalString(@"正在删除...")];
    
    // ✅ 停止音频播放（如果正在播放）
    [self stopAudioPlayback];
    
    // ✅ 调用删除接口
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] deleteStoryWithId:self.storyId
                                                  success:^(APIResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            NSLog(@"✅ 故事删除成功: %@", response);
            
            // ✅ 显示删除成功提示
            [strongSelf showDeleteSuccessAlert];
        });
        
    } failure:^(NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        [SVProgressHUD dismiss];
        
    }];
}

/// 停止音频播放
- (void)stopAudioPlayback {
    if (self.audioPlayerView) {
        [self.audioPlayerView stop];
        self.audioPlayerView = nil;
        self.currentPlayingIndex = -1;
        NSLog(@"🔇 已停止音频播放");
    }
}

/// 显示删除成功提示
- (void)showDeleteSuccessAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"删除成功")
                                                                             message:LocalString(@"故事已成功删除")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LocalString(@"确定")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        // ✅ 发送通知，让故事列表页面刷新数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StoryDeletedNotification"
                                                            object:nil
                                                          userInfo:@{@"storyId": @(self.storyId)}];
        
        // ✅ 删除成功后返回上一页
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - ✅ 编辑模式变更追踪方法

/// 记录原始故事数据
- (void)recordOriginalStoryData:(VoiceStoryModel *)story {
    NSLog(@"📋 记录原始故事数据用于变更追踪...");
    
    self.originalStoryName = story.storyName ?: @"";
    self.originalStoryContent = story.storyContent ?: @"";
    self.originalIllustrationUrl = story.illustrationUrl ?: @"";
    self.originalVoiceId = story.voiceId;
    
    NSLog(@"   原始故事名称: %@", self.originalStoryName);
    NSLog(@"   原始故事内容长度: %ld", (long)self.originalStoryContent.length);
    NSLog(@"   原始插画URL: %@", self.originalIllustrationUrl);
    NSLog(@"   原始音色ID: %ld", (long)self.originalVoiceId);
}

/// 设置编辑模式文本变化监听
- (void)setupEditModeTextObservers {
    NSLog(@"🔧 设置编辑模式文本变化监听");
    
    // 监听故事名称变化
    [self.stroryThemeTextView addTarget:self
                                 action:@selector(storyNameDidChange:)
                       forControlEvents:UIControlEventEditingChanged];
    
    // 监听故事内容变化（UITextView需要使用通知）
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storyContentDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self.storyTextField];
}

/// 故事名称变化监听
- (void)storyNameDidChange:(UITextField *)textField {
    NSString *currentName = textField.text ?: @"";
    if (![currentName isEqualToString:self.originalStoryName]) {
        self.hasUnsavedChanges = YES;
        NSLog(@"🔄 故事名称发生变更: '%@' → '%@'", self.originalStoryName, currentName);
    }
}

/// 故事内容变化监听
- (void)storyContentDidChange:(NSNotification *)notification {
    if (notification.object == self.storyTextField) {
        NSString *currentContent = self.storyTextField.text ?: @"";
        if (![currentContent isEqualToString:self.originalStoryContent]) {
            self.hasUnsavedChanges = YES;
            NSLog(@"🔄 故事内容发生变更，长度: %ld → %ld",
                  (long)self.originalStoryContent.length, (long)currentContent.length);
        }
        
        // ✅ 使用延迟调整，避免频繁更新，并优化滚动视图计算
        [self scheduleOptimizedStoryHeightAdjustment];
    }
}

/// 根据音色ID选中对应的音色 - 改进匹配逻辑
- (void)selectVoiceWithId:(NSInteger)voiceId {
    NSLog(@"🔍 开始查找音色ID: %ld，当前音色列表数量: %ld", (long)voiceId, (long)self.voiceListArray.count);
    
    if (voiceId <= 0) {
        NSLog(@"⚠️ 无效的音色ID: %ld", (long)voiceId);
        self.selectedVoiceIndex = -1;
        return;
    }
    
    // ✅ 重置选中索引
    self.selectedVoiceIndex = -1;
    
    // ✅ 遍历查找匹配的音色
    for (NSInteger i = 0; i < self.voiceListArray.count; i++) {
        VoiceModel *voice = self.voiceListArray[i];
        
        // ✅ 添加更详细的日志
        NSLog(@"   检查音色[%ld]: 名称='%@', ID=%ld, cloneStatus=%ld",
              (long)i, voice.voiceName ?: @"无名称", (long)voice.voiceId, (long)voice.cloneStatus);
        
        // ✅ 严格匹配音色ID
        if (voice.voiceId == voiceId) {
            self.selectedVoiceIndex = i;
            NSLog(@"🎵 成功匹配！自动选中音色: '%@' (ID: %ld, 索引: %ld)",
                  voice.voiceName ?: @"无名称", (long)voiceId, (long)i);
            
            // ✅ 匹配成功后立即返回
            return;
        }
    }
    
    // ✅ 如果没有找到匹配的音色，提供更详细的错误信息
    NSLog(@"⚠️ 未找到匹配的音色ID: %ld", (long)voiceId);
    NSLog(@"   当前可用音色列表:");
    for (NSInteger i = 0; i < self.voiceListArray.count; i++) {
        VoiceModel *voice = self.voiceListArray[i];
        NSLog(@"     [%ld] %@ (ID: %ld)", (long)i, voice.voiceName ?: @"无名称", (long)voice.voiceId);
    }
    
    self.selectedVoiceIndex = -1;
}

/// ✅ 备用音色选择策略
- (void)tryFallbackVoiceSelection {
    NSLog(@"🔄 尝试备用音色选择策略");
    
    if (!self.isEditMode || !self.currentStory) {
        return;
    }
    
    NSInteger targetVoiceId = self.currentStory.voiceId;
    NSLog(@"🎯 目标音色ID: %ld", (long)targetVoiceId);
    
    // ✅ 策略1: 重新获取完整音色列表（包括所有状态）
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] getVoicesWithStatus:0 success:^(VoiceListResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"🔍 备用策略：获得完整音色列表，数量: %ld", (long)response.list.count);
        
        // 查找目标音色的详细信息
        VoiceModel *targetVoice = nil;
        for (VoiceModel *voice in response.list) {
            if (voice.voiceId == targetVoiceId) {
                targetVoice = voice;
                break;
            }
        }
        
        if (targetVoice) {
            NSLog(@"🎵 找到目标音色: %@, cloneStatus: %ld", targetVoice.voiceName ?: @"无名称", (long)targetVoice.cloneStatus);
            
            if (targetVoice.cloneStatus != 2) {
                NSLog(@"⚠️ 音色状态异常: cloneStatus = %ld (应为2)", (long)targetVoice.cloneStatus);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *statusText = @"";
                    switch (targetVoice.cloneStatus) {
                        case 0:
                            statusText = LocalString(@"待处理");
                            break;
                        case 1:
                            statusText = LocalString(@"处理中");
                            break;
                        case 3:
                            statusText = LocalString(@"失败");
                            break;
                        default:
                            statusText = [NSString stringWithFormat:LocalString(@"未知状态（%ld）"), (long)targetVoice.cloneStatus];
                            break;
                    }
                    
                    NSString *alertMessage = [NSString stringWithFormat:LocalString(@"故事使用的音色“%@”当前状态为：%@\n无法在列表中显示"),
                                            targetVoice.voiceName ?: LocalString(@"未知音色"), statusText];
                    [strongSelf showErrorAlert:alertMessage];
                });
            } else {
                // 音色状态正常但不在过滤列表中，可能是数据同步问题
                NSLog(@"🔄 音色状态正常，重新加载音色列表");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf reloadVoiceListAndRetrySelection];
                });
            }
        } else {
            NSLog(@"❌ 完整列表中也找不到音色ID: %ld", (long)targetVoiceId);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *alertMessage = [NSString stringWithFormat:LocalString(@"故事使用的音色（ID:%ld）已不存在\n请重新选择音色"), (long)targetVoiceId];
                [strongSelf showErrorAlert:alertMessage];
            });
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"❌ 备用策略失败: %@", error.localizedDescription);
    }];
}

/// ✅ 重新加载音色列表并重试选择
- (void)reloadVoiceListAndRetrySelection {
    NSLog(@"🔄 重新加载音色列表并重试选择");
    
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] getVoicesWithStatus:0 success:^(VoiceListResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        // 重新过滤音色列表
        [strongSelf.voiceListArray removeAllObjects];
        strongSelf.voiceCount = response.list.count;
        
        for (VoiceModel *model in response.list) {
            if (model.cloneStatus == 2) {
                [strongSelf.voiceListArray addObject:model];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 刷新UI
            [strongSelf.voiceTabelView reloadData];
            strongSelf.emptyView.hidden = (strongSelf.voiceListArray.count > 0);
            
            // 再次尝试匹配
            if (strongSelf.currentStory.voiceId > 0) {
                [strongSelf selectVoiceWithId:strongSelf.currentStory.voiceId];
                
                if (strongSelf.selectedVoiceIndex >= 0) {
                    NSLog(@"✅ 重新加载后匹配成功");
                    [strongSelf.voiceTabelView reloadData];
                } else {
                    NSLog(@"❌ 重新加载后仍匹配失败");
                }
            }
            
            // 更新滚动视图（音色列表有变化，需要重新计算）
            [strongSelf updateScrollViewContentSizeWithVoiceHeightRecalc:YES];
        });
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"❌ 重新加载音色列表失败: %@", error.localizedDescription);
    }];
}

/// 获取当前选中的音色ID
- (NSInteger)getCurrentVoiceId {
    if (self.selectedVoiceIndex >= 0 && self.selectedVoiceIndex < self.voiceListArray.count) {
        VoiceModel *selectedVoice = self.voiceListArray[self.selectedVoiceIndex];
        return selectedVoice.voiceId;
    }
    
    // ✅ 编辑模式下，如果没有重新选择音色，返回原始音色ID
    if (self.isEditMode && self.originalVoiceId > 0) {
        NSLog(@"⚠️ 编辑模式下未重新选择音色，使用原始音色ID: %ld", (long)self.originalVoiceId);
        return self.originalVoiceId;
    }
    
    return 0;
}

/// 验证编辑故事参数
- (NSString *)validateEditStoryParameters {
    // 检查故事名称
    NSString *storyName = self.stroryThemeTextView.text;
    if (!storyName || storyName.length == 0) {
        return LocalString(@"请输入故事名称");
    }
    
    // 检查故事内容
    NSString *storyContent = self.storyTextField.text;
    if (!storyContent || storyContent.length == 0) {
        return LocalString(@"请输入故事内容");
    }
    
    // ✅ 改进音色选择检查逻辑 - 确保有有效的音色ID
    NSInteger currentVoiceId = [self getCurrentVoiceId];
    if (currentVoiceId <= 0) {
        // 如果是编辑模式且没有选择新音色，检查是否有原始音色ID
        if (self.isEditMode && self.originalVoiceId > 0) {
            NSLog(@"✅ 编辑模式：使用原始音色ID %ld", (long)self.originalVoiceId);
        } else {
            return LocalString(@"请选择音色");
        }
    }
    
    // 检查插画选择
    if (!self.selectedIllustrationUrl || self.selectedIllustrationUrl.length == 0) {
        return LocalString(@"请选择故事插画");
    }
    
    return nil; // 验证通过
}

/// 检测任意变更
- (BOOL)detectAnyChanges {
    NSString *currentName = self.stroryThemeTextView.text ?: @"";
    NSString *currentContent = self.storyTextField.text ?: @"";
    NSString *currentIllustration = self.selectedIllustrationUrl ?: @"";
    NSInteger currentVoiceId = [self getCurrentVoiceId];
    
    BOOL nameChanged = ![currentName isEqualToString:self.originalStoryName];
    BOOL contentChanged = ![currentContent isEqualToString:self.originalStoryContent];
    BOOL illustrationChanged = ![currentIllustration isEqualToString:self.originalIllustrationUrl];
    BOOL voiceChanged = (currentVoiceId != self.originalVoiceId);
    
    return (nameChanged || contentChanged || illustrationChanged || voiceChanged);
}

/// 检测所有故事变更
- (NSDictionary *)detectAllStoryChanges {
    NSMutableDictionary *changes = [NSMutableDictionary dictionary];
    NSMutableArray *changedFields = [NSMutableArray array];
    
    // 检测故事名称变更
    NSString *currentName = self.stroryThemeTextView.text ?: @"";
    BOOL nameChanged = ![currentName isEqualToString:self.originalStoryName];
    if (nameChanged) {
        [changedFields addObject:@"storyName"];
        changes[@"storyName"] = @{@"original": self.originalStoryName, @"current": currentName};
    }
    
    // 检测故事内容变更
    NSString *currentContent = self.storyTextField.text ?: @"";
    BOOL contentChanged = ![currentContent isEqualToString:self.originalStoryContent];
    if (contentChanged) {
        [changedFields addObject:@"storyContent"];
        changes[@"storyContent"] = @{
            @"original": @(self.originalStoryContent.length),
            @"current": @(currentContent.length)
        };
    }
    
    // 检测插画变更
    NSString *currentIllustration = self.selectedIllustrationUrl ?: @"";
    BOOL illustrationChanged = ![currentIllustration isEqualToString:self.originalIllustrationUrl];
    if (illustrationChanged) {
        [changedFields addObject:@"illustrationUrl"];
        changes[@"illustrationUrl"] = @{@"original": self.originalIllustrationUrl, @"current": currentIllustration};
    }
    
    // 检测音色变更
    NSInteger currentVoiceId = [self getCurrentVoiceId];
    BOOL voiceChanged = (currentVoiceId != self.originalVoiceId);
    if (voiceChanged) {
        [changedFields addObject:@"voiceId"];
        changes[@"voiceId"] = @{@"original": @(self.originalVoiceId), @"current": @(currentVoiceId)};
    }
    
    // 汇总变更信息
    changes[@"changedFields"] = [changedFields copy];
    changes[@"hasChanges"] = @(changedFields.count > 0);
    changes[@"changeCount"] = @(changedFields.count);
    
    return [changes copy];
}

/// 保存成功后更新原始数据
- (void)updateOriginalDataAfterSave {
    NSLog(@"🔄 更新原始数据以防重复提交...");
    
    self.originalStoryName = self.stroryThemeTextView.text ?: @"";
    self.originalStoryContent = self.storyTextField.text ?: @"";
    self.originalIllustrationUrl = self.selectedIllustrationUrl ?: @"";
    self.originalVoiceId = [self getCurrentVoiceId];
    self.hasUnsavedChanges = NO;
    
    NSLog(@"   已更新原始故事名称: %@", self.originalStoryName);
    NSLog(@"   已更新原始故事内容长度: %ld", (long)self.originalStoryContent.length);
    NSLog(@"   已更新原始插画URL: %@", self.originalIllustrationUrl);
    NSLog(@"   已更新原始音色ID: %ld", (long)self.originalVoiceId);
}

#pragma mark - ✅ 调试和验证方法

/// ✅ 验证并修复音色选中状态
- (void)validateAndFixVoiceSelectionState {
    NSLog(@"🔍 ========== 验证音色选中状态 ==========");
    NSLog(@"   编辑模式: %@", self.isEditMode ? @"是" : @"否");
    NSLog(@"   当前selectedVoiceIndex: %ld", (long)self.selectedVoiceIndex);
    NSLog(@"   音色数组数量: %ld", (long)self.voiceListArray.count);
    
    if (self.isEditMode && self.currentStory) {
        NSLog(@"   故事原始音色ID: %ld", (long)self.currentStory.voiceId);
        
        // 如果当前没有选中任何音色，但故事有音色ID，尝试重新匹配
        if (self.selectedVoiceIndex < 0 && self.currentStory.voiceId > 0) {
            NSLog(@"🔄 发现选中状态丢失，尝试重新匹配音色ID: %ld", (long)self.currentStory.voiceId);
            [self selectVoiceWithId:self.currentStory.voiceId];
            
            if (self.selectedVoiceIndex >= 0) {
                NSLog(@"✅ 重新匹配成功，选中索引: %ld", (long)self.selectedVoiceIndex);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.voiceTabelView reloadData];
                });
            }
        }
    }
    
    // 显示当前选中的音色信息
    if (self.selectedVoiceIndex >= 0 && self.selectedVoiceIndex < self.voiceListArray.count) {
        VoiceModel *selectedVoice = self.voiceListArray[self.selectedVoiceIndex];
        NSLog(@"   ✅ 当前选中音色: '%@' (ID: %ld, 索引: %ld)",
              selectedVoice.voiceName ?: @"无名称",
              (long)selectedVoice.voiceId,
              (long)self.selectedVoiceIndex);
              
        // ✅ 强制更新对应的cell显示状态
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedVoiceIndex inSection:0];
            CreateStoryWithVoiceTableViewCell *selectedCell = [self.voiceTabelView cellForRowAtIndexPath:selectedIndexPath];
            if (selectedCell) {
                selectedCell.selectBtn.selected = YES;
                NSLog(@"🔧 强制更新选中cell的按钮状态");
            }
            
            // 同时确保其他cell都是非选中状态
            for (NSInteger i = 0; i < self.voiceListArray.count; i++) {
                if (i != self.selectedVoiceIndex) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    CreateStoryWithVoiceTableViewCell *cell = [self.voiceTabelView cellForRowAtIndexPath:indexPath];
                    if (cell) {
                        cell.selectBtn.selected = NO;
                    }
                }
            }
        });
    } else {
        NSLog(@"   ❌ 未选中任何音色");
    }
    
    NSLog(@"==========================================");
}

/// 调试当前选中状态 - 增强版
- (void)debugCurrentSelectionState {
    NSLog(@"🔍 ========== 当前选中状态详细调试 ==========");
    NSLog(@"   编辑模式: %@", self.isEditMode ? @"是" : @"否");
    NSLog(@"   选中索引: %ld", (long)self.selectedVoiceIndex);
    NSLog(@"   音色数组数量: %ld", (long)self.voiceListArray.count);
    NSLog(@"   原始音色ID: %ld", (long)self.originalVoiceId);
    NSLog(@"   故事音色ID: %ld", (long)(self.currentStory ? self.currentStory.voiceId : -1));
    NSLog(@"   当前音色ID: %ld", (long)[self getCurrentVoiceId]);
    
    if (self.selectedVoiceIndex >= 0 && self.selectedVoiceIndex < self.voiceListArray.count) {
        VoiceModel *selectedVoice = self.voiceListArray[self.selectedVoiceIndex];
        NSLog(@"   选中音色: '%@' (ID: %ld, cloneStatus: %ld)",
              selectedVoice.voiceName ?: @"无名称",
              (long)selectedVoice.voiceId,
              (long)selectedVoice.cloneStatus);
    } else if (self.isEditMode && self.originalVoiceId > 0) {
        NSLog(@"   编辑模式：使用原始音色ID: %ld", (long)self.originalVoiceId);
    } else {
        NSLog(@"   未选中任何音色");
    }
    
    // ✅ 显示完整的音色列表信息
    NSLog(@"   --- 当前音色列表详情 ---");
    for (NSInteger i = 0; i < self.voiceListArray.count; i++) {
        VoiceModel *voice = self.voiceListArray[i];
        NSString *isSelectedMark = (i == self.selectedVoiceIndex) ? @" ✅" : @"";
        NSLog(@"     [%ld] '%@' (ID: %ld, cloneStatus: %ld)%@",
              (long)i,
              voice.voiceName ?: @"无名称",
              (long)voice.voiceId,
              (long)voice.cloneStatus,
              isSelectedMark);
    }
    
    NSLog(@"========================================");
}

- (void)dealloc {
    NSLog(@"🔄 CreateStoryWithVoiceViewController dealloc");
    
    // ✅ 取消所有延迟调用
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(adjustStoryViewHeightOptimized) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateMainScrollViewContentSize) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateMainScrollViewContentSizeWithExtraHeight:) object:nil];
    
    // ✅ 移除通知监听（包括键盘通知和文本变化通知）
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // ✅ 停止音频播放并清理资源
    [self stopAudioPlayback];
    
    // ✅ 清理其他资源
    self.voiceListArray = nil;
    self.currentStory = nil;
    self.mainScrollView = nil;
    self.contentView = nil;
    
    NSLog(@"✅ CreateStoryWithVoiceViewController 资源清理完成");
}



/// 显示自定义加载视图
- (void)showCustomLoadingView {
    // 创建加载视图背景（蒙层效果）
    self.loadingView = [[UIView alloc] init];
    self.loadingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1]; // 黑色半透明蒙层
    [self.view addSubview:self.loadingView];
    
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // 创建加载内容容器（类似SVProgressHUD的圆角容器）
    UIView *loadingContainer = [[UIView alloc] init];
    loadingContainer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8]; // 深色半透明背景
    loadingContainer.layer.cornerRadius = 12;
    loadingContainer.layer.masksToBounds = YES;
    [self.loadingView addSubview:loadingContainer];
    
    [loadingContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.loadingView);
        make.width.height.mas_equalTo(120);
    }];
    
    // 创建活动指示器（白色）
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.color = [UIColor whiteColor]; // 设置为白色
    self.activityIndicator.hidesWhenStopped = YES;
    [loadingContainer addSubview:self.activityIndicator];
    
    [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(loadingContainer);
        make.centerY.equalTo(loadingContainer).offset(-15);
    }];
    
    // 创建加载文字（白色）
    self.loadingLabel = [[UILabel alloc] init];
    self.loadingLabel.text = LocalString(@"加载中...");
    self.loadingLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.loadingLabel.textColor = [UIColor whiteColor]; // 设置为白色
    self.loadingLabel.textAlignment = NSTextAlignmentCenter;
    [loadingContainer addSubview:self.loadingLabel];
    
    [self.loadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.activityIndicator.mas_bottom).offset(12);
        make.centerX.equalTo(loadingContainer);
        make.leading.greaterThanOrEqualTo(loadingContainer).offset(12);
        make.trailing.lessThanOrEqualTo(loadingContainer).offset(-12);
    }];
    
    // 开始动画
    [self.activityIndicator startAnimating];
}

/// 隐藏自定义加载视图
- (void)hideCustomLoadingView {
    if (self.loadingView) {
        [self.activityIndicator stopAnimating];
        // 立即移除，不使用淡出动画
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
        self.activityIndicator = nil;
        self.loadingLabel = nil;
    }
}

/// 更新加载文字
- (void)updateLoadingText:(NSString *)text {
    if (self.loadingLabel) {
        self.loadingLabel.text = text;
    }
}

#pragma mark - Story Status Configuration

/// ✅ 根据故事状态配置视图显示
/// @param storyStatus 故事状态
- (void)configureViewsForStoryStatus:(StoryStatus)storyStatus {
    NSLog(@"🎯 配置视图状态，故事状态: %ld (%@)", (long)storyStatus, [self storyStatusDescription:storyStatus]);
    
    
    
    switch (storyStatus) {
        case StoryStatusGenerated: // 状态为2，故事生成成功
            NSLog(@"✅ 故事生成成功，正常显示");
            [self hideFailedViewWithStoryNameTopConstraint:10.0];
           
            break;
            
        case StoryStatusCompleted: // 状态为5，音频生成成功（完成状态）
            NSLog(@"✅ 故事完成，正常显示");
            [self hideFailedViewWithStoryNameTopConstraint:10.0];
           
            break;
            
        case StoryStatusAudioFailed: // 状态为6，音频生成失败
            NSLog(@"❌ 故事音频生成失败，显示错误视图");
            [self showFailedViewWithStoryNameTopConstraint:52.0];
        
            break;
            
        default:
            // 理论上不应该到达这里，因为前面已经做了状态验证
            NSLog(@"⚠️ 未预期的故事状态: %ld", (long)storyStatus);
            [self hideFailedViewWithStoryNameTopConstraint:10.0];
           
            break;
    }
}

/// ✅ 获取故事状态描述
/// @param storyStatus 故事状态
/// @return 状态描述字符串
- (NSString *)storyStatusDescription:(StoryStatus)storyStatus {
    switch (storyStatus) {
        case StoryStatusPending:
            return LocalString(@"待处理");
        case StoryStatusGenerating:
            return LocalString(@"故事生成中");
        case StoryStatusGenerated:
            return LocalString(@"故事已生成");
        case StoryStatusGenerateFailed:
            return LocalString(@"故事生成失败");
        case StoryStatusAudioGenerating:
            return LocalString(@"音频生成中");
        case StoryStatusCompleted:
            return LocalString(@"已完成");
        case StoryStatusAudioFailed:
            return LocalString(@"音频生成失败");
        default:
            return [NSString stringWithFormat:LocalString(@"未知状态（%ld）"), (long)storyStatus];
    }
}





/// ✅ 显示失败视图并调整约束
/// @param topConstraintValue storyNameTop约束值
- (void)showFailedViewWithStoryNameTopConstraint:(CGFloat)topConstraintValue {
    // 显示失败视图
    self.failedView.hidden = NO;
    
    // 调整storyNameTop约束
    self.storyNameTop.constant = topConstraintValue;
    
    // 添加渐显动画
    self.failedView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.failedView.alpha = 1.0;
        [self.view layoutIfNeeded]; // 让约束变化生效
    } completion:^(BOOL finished) {
        if (finished) {
            // ✅ 显示完成后重新计算滚动视图高度（不需要额外高度，使用统一的100pt底部边距）
            [self scheduleScrollViewContentSizeUpdate];
        }
    }];
    
    NSLog(@"📊 显示失败视图，storyNameTop约束设置为: %.1f", topConstraintValue);
}

/// ✅ 隐藏失败视图并调整约束
/// @param topConstraintValue storyNameTop约束值
- (void)hideFailedViewWithStoryNameTopConstraint:(CGFloat)topConstraintValue {
    // 调整storyNameTop约束
    self.storyNameTop.constant = topConstraintValue;
    
    // 添加渐隐动画
    [UIView animateWithDuration:0.3 animations:^{
        self.failedView.alpha = 0.0;
        [self.view layoutIfNeeded]; // 让约束变化生效
    } completion:^(BOOL finished) {
        if (finished) {
            // 隐藏失败视图
            self.failedView.hidden = YES;
            // ✅ 隐藏完成后重新计算滚动视图高度
            [self scheduleScrollViewContentSizeUpdate];
        }
    }];
    
    NSLog(@"📊 隐藏失败视图，storyNameTop约束设置为: %.1f", topConstraintValue);
}







@end
