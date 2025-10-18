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

@interface CreateVoiceViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *chooseImageBtn;
@property (weak, nonatomic) IBOutlet UIButton *speekBtn;
@property (weak, nonatomic) IBOutlet UILabel *voiceTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *speekLabel;
@property (weak, nonatomic) IBOutlet UIButton *deletPickImageBtn;
@property (weak, nonatomic) IBOutlet UITextField *voiceNameTextView;

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

@end

@implementation CreateVoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"创建音色";
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    
    // 初始时隐藏删除按钮
    self.deletPickImageBtn.hidden = YES;
    [self.deletPickImageBtn addTarget:self action:@selector(deletPickImage) forControlEvents:UIControlEventTouchUpInside];
    
    // 初始化状态
    self.isUploading = NO;
    self.isCloningVoice = NO;
    
    [self setupNavigationBar];
    [self setupButtons];
    [self setupSpeechRecognizer];
    [self setupVoiceTextLabel];
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
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [saveBtn addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
}

- (void)setupButtons {
    // 设置图片选择按钮
    [self.chooseImageBtn addTarget:self action:@selector(chooseImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.chooseImageBtn.clipsToBounds = YES;
    self.chooseImageBtn.contentMode = UIViewContentModeScaleAspectFill;
    
    // 设置录音按钮(长按手势)
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.1;
    [self.speekBtn addGestureRecognizer:longPress];
}

- (void)setupVoiceTextLabel {
    // 设置label的基本属性
    self.voiceTextLabel.numberOfLines = 0;
    self.voiceTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.voiceTextLabel.textAlignment = NSTextAlignmentLeft;
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
    
    // 创建高度约束，初始高度为50
    self.voiceTextLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.voiceTextLabel
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:50];
    [self.voiceTextLabel addConstraint:self.voiceTextLabelHeightConstraint];
    
    // 创建placeholder label
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.text = @"这里可以显示您录音的语音转换";
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

#pragma mark - Button Actions

/// ⭐ 保存按钮点击事件 - 包含参数验证和声音克隆流程
- (void)saveButtonTapped:(UIButton *)sender {
    NSLog(@"=== 开始创建声音流程 ===");
    
    // Step 1: 参数验证
    NSString *validationError = [self validateCreateVoiceParameters];
    if (validationError) {
        [self showAlert:validationError];
        return;
    }
    
    NSLog(@"✅ 参数验证通过");
    
    // Step 2: 检查是否需要上传音频
    if (self.audioFileURL && !self.uploadedAudioFileUrl) {
        // 需要先上传音频文件
        [self uploadAudioAndStartVoiceCloning];
    } else if (self.uploadedAudioFileUrl) {
        // 音频已上传，直接开始克隆
        [self startVoiceCloning];
    } else {
        [self showAlert:@"请先录制音频"];
    }
}

/// ⭐ 参数验证方法
- (NSString *)validateCreateVoiceParameters {
    // 1. 检查声音名称
    if (!self.voiceName || self.voiceName.length == 0) {
        // 尝试从 voiceTextLabel 获取
        NSString *text = self.voiceNameTextView.text;
        if (!text || text.length == 0) {
            return @"请输入声音名称或进行语音录制";
        }
        self.voiceName = text;
    }
    
    // 2. 检查插画URL
    if (!self.selectedAvatarUrl || self.selectedAvatarUrl.length == 0) {
        return @"请选择插画头像";
    }
    
    // 3. 检查录音文件
    if (!self.audioFileURL && !self.uploadedAudioFileUrl) {
        return @"请先录制音频";
    }
    
    // 4. 检查录音时长
    if (self.recordedTime < 5) {
        return @"录音时间不足5秒";
    }
    
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
        [self showAlert:@"正在上传中，请稍候"];
        return;
    }
    
    self.isUploading = YES;
    
    // 显示上传进度
    [SVProgressHUD showWithStatus:@"上传音频中..."];
    
    // 调用音频上传接口
    [[AFStoryAPIManager sharedManager]uploadAudioFile:self.audioFileURL.path voiceName:self.voiceName progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat progress = uploadProgress.fractionCompleted;
            NSLog(@"上传进度: %.0f%%", progress * 100);
            [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:@"上传中... %.0f%%", progress * 100]];
        });
        } success:^(NSDictionary * _Nonnull data) {
            // ✅ 上传成功，保存返回的URL
            NSLog(@"✅ 音频上传成功!");
            NSLog(@"   返回的文件: %@", data);
        
            self.uploadedAudioFileUrl = [data objectForKey:@"audioFileUrl"];
            self.uploadedFileId = [[data objectForKey:@"fileId"] intValue];
            
//            NSLog(@"   提取的文件ID: %ld", (long)self.uploadedFileId);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isUploading = NO;
                [SVProgressHUD dismiss];
                
                // 上传成功后，继续克隆声音
                NSLog(@"\n🎤 上传完成，准备开始克隆声音...");
                [self startVoiceCloning];
            });
        } failure:^(NSError * _Nonnull error) {
            // ❌ 上传失败
            NSLog(@"❌ 音频上传失败!");
            NSLog(@"   错误信息: %@", error.localizedDescription);
            NSLog(@"   错误代码: %ld", (long)error.code);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isUploading = NO;
                [SVProgressHUD dismiss];
                [self showAlert:[NSString stringWithFormat:@"上传失败: %@", error.localizedDescription]];
            });
        }];
    
    
    
}

