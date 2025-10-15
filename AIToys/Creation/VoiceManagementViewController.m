//
//  VoiceManagementViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "VoiceManagementViewController.h"
#import "VoiceManagementTableViewCell.h"
#import "CreateVoiceViewController.h"

@interface VoiceManagementViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIButton *createVoiceBtn;
@property (weak, nonatomic) IBOutlet UITableView *voiceListTabelView;
@property (nonatomic, strong) UIPanGestureRecognizer *customPopGesture; // ✅ 自定义返回手势

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
    self.emptyView.hidden  = YES;
    if (@available(iOS 15.0, *)) {
            self.voiceListTabelView.sectionHeaderTopPadding = 0;
        }
    UINib *VoiceManagementTableViewCell = [UINib nibWithNibName:@"VoiceManagementTableViewCell" bundle:nil];
    [self.voiceListTabelView registerNib:VoiceManagementTableViewCell forCellReuseIdentifier:@"VoiceManagementTableViewCell"];
    if (@available(iOS 26.0, *)) {
        self.navigationController.interactiveContentPopGestureRecognizer.enabled = NO;
    } else {
        // Fallback on earlier versions
    }
    // ✅ 设置自定义返回手势
    [self setupCustomPopGesture];
}

// ✅ 新增：设置自定义返回手势
- (void)setupCustomPopGesture {
    // 禁用系统的返回手势
    if (@available(iOS 26.0, *)) {
        self.navigationController.interactiveContentPopGestureRecognizer.enabled = NO;
    } else {
        // Fallback on earlier versions
    }
    
    // 创建自定义手势
    self.customPopGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCustomPopGesture:)];
    self.customPopGesture.delegate = self;
    [self.view addGestureRecognizer:self.customPopGesture];
}

// ✅ 新增：处理自定义返回手势
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

// ✅ 新增：手势代理方法 - 决定手势是否开始
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
        
        // ✅ 检查是否有 swipe action 正在显示
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

// ✅ 新增：允许自定义手势与 tableView 的手势同时识别
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 自定义返回手势可以和 tableView 的手势同时工作
    if (gestureRecognizer == self.customPopGesture) {
        return YES;
    }
    return NO;
}

// ✅ 离开页面时恢复系统手势
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 移除自定义手势
    if (self.customPopGesture) {
        [self.view removeGestureRecognizer:self.customPopGesture];
        self.customPopGesture = nil;
    }
    
    // 恢复系统手势
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VoiceManagementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoiceManagementTableViewCell" forIndexPath:indexPath];
    
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

#pragma mark - UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self deleteItemAtIndexPath:indexPath];
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    
    // 自定义删除按钮
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                               title:nil
                                                                             handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//        [self deleteItemAtIndexPath:indexPath];
        completionHandler(YES);
    }];
    
    deleteAction.backgroundColor = Hex_A(0xEA0000, 0.1);
    deleteAction.image = [UIImage imageNamed:@"create_delete"];
    
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    configuration.performsFirstActionWithFullSwipe = NO;
    
    return configuration;
}

-(void)createVoiceBtnClick{
    
    CreateVoiceViewController * vc = [[CreateVoiceViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

@end
