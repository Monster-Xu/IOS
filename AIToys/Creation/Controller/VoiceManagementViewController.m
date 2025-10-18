//
//  VoiceManagementViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//  Updated: 2025/10/16 - 集成骨架屏加载效果
//

#import "VoiceManagementViewController.h"
#import "VoiceManagementTableViewCell.h"
#import "SkeletonTableViewCell.h"
#import "CreateVoiceViewController.h"
#import "AFStoryAPIManager.h"
#import "AudioPlayerView.h"

@interface VoiceManagementViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIButton *createVoiceBtn;
@property (weak, nonatomic) IBOutlet UITableView *voiceListTabelView;
@property (nonatomic, strong) UIPanGestureRecognizer *customPopGesture;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation VoiceManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"音色管理";
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0]];
    self.voiceListTabelView.backgroundColor = [UIColor clearColor];
    self.voiceListTabelView.delegate = self;
    self.voiceListTabelView.dataSource = self;
    [self.createVoiceBtn addTarget:self action:@selector(createVoiceBtnClick) forControlEvents:UIControlEventTouchDown];
    self.emptyView.hidden = YES;
    
    if (@available(iOS 15.0, *)) {
        self.voiceListTabelView.sectionHeaderTopPadding = 0;
    }
    
    // ✅ 注册真实数据Cell
    UINib *VoiceManagementTableViewCell = [UINib nibWithNibName:@"VoiceManagementTableViewCell" bundle:nil];
    [self.voiceListTabelView registerNib:VoiceManagementTableViewCell forCellReuseIdentifier:@"VoiceManagementTableViewCell"];
    
    // ✅ 注册骨架屏Cell
    [self.voiceListTabelView registerClass:[SkeletonTableViewCell class] forCellReuseIdentifier:@"SkeletonTableViewCell"];
    
    if (@available(iOS 26.0, *)) {
        self.navigationController.interactiveContentPopGestureRecognizer.enabled = NO;
    }
    
    // 设置自定义返回手势
    [self setupCustomPopGesture];
    
    // ✅ 初始化数据
    self.voiceList = [NSMutableArray array];
    self.isLoading = NO;
    self.skeletonRowCount = 5;  // 默认显示5行骨架屏
    
    // ✅ 加载声音列表（显示骨架屏）
    [self loadVoiceListWithSkeleton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 每次显示页面时刷新数据
    [self loadVoiceListWithSkeleton];
}

#pragma mark - ✅ 加载数据（带骨架屏效果）

/// 加载声音列表，显示骨架屏加载效果
- (void)loadVoiceListWithSkeleton {
    // 设置加载状态
    self.isLoading = YES;
    self.emptyView.hidden = YES;
    
    // 刷新TableView，显示骨架屏
    [self.voiceListTabelView reloadData];
    
    NSLog(@"[VoiceManagement] 开始加载数据，显示骨架屏...");
    
    // 调用API获取声音列表
    [[AFStoryAPIManager sharedManager] getVoicesWithStatus:0 success:^(VoiceListResponseModel *response) {
        
        NSLog(@"[VoiceManagement] 数据加载成功，共 %ld 个音色", response.list.count);
        
        // 更新数据源
        if (response && response.list.count > 0) {
            self.voiceList = [NSMutableArray arrayWithArray:response.list];
            self.emptyView.hidden = YES;
        } else {
            self.voiceList = [NSMutableArray array];
            self.emptyView.hidden = NO;
        }
        
        // 结束加载状态
        self.isLoading = NO;
        
        // 刷新TableView，显示真实数据
        [self.voiceListTabelView reloadData];
        
        NSLog(@"[VoiceManagement] TableView 已刷新，显示真实数据");
        
    } failure:^(NSError *error) {
        
        NSLog(@"[VoiceManagement] 加载数据失败: %@", error.localizedDescription);
        
        // 结束加载状态
        self.isLoading = NO;
        
        // 显示错误提示
        [self showErrorAlert:@"加载失败" message:error.localizedDescription];
        
        self.emptyView.hidden = NO;
        
        // 刷新TableView
        [self.voiceListTabelView reloadData];
    }];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // ✅ 加载中时显示骨架屏行数，加载完成时显示真实数据行数
    if (self.isLoading) {
        return self.skeletonRowCount;
    }
    return MAX(1, self.voiceList.count);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // ✅ 加载中时返回骨架屏Cell
    if (self.isLoading) {
        SkeletonTableViewCell *skeletonCell = [tableView dequeueReusableCellWithIdentifier:@"SkeletonTableViewCell" forIndexPath:indexPath];
        
        // 配置骨架屏样式（带头像样式）
        [skeletonCell configureWithStyle:SkeletonCellStyleWithAvatar];
        
        // 开始骨架屏动画
        [skeletonCell startSkeletonAnimation];
        
        return skeletonCell;
    }
    
    // ✅ 数据加载完成后返回真实数据Cell
    VoiceManagementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoiceManagementTableViewCell" forIndexPath:indexPath];
    
    // 绑定数据
    if (indexPath.section < self.voiceList.count) {
        VoiceModel *voice = self.voiceList[indexPath.section];
        [cell configureWithVoiceModel:voice];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 76;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 10 : 5;
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

#pragma mark - UITableViewDelegate - 左滑删除

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // ✅ 加载中不允许删除
    if (self.isLoading) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteVoiceAtIndexPath:indexPath];
    }
}

