//
//  CreateVoiceViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/14.
//

#import "CreateVoiceViewController.h"
#import <Photos/Photos.h>
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>
#import "SelectIllustrationVC.h"
#import "AFStoryAPIManager.h"
#import "LGBaseAlertView.h"
#import "SVProgressHUD.h"
#import "ATLanguageHelper.h"

// ✅ VoiceModel便利方法扩展
@interface VoiceModel (VoiceManagementExtensions)
- (BOOL)canEdit;
- (BOOL)canPlay;
- (NSString *)statusDisplayText;
- (UIColor *)statusDisplayColor;
@end

@implementation VoiceModel (VoiceManagementExtensions)

- (BOOL)canEdit {
    // 克隆中状态不可编辑，其他状态都可以编辑
    return self.cloneStatus != VoiceCloneStatusCloning;
}

- (BOOL)canPlay {
    // 只有克隆成功且有示例音频的才能播放
    return (self.cloneStatus == VoiceCloneStatusSuccess && 
            self.sampleAudioUrl && 
            self.sampleAudioUrl.length > 0);
}

- (NSString *)statusDisplayText {
    switch (self.cloneStatus) {
        case VoiceCloneStatusPending:
            return LocalString(@"待克隆");
        case VoiceCloneStatusCloning:
            return LocalString(@"克隆中");
        case VoiceCloneStatusSuccess:
            return LocalString(@"已完成");
        case VoiceCloneStatusFailed:
            return LocalString(@"克隆失败");
        default:
            return LocalString(@"未知状态");
    }
}

- (UIColor *)statusDisplayColor {
    switch (self.cloneStatus) {
        case VoiceCloneStatusPending:
            return [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0];
        case VoiceCloneStatusCloning:
            return [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0];
        case VoiceCloneStatusSuccess:
            return [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0];
        case VoiceCloneStatusFailed:
            return [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
        default:
            return [UIColor grayColor];
    }
}

@end

@interface CreateVoiceViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *chooseImageBtn;
@property (weak, nonatomic) IBOutlet UIButton *speekBtn;
@property (weak, nonatomic) IBOutlet UILabel *voiceTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *speekLabel;
@property (weak, nonatomic) IBOutlet UIImageView *voiceGifImageView;
@property (weak, nonatomic) IBOutlet UIButton *deletPickImageBtn;
@property (weak, nonatomic) IBOutlet UITextField *voiceNameTextView;
@property (weak, nonatomic) IBOutlet UILabel *voiceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *voiceAvatarLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceTextTopConstraint;

// 语音识别相关
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) AVAudioEngine *audioEngine;

// 录音相关
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSURL *audioFileURL;

// 录音计时
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, assign) NSInteger remainingTime;
@property (nonatomic, assign) NSInteger recordedTime;
@property (nonatomic, assign) BOOL isRecording;

// Label高度约束和placeholder
@property (nonatomic, strong) NSLayoutConstraint *voiceTextLabelHeightConstraint;
@property (nonatomic, strong) UILabel *placeholderLabel;

// ⭐ 声音参数相关
@property (nonatomic, copy) NSString *voiceName;           // 声音名称
@property (nonatomic, copy) NSString *selectedAvatarUrl;   // 选中的插画URL
@property (nonatomic, copy) NSString *uploadedAudioFileUrl; // 上传后的音频文件URL
@property (nonatomic, assign) NSInteger uploadedFileId;      // 上传后的文件ID

// UI 状态
@property (nonatomic, assign) BOOL isUploading;
@property (nonatomic, assign) BOOL isCloningVoice;

// 编辑状态追踪
@property (nonatomic, assign) BOOL hasUnsavedChanges;

// ✅ 变更追踪 - 记录原始值用于比较
@property (nonatomic, copy) NSString *originalVoiceName;
@property (nonatomic, copy) NSString *originalAvatarUrl;
@property (nonatomic, copy) NSString *originalSampleText;
@property (nonatomic, copy) NSString *originalSampleAudioUrl;

// ✅ 故事相关的变更追踪（如果页面涉及故事编辑）
@property (nonatomic, assign) NSInteger relatedStoryId;
@property (nonatomic, copy) NSString *originalStoryName;
@property (nonatomic, copy) NSString *originalStoryContent;
@property (nonatomic, copy) NSString *originalIllustrationUrl;

// ✅ 声音数据加载状态
@property (nonatomic, assign) BOOL isLoadingVoiceData;
@property (nonatomic, strong) VoiceModel *currentVoiceData;  // 从API加载的最新数据

// 录音进度条
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;

// ✅ 保存最终识别文本，用于录音结束后回显
@property (nonatomic, copy) NSString *finalRecognizedText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *faildViewConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIView *faildView;
@property (weak, nonatomic) IBOutlet UILabel *faildMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *voiceSubLabel;
@property (weak, nonatomic) IBOutlet UIImageView *voiceImage;
@property (weak, nonatomic) IBOutlet UILabel *voiceTitleLabel;

@end

@implementation CreateVoiceViewController

- (NSString *)defaultVoiceSampleText {
    return LocalString(@"露娜在雨中捡到一只小狗，躲在长椅下发抖。她把它带回家，但妈妈说不能养宠物。露娜很难过，贴了“招领”海报。第二天，一位老太太来敲门——原来是小狗的主人！她很感激，送给露娜一份手写曲奇配方。从此露娜每周都会去看望她，小狗每次见到她都摇尾巴。");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // ✅ 如果是编辑模式，从API加载最新的声音数据
    if (self.isEditMode && self.editingVoice) {
        [self loadVoiceDataFromAPI];
    } else {
        self.faildView.hidden = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL isRTL = [ATLanguageHelper isRTLLanguage];
    NSTextAlignment inputAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.view.semanticContentAttribute = isRTL ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
    
    // 根据模式设置标题
    if (self.isEditMode && self.editingVoice) {
        self.title = LocalString(@"编辑音色");
        self.voiceTextTopConstraint.constant = -50;
        self.voiceSubLabel.hidden = YES;
        self.voiceTitleLabel.hidden  = YES;
        self.voiceImage.hidden  = YES;
    } else {
        self.title = LocalString(@"创建音色");
        self.voiceTextTopConstraint.constant = 10;
        self.voiceSubLabel.hidden = NO;
        self.voiceTitleLabel.hidden  = NO;
        self.voiceImage.hidden  = NO;
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    // 创建基础字符串
    NSString *fullText = LocalString(@"请按住“开始朗读”并清晰、富有感情且大声地朗读以下内容，录音需超过30秒。");

    // 创建可变的富文本
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText];

    // 找到需要标红加粗的文本范围
    NSString *highlightedText = LocalString(@"清晰、富有感情且大声");
    NSRange highlightRange = [fullText rangeOfString:highlightedText];

    if (highlightRange.location != NSNotFound) {
        // 设置加粗
        UIFont *boldFont = [UIFont boldSystemFontOfSize:self.voiceSubLabel.font.pointSize];
        [attributedText addAttribute:NSFontAttributeName value:boldFont range:highlightRange];
        
        // 设置红色
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:highlightRange];
    }

    // 应用到UILabel
    self.voiceSubLabel.attributedText = attributedText;
    
    self.voiceNameLabel.text = LocalString(@"音色名称");
    self.voiceAvatarLabel.text = LocalString(@"音色头像");
    self.voiceTitleLabel.text = LocalString(@"声音复刻");
    self.speekLabel.text = LocalString(@"按住开始录音");
    self.faildMessageLabel.text = LocalString(@"声音克隆失败，请重新开始录音");
    self.voiceNameTextView.placeholder = LocalString(@"请输入音色名称");
    self.voiceNameTextView.textAlignment = inputAlignment;
    
    // 初始时隐藏删除按钮
    self.deletPickImageBtn.hidden = YES;
    [self.deletPickImageBtn addTarget:self action:@selector(deletPickImage) forControlEvents:UIControlEventTouchUpInside];
    
    // 初始化状态
    self.isUploading = NO;
    self.isCloningVoice = NO;
    self.hasUnsavedChanges = NO;
    
    [self setupNavigationBar];
    [self setupButtons];
    [self setupSpeechRecognizer];
    [self setupVoiceTextLabel];
    [self setupTextFieldObservers];
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 在布局完成后重新计算初始高度，确保宽度计算正确
    if (self.voiceTextLabel.frame.size.width > 0 && self.voiceTextLabel.text.length == 0) {
        NSString *placeholderText = [self defaultVoiceSampleText];
        CGFloat correctHeight = [self calculateTextHeight:placeholderText];
        
        if (abs(self.voiceTextLabelHeightConstraint.constant - correctHeight) > 1.0) {
            self.voiceTextLabelHeightConstraint.constant = correctHeight;
        }
    }
    
    // ✅ 如果是成功状态的编辑模式，重新设置录音按钮的圆角
    if (self.isEditMode && self.editingVoice && self.editingVoice.cloneStatus == VoiceCloneStatusSuccess) {
        // 确保在布局完成后设置正确的圆角半径
        if (self.speekBtn.layer.cornerRadius != CGRectGetWidth(self.speekBtn.frame) / 2.0) {
            self.speekBtn.layer.cornerRadius = CGRectGetWidth(self.speekBtn.frame) / 2.0;
        }
    }
    
    // ✅ 录音按钮布局完成后，创建进度条（只在需要时创建）
    if (self.speekBtn && CGRectGetWidth(self.speekBtn.bounds) > 0) {
        // 只有当进度条不存在且按钮有实际尺寸时才创建
        if (!self.progressLayer || !self.backgroundLayer) {
            [self createProgressLayers];
        }
    }
}

#pragma mark - Setup Methods

- (void)setupNavigationBar {
    // 设置导航栏透明
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithTransparentBackground];
        appearance.backgroundColor = [UIColor clearColor];
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
    }
    
    // 创建保存按钮
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setTitle:LocalString(@"保存") forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [saveBtn addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    // 添加自定义返回按钮处理
    [self setupCustomBackButton];
}

