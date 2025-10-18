//
//  CreateStoryWithVoiceViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "CreateStoryWithVoiceViewController.h"
#import "CreateStoryWithVoiceTableViewCell.h"
#import "AFStoryAPIManager.h"
#import "CreateVoiceViewController.h"

@interface CreateStoryWithVoiceViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *createImageView;
@property (weak, nonatomic) IBOutlet UILabel *storyStautsLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *chooseVoiceLabel;
@property (weak, nonatomic) IBOutlet UIButton *addNewVoiceBtn;
@property (weak, nonatomic) IBOutlet UITableView *voiceTabelView;
@property (weak, nonatomic) IBOutlet UIButton *saveStoryBtn;
@property (weak, nonatomic) IBOutlet UITextField *stroryThemeTextView;
@property (weak, nonatomic) IBOutlet UIButton *voiceHeaderImageBtn;
@property (weak, nonatomic) IBOutlet UIButton *deletHeaderBtn;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

// 数据源
@property (nonatomic, strong) NSMutableArray *voiceListArray;  // 音色列表数据
@property (nonatomic, strong) VoiceStoryModel *currentStory;   // 当前故事模型
@property (nonatomic, assign) NSInteger selectedVoiceIndex;    // 选中的音色索引

@end

@implementation CreateStoryWithVoiceViewController





- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Create Story";
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0]];
    self.voiceTabelView.delegate = self;
    self.voiceTabelView.dataSource = self;
    self.addNewVoiceBtn.borderWidth = 1;
    self.addNewVoiceBtn.borderColor = HexOf(0x1EAAFD);
    
    // 初始化数据源
    self.voiceListArray = [NSMutableArray array];
    self.selectedVoiceIndex = -1; // 默认未选中
    
    UINib *CreateStoryWithVoiceTableViewCell = [UINib nibWithNibName:@"CreateStoryWithVoiceTableViewCell" bundle:nil];
    [self.voiceTabelView registerNib:CreateStoryWithVoiceTableViewCell forCellReuseIdentifier:@"CreateStoryWithVoiceTableViewCell"];
    
    [self loadData];

}
- (void)setStoryId:(NSInteger)storyId{
    _storyId = storyId;
}
-(void)loadData{
    
    
    
    // 发起网络请求
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager]getStoryDetailWithId:self.storyId success:^(VoiceStoryModel * _Nonnull story) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        // 保存故事模型
        strongSelf.currentStory = story;
        
        // 更新UI
        strongSelf.stroryThemeTextView.text = story.storyName;
        [strongSelf.voiceHeaderImageBtn sd_setImageWithURL:[NSURL URLWithString:story.illustrationUrl] forState:UIControlStateNormal];
        strongSelf.storyTextLabel.text = story.storyContent;
        strongSelf.storyStautsLabel.text = @"The story has been created!";
        } failure:^(NSError * _Nonnull error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            NSLog(@"❌ 获取故事列表失败: %@", error.localizedDescription);
            
            // 显示错误提示
            [strongSelf showErrorAlert:error.localizedDescription];
        }];
    
    
    [[AFStoryAPIManager sharedManager]getVoicesWithStatus:2 success:^(VoiceListResponseModel * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        // 保存音色列表数据
        if (response.list && response.list.count > 0) {
            [strongSelf.voiceListArray removeAllObjects];
            [strongSelf.voiceListArray addObjectsFromArray:response.list];
            self.emptyView.hidden = YES;
            // 刷新TableView
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.voiceTabelView reloadData];
            });
            
            NSLog(@"✅ 成功加载 %ld 个音色", (long)strongSelf.voiceListArray.count);
        } else {
            NSLog(@"⚠️ 音色列表为空");
        }
        
        } failure:^(NSError * _Nonnull error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            NSLog(@"❌ 获取音色列表失败: %@", error.localizedDescription);
            
            // 显示错误提示
            [strongSelf showErrorAlert:error.localizedDescription];
        }];
    
    
    
}

#pragma mark - UITableView DataSource

// ✅ 添加：每个 cell 作为一个独立的 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.voiceListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CreateStoryWithVoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateStoryWithVoiceTableViewCell" forIndexPath:indexPath];
    
    // 获取当前音色数据
    if (indexPath.row < self.voiceListArray.count) {
        id voiceModel = self.voiceListArray[indexPath.row];
        BOOL isSelected = (indexPath.row == self.selectedVoiceIndex);
        
        // 使用配置方法设置cell数据
        [cell configureWithVoiceModel:voiceModel isSelected:isSelected];
        
        // 保存当前索引，方便点击事件使用
        cell.tag = indexPath.row;
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 更新选中状态
    self.selectedVoiceIndex = indexPath.row;
    
    // 刷新tableView显示选中状态
    [tableView reloadData];
    
    NSLog(@"✅ 选中音色索引: %ld", (long)indexPath.row);
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
- (IBAction)addNewVoice:(id)sender {
    
    CreateVoiceViewController * vc = [[CreateVoiceViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)saveStory:(id)sender {
    // 检查是否选择了音色
    if (self.selectedVoiceIndex < 0 || self.selectedVoiceIndex >= self.voiceListArray.count) {
        [self showErrorAlert:@"请先选择一个音色"];
        return;
    }
    
    // 检查故事名称是否为空
    if (!self.stroryThemeTextView.text || self.stroryThemeTextView.text.length == 0) {
        [self showErrorAlert:@"请输入故事名称"];
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
        [self showErrorAlert:@"获取音色ID失败"];
        return;
    }
    
    // 准备请求参数
    NSDictionary *params = @{
        @"storyId": @(self.storyId),
        @"familyId":@([[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue]),
        @"voiceId": @(voiceId),
        @"storyName": self.stroryThemeTextView.text ?: @"",
        @"storyContent": self.currentStory.storyContent ?: @"",
        @"illustrationUrl": self.currentStory.illustrationUrl ?: @""
    };
    
    NSLog(@"📤 开始合成音频，参数: %@", params);
    
    // 显示加载提示
    [SVProgressHUD showWithStatus:@"正在合成音频..."];
    
    // 调用音频合成接口
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] synthesizeStoryAudioWithParams:params
                                                              success:^(id _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [SVProgressHUD dismiss];
        
        NSLog(@"✅ 音频合成成功: %@", response);
        
        // 显示成功提示
        [SVProgressHUD showSuccessWithStatus:@"音频合成成功！"];
        
        // 延迟返回上一页
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf.navigationController popViewControllerAnimated:YES];
        });
        
    } failure:^(NSError * _Nonnull error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [SVProgressHUD dismiss];
        
        NSLog(@"❌ 音频合成失败: %@", error.localizedDescription);
        
        // 显示错误提示
        [strongSelf showErrorAlert:error.localizedDescription ?: @"音频合成失败，请重试"];
    }];
}

@end