/// ⭐ 开始声音克隆
- (void)startVoiceCloning {
    NSLog(@"\n🎬 开始创建声音（克隆）...");
    
    if (self.isCloningVoice) {
        [self showAlert:@"正在克隆中，请稍候"];
        return;
    }
    
    // 检查必要参数
    if (!self.uploadedAudioFileUrl || self.uploadedAudioFileUrl.length == 0) {
        [self showAlert:@"音频文件URL不存在"];
        return;
    }
    
    self.isCloningVoice = YES;
    [SVProgressHUD showWithStatus:@"正在克隆声音..."];
    
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
            
            // 显示成功信息
            [self showSuccessAlertWithMessage:@"声音克隆已启动！\n\n系统正在后台处理您的声音，\n请稍候片刻后刷新查看进度。"];
            
            // 延迟一秒后返回前一个页面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
        
    } failure:^(NSError *error) {
        // ❌ 声音创建失败
        NSLog(@"\n❌ 声音克隆失败!");
        NSLog(@"   错误信息: %@", error.localizedDescription);
        NSLog(@"   错误代码: %ld", (long)error.code);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isCloningVoice = NO;
            [SVProgressHUD dismiss];
            [self showAlert:[NSString stringWithFormat:@"创建声音失败: %@", error.localizedDescription]];
        });
    }];
}

- (void)chooseImageButtonTapped:(UIButton *)sender {
    SelectIllustrationVC *vc = [[SelectIllustrationVC alloc] init];
    
    // 设置回调
    vc.sureBlock = ^(NSString *imgUrl) {
        NSLog(@"选中的插画: %@", imgUrl);
        
        // 保存选中的插画URL
        self.selectedAvatarUrl = imgUrl;
        
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
    
    // 隐藏删除按钮
    self.deletPickImageBtn.hidden = YES;
    
    NSLog(@"✅ 插画已删除");
}

#pragma mark - Speech Recognition & Recording

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self startRecording];
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        [self stopRecording];
    }
}

- (void)startRecording {
    if (self.isRecording) {
        return;
    }
    
    // 检查语音识别权限
    if ([SFSpeechRecognizer authorizationStatus] != SFSpeechRecognizerAuthorizationStatusAuthorized) {
        [self showAlert:@"请在设置中允许语音识别权限"];
        return;
    }
    
    // 请求录音权限
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlert:@"请在设置中允许麦克风权限"];
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self beginRecordingSession];
        });
    }];
}

- (void)beginRecordingSession {
    // 取消之前的任务
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    // 配置音频会话
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    if (error) {
        NSLog(@"音频会话配置失败: %@", error);
        return;
    }
    
    // 设置录音文件路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *audioFileName = [NSString stringWithFormat:@"voice_recording_%@.m4a", [self currentTimestamp]];
    NSString *audioFilePath = [documentsPath stringByAppendingPathComponent:audioFileName];
    self.audioFileURL = [NSURL fileURLWithPath:audioFilePath];
    
    // 配置录音设置
    NSDictionary *recordSettings = @{
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVSampleRateKey: @(16000.0),
        AVNumberOfChannelsKey: @(1),
        AVEncoderAudioQualityKey: @(AVAudioQualityHigh)
    };
    
    // 初始化录音器
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.audioFileURL settings:recordSettings error:&error];
    
    if (error) {
        NSLog(@"录音器初始化失败: %@", error);
        return;
    }
    
    [self.audioRecorder prepareToRecord];
    [self.audioRecorder record];
    
    // 创建识别请求
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    self.recognitionRequest.shouldReportPartialResults = YES;
    
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    
    // 开始识别任务
    __weak typeof(self) weakSelf = self;
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (result) {
            // 更新识别的文本
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *recognizedText = result.bestTranscription.formattedString;
                strongSelf.voiceTextLabel.text = recognizedText;
                
                // 隐藏placeholder
                strongSelf.placeholderLabel.hidden = (recognizedText.length > 0);
                
                // 动态调整label高度
                [strongSelf updateVoiceTextLabelHeight:recognizedText];
            });
        }
        
        if (error || (result && result.isFinal)) {
            [strongSelf.audioEngine stop];
            [inputNode removeTapOnBus:0];
            strongSelf.recognitionRequest = nil;
            strongSelf.recognitionTask = nil;
        }
    }];
    
    // 配置音频输入
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [weakSelf.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    // 启动音频引擎
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
    
    if (error) {
        NSLog(@"音频引擎启动失败: %@", error);
        return;
    }
    
    // 更新UI状态
    self.isRecording = YES;
    self.remainingTime = 12;
    self.recordedTime = 0;
    self.speekLabel.text = @"录音中,松开结束录音(5s)";
    
    // 启动计时器
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRecordingTime) userInfo:nil repeats:YES];
}