- (void)setupButtons {
    // 设置图片选择按钮
    [self.chooseImageBtn addTarget:self action:@selector(chooseImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.chooseImageBtn.clipsToBounds = YES;
    self.chooseImageBtn.contentMode = UIViewContentModeScaleAspectFill;
    
    // ✅ 只设置长按手势，不再设置点击手势
    // 设置录音按钮(长按手势) - 按住录音，松手停止
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.1;  // 很短的时间就开始录音
    [self.speekBtn addGestureRecognizer:longPress];
    
    // 设置录音按钮进度条
    [self setupRecordingProgressLayer];
}

#pragma mark - ✅ 成功状态UI设置

/// 设置成功状态的UI - 不允许重新录音
- (void)setupSuccessStateUI {
    // 1. 禁用录音按钮的手势识别
    for (UIGestureRecognizer *gesture in self.speekBtn.gestureRecognizers) {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            gesture.enabled = NO;
        }
    }
    
    // 2. 隐藏原有的录音按钮和标签
    self.speekBtn.hidden = YES;
    self.speekLabel.hidden = YES;
    
    // 3. 创建新的完成状态UI
    [self createCompletedStateUI];
}

/// 创建完成状态的UI布局 - 居中显示
- (void)createCompletedStateUI {
    // 移除之前可能创建的完成状态视图
    for (UIView *subview in self.view.subviews) {
        if (subview.tag == 1000) { // 完成状态视图的标识
            [subview removeFromSuperview];
        }
    }
    
    // 创建容器视图来包含对勾和文字，便于整体居中
    UIView *completedContainer = [[UIView alloc] init];
    completedContainer.backgroundColor = [UIColor clearColor];
    completedContainer.translatesAutoresizingMaskIntoConstraints = NO;
    completedContainer.tag = 1000; // 标记方便清理
    [self.view addSubview:completedContainer];
    
    // 创建完成图标（对勾）
    UIImageView *checkmarkImageView = [[UIImageView alloc] init];
    checkmarkImageView.image = [UIImage imageNamed:@"完成"]; // 使用您指定的完成图片
    if (!checkmarkImageView.image) {
        // 如果找不到图片，使用系统对勾图标作为后备
        checkmarkImageView.image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
        checkmarkImageView.tintColor = [UIColor systemGreenColor];
    }
    checkmarkImageView.contentMode = UIViewContentModeScaleAspectFit;
    checkmarkImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [completedContainer addSubview:checkmarkImageView];
    
    // 创建完成文字标签
    UILabel *completedLabel = [[UILabel alloc] init];
    completedLabel.text = LocalString(@"音色复刻完成");
    completedLabel.textColor = [UIColor systemBlueColor];
    completedLabel.font = [UIFont systemFontOfSize:16];
    completedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [completedContainer addSubview:completedLabel];
    
    // 设置容器内部布局 - 对勾在左，文字在右，水平居中对齐
    [NSLayoutConstraint activateConstraints:@[
        // 对勾图标约束 - 在容器左侧
        [checkmarkImageView.leadingAnchor constraintEqualToAnchor:completedContainer.leadingAnchor],
        [checkmarkImageView.centerYAnchor constraintEqualToAnchor:completedContainer.centerYAnchor],
        [checkmarkImageView.widthAnchor constraintEqualToConstant:24],
        [checkmarkImageView.heightAnchor constraintEqualToConstant:24],
        
        // 完成文字标签约束 - 在对勾右侧10像素
        [completedLabel.leadingAnchor constraintEqualToAnchor:checkmarkImageView.trailingAnchor constant:10],
        [completedLabel.centerYAnchor constraintEqualToAnchor:completedContainer.centerYAnchor],
        [completedLabel.trailingAnchor constraintEqualToAnchor:completedContainer.trailingAnchor],
        
        // 容器高度由内容决定
        [completedContainer.topAnchor constraintEqualToAnchor:checkmarkImageView.topAnchor],
        [completedContainer.bottomAnchor constraintEqualToAnchor:checkmarkImageView.bottomAnchor]
    ]];
    
    // 设置容器在屏幕中的位置 - 水平和垂直都居中
    [NSLayoutConstraint activateConstraints:@[
        // 容器水平居中
        [completedContainer.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        
        // 容器垂直居中于语音文字框和屏幕底部之间
        [completedContainer.topAnchor constraintEqualToAnchor:self.voiceTextLabel.bottomAnchor constant:30],
        [completedContainer.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-30]
    ]];
}



#pragma mark - ✅ 编辑模式数据加载和填充

/// ✅ 从API加载声音数据
- (void)loadVoiceDataFromAPI {
    if (!self.editingVoice || self.editingVoice.voiceId <= 0) {
        NSLog(@"⚠️ 编辑模式但声音ID无效");
        [self showAlert:LocalString(@"音色ID无效")];
        return;
    }
    
    if (self.isLoadingVoiceData) {
        NSLog(@"⚠️ 声音数据正在加载中，跳过重复请求");
        return;
    }
    
    NSLog(@"📡 开始从API加载声音数据，voiceId: %ld", (long)self.editingVoice.voiceId);
    
    self.isLoadingVoiceData = YES;
    [SVProgressHUD showWithStatus:LocalString(@"正在加载音色数据...")];
    
    __weak typeof(self) weakSelf = self;
    [[AFStoryAPIManager sharedManager] getVoiceDetailWithId:self.editingVoice.voiceId
                                                    success:^(VoiceModel *voice) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"✅ 声音数据加载成功");
        NSLog(@"   声音ID: %ld", (long)voice.voiceId);
        NSLog(@"   声音名称: %@", voice.voiceName);
        NSLog(@"   克隆状态: %ld", (long)voice.cloneStatus);
        NSLog(@"   头像URL: %@", voice.avatarUrl);
        NSLog(@"   示例文本: %@", voice.sampleText);
        NSLog(@"   示例音频: %@", voice.sampleAudioUrl);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.isLoadingVoiceData = NO;
            [SVProgressHUD dismiss];
            
            // 保存最新的声音数据
            strongSelf.currentVoiceData = voice;
            
            // 使用API返回的最新数据填充UI
            [strongSelf populateEditingDataWithVoice:voice];
        });
        
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSLog(@"❌ 声音数据加载失败: %@", error.localizedDescription);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.isLoadingVoiceData = NO;
            [SVProgressHUD dismiss];
            
            // 加载失败时的处理
//            [strongSelf handleVoiceDataLoadFailure:error];
        });
    }];
}

/// ✅ 处理声音数据加载失败
- (void)handleVoiceDataLoadFailure:(NSError *)error {
    NSString *errorMessage;
    
    if (error.code == -1009) {
        errorMessage = LocalString(@"网络连接失败，请检查网络后重试");
    } else if (error.code == 404) {
        errorMessage = LocalString(@"音色不存在，可能已被删除");
    } else if (error.code == 401) {
        errorMessage = LocalString(@"认证失败，请重新登录");
    } else {
        errorMessage = [NSString stringWithFormat:LocalString(@"加载音色数据失败：%@"), error.localizedDescription];
    }
    
    [LGBaseAlertView showAlertWithTitle:LocalString(@"加载失败")
                                content:errorMessage
                           cancelBtnStr:LocalString(@"返回")
                          confirmBtnStr:LocalString(@"重试")
                           confirmBlock:^(BOOL isValue, id obj) {
        if (isValue) {
            // 用户选择重试
            [self loadVoiceDataFromAPI];
        } else {
            // 用户选择返回
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

/// 填充编辑模式的数据（使用API返回的数据）
- (void)populateEditingDataWithVoice:(VoiceModel *)voice {
    if (!voice) {
        NSLog(@"⚠️ 声音数据为空，无法填充UI");
        return;
    }
    
    NSLog(@"🔄 开始填充编辑模式数据");
    
    // 根据克隆状态设置失败视图显示/隐藏
    if (voice.cloneStatus == VoiceCloneStatusFailed) {
        self.topConstraint.constant = 52;
        self.faildView.hidden = NO;
    } else {
        self.faildView.hidden = YES;
    }
    
    // ✅ 首先保存原始数据用于变更比较
    [self recordOriginalValues:voice];
    
    // 1. 填充音色名称
    if (voice.voiceName && voice.voiceName.length > 0) {
        self.voiceNameTextView.text = voice.voiceName;
        self.voiceName = voice.voiceName;
        NSLog(@"   ✏️ 填充音色名称: %@", voice.voiceName);
    }
    
    // 2. 填充头像图片
    if (voice.avatarUrl && voice.avatarUrl.length > 0) {
        self.selectedAvatarUrl = voice.avatarUrl;
        [self.chooseImageBtn sd_setImageWithURL:[NSURL URLWithString:voice.avatarUrl] forState:UIControlStateNormal];
        self.deletPickImageBtn.hidden = NO;
        NSLog(@"   🖼️ 填充头像图片: %@", voice.avatarUrl);
    }
    
    // 3. 处理音频数据
    [self handleEditingVoiceAudio:voice];
    
    // 4. 根据状态调整UI
    [self adjustUIForEditingVoiceStatus:voice];
    
    // 5. 标记无未保存的更改（因为是刚加载的数据）
    self.hasUnsavedChanges = NO;
    
    NSLog(@"✅ 编辑模式数据填充完成");
}

#pragma mark - ✅ 编辑模式数据填充（原有方法保持兼容）

/// 填充编辑模式的数据
- (void)populateEditingData {
    NSLog(@"⚠️ 使用旧版本 populateEditingData 方法，建议使用 API 加载");
    
    if (!self.editingVoice) {
        return;
    }
    
    // 使用传入的 VoiceModel 填充数据（兼容旧版本调用）
    [self populateEditingDataWithVoice:self.editingVoice];
}


/// ✅ 记录原始值用于变更比较
- (void)recordOriginalValues:(VoiceModel *)voice {
    if (!voice) {
        NSLog(@"⚠️ 声音数据为空，无法记录原始值");
        
        // 设置默认值避免空指针异常
        self.originalVoiceName = @"";
        self.originalAvatarUrl = @"";
        self.originalSampleText = @"";
        self.originalSampleAudioUrl = @"";
        return;
    }
    
    // 记录音色相关原始值
    self.originalVoiceName = voice.voiceName ?: @"";
    self.originalAvatarUrl = voice.avatarUrl ?: @"";
    self.originalSampleText = voice.sampleText ?: @"";
    self.originalSampleAudioUrl = voice.sampleAudioUrl ?: @"";
    
    NSLog(@"📋 已记录原始值:");
    NSLog(@"   原始音色名称: %@", self.originalVoiceName);
    NSLog(@"   原始头像URL: %@", self.originalAvatarUrl);
    NSLog(@"   原始示例文本: %@", self.originalSampleText);
    NSLog(@"   原始音频URL: %@", self.originalSampleAudioUrl);
}

/// 处理编辑音色的音频数据
- (void)handleEditingVoiceAudio:(VoiceModel *)voice {
    // 对于编辑模式，需要根据音色状态来处理音频
    switch (voice.cloneStatus) {
        case VoiceCloneStatusSuccess:
            // 克隆成功的音色，显示示例文本和音频信息
            [self handleSuccessVoiceAudio:voice];
            break;
            
        case VoiceCloneStatusFailed:
        case VoiceCloneStatusPending:
            // 失败或待处理的音色，需要重新录音
            [self handleFailedOrPendingVoiceAudio:voice];
            break;
            
        case VoiceCloneStatusCloning:
            // 克隆中不应该进入编辑模式
            NSLog(@"⚠️ 克隆中的音色不应该进入编辑模式");
            [self handleFailedOrPendingVoiceAudio:voice];
            break;
            
        default:
            [self handleFailedOrPendingVoiceAudio:voice];
            break;
    }
}

/// 处理克隆成功音色的音频数据
- (void)handleSuccessVoiceAudio:(VoiceModel *)voice {
    // 显示示例文本 - 使用 placeholder 样式显示数据
    if (voice.sampleText && voice.sampleText.length > 0) {
        [self displayTextWithPlaceholderStyle:voice.sampleText];
    }
    
    // 标记已有音频（假设克隆成功表示有音频文件）
    if (voice.sampleAudioUrl && voice.sampleAudioUrl.length > 0) {
        // 注意：这里不直接设置audioFileURL，因为那是本地录音文件
        // 对于已克隆成功的音色，我们假设有远程音频URL
        self.uploadedAudioFileUrl = voice.sampleAudioUrl;
        self.speekLabel.text = LocalString(@"已有录音，可重新录制");
    }
}

/// 处理失败或待处理音色的音频数据
- (void)handleFailedOrPendingVoiceAudio:(VoiceModel *)voice {
    // 失败或待处理状态，用户需要重新录音
    self.speekLabel.text = LocalString(@"按住开始录音");
    
    // 如果有示例文本，也使用 placeholder 样式显示
    if (voice.sampleText && voice.sampleText.length > 0) {
        [self displayTextWithPlaceholderStyle:voice.sampleText];
    }
}

/// 根据音色状态调整UI
- (void)adjustUIForEditingVoiceStatus:(VoiceModel *)voice {
    if (!voice) {
        NSLog(@"⚠️ 声音数据为空，无法调整UI状态");
        return;
    }
    
    NSLog(@"🔧 根据音色状态调整UI，状态: %ld", (long)voice.cloneStatus);
    
    switch (voice.cloneStatus) {
        case VoiceCloneStatusSuccess:
            // 成功状态：不允许重新录音，显示完成状态
            NSLog(@"   🟢 成功状态，设置成功状态UI");
            [self setupSuccessStateUI];
            break;
            
        case VoiceCloneStatusFailed:
            NSLog(@"   🔴 失败状态，允许重新录音");
            break;
            
        case VoiceCloneStatusPending:
            NSLog(@"   🟡 待处理状态，允许重新录音");
            break;
            
        case VoiceCloneStatusCloning:
            NSLog(@"   🔵 克隆中状态，不应该进入编辑模式");
            break;
            
        default:
            NSLog(@"   ⚪ 未知状态: %ld，默认允许录音", (long)voice.cloneStatus);
            break;
    }
}

- (void)setupVoiceTextLabel {
    // 设置label的基本属性
    self.voiceTextLabel.numberOfLines = 0;
    self.voiceTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.voiceTextLabel.textAlignment = NSTextAlignmentNatural;
    self.voiceTextLabel.backgroundColor = [UIColor whiteColor];
    
    // 添加内边距效果(通过给label的layer设置)
    self.voiceTextLabel.layer.borderWidth = 1;
    self.voiceTextLabel.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.voiceTextLabel.layer.cornerRadius = 12;
    self.voiceTextLabel.clipsToBounds = YES;
    
    // 查找并移除现有的高度约束，添加新的高度约束
    for (NSLayoutConstraint *constraint in self.voiceTextLabel.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight && constraint.relation == NSLayoutRelationEqual) {
            [self.voiceTextLabel removeConstraint:constraint];
        }
    }
    
    // 计算placeholder文字的实际高度作为初始高度
    NSString *placeholderText = [self defaultVoiceSampleText];
    CGFloat initialHeight = [self calculateTextHeight:placeholderText];
    
    // 创建高度约束，使用计算出的初始高度
    self.voiceTextLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.voiceTextLabel
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:initialHeight];
    [self.voiceTextLabel addConstraint:self.voiceTextLabelHeightConstraint];
    
    // 创建placeholder label
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.text = [self defaultVoiceSampleText];
    self.placeholderLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    self.placeholderLabel.font = self.voiceTextLabel.font;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.voiceTextLabel addSubview:self.placeholderLabel];
    
    // 设置placeholder的约束
    [NSLayoutConstraint activateConstraints:@[
        [self.placeholderLabel.leadingAnchor constraintEqualToAnchor:self.voiceTextLabel.leadingAnchor constant:12],
        [self.placeholderLabel.trailingAnchor constraintEqualToAnchor:self.voiceTextLabel.trailingAnchor constant:-12],
        [self.placeholderLabel.topAnchor constraintEqualToAnchor:self.voiceTextLabel.topAnchor constant:12],
        [self.placeholderLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.voiceTextLabel.bottomAnchor constant:-12]
    ]];
    
    // 初始显示placeholder
    self.placeholderLabel.hidden = NO;
}

- (void)setupSpeechRecognizer {
    // 初始化语音识别器(中文)
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    self.audioEngine = [[AVAudioEngine alloc] init];
    
    // 请求语音识别权限
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case SFSpeechRecognizerAuthorizationStatusAuthorized:
                    NSLog(@"语音识别授权成功");
                    break;
                case SFSpeechRecognizerAuthorizationStatusDenied:
                    NSLog(@"语音识别授权被拒绝");
                    break;
                case SFSpeechRecognizerAuthorizationStatusRestricted:
                    NSLog(@"语音识别授权受限");
                    break;
                case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                    NSLog(@"语音识别授权未确定");
                    break;
            }
        });
    }];
}