/// 处理左滑删除操作
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    
    // ✅ 加载中不显示删除操作
    if (self.isLoading) {
        return nil;
    }
    
    // 自定义删除按钮
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                               title:nil
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self deleteVoiceAtIndexPath:indexPath];
        completionHandler(YES);
    }];
    
    deleteAction.backgroundColor = [UIColor colorWithRed:0xEA/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:0.1];
    deleteAction.image = [UIImage imageNamed:@"create_delete"];
    
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    configuration.performsFirstActionWithFullSwipe = NO;
    
    return configuration;
}

#pragma mark - 删除声音

/// 删除指定位置的声音
- (void)deleteVoiceAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.voiceList.count) {
        return;
    }
    
    VoiceModel *voice = self.voiceList[indexPath.section];
    
    // 检查是否可以删除
    if (!voice.canDelete) {
        [self showErrorAlert:@"删除失败" message:@"该音色已关联故事，无法删除"];
        return;
    }
    
    // 确认删除
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除音色"
                                                                             message:[NSString stringWithFormat:@"确定要删除音色 \"%@\" 吗？", voice.voiceName]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // 取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
        // 关闭左滑菜单
        [self.voiceListTabelView setEditing:NO animated:YES];
    }];
    
    // 删除按钮
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
        // 调用删除API
        [self performDeleteVoiceWithId:voice.voiceId atIndexPath:indexPath];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/// 执行API删除操作
- (void)performDeleteVoiceWithId:(NSInteger)voiceId atIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"[VoiceManagement] 删除音色 ID: %ld", (long)voiceId);
    
    [[AFStoryAPIManager sharedManager] deleteVoiceWithId:voiceId success:^(APIResponseModel *response) {
        
        NSLog(@"[VoiceManagement] 删除成功");
        
        // 从本地列表删除
        if (indexPath.section < self.voiceList.count) {
            [self.voiceList removeObjectAtIndex:indexPath.section];
        }
        
        // 刷新表格
        [self.voiceListTabelView beginUpdates];
        [self.voiceListTabelView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                              withRowAnimation:UITableViewRowAnimationFade];
        [self.voiceListTabelView endUpdates];
        
        // 如果没有数据了，显示空状态
        if (self.voiceList.count == 0) {
            self.emptyView.hidden = NO;
        }
        
        // 显示成功提示
        [self showSuccessAlert:@"删除成功"];
        
    } failure:^(NSError *error) {
        
        NSLog(@"[VoiceManagement] 删除失败: %@", error.localizedDescription);
        
        // 显示错误提示
        [self showErrorAlert:@"删除失败" message:error.localizedDescription];
    }];
}

#pragma mark - 自定义返回手势

- (void)setupCustomPopGesture {
    // 禁用系统的返回手势
    if (@available(iOS 26.0, *)) {
        self.navigationController.interactiveContentPopGestureRecognizer.enabled = NO;
    }
    
    // 创建自定义手势
    self.customPopGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCustomPopGesture:)];
    self.customPopGesture.delegate = self;
    [self.view addGestureRecognizer:self.customPopGesture];
}

- (void)handleCustomPopGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    CGPoint velocity = [gesture velocityInView:self.view];
    
    // 只处理从左向右的滑动
    if (translation.x > 0 && velocity.x > 0) {
        if (gesture.state == UIGestureRecognizerStateEnded) {
            // 滑动距离超过一定阈值才触发返回
            if (translation.x > 100 || velocity.x > 500) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.customPopGesture) {
        // 只在屏幕左边缘触发
        CGPoint location = [gestureRecognizer locationInView:self.view];
        if (location.x > 50) {
            return NO;
        }
        
        // 检查是否有 cell 正在编辑
        if (self.voiceListTabelView.isEditing) {
            return NO;
        }
        
        // 检查是否有 swipe action 正在显示
        for (UITableViewCell *cell in self.voiceListTabelView.visibleCells) {
            for (UIView *subview in cell.subviews) {
                if ([NSStringFromClass([subview class]) containsString:@"Swipe"]) {
                    return NO;
                }
            }
        }
        
        // 确保是从左向右滑动
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
            CGPoint velocity = [pan velocityInView:self.view];
            return velocity.x > 0 && fabs(velocity.x) > fabs(velocity.y);
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 自定义返回手势可以和 tableView 的手势同时工作
    if (gestureRecognizer == self.customPopGesture) {
        return YES;
    }
    return NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 移除自定义手势
    if (self.customPopGesture) {
        [self.view removeGestureRecognizer:self.customPopGesture];
        self.customPopGesture = nil;
    }
    
    // 恢复系统手势
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    // ✅ 停止所有骨架屏动画
    for (SkeletonTableViewCell *cell in self.voiceListTabelView.visibleCells) {
        if ([cell isKindOfClass:[SkeletonTableViewCell class]]) {
            [cell stopSkeletonAnimation];
        }
    }
}

#pragma mark - 按钮事件

-(void)createVoiceBtnClick{
    CreateVoiceViewController *vc = [[CreateVoiceViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 提示框

/// 显示成功提示
- (void)showSuccessAlert:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"成功"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/// 显示错误提示
- (void)showErrorAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