- (void)updateVoiceTextLabelHeight:(NSString *)text {
    if (!text || text.length == 0) {
        // 文本为空时，恢复初始高度
        self.voiceTextLabelHeightConstraint.constant = 50;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        return;
    }
    
    // 计算文本所需高度
    CGFloat maxWidth = self.voiceTextLabel.frame.size.width - 24; // 减去左右内边距
    CGSize maxSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    
    NSDictionary *attributes = @{NSFontAttributeName: self.voiceTextLabel.font};
    CGRect textRect = [text boundingRectWithSize:maxSize
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attributes
                                         context:nil];
    
    // 计算实际高度（加上上下内边距）
    CGFloat calculatedHeight = ceil(textRect.size.height) + 24;
    
    // 限制高度范围：50-160
    CGFloat newHeight = MAX(50, MIN(160, calculatedHeight));
    
    // 更新高度约束
    if (self.voiceTextLabelHeightConstraint.constant != newHeight) {
        self.voiceTextLabelHeightConstraint.constant = newHeight;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)updateRecordingTime {
    self.recordedTime++;
    self.remainingTime--;
    
    if (self.remainingTime > 0) {
        self.speekLabel.text = [NSString stringWithFormat:@"录音中,松开结束录音(%lds)", (long)self.remainingTime];
    } else {
        // 时间到,自动停止
        [self stopRecording];
    }
}

- (void)stopRecording {
    if (!self.isRecording) {
        return;
    }
    
    // 停止计时器
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    
    // 检查录音时长
    if (self.recordedTime < 5) {
        [self showAlert:@"录音时间太短,至少需要5秒"];
        
        // 停止并删除录音文件
        [self.audioRecorder stop];
        [[NSFileManager defaultManager] removeItemAtURL:self.audioFileURL error:nil];
        self.audioFileURL = nil;
        
        [self resetRecordingState];
        return;
    }
    
    // 停止录音器
    [self.audioRecorder stop];
    
    // 停止音频引擎和识别
    [self.audioEngine stop];
    [self.recognitionRequest endAudio];
    
    // 输出录音文件地址
    if (self.audioFileURL) {
        NSLog(@"=== 录音完成 ===");
        NSLog(@"录音文件路径: %@", self.audioFileURL.path);
        NSLog(@"录音时长: %ld秒", (long)self.recordedTime);
        NSLog(@"文件大小: %.2f KB", [self getFileSizeInKB:self.audioFileURL]);
        NSLog(@"===============");
        
        // 在UI上显示提示
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showRecordingCompletedAlert];
        });
    }
    
    // 重置UI
    [self resetRecordingState];
}

- (void)resetRecordingState {
    self.isRecording = NO;
    self.speekLabel.text = @"按住开始录音";
    
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
        [self.audioEngine.inputNode removeTapOnBus:0];
    }
    
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    self.recognitionRequest = nil;
}

#pragma mark - Alert Methods

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showSuccessAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"成功"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showRecordingCompletedAlert {
    NSString *message = [NSString stringWithFormat:@"录音完成!\n\n文件路径:\n%@\n\n录音时长: %ld秒\n文件大小: %.2f KB",
                        self.audioFileURL.path,
                        (long)self.recordedTime,
                        [self getFileSizeInKB:self.audioFileURL]];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"录音完成"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Helper Methods



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
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
    }
    
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
    }
    
    if (self.audioRecorder && self.audioRecorder.isRecording) {
        [self.audioRecorder stop];
    }
}

@end