- (void)setupCustomBackButton {
    // 隐藏默认的返回按钮
    self.navigationItem.hidesBackButton = YES;
    
    // 创建自定义返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:QD_IMG(@"icon_back") forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor blackColor]];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置按钮大小
    backButton.frame = CGRectMake(0, 0, 30, 30);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)setupTextFieldObservers {
    // 监听文本框变化
    [self.voiceNameTextView addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setupRecordingProgressLayer {
    // ✅ 不在这里立即创建进度条，而是等待布局完成
    // 进度条的创建现在在 viewDidLayoutSubviews 中进行
    NSLog(@"📋 录音进度条设置已准备，将在布局完成后创建");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // ✅ 确保在视图完全显示后进度条已正确创建
    if (!self.progressLayer && self.speekBtn && CGRectGetWidth(self.speekBtn.bounds) > 0) {
        [self createProgressLayers];
        NSLog(@"📐 在 viewDidAppear 中创建进度条");
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 页面即将消失时，停止录音
    if (self.isRecording) {
        NSLog(@"⚠️ 页面切换，强制停止录音");
        [self resetRecordingState];
        
        // 停止录音器
        @try {
            if (self.audioRecorder && self.audioRecorder.isRecording) {
                [self.audioRecorder stop];
            }
        } @catch (NSException *exception) {
            NSLog(@"⚠️ 页面切换时停止录音器异常: %@", exception.reason);
        }
        
        // 停止计时器
        if (self.recordTimer) {
            [self.recordTimer invalidate];
            self.recordTimer = nil;
        }
    }
}

- (void)createProgressLayers {
    NSLog(@"📐 createProgressLayers 被调用");
    
    if (!self.speekBtn) {
        NSLog(@"⚠️ 录音按钮不存在，无法创建进度条");
        return;
    }
    
    // ✅ 检查是否已经有进度层，避免重复创建
    if (self.progressLayer && self.backgroundLayer) {
        NSLog(@"ℹ️ 进度条已存在，跳过重复创建");
        return;
    }
    
    // 清理之前可能存在的进度层
    [self removeExistingProgressLayers];
    
    // 确保按钮已经完成布局，获取实际的frame尺寸
    [self.speekBtn layoutIfNeeded];
    
    // ✅ 获取录音按钮的实际尺寸和中心点
    CGRect buttonFrame = self.speekBtn.bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(buttonFrame), CGRectGetMidY(buttonFrame));
    
    // ✅ 动态计算半径，适应不同的按钮尺寸
    CGFloat buttonRadius = MIN(CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame)) / 2.0;
    CGFloat progressRadius = buttonRadius + 8; // 进度条比按钮大8像素
    
    NSLog(@"📐 录音按钮尺寸信息:");
    NSLog(@"   按钮Frame: %@", NSStringFromCGRect(buttonFrame));
    NSLog(@"   中心点: %@", NSStringFromCGPoint(center));
    NSLog(@"   按钮半径: %.1f", buttonRadius);
    NSLog(@"   进度条半径: %.1f", progressRadius);
    
    // ✅ 验证按钮尺寸是否合理
    if (buttonRadius < 5.0) {
        NSLog(@"⚠️ 按钮尺寸过小，延迟创建进度条");
        return;
    }
    
    // 创建圆形路径 - 从12点钟方向开始
    UIBezierPath *circularPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                 radius:progressRadius
                                                             startAngle:-M_PI_2  // 12点钟方向
                                                               endAngle:3 * M_PI_2  // 顺时针一圈
                                                              clockwise:YES];
    
    // 创建背景层（灰色圆圈）
    self.backgroundLayer = [CAShapeLayer layer];
    self.backgroundLayer.path = circularPath.CGPath;
    self.backgroundLayer.strokeColor = [UIColor colorWithWhite:0.9 alpha:0.3].CGColor;
    self.backgroundLayer.lineWidth = 3.0;
    self.backgroundLayer.fillColor = [UIColor clearColor].CGColor;
    self.backgroundLayer.lineCap = kCALineCapRound;
    self.backgroundLayer.hidden = YES; // 初始隐藏
    
    // 创建进度层（彩色圆圈）
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.path = circularPath.CGPath;
    self.progressLayer.strokeColor = [UIColor systemPurpleColor].CGColor;
    self.progressLayer.lineWidth = 3.0;
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.lineCap = kCALineCapRound;
    self.progressLayer.strokeEnd = 0.0; // 初始为0
    self.progressLayer.hidden = YES; // 初始隐藏
    
    // ✅ 添加到录音按钮的图层
    [self.speekBtn.layer addSublayer:self.backgroundLayer];
    [self.speekBtn.layer addSublayer:self.progressLayer];
    
    NSLog(@"✅ 录音进度条已创建并添加到按钮层");
}

/// ✅ 清理已存在的进度层
- (void)removeExistingProgressLayers {
    if (self.progressLayer) {
        [self.progressLayer removeFromSuperlayer];
        self.progressLayer = nil;
    }
    
    if (self.backgroundLayer) {
        [self.backgroundLayer removeFromSuperlayer];
        self.backgroundLayer = nil;
    }
}

#pragma mark - Button Actions

/// ⭐ 保存按钮点击事件 - 包含参数验证和声音克隆流程
- (void)saveButtonTapped:(UIButton *)sender {
    if (self.isEditMode && self.editingVoice) {
        [self handleEditVoiceSave];
    } else {
        [self handleCreateVoiceSave];
    }
}

/// 处理创建音色保存（原有逻辑）
- (void)handleCreateVoiceSave {
    // Step 1: 参数验证
    NSString *validationError = [self validateCreateVoiceParameters];
    if (validationError) {
        [self showAlert:validationError];
        return;
    }
    
    // Step 2: 检查是否需要上传音频
    if (self.audioFileURL && !self.uploadedAudioFileUrl) {
        // 需要先上传音频文件
        [self uploadAudioAndStartVoiceCloning];
    } else if (self.uploadedAudioFileUrl) {
        // 音频已上传，直接开始克隆
        [self startVoiceCloning];
    } else {
        [self showAlert:LocalString(@"请先录音")];
    }
}

/// 处理编辑音色保存
- (void)handleEditVoiceSave {
    // ✅ 使用从API加载的最新数据进行操作
    VoiceModel *voice = self.currentVoiceData ?: self.editingVoice;
    
    if (!voice) {
        NSLog(@"❌ 没有可用的声音数据进行保存");
        [self showAlert:LocalString(@"没有可保存的音色数据")];
        return;
    }
    
    NSLog(@"💾 开始处理编辑音色保存");
    NSLog(@"   使用声音数据: voiceId=%ld, 状态=%ld", (long)voice.voiceId, (long)voice.cloneStatus);
    
    // Step 1: 验证编辑参数
    NSString *validationError = [self validateEditVoiceParameters];
    if (validationError) {
        [self showAlert:validationError];
        return;
    }
    
    // Step 2: 检查是否正在上传或克隆中，防止重复操作
    if (self.isUploading || self.isCloningVoice) {
        [self showAlert:LocalString(@"处理中，请稍候")];
        return;
    }
    
    // Step 3: 根据音色状态决定更新策略
    switch (voice.cloneStatus) {
        case VoiceCloneStatusSuccess:
            // 成功状态：可能只是更新基本信息，或者重新克隆
            [self handleUpdateSuccessVoice:voice];
            break;
            
        case VoiceCloneStatusFailed:
        case VoiceCloneStatusPending:
            // 失败或待处理状态：重新创建
            [self handleRecreateFailedVoice:voice];
            break;
            
        case VoiceCloneStatusCloning:
            // 克隆中状态不应该允许编辑
            [self showAlert:LocalString(@"音色正在克隆中，请稍后再试")];
            break;
            
        default:
            NSLog(@"⚠️ 未知音色状态: %ld", (long)voice.cloneStatus);
            [self showAlert:LocalString(@"音色状态异常，无法保存")];
            break;
    }
}

/// 验证编辑音色参数
- (NSString *)validateEditVoiceParameters {
    // 1. 检查声音名称
    NSString *nameText = self.voiceNameTextView.text;
    if (!nameText || nameText.length == 0) {
        return LocalString(@"请输入音色名称");
    }
    self.voiceName = nameText;
    
    // 2. 检查插画选择
    if (!self.selectedAvatarUrl || self.selectedAvatarUrl.length == 0) {
        return LocalString(@"请选择音色头像");
    }
    
    // ✅ 对于编辑模式，音频验证根据状态而定，使用最新的API数据
    VoiceModel *currentVoice = self.currentVoiceData ?: self.editingVoice;
    
    BOOL hasNewRecording = (self.audioFileURL != nil);
    BOOL hasExistingAudio = (self.uploadedAudioFileUrl && self.uploadedAudioFileUrl.length > 0);
    
    // ✅ 如果是成功状态的音色，不需要重新录音
    if (currentVoice && currentVoice.cloneStatus == VoiceCloneStatusSuccess) {
        // 成功状态只需要验证基本信息，不需要音频
        NSLog(@"✅ 成功状态音色编辑，跳过音频验证");
    } else {
        // 其他状态需要音频
        if (!hasNewRecording && !hasExistingAudio) {
            return LocalString(@"请录音");
        }
        
        // 4. 如果有新录音，检查时长
        if (hasNewRecording && self.recordedTime < 30) {
            return LocalString(@"录音过短，至少需要30秒");
        }
    }
    
    return nil; // 验证通过
}

/// 处理更新成功状态的音色
- (void)handleUpdateSuccessVoice:(VoiceModel *)voice {
    // ✅ 使用新的变更检测方法
    NSDictionary *changes = [self detectAllChanges];
    
    BOOL hasNewRecording = [changes[@"hasNewRecording"] boolValue];
    BOOL hasBasicInfoChanges = [changes[@"hasBasicInfoChanges"] boolValue];
    BOOL hasAnyChanges = [changes[@"hasAnyChanges"] boolValue];
    
    if (!hasAnyChanges) {
        [self showAlert:LocalString(@"未检测到修改")];
        return;
    }
    
    // ✅ 无论是否有新录音，都调用音色编辑接口
    [self updateVoiceWithAllChanges:changes voice:voice];
}

/// ✅ 检测所有类型的变更
- (NSDictionary *)detectAllChanges {
    NSMutableDictionary *changes = [NSMutableDictionary dictionary];
    NSMutableArray *changedFields = [NSMutableArray array];
    
    // 1. 检测音色名称变更
    NSString *currentVoiceName = self.voiceName ?: @"";
    BOOL nameChanged = ![currentVoiceName isEqualToString:self.originalVoiceName];
    if (nameChanged) {
        [changedFields addObject:@"voiceName"];
        changes[@"voiceName"] = currentVoiceName;
        changes[@"originalVoiceName"] = self.originalVoiceName;
    }
    
    // 2. 检测头像变更
    NSString *currentAvatarUrl = self.selectedAvatarUrl ?: @"";
    BOOL avatarChanged = ![currentAvatarUrl isEqualToString:self.originalAvatarUrl];
    if (avatarChanged) {
        [changedFields addObject:@"avatarUrl"];
        changes[@"avatarUrl"] = currentAvatarUrl;
        changes[@"originalAvatarUrl"] = self.originalAvatarUrl;
    }
    
    // 3. 检测音频变更（新录音）
    BOOL hasNewRecording = (self.audioFileURL != nil);
    if (hasNewRecording) {
        [changedFields addObject:@"audioFile"];
        changes[@"hasNewRecording"] = @YES;
        changes[@"newAudioFileURL"] = self.audioFileURL.absoluteString;
    } else {
        changes[@"hasNewRecording"] = @NO;
    }
    
    // 4. 检测文本内容变更
    NSString *currentText = self.voiceTextLabel.text ?: @"";
    BOOL textChanged = ![currentText isEqualToString:self.originalSampleText];
    if (textChanged) {
        [changedFields addObject:@"sampleText"];
        changes[@"sampleText"] = currentText;
        changes[@"originalSampleText"] = self.originalSampleText;
    }
    
    // 5. 汇总变更信息
    changes[@"changedFields"] = [changedFields copy];
    changes[@"hasBasicInfoChanges"] = @(nameChanged || avatarChanged || textChanged);
    changes[@"hasAnyChanges"] = @(nameChanged || avatarChanged || hasNewRecording || textChanged);
    changes[@"changeCount"] = @(changedFields.count);
    
    // 6. 详细日志
    if (nameChanged || avatarChanged || hasNewRecording) {
        NSLog(@"🔍 检测到变更:");
        if (nameChanged) NSLog(@"   音色名称: %@ → %@", self.originalVoiceName, currentVoiceName);
        if (avatarChanged) NSLog(@"   头像变更");
        if (hasNewRecording) NSLog(@"   新录音");
    }
    
    return [changes copy];
}

/// ✅ 使用变更信息更新音色
- (void)updateVoiceWithChanges:(NSDictionary *)changes voice:(VoiceModel *)voice {
    // 显示加载提示
    [SVProgressHUD showWithStatus:LocalString(@"保存中...")];
    
    // 创建更新请求模型
    UpdateVoiceRequestModel *updateRequest = [[UpdateVoiceRequestModel alloc] initWithVoiceId:voice.voiceId];
    
    // 只设置有变更的字段
    NSArray *changedFields = changes[@"changedFields"];
    
    if ([changedFields containsObject:@"voiceName"]) {
        updateRequest.voiceName = changes[@"voiceName"];
    }
    
    if ([changedFields containsObject:@"avatarUrl"]) {
        updateRequest.avatarUrl = changes[@"avatarUrl"];
    }
    
    // 注意：成功状态的音色不更新音频文件
    
    NSLog(@"📤 发送更新请求参数: %@", [updateRequest toDictionary]);
    
    // 调用更新音色接口
    [[AFStoryAPIManager sharedManager] updateVoice:updateRequest 
                                           success:^(APIResponseModel * _Nonnull response) {
        // ✅ 更新成功
        NSLog(@"✅ Voice information updated successfully");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            // 更新原始值，防止重复提交
            [self updateOriginalValuesAfterSave];
            
            // 清除未保存状态
            self.hasUnsavedChanges = NO;
            
            // 显示成功提示并返回
            [self showSuccessAlertWithCompletion:LocalString(@"音色信息更新成功！")];
            
            //APP埋点：点击声音复刻页面保存按钮
                [[AnalyticsManager sharedManager]reportEventWithName:@"voice_clone_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"点击声音复刻页面保存按钮时" properties:@{@"voiceclonesaveResult":@"success"} completion:^(BOOL success, NSString * _Nullable message) {
                        
                }];
        });
        
    } failure:^(NSError * _Nonnull error) {
        // ❌ 更新失败
        NSLog(@"❌ 音色信息更新失败: %@", error.localizedDescription);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            // 根据错误类型显示更具体的错误信息
            NSString *errorMessage;
            if (error.code == -1009) { // 网络错误
                errorMessage = LocalString(@"网络连接失败，请检查网络后重试");
            } else if (error.code == 401) { // 认证错误
                errorMessage = LocalString(@"认证失败，请重新登录");
            } else if (error.code >= 500) { // 服务器错误
                errorMessage = LocalString(@"服务器繁忙，请稍后重试");
            } else {
                errorMessage = [NSString stringWithFormat:LocalString(@"更新失败：%@"), error.localizedDescription];
            }
            //APP埋点：点击声音复刻页面保存按钮
                [[AnalyticsManager sharedManager]reportEventWithName:@"voice_clone_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"点击声音复刻页面保存按钮时" properties:@{@"voiceclonesaveResult":[NSString stringWithFormat:@"fail(failCode:%ld): 失败，返回失败原因:%@",error.code,errorMessage]} completion:^(BOOL success, NSString * _Nullable message) {
                        
                }];
//            [self showAlert:errorMessage];
        });
    }];
}

/// ✅ 新增：处理包含音频文件的完整音色编辑
- (void)updateVoiceWithAllChanges:(NSDictionary *)changes voice:(VoiceModel *)voice {
    BOOL hasNewRecording = [changes[@"hasNewRecording"] boolValue];
    NSArray *changedFields = changes[@"changedFields"];
    
    // 如果有新录音，需要先上传音频文件
    if (hasNewRecording && self.audioFileURL && !self.uploadedAudioFileUrl) {
        [self uploadAudioAndUpdateVoice:changes voice:voice];
    } else {
        // 没有新录音或音频已上传，直接调用编辑接口
        [self updateVoiceWithEditRequest:changes voice:voice];
    }
}

/// ✅ 上传音频文件后调用编辑接口
- (void)uploadAudioAndUpdateVoice:(NSDictionary *)changes voice:(VoiceModel *)voice {
    if (self.isUploading) {
        [self showAlert:LocalString(@"上传中，请稍候")];
        return;
    }
    
    self.isUploading = YES;
    
    // 显示上传进度
    [SVProgressHUD showWithStatus:LocalString(@"正在上传音频...")];
    
    // 调用音频上传接口
    [[AFStoryAPIManager sharedManager] uploadAudioFile:self.audioFileURL.path 
                                              voiceName:self.voiceName 
                                               progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat progress = uploadProgress.fractionCompleted;
            NSLog(@"上传进度: %.0f%%", progress * 100);
            [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:LocalString(@"上传中... %.0f%%"), progress * 100]];
        });
    } success:^(NSDictionary * _Nonnull data) {
        // ✅ 上传成功，保存返回的URL
        NSLog(@"✅ 音频上传成功!");
        NSLog(@"   返回的文件: %@", data);
    
        self.uploadedAudioFileUrl = [data objectForKey:@"audioFileUrl"];
        self.uploadedFileId = [[data objectForKey:@"fileId"] integerValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isUploading = NO;
            
            // 上传成功后，调用编辑接口
            NSLog(@"📝 音频上传完成，调用编辑接口");
            [self updateVoiceWithEditRequest:changes voice:voice];
        });
        
    } failure:^(NSError * _Nonnull error) {
        // ❌ 上传失败
        NSLog(@"❌ 音频上传失败!");
        NSLog(@"   错误信息: %@", error.localizedDescription);
        NSLog(@"   错误代码: %ld", (long)error.code);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isUploading = NO;
            [SVProgressHUD dismiss];
//            [self showAlert:[NSString stringWithFormat:@"Upload failed: %@", error.localizedDescription]];
        });
    }];
}

/// ✅ 调用音色编辑接口
- (void)updateVoiceWithEditRequest:(NSDictionary *)changes voice:(VoiceModel *)voice {
    NSLog(@"📝 调用音色编辑接口...");
    
    // 如果还没有显示加载提示，则显示
    if (!self.isUploading) {
        [SVProgressHUD showWithStatus:LocalString(@"保存中...")];
    } else {
        [SVProgressHUD showWithStatus:LocalString(@"正在更新音色...")];
    }
    
    // 创建编辑请求模型
    UpdateVoiceRequestModel *updateRequest = [[UpdateVoiceRequestModel alloc] initWithVoiceId:voice.voiceId];
    
    // 设置所有变更的字段
    NSArray *changedFields = changes[@"changedFields"];
    
    if ([changedFields containsObject:@"voiceName"]) {
        updateRequest.voiceName = changes[@"voiceName"];
        NSLog(@"   ✏️ 更新音色名称: %@ → %@", changes[@"originalVoiceName"], changes[@"voiceName"]);
    }
    
    if ([changedFields containsObject:@"avatarUrl"]) {
        updateRequest.avatarUrl = changes[@"avatarUrl"];
        NSLog(@"   🖼️ 更新头像URL: %@ → %@", changes[@"originalAvatarUrl"], changes[@"avatarUrl"]);
    }
    
    
    
    // ✅ 如果有新录音，更新音频文件信息
    BOOL hasNewRecording = [changes[@"hasNewRecording"] boolValue];
    if (hasNewRecording && self.uploadedAudioFileUrl) {
        updateRequest.audioFileUrl = self.uploadedAudioFileUrl;
        updateRequest.FileId = self.uploadedFileId;
        NSLog(@"   🎤 更新音频文件: %@", self.uploadedAudioFileUrl);
        NSLog(@"   📁 文件ID: %ld", (long)self.uploadedFileId);
    }
    
    NSLog(@"📤 发送编辑请求参数: %@", [updateRequest toDictionary]);
    
    // 调用音色编辑接口
    [[AFStoryAPIManager sharedManager] updateVoice:updateRequest 
                                           success:^(APIResponseModel * _Nonnull response) {
        // ✅ 编辑成功
        NSLog(@"✅ 音色编辑成功!");
        NSLog(@"   响应码: %ld", (long)response.code);
        NSLog(@"   响应信息: %@", response.message);
        NSLog(@"   更新字段: %@", changedFields);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            // 更新原始值，防止重复提交
            [self updateOriginalValuesAfterSave];
            
            // 清除未保存状态
            self.hasUnsavedChanges = NO;
            
            // 显示成功提示并返回
            NSString *successMessage = hasNewRecording ? 
                LocalString(@"音色已更新，新录音将重新克隆。") : 
                LocalString(@"音色信息更新成功！");
            [self showSuccessAlertWithCompletion:successMessage];
        });
        
    } failure:^(NSError * _Nonnull error) {
        // ❌ 编辑失败
        NSLog(@"❌ 音色编辑失败!");
        NSLog(@"   错误信息: %@", error.localizedDescription);
        NSLog(@"   错误代码: %ld", (long)error.code);
        NSLog(@"   错误域: %@", error.domain);
        NSLog(@"   尝试更新字段: %@", changedFields);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            // 根据错误类型显示更具体的错误信息
            NSString *errorMessage;
            if (error.code == -1009) {
                errorMessage = @"网络连接失败，请检查网络后重试";
            } else if (error.code == 401) {
                errorMessage = @"认证失败，请重新登录";
            } else if (error.code >= 500) {
                errorMessage = @"服务器繁忙，请稍后重试";
            } else {
                errorMessage = [NSString stringWithFormat:@"更新失败: %@", error.localizedDescription];
            }
            
//            [self showAlert:errorMessage];
        });
    }];
}

/// ✅ 保存成功后更新原始值
- (void)updateOriginalValuesAfterSave {
    NSLog(@"🔄 更新原始值以防重复提交...");
    
    self.originalVoiceName = self.voiceName ?: @"";
    self.originalAvatarUrl = self.selectedAvatarUrl ?: @"";
    self.originalSampleText = self.voiceTextLabel.text ?: @"";
    
    // ✅ 如果有新录音，也更新原始音频URL
    if (self.uploadedAudioFileUrl) {
        self.originalSampleAudioUrl = self.uploadedAudioFileUrl;
    }
    
    NSLog(@"   已更新原始音色名称: %@", self.originalVoiceName);
    NSLog(@"   已更新原始头像URL: %@", self.originalAvatarUrl);
    NSLog(@"   已更新原始示例文本: %@", self.originalSampleText);
    NSLog(@"   已更新原始音频URL: %@", self.originalSampleAudioUrl);
}

#pragma mark - ✅ 故事编辑相关方法（如果需要）

/// ✅ 更新关联的故事信息
- (void)updateStoryWithParameters:(NSDictionary *)parameters {
    NSLog(@"📖 更新关联的故事信息...");
    NSLog(@"   参数: %@", parameters);
    
    // 显示加载提示
    [SVProgressHUD showWithStatus:LocalString(@"正在更新故事...")];
    
    // 创建故事更新请求模型
    UpdateStoryRequestModel *updateRequest = [[UpdateStoryRequestModel alloc] 
                                              initWithStoryId:[parameters[@"storyId"] integerValue]];
    
    // 设置更新的字段
    if (parameters[@"storyName"]) {
        updateRequest.storyName = parameters[@"storyName"];
    }
    if (parameters[@"storyContent"]) {
        updateRequest.storyContent = parameters[@"storyContent"];
    }
    if (parameters[@"illustrationUrl"]) {
        updateRequest.illustrationUrl = parameters[@"illustrationUrl"];
    }
    if (parameters[@"voiceId"]) {
        updateRequest.voiceId = [parameters[@"voiceId"] integerValue];
    }
    
    NSLog(@"📤 发送故事更新请求参数: %@", [updateRequest toDictionary]);
    
    // 调用更新故事接口
    [[AFStoryAPIManager sharedManager] updateStory:updateRequest 
                                           success:^(APIResponseModel * _Nonnull response) {
        // ✅ 故事更新成功
        NSLog(@"✅ 故事信息更新成功!");
        NSLog(@"   响应码: %ld", (long)response.code);
        NSLog(@"   响应信息: %@", response.message);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self showSuccessAlertWithMessage:LocalString(@"故事信息更新成功！")];
        });
        
    } failure:^(NSError * _Nonnull error) {
        // ❌ 故事更新失败
        NSLog(@"❌ 故事信息更新失败!");
        NSLog(@"   错误信息: %@", error.localizedDescription);
        NSLog(@"   错误代码: %ld", (long)error.code);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            NSString *errorMessage;
            if (error.code == -1009) {
                errorMessage = LocalString(@"网络连接失败，请检查网络后重试");
            } else if (error.code == 401) {
                errorMessage = LocalString(@"认证失败，请重新登录");
            } else if (error.code >= 500) {
                errorMessage = LocalString(@"服务器繁忙，请稍后重试");
            } else {
                errorMessage = [NSString stringWithFormat:LocalString(@"故事更新失败：%@"), error.localizedDescription];
            }
            
//            [self showAlert:errorMessage];
        });
    }];
}

/// ✅ 创建标准的故事更新参数字典
- (NSDictionary *)createStoryUpdateParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // 获取当前家庭ID
    NSInteger familyId = [[CoreArchive strForKey:KCURRENT_HOME_ID] integerValue];
    parameters[@"familyId"] = @(familyId);
    
    // 添加故事相关参数（如果有）
    if (self.relatedStoryId > 0) {
        parameters[@"storyId"] = @(self.relatedStoryId);
    }
    
    // 如果故事名称有变更
    if (self.originalStoryName && ![self.originalStoryName isEqualToString:@""]) {
        // 这里需要获取当前的故事名称，可能来自其他UI控件
        // parameters[@"storyName"] = currentStoryName;
    }
    
    // 如果插画有变更
    if (self.selectedAvatarUrl && ![self.selectedAvatarUrl isEqualToString:self.originalIllustrationUrl]) {
        parameters[@"illustrationUrl"] = self.selectedAvatarUrl;
    }
    
    // 如果音色有关联
    if (self.editingVoice && self.editingVoice.voiceId > 0) {
        parameters[@"voiceId"] = @(self.editingVoice.voiceId);
    }
    
    NSLog(@"📋 创建的故事更新参数: %@", parameters);
    return [parameters copy];
}

/// 处理有新录音的重新克隆流程
- (void)handleVoiceRecloneWithNewRecording {
    NSLog(@"🎤 开始处理新录音的重新克隆流程");
    
    // 检查是否有新录音但还没上传
    if (self.audioFileURL && !self.uploadedAudioFileUrl) {
        NSLog(@"📤 新录音需要先上传");
        [self uploadAudioAndStartVoiceCloning];
    } else if (self.uploadedAudioFileUrl) {
        NSLog(@"🎬 新录音已上传，直接开始克隆");
        [self startVoiceCloning];
    } else {
        NSLog(@"⚠️ 异常状态：有新录音标记但没有录音文件");
        [self showAlert:LocalString(@"音频文件错误，请重新录音")];
    }
}

/// 处理重新创建失败的音色
- (void)handleRecreateFailedVoice:(VoiceModel *)voice {
    NSLog(@"🔴 处理失败状态音色的编辑");
    
    // ✅ 失败状态的音色编辑也统一调用编辑接口，不再创建新音色
    NSDictionary *changes = [self detectAllChanges];
    
    NSLog(@"📋 失败音色变更检测结果: %@", changes);
    
    BOOL hasAnyChanges = [changes[@"hasAnyChanges"] boolValue];
    
    if (!hasAnyChanges) {
        NSLog(@"⚠️ 没有检测到任何更改");
        [self showAlert:LocalString(@"未检测到修改")];
        return;
    }
    
    // ✅ 调用音色编辑接口
    NSLog(@"📝 失败状态音色调用编辑接口");
    [self updateVoiceWithAllChanges:changes voice:voice];
}

/// 更新音色基本信息（不重新克隆）
- (void)updateVoiceBasicInfo:(VoiceModel *)voice {
    NSLog(@"📝 更新音色基本信息...");
    NSLog(@"   音色ID: %ld", (long)voice.voiceId);
    NSLog(@"   原名称: %@", voice.voiceName);
    NSLog(@"   新名称: %@", self.voiceName);
    NSLog(@"   原头像: %@", voice.avatarUrl);
    NSLog(@"   新头像: %@", self.selectedAvatarUrl);
    
    // 显示加载提示
    [SVProgressHUD showWithStatus:LocalString(@"保存中...")];
    
    // 创建更新请求模型
    UpdateVoiceRequestModel *updateRequest = [[UpdateVoiceRequestModel alloc] initWithVoiceId:voice.voiceId];
    updateRequest.voiceName = self.voiceName;
    updateRequest.avatarUrl = self.selectedAvatarUrl;
    // 注意：不更新audioFileUrl，因为成功状态的音色不允许重新录音
    
    NSLog(@"📤 发送更新请求参数: %@", [updateRequest toDictionary]);
    
    // 调用更新音色接口
    [[AFStoryAPIManager sharedManager] updateVoice:updateRequest 
                                           success:^(APIResponseModel * _Nonnull response) {
        // ✅ 更新成功
        NSLog(@"✅ Voice information updated successfully!");
        NSLog(@"   响应码: %ld", (long)response.code);
        NSLog(@"   响应信息: %@", response.message);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            // 清除未保存状态
            self.hasUnsavedChanges = NO;
            
            // 显示成功提示并返回
            [self showSuccessAlertWithCompletion:LocalString(@"音色信息更新成功！")];
        });
        
    } failure:^(NSError * _Nonnull error) {
        // ❌ 更新失败
        NSLog(@"❌ 音色信息更新失败!");
        NSLog(@"   错误信息: %@", error.localizedDescription);
        NSLog(@"   错误代码: %ld", (long)error.code);
        NSLog(@"   错误域: %@", error.domain);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            // 根据错误类型显示更具体的错误信息
            NSString *errorMessage;
            if (error.code == -1009) { // 网络错误
                errorMessage = LocalString(@"网络连接失败，请检查网络后重试");
            } else if (error.code == 401) { // 认证错误
                errorMessage = LocalString(@"认证失败，请重新登录");
            } else if (error.code >= 500) { // 服务器错误
                errorMessage = LocalString(@"服务器繁忙，请稍后重试");
            } else {
                errorMessage = [NSString stringWithFormat:LocalString(@"更新失败：%@"), error.localizedDescription];
            }
            
//            [self showAlert:errorMessage];
        });
    }];
}

/// ⭐ 参数验证方法 - 按从上到下顺序单独验证每个字段
- (NSString *)validateCreateVoiceParameters {
    // 1. 首先检查声音名称（最上方的输入框）
    NSString *nameText = self.voiceNameTextView.text;
    if (!nameText || nameText.length == 0) {
        return LocalString(@"请输入音色名称");
    }
    self.voiceName = nameText; // 验证通过后保存
    
    // 2. 检查插画选择（第二个字段）
    if (!self.selectedAvatarUrl || self.selectedAvatarUrl.length == 0) {
        return LocalString(@"请选择音色头像");
    }
    
    // 3. 检查是否有录音文件（第三个字段）
    if (!self.audioFileURL && !self.uploadedAudioFileUrl) {
        return LocalString(@"请先录音");
    }
    
    // 4. 检查录音时长（最后一个限制）
    if (self.recordedTime < 30) {
        return LocalString(@"录音过短，至少需要30秒");
    }
    
    // ✅ 所有验证通过，输出详情
    NSLog(@"📋 参数验证详情:");
    NSLog(@"   声音名称: %@", self.voiceName);
    NSLog(@"   插画URL: %@", self.selectedAvatarUrl);
    NSLog(@"   录音文件: %@", self.audioFileURL.lastPathComponent);
    NSLog(@"   录音时长: %ld秒", (long)self.recordedTime);
    
    return nil; // 验证通过
}

/// ⭐ 上传音频并启动声音克隆
- (void)uploadAudioAndStartVoiceCloning {
    NSLog(@"\n📤 开始上传音频文件...");
    
    if (self.isUploading) {
        [self showAlert:LocalString(@"上传中，请稍候")];
        return;
    }
    
    self.isUploading = YES;
    
    // 显示上传进度
    [SVProgressHUD showWithStatus:LocalString(@"正在上传音频...")];
    
    // 调用音频上传接口
    [[AFStoryAPIManager sharedManager]uploadAudioFile:self.audioFileURL.path voiceName:self.voiceName progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat progress = uploadProgress.fractionCompleted;
            NSLog(@"上传进度: %.0f%%", progress * 100);
            [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:LocalString(@"上传中... %.0f%%"), progress * 100]];
        });
        } success:^(NSDictionary * _Nonnull data) {
            // ✅ 上传成功，保存返回的URL
            NSLog(@"✅ 音频上传成功!");
            NSLog(@"   返回的文件: %@", data);
        
            self.uploadedAudioFileUrl = [data objectForKey:@"audioFileUrl"];
            self.uploadedFileId = [[data objectForKey:@"fileId"] integerValue];
            
            NSLog(@"   提取的文件ID: %ld", (long)self.uploadedFileId);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isUploading = NO;
                [SVProgressHUD dismiss];
                
                // 上传成功后，继续克隆声音
                NSLog(@"\n🎤 上传完成，准备开始克隆声音...");
                [self startVoiceCloning];
            });
            
            //APP埋点：长按声音录制按钮
            [[AnalyticsManager sharedManager]reportEventWithName:@"voice_replication_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"用户在声音复刻页面点击录制声音的按钮" properties:@{@"voicereplicationResult":@"success"} completion:^(BOOL success, NSString * _Nullable message) {
                        
                }];
            
        } failure:^(NSError * _Nonnull error) {
            // ❌ 上传失败
            NSLog(@"❌ 音频上传失败!");
            NSLog(@"   错误信息: %@", error.localizedDescription);
            NSLog(@"   错误代码: %ld", (long)error.code);
            
            //APP埋点：长按声音录制按钮
            [[AnalyticsManager sharedManager]reportEventWithName:@"voice_replication_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"用户在声音复刻页面点击录制声音的按钮" properties:@{@"voicereplicationResult":@"fail"} completion:^(BOOL success, NSString * _Nullable message) {
                        
                }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isUploading = NO;
                [SVProgressHUD dismiss];
//                [self showAlert:[NSString stringWithFormat:@"Upload failed: %@", error.localizedDescription]];
            });
        }];
    
    
    
}

/// ⭐ 开始声音克隆
- (void)startVoiceCloning {
    NSLog(@"\n🎬 开始创建声音（克隆）...");
    
    if (self.isCloningVoice) {
        [self showAlert:LocalString(@"克隆进行中，请稍候")];
        //APP埋点：点击声音复刻页面保存按钮
            [[AnalyticsManager sharedManager]reportEventWithName:@"voice_clone_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"点击声音复刻页面保存按钮时" properties:@{@"voiceclonesaveResult":@"fail(Cloning in progress, please wait.)"} completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
        return;
    }
    
    // 检查必要参数
    if (!self.uploadedAudioFileUrl || self.uploadedAudioFileUrl.length == 0) {
        [self showAlert:LocalString(@"音频文件地址不存在")];
        //APP埋点：点击声音复刻页面保存按钮
            [[AnalyticsManager sharedManager]reportEventWithName:@"voice_clone_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"点击声音复刻页面保存按钮时" properties:@{@"voiceclonesaveResult":@"Audio file URL does not exist)"} completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
        return;
    }
    
    self.isCloningVoice = YES;
    [SVProgressHUD showWithStatus:LocalString(@"正在克隆音色...")];
    
    // 创建声音请求模型
    CreateVoiceRequestModel *voiceRequest = [[CreateVoiceRequestModel alloc]
                                            initWithName:self.voiceName
                                                avatarUrl:self.selectedAvatarUrl
                                            audioFileUrl:self.uploadedAudioFileUrl fileId:self.uploadedFileId];
    
    NSLog(@"📝 声音克隆参数:");
    NSLog(@"   名称: %@", voiceRequest.voiceName);
    NSLog(@"   插画URL: %@", voiceRequest.avatarUrl);
    NSLog(@"   音频URL: %@", voiceRequest.audioFileUrl);
    NSLog(@"   家庭ID: %ld", (long)voiceRequest.familyId);
    
    // 调用创建声音接口
    [[AFStoryAPIManager sharedManager] createVoice:voiceRequest
                                           success:^(APIResponseModel *response) {
        // ✅ 声音创建成功
        NSLog(@"\n✅ 声音克隆已启动!");
        NSLog(@"   响应码: %ld", (long)response.code);
        NSLog(@"   响应信息: %@", response.message);
        
        if (response.data) {
            NSLog(@"   返回数据: %@", response.data);
            
            // 尝试从返回数据中获取 voiceId
            if ([response.data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDict = (NSDictionary *)response.data;
                NSInteger voiceId = [dataDict[@"voiceId"] integerValue];
                NSLog(@"   声音ID: %ld", (long)voiceId);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isCloningVoice = NO;
            [SVProgressHUD dismiss];
            
            // 清除未保存状态（保存成功）
            self.hasUnsavedChanges = NO;
            
            // 显示成功信息，用户点击确定后再跳转
            [self showSuccessAlertWithCompletion:LocalString(@"音色克隆已开始！\n\n系统正在后台处理您的声音。\n请稍后刷新查看进度。")];
        });
        
        //APP埋点：点击声音复刻页面保存按钮
            [[AnalyticsManager sharedManager]reportEventWithName:@"voice_clone_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"点击声音复刻页面保存按钮时" properties:@{@"voiceclonesaveResult":@"success"} completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
        
        
    } failure:^(NSError *error) {
        // ❌ 声音创建失败
        NSLog(@"\n❌ 声音克隆失败!");
        NSLog(@"   错误信息: %@", error.localizedDescription);
        NSLog(@"   错误代码: %ld", (long)error.code);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isCloningVoice = NO;
            [SVProgressHUD dismiss];
//            [self showAlert:[NSString stringWithFormat:@"Failed to create voice: %@", error.localizedDescription]];
        });
        //APP埋点：点击声音复刻页面保存按钮
            [[AnalyticsManager sharedManager]reportEventWithName:@"voice_clone_save_click" level1:kAnalyticsLevel1_Creation level2:@"" level3:@"" reportTrigger:@"点击声音复刻页面保存按钮时" properties:@{@"voiceclonesaveResult":[NSString stringWithFormat:@"fail(failCode:%ld): 失败，返回失败原因:%@",error.code,error]} completion:^(BOOL success, NSString * _Nullable message) {
                    
            }];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // 计算替换后的文本长度
    NSUInteger newLength = textField.text.length + string.length - range.length;
    
    // 限制长度不超过30个字符
    if (newLength > 30) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Navigation & UI Event Handlers

/// 自定义返回按钮点击事件
- (void)backButtonTapped:(UIButton *)sender {
    if (self.hasUnsavedChanges) {
        [self showExitConfirmationDialog];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/// 文本框内容变化监听
- (void)textFieldDidChange:(UITextField *)textField {
    // ✅ 检查是否真的有变更
    NSString *currentText = textField.text ?: @"";
    BOOL actuallyChanged = ![currentText isEqualToString:self.originalVoiceName];
    
    if (actuallyChanged) {
        self.hasUnsavedChanges = YES;
        NSLog(@"📝 音色名称发生变更: '%@' → '%@'", self.originalVoiceName, currentText);
    }
    
    // 限制文本长度不超过30个字符
    if (textField.text.length > 30) {
        textField.text = [textField.text substringToIndex:30];
    }
}

/// 显示退出确认对话框
- (void)showExitConfirmationDialog {
    [LGBaseAlertView showAlertWithTitle:LocalString(@"音色复刻尚未保存，确定要离开吗？")
                                content:nil
                           cancelBtnStr:LocalString(@"取消")
                          confirmBtnStr:LocalString(@"离开")
                           confirmBlock:^(BOOL isValue, id obj) {
        if (isValue) {
            // 用户确认退出，清除未保存状态并返回
            self.hasUnsavedChanges = NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)chooseImageButtonTapped:(UIButton *)sender {
    SelectIllustrationVC *vc = [[SelectIllustrationVC alloc] init];
    
    // 传递当前已选中的插画URL给选择页面
    if (self.selectedAvatarUrl && self.selectedAvatarUrl.length > 0) {
        vc.imgUrl = self.selectedAvatarUrl;
    }
    
    // 设置回调
    vc.sureBlock = ^(NSString *imgUrl) {
        NSLog(@"选中的插画: %@", imgUrl);
        
        // ✅ 检查头像是否真的有变更
        NSString *currentAvatarUrl = imgUrl ?: @"";
        BOOL actuallyChanged = ![currentAvatarUrl isEqualToString:self.originalAvatarUrl];
        
        // 保存选中的插画URL
        self.selectedAvatarUrl = imgUrl;
        
        // 只有真正变更时才标记
        if (actuallyChanged) {
            self.hasUnsavedChanges = YES;
            NSLog(@"🖼️ 头像发生变更: '%@' → '%@'", self.originalAvatarUrl, currentAvatarUrl);
        }
        
        // 使用插画URL设置按钮背景
        [self.chooseImageBtn sd_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal];
        self.deletPickImageBtn.hidden = NO;
        
        NSLog(@"✅ 插画已选中，URL已保存");
    };
    
    // 显示
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:vc animated:NO completion:^{
        [vc showView];
    }];
}

/// 删除选中的图片，恢复默认状态
- (void)deletPickImage {
    // 恢复默认图片
    UIImage *defaultImage = [UIImage imageNamed:@"create_ad"];
    [self.chooseImageBtn setImage:defaultImage forState:UIControlStateNormal];
    [self.chooseImageBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    // 清空选中的URL
    self.selectedAvatarUrl = nil;
    
    // 标记有未保存的更改
    self.hasUnsavedChanges = YES;
    
    // 隐藏删除按钮
    self.deletPickImageBtn.hidden = YES;
    
    NSLog(@"✅ 插画已删除");
}

#pragma mark - Speech Recognition & Recording

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    // ✅ 如果是编辑成功状态的音色，不允许录音（使用最新API数据判断）
    VoiceModel *currentVoice = self.currentVoiceData ?: self.editingVoice;
    if (self.isEditMode && currentVoice && currentVoice.cloneStatus == VoiceCloneStatusSuccess) {
        NSLog(@"⚠️ 成功状态的音色不允许重新录音");
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // ✅ 按下时开始录音
        [self startRecording];
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        // ✅ 松手时停止录音（无论录音时长多少都停止）
        [self stopRecording];
    }
    
    
}


- (void)startRecording {
    NSLog(@"🎤 startRecording 被调用");
    
    // ✅ 如果是编辑成功状态的音色，不允许录音（使用最新API数据判断）
    VoiceModel *currentVoice = self.currentVoiceData ?: self.editingVoice;
    if (self.isEditMode && currentVoice && currentVoice.cloneStatus == VoiceCloneStatusSuccess) {
        NSLog(@"⚠️ 成功状态的音色不允许重新录音");
        return;
    }
    
    if (self.isRecording) {
        NSLog(@"⚠️ 录音已在进行中，忽略重复请求");
        return;
    }
    
    NSLog(@"🎤 开始录音流程");
    
    // ✅ 简化权限检查，避免异步调用导致的问题
    // 检查语音识别权限
    SFSpeechRecognizerAuthorizationStatus speechStatus = [SFSpeechRecognizer authorizationStatus];
    if (speechStatus != SFSpeechRecognizerAuthorizationStatusAuthorized) {
        NSLog(@"⚠️ 语音识别权限未授权，状态: %ld", (long)speechStatus);
        [self showAlert:LocalString(@"请在设置中允许语音识别权限")];
        return;
    }
    
    // 检查录音权限
    AVAudioSessionRecordPermission recordPermission = [[AVAudioSession sharedInstance] recordPermission];
    if (recordPermission == AVAudioSessionRecordPermissionDenied) {
        NSLog(@"⚠️ 录音权限被拒绝");
        [self showAlert:LocalString(@"请在设置中允许麦克风权限")];
        return;
    } else if (recordPermission == AVAudioSessionRecordPermissionUndetermined) {
        NSLog(@"⚠️ 录音权限未确定，需要请求权限");
        // 请求录音权限
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    NSLog(@"✅ 录音权限获取成功，开始录音");
                    [self beginRecordingSession];
                } else {
                    NSLog(@"❌ 录音权限被拒绝");
                    [self showAlert:LocalString(@"请在设置中允许麦克风权限")];
                }
            });
        }];
        return;
    }
    
    // 权限都已授权，直接开始录音
    NSLog(@"✅ 所有权限已授权，开始录音会话");
    [self beginRecordingSession];
}

/// ✅ 修改：录音过程中不显示识别文字，录音结束才回显
- (void)beginRecordingSession {
    NSLog(@"🎙️ beginRecordingSession 开始");
    
    // ✅ 防止重复调用
    if (self.isRecording) {
        NSLog(@"⚠️ 录音会话已在进行中，忽略重复调用");
        return;
    }
    
    // ✅ 立即设置录音状态，防止重复调用
    self.isRecording = YES;
    self.remainingTime = 30;
    self.recordedTime = 0;
    self.finalRecognizedText = nil;
    
    NSLog(@"🔄 开始录音前的清理工作");
    
    // ✅ 开始录音前，重置按钮状态（如果之前显示过处理动画）
    [self resetRecordingButton];
    
    // 重置label为录音状态
    self.speekLabel.text = LocalString(@"正在准备录音...");
    
    // 取消之前的任务
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    // 停止之前的音频引擎（如果正在运行）
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
        [self.audioEngine.inputNode removeTapOnBus:0];
    }
    
    NSLog(@"🔊 配置音频会话");
    
    // 配置音频会话
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord 
                         mode:AVAudioSessionModeMeasurement 
                      options:AVAudioSessionCategoryOptionDefaultToSpeaker 
                        error:&error];
    
    if (error) {
        NSLog(@"❌ 音频会话配置失败: %@", error);
        self.isRecording = NO; // 重置状态
        [self showAlert:LocalString(@"录音初始化失败，请重试")];
        return;
    }
    
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    if (error) {
        NSLog(@"❌ 音频会话激活失败: %@", error);
        self.isRecording = NO; // 重置状态
        [self showAlert:LocalString(@"录音初始化失败，请重试")];
        return;
    }
    
    NSLog(@"📁 设置录音文件路径");
    
    // 设置录音文件路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *audioFileName = [NSString stringWithFormat:@"voice_recording_%@.m4a", [self currentTimestamp]];
    NSString *audioFilePath = [documentsPath stringByAppendingPathComponent:audioFileName];
    self.audioFileURL = [NSURL fileURLWithPath:audioFilePath];
    
    NSLog(@"📁 录音文件将保存到: %@", self.audioFileURL.path);
    
    // 配置录音设置
    NSDictionary *recordSettings = @{
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVSampleRateKey: @(16000.0),
        AVNumberOfChannelsKey: @(1),
        AVEncoderAudioQualityKey: @(AVAudioQualityHigh)
    };
    
    NSLog(@"🎙️ 初始化录音器");
    
    // 初始化录音器
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.audioFileURL 
                                                      settings:recordSettings 
                                                         error:&error];
    
    if (error) {
        NSLog(@"❌ 录音器初始化失败: %@", error);
        self.isRecording = NO; // 重置状态
        [self showAlert:LocalString(@"录音器初始化失败，请重试")];
        return;
    }
    
    if (![self.audioRecorder prepareToRecord]) {
        NSLog(@"❌ 录音器准备失败");
        self.isRecording = NO; // 重置状态
        [self showAlert:LocalString(@"录音器准备失败，请重试")];
        return;
    }
    
    if (![self.audioRecorder record]) {
        NSLog(@"❌ 录音启动失败");
        self.isRecording = NO; // 重置状态
        [self showAlert:LocalString(@"开始录音失败，请重试")];
        return;
    }
    
    NSLog(@"✅ 录音器启动成功");
    
    // 创建识别请求
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    self.recognitionRequest.shouldReportPartialResults = YES;
    
    NSLog(@"🗣️ 启动语音识别");
    
    // ✅ 使用 @try-@catch 保护音频引擎操作
    @try {
        AVAudioInputNode *inputNode = self.audioEngine.inputNode;
        
        // ⭐ 开始识别任务 - 但录音过程中不更新UI，只在录音结束时获取最终结果
        __weak typeof(self) weakSelf = self;
        self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest 
                                                                   resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (result) {
                // ✅ 录音过程中不更新UI，只在最终结果时保存文本用于录音结束后回显
                if (result.isFinal) {
                    NSString *finalText = result.bestTranscription.formattedString;
                    strongSelf.finalRecognizedText = finalText; // 保存最终识别结果
                    NSLog(@"🔊 最终识别文本: %@", finalText);
                }
            }
            
            if (error) {
                NSLog(@"🔊 语音识别错误: %@", error.localizedDescription);
                // 语音识别错误不应该中断录音
            }
        }];
        
        // 配置音频输入
        AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
        [inputNode installTapOnBus:0 
                        bufferSize:1024 
                            format:recordingFormat 
                             block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
            if (weakSelf.recognitionRequest) {
                [weakSelf.recognitionRequest appendAudioPCMBuffer:buffer];
            }
        }];
        
        // 启动音频引擎
        [self.audioEngine prepare];
        BOOL engineStarted = [self.audioEngine startAndReturnError:&error];
        
        if (!engineStarted || error) {
            NSLog(@"❌ 音频引擎启动失败: %@", error.localizedDescription);
            // 语音识别失败不应该阻止录音
        } else {
            NSLog(@"✅ 音频引擎启动成功");
        }
        
    } @catch (NSException *exception) {
        NSLog(@"❌ 音频引擎异常: %@", exception.reason);
        // 继续录音流程，即使语音识别失败
    }
    
    NSLog(@"🎬 录音正式开始");
    
    // 更新UI状态
    self.speekLabel.text = LocalString(@"录音中，松开结束（0秒）");
    
    // 显示进度条
    [self showRecordingProgress];
    
    // 启动计时器
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                        target:self 
                                                      selector:@selector(updateRecordingTime) 
                                                      userInfo:nil 
                                                       repeats:YES];
    
    NSLog(@"✅ 录音会话完全启动成功");
}

- (void)updateVoiceTextLabelHeight:(NSString *)text {
    CGFloat newHeight;
    
    if (!text || text.length == 0) {
        // 文本为空时，使用placeholder文字的高度
        NSString *placeholderText = [self defaultVoiceSampleText];
        newHeight = [self calculateTextHeight:placeholderText];
    } else {
        // 计算实际文本所需高度
        newHeight = [self calculateTextHeight:text];
    }
    
    // 更新高度约束
    if (self.voiceTextLabelHeightConstraint.constant != newHeight) {
        self.voiceTextLabelHeightConstraint.constant = newHeight;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

/// 计算文本高度的通用方法
- (CGFloat)calculateTextHeight:(NSString *)text {
    if (!text || text.length == 0) {
        return 50; // 最小高度
    }
    
    // 计算文本所需高度
    CGFloat maxWidth = self.voiceTextLabel.frame.size.width - 24; // 减去左右内边距
    if (maxWidth <= 0) {
        // 如果label还没有布局完成，使用屏幕宽度估算
        maxWidth = [UIScreen mainScreen].bounds.size.width - 48; // 减去左右边距
    }
    
    CGSize maxSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    NSDictionary *attributes = @{NSFontAttributeName: self.voiceTextLabel.font ?: [UIFont systemFontOfSize:17]};
    CGRect textRect = [text boundingRectWithSize:maxSize
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attributes
                                         context:nil];
    
    // 计算实际高度（加上上下内边距）
    CGFloat calculatedHeight = ceil(textRect.size.height) + 24;
    
    // 限制高度范围：50-200
    return MAX(50, MIN(200, calculatedHeight));
}

- (void)updateRecordingTime {
    self.recordedTime++;
    self.remainingTime--;
    
    // ✅ 更新进度条（30秒为满进度）
    CGFloat progress = MIN(1.0, self.recordedTime / 30.0);
    [self updateRecordingProgress:progress];
    
    // ✅ 更新录音时间显示 - 松手就能停止录音
    if (self.recordedTime < 30) {
        // 还没达到最少时间要求，提醒用户
        self.speekLabel.text = [NSString stringWithFormat:LocalString(@"录音中，建议至少30秒，松开结束（%ld秒）"), (long)self.recordedTime];
    } else {
        // 已达到建议时间，正常显示
        self.speekLabel.text = [NSString stringWithFormat:LocalString(@"录音中，松开结束（%ld秒）"), (long)self.recordedTime];
    }
}

- (void)stopRecording {
    if (!self.isRecording) {
        return;
    }
    
    // 停止计时器
    if (self.recordTimer) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    
    // 停止录音器
    @try {
        if (self.audioRecorder && self.audioRecorder.isRecording) {
            [self.audioRecorder stop];
        }
    } @catch (NSException *exception) {
        NSLog(@"⚠️ 停止录音器异常: %@", exception.reason);
    }
    
    // 停止音频引擎和识别
    [self stopAudioEngine];
    
    // ✅ 根据录音时长决定处理方式
    if (self.recordedTime < 30) {
        // 录音时间不足30秒：显示提示，删除录音文件，不回显文本
        [self handleShortRecording];
    } else {
        // 录音时间足够：保存录音，回显识别文本
        [self handleSuccessfulRecording];
    }
    
    // 重置UI
    [self resetRecordingState];
}

/// ✅ 处理录音时间不足的情况
- (void)handleShortRecording {
    NSLog(@"⚠️ 录音时间不足30秒 (实际: %lds)", (long)self.recordedTime);
    
    // ✅ 使用SVProgressHUD显示提示
    [SVProgressHUD showErrorWithStatus:LocalString(LocalString(@"录音过短，至少需要30秒"))];
    [SVProgressHUD dismissWithDelay:2.0];
    
    // 删除录音文件
    if (self.audioFileURL) {
        [[NSFileManager defaultManager] removeItemAtURL:self.audioFileURL error:nil];
        self.audioFileURL = nil;
        NSLog(@"🗑️ 已删除短录音文件");
    }
    
    // ✅ 停止并清理计时器
    if (self.recordTimer) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    
    // ✅ 重置录音相关状态
    self.recordedTime = 0;
    self.remainingTime = 30;
    self.finalRecognizedText = nil;
    
    // 恢复录音标签文字
    self.speekLabel.text = LocalString(@"按住开始录音");
    
    
}

/// ✅ 处理录音成功的情况
- (void)handleSuccessfulRecording {
    NSLog(@"✅ 录音完成 (时长: %lds)", (long)self.recordedTime);
    
    // 输出录音文件信息
    if (self.audioFileURL) {
        NSLog(@"=== 录音完成 ===");
        NSLog(@"录音文件路径: %@", self.audioFileURL.path);
        NSLog(@"录音时长: %ld秒", (long)self.recordedTime);
        NSLog(@"文件大小: %.2f KB", [self getFileSizeInKB:self.audioFileURL]);
        NSLog(@"===============");
        
        // 标记有未保存的更改
        self.hasUnsavedChanges = YES;
    }
    
    // ✅ 不再回显识别到的文本，保持当前显示
    NSLog(@"ℹ️ 录音完成，不回显识别文本");
    
    // ✅ 录音完成后，将按钮变为声音处理gif图
    [self showSoundProcessingAnimation];
    
    // 显示录音完成提示
    self.speekLabel.text = LocalString(@"音色克隆约需3-5分钟，可先保存");
    
    
    
}

/// 安全停止音频引擎
- (void)stopAudioEngine {
    @try {
        if (self.audioEngine && self.audioEngine.isRunning) {
            [self.audioEngine stop];
        }
        
        if (self.audioEngine && self.audioEngine.inputNode) {
            [self.audioEngine.inputNode removeTapOnBus:0];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"⚠️ 停止音频引擎异常: %@", exception.reason);
    }
    
    // 清理识别相关资源
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    if (self.recognitionRequest) {
        [self.recognitionRequest endAudio];
        self.recognitionRequest = nil;
    }
}

- (void)resetRecordingState {
    self.isRecording = NO;
    // 注意：这里不再重置 speekLabel.text，因为录音完成后需要显示特定文案
    
    // 隐藏进度条
    [self hideRecordingProgress];
    
    // 安全停止音频引擎
    [self stopAudioEngine];
    
    // ✅ 当录音时间不足时，重置按钮状态
    if (self.recordedTime < 30) {
        [self resetRecordingButton];
    }
}

#pragma mark - Alert Methods

- (void)showAlert:(NSString *)message {
    [LGBaseAlertView showAlertWithTitle:LocalString(@"提示")
                                content:message
                           cancelBtnStr:nil
                          confirmBtnStr:LocalString(@"确定")
                           confirmBlock:^(BOOL isValue, id obj) {
        // 用户点击确定，无需额外操作
    }];
}

- (void)showSuccessAlertWithMessage:(NSString *)message {
    [LGBaseAlertView showAlertWithTitle:LocalString(@"成功")
                                content:message
                           cancelBtnStr:nil
                          confirmBtnStr:LocalString(@"确定")
                           confirmBlock:^(BOOL isValue, id obj) {
        // 用户点击确定，无需额外操作
    }];
}

- (void)showSuccessAlertWithCompletion:(NSString *)message {
    [LGBaseAlertView showAlertWithTitle:LocalString(@"成功")
                                content:message
                           cancelBtnStr:nil
                          confirmBtnStr:LocalString(@"确定")
                           confirmBlock:^(BOOL isValue, id obj) {
        if (isValue) {
            // 用户点击确定后，跳转到列表页面
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}


#pragma mark - Helper Methods

/// ✅ 以 placeholder 样式显示文本（用于回显数据）
- (void)displayTextWithPlaceholderStyle:(NSString *)text {
    if (!text || text.length == 0) {
        // 文本为空时显示默认 placeholder
        [self showDefaultPlaceholder];
        return;
    }
    
    // 清空主 label 的文本
    self.voiceTextLabel.text = @"";
    
    // 该页面示例文本是固定稿，加载时统一显示当前语言版本
    NSString *localizedText = [self defaultVoiceSampleText];
    self.placeholderLabel.text = localizedText;
    self.placeholderLabel.hidden = NO;
    
    // 更新高度以适应回显的文本
    [self updateVoiceTextLabelHeight:localizedText];
    
    NSLog(@"📝 以 placeholder 样式显示回显文本: %@", text);
}

/// ✅ 显示默认的 placeholder 文本
- (void)showDefaultPlaceholder {
    self.voiceTextLabel.text = @"";
    self.placeholderLabel.text = [self defaultVoiceSampleText];
    self.placeholderLabel.hidden = NO;
    
    // 使用默认文本计算高度
    [self updateVoiceTextLabelHeight:self.placeholderLabel.text];
}

/// ✅ 以正常样式显示文本（用于识别结果等实时内容）
- (void)displayTextWithNormalStyle:(NSString *)text {
    if (!text || text.length == 0) {
        [self showDefaultPlaceholder];
        return;
    }
    
    // 在主 label 中显示文本
    self.voiceTextLabel.text = text;
    self.placeholderLabel.hidden = YES;
    
    // 更新高度
    [self updateVoiceTextLabelHeight:text];
    
    NSLog(@"📝 以正常样式显示文本: %@", text);
}

/// ✅ 显示声音处理动画
- (void)showSoundProcessingAnimation {
    // 禁用录音按钮的所有手势，避免在处理动画期间重新录音
    self.speekBtn.userInteractionEnabled = NO;
    // 隐藏进度条
    [self hideRecordingProgress];
    self.voiceGifImageView.hidden = NO;
    
    // 加载帧动画图片序列（声音处理0000到声音处理0039）
    NSMutableArray *frameImages = [NSMutableArray array];
    
    // 循环加载40帧图片（0000到0039）
    for (int i = 0; i <= 39; i++) {
        NSString *imageName = [NSString stringWithFormat:@"声音处理%04d", i];
        UIImage *frameImage = [UIImage imageNamed:imageName];
        
        if (frameImage) {
            [frameImages addObject:frameImage];
        } else {
            NSLog(@"⚠️ 找不到帧图片: %@", imageName);
        }
    }
    
    if (frameImages.count > 0) {
        NSLog(@"✅ 成功加载 %lu 帧动画图片", (unsigned long)frameImages.count);
        
        // 设置帧动画
        self.voiceGifImageView.animationImages = frameImages;
        self.voiceGifImageView.animationDuration = 2.0; // 动画总时长2秒
        self.voiceGifImageView.animationRepeatCount = 0; // 无限循环
        
        // 开始动画
        [self.voiceGifImageView startAnimating];
        
        // 隐藏录音按钮
        self.speekBtn.hidden = YES;
        
        NSLog(@"🎬 声音处理帧动画已开始");
    } else {
        NSLog(@"❌ 没有找到任何帧图片，回退使用录音按钮");
        // 如果没有找到帧图片，保持原有状态
        self.voiceGifImageView.hidden = YES;
        self.speekBtn.hidden = NO;
    }
    
    // 可选：添加按钮点击提示，告诉用户正在处理
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processingButtonTapped:)];
    [self.speekBtn addGestureRecognizer:tapGesture];
}





/// ✅ 处理中按钮被点击时的提示
- (void)processingButtonTapped:(UITapGestureRecognizer *)gesture {
    // 显示处理中的提示
    [self showAlert:LocalString(@"声音处理中，请稍候...")];
}

/// ✅ 重置录音按钮到初始状态（在需要重新录音时调用）
- (void)resetRecordingButton {
    NSLog(@"🔄 resetRecordingButton 被调用");
    
    // ✅ 如果正在录音，不要重置
    if (self.isRecording) {
        NSLog(@"⚠️ 正在录音中，跳过按钮重置");
        return;
    }
    
    NSLog(@"🔄 开始重置录音按钮状态");
    
    // 1. 停止并隐藏帧动画
    if (self.voiceGifImageView.isAnimating) {
        [self.voiceGifImageView stopAnimating];
        NSLog(@"⏹️ 已停止声音处理帧动画");
    }
    self.voiceGifImageView.hidden = YES;
    self.voiceGifImageView.animationImages = nil; // 清理动画图片数组，释放内存
    
    // 2. 移除处理动画
    if (self.speekBtn.imageView.layer) {
        [self.speekBtn.imageView.layer removeAnimationForKey:@"rotationAnimation"];
    }
    
    // 3. 移除点击手势（处理状态的点击手势）
    NSArray *gestures = [self.speekBtn.gestureRecognizers copy];
    for (UIGestureRecognizer *gesture in gestures) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [self.speekBtn removeGestureRecognizer:gesture];
        }
    }
    
    // 4. 重新启用长按手势（录音手势）
    for (UIGestureRecognizer *gesture in self.speekBtn.gestureRecognizers) {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            gesture.enabled = YES;
        }
    }
    
    // 5. 恢复原始的录音按钮外观
    UIImage *defaultRecordImage = [UIImage imageNamed:@"create_voiceclone"];
    if (defaultRecordImage) {
        [self.speekBtn setImage:defaultRecordImage forState:UIControlStateNormal];
    } else {
        // 如果找不到图片，使用系统麦克风图标
        UIImage *micImage = [UIImage systemImageNamed:@"mic.circle.fill"];
        [self.speekBtn setImage:micImage forState:UIControlStateNormal];
        [self.speekBtn setTintColor:[UIColor systemBlueColor]];
    }
    
    [self.speekBtn setTitle:nil forState:UIControlStateNormal];
    [self.speekBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    // 6. 重新启用用户交互
    self.speekBtn.userInteractionEnabled = YES;
    
    // 7. 确保按钮可见
    self.speekBtn.hidden = NO;
    self.speekBtn.alpha = 1.0;
    
    // 8. 确保进度条被隐藏和重置
    [self hideRecordingProgress];
    
    NSLog(@"✅ 录音按钮状态已重置为初始状态");
}

#pragma mark - Recording Progress Methods

- (void)showRecordingProgress {
    // ✅ 确保进度条已正确创建
    if (!self.progressLayer || !self.backgroundLayer) {
        [self createProgressLayers];
    }
    
    // 显示进度条
    if (self.backgroundLayer && self.progressLayer) {
        self.backgroundLayer.hidden = NO;
        self.progressLayer.hidden = NO;
        
        // 重置进度
        self.progressLayer.strokeEnd = 0.0;
        NSLog(@"✅ 录音进度条已显示");
    } else {
        NSLog(@"⚠️ 进度条创建失败，无法显示进度");
    }
}

- (void)updateRecordingProgress:(CGFloat)progress {
    if (!self.progressLayer) {
        NSLog(@"⚠️ 进度条不存在，无法更新进度");
        return;
    }
    
    // ✅ 限制进度范围
    progress = MAX(0.0, MIN(1.0, progress));
    
    // 更新进度条
    [CATransaction begin];
    [CATransaction setDisableActions:YES]; // 禁用隐式动画
    self.progressLayer.strokeEnd = progress;
    [CATransaction commit];
    
    // ✅ 根据进度使用渐变颜色：#FDAB1E → #F443AF → #6D36F5，透明度90%
    UIColor *strokeColor;
    if (progress <= 0.3) {
        // 前30%：使用第一个颜色 #FDAB1E（橙黄色），透明度90%
        strokeColor = [UIColor colorWithRed:0xFD/255.0 green:0xAB/255.0 blue:0x1E/255.0 alpha:0.9];
    } else if (progress <= 0.6) {
        // 中间30%：使用第二个颜色 #F443AF（粉红色），透明度90%
        strokeColor = [UIColor colorWithRed:0xF4/255.0 green:0x43/255.0 blue:0xAF/255.0 alpha:0.9];
    } else {
        // 最后40%：使用第三个颜色 #6D36F5（紫蓝色），透明度90%
        strokeColor = [UIColor colorWithRed:0x6D/255.0 green:0x36/255.0 blue:0xF5/255.0 alpha:0.9];
    }
    
    self.progressLayer.strokeColor = strokeColor.CGColor;
}

- (void)hideRecordingProgress {
    // 隐藏进度条
    if (self.backgroundLayer) {
        self.backgroundLayer.hidden = YES;
    }
    if (self.progressLayer) {
        self.progressLayer.hidden = YES;
        // 重置进度
        self.progressLayer.strokeEnd = 0.0;
    }
}



- (NSString *)currentTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
    return [formatter stringFromDate:[NSDate date]];
}

- (CGFloat)getFileSizeInKB:(NSURL *)fileURL {
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:&error];
    if (error) {
        return 0;
    }
    unsigned long long fileSize = [attributes fileSize];
    return fileSize / 1024.0;
}

#pragma mark - Dealloc

- (void)dealloc {
    NSLog(@"🗑️ CreateVoiceViewController dealloc");
    
    // 清理API加载状态
    self.isLoadingVoiceData = NO;
    self.currentVoiceData = nil;
    
    // 安全停止计时器
    if (self.recordTimer) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    
    // 清理帧动画
    @try {
        if (self.voiceGifImageView.isAnimating) {
            [self.voiceGifImageView stopAnimating];
        }
        self.voiceGifImageView.animationImages = nil; // 释放帧图片内存
    } @catch (NSException *exception) {
        NSLog(@"⚠️ 清理帧动画异常: %@", exception.reason);
    }
    
    // 清理进度条
    @try {
        [self removeExistingProgressLayers];
    } @catch (NSException *exception) {
        NSLog(@"⚠️ 清理进度条异常: %@", exception.reason);
    }
    
    // 安全停止音频引擎
    [self stopAudioEngine];
    
    // 停止录音器
    @try {
        if (self.audioRecorder && self.audioRecorder.isRecording) {
            [self.audioRecorder stop];
        }
        self.audioRecorder = nil;
    } @catch (NSException *exception) {
        NSLog(@"⚠️ 停止录音器异常: %@", exception.reason);
    }
    
    // 清理音频引擎
    self.audioEngine = nil;
    self.speechRecognizer = nil;
}

@end
