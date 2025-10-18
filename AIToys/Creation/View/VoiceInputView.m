//
//  VoiceInputView.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "VoiceInputView.h"
#import <Masonry/Masonry.h>
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>

@interface VoiceInputView () <AVAudioRecorderDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, assign) VoiceInputState currentState;
@property (nonatomic, copy) VoiceInputCompletionBlock completionBlock;
@property (nonatomic, copy) VoiceInputCancelBlock cancelBlock;

@property (nonatomic, strong) NSString *recognizedText;

// Speech Recognition
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) AVAudioInputNode *audioInputNode;

@end

@implementation VoiceInputView

#pragma mark - 初始化

- (instancetype)initWithCompletionBlock:(VoiceInputCompletionBlock)completionBlock
                            cancelBlock:(VoiceInputCancelBlock)cancelBlock {
    if (self = [super init]) {
        self.completionBlock = completionBlock;
        self.cancelBlock = cancelBlock;
        self.currentState = VoiceInputStateReady;
        self.recognizedText = @"";
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)dealloc {
    [self cleanupAudio];
}

#pragma mark - UI设置

- (void)setupUI {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    // 背景遮罩
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.backgroundView.alpha = 0;
    [self addSubview:self.backgroundView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self
                                         action:@selector(backgroundTapped)];
    [self.backgroundView addGestureRecognizer:tapGesture];
    
    // 容器
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 20;
    self.containerView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    [self addSubview:self.containerView];
    
    // 文本显示
    self.contentTextView = [[UITextView alloc] init];
    self.contentTextView.backgroundColor = [UIColor clearColor];
    self.contentTextView.font = [UIFont systemFontOfSize:16];
    self.contentTextView.textColor = [UIColor blackColor];
    self.contentTextView.text = @"请说话...";
    self.contentTextView.editable = NO;
    self.contentTextView.scrollEnabled = YES;
    [self.containerView addSubview:self.contentTextView];
    
    // 麦克风按钮
    self.voiceButton = [[UIButton alloc] init];
    self.voiceButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    self.voiceButton.layer.cornerRadius = 40;
    [self.voiceButton setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
    [self.voiceButton setTintColor:[UIColor whiteColor]];
    [self.voiceButton addTarget:self action:@selector(voiceButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.voiceButton];
    
    // 取消按钮
    self.cancelButton = [[UIButton alloc] init];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.cancelButton];
    
    // 状态标签
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"按住说话";
    self.statusLabel.textColor = [UIColor grayColor];
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    [self.containerView addSubview:self.statusLabel];
}

- (void)setupConstraints {
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(400);
    }];
    
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(20);
        make.left.mas_equalTo(self.containerView).offset(20);
        make.right.mas_equalTo(self.containerView).offset(-20);
        make.height.mas_equalTo(200);
    }];
    
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.top.mas_equalTo(self.contentTextView.mas_bottom).offset(20);
        make.width.height.mas_equalTo(80);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.containerView).offset(20);
        make.top.mas_equalTo(self.voiceButton.mas_bottom).offset(20);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(44);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.centerY.equalTo(self.cancelButton);
    }];
}

#pragma mark - 公共方法

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [keyWindow addSubview:self];
    
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(400);
    }];
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 1;
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self).offset(0);
        }];
        [self layoutIfNeeded];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 0;
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self).offset(400);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)updateRecognizedText:(NSString *)text {
    self.recognizedText = text ?: @"";
    
    if (self.recognizedText.length == 0) {
        self.contentTextView.text = @"请说话...";
        self.contentTextView.textColor = [UIColor grayColor];
    } else {
        self.contentTextView.text = self.recognizedText;
        self.contentTextView.textColor = [UIColor blackColor];
        
        if (self.contentTextView.text.length > 0) {
            NSRange bottom = NSMakeRange(self.contentTextView.text.length - 1, 1);
            [self.contentTextView scrollRangeToVisible:bottom];
        }
    }
}

- (void)switchToState:(VoiceInputState)state {
    self.currentState = state;
    
    switch (state) {
        case VoiceInputStateReady:
            [self.voiceButton setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
            self.statusLabel.text = @"按住说话";
            [self updateRecognizedText:@""];
            break;
            
        case VoiceInputStateRecording:
            self.statusLabel.text = @"正在录音中...";
            break;
            
        case VoiceInputStateCompleted:
            [self.voiceButton setImage:[UIImage systemImageNamed:@"checkmark"] forState:UIControlStateNormal];
            self.statusLabel.text = @"点击完成";
            break;
    }
}

#pragma mark - 按钮事件

- (void)voiceButtonTapped {
    switch (self.currentState) {
        case VoiceInputStateReady:
            [self checkAndStartRecording];
            break;
            
        case VoiceInputStateRecording:
            [self stopRecording];
            break;
            
        case VoiceInputStateCompleted:
            if (self.completionBlock) {
                self.completionBlock(self.recognizedText);
            }
            [self dismiss];
            break;
    }
}

- (void)cancelButtonTapped {
    [self stopRecording];
    
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self dismiss];
}

- (void)backgroundTapped {
    [self cancelButtonTapped];
}

#pragma mark - 语音识别

- (void)checkAndStartRecording {
    // 检查权限
    SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
    
    if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus authStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (authStatus == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                    [self startRecording];
                } else {
                    [self showPermissionDeniedAlert];
                }
            });
        }];
    } else if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
        [self startRecording];
    } else {
        [self showPermissionDeniedAlert];
    }
}

- (void)startRecording {
    NSLog(@"💬 开始语音识别");
    
    // 清理之前的任务
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    // 初始化语音识别器
    if (!self.speechRecognizer) {
        self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    }
    
    if (!self.speechRecognizer.isAvailable) {
        [self showAlert:@"语音识别不可用"];
        return;
    }
    
    // 配置音频会话
    NSError *audioError = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    if (![audioSession setCategory:AVAudioSessionCategoryRecord
                       withOptions:AVAudioSessionCategoryOptionDuckOthers
                             error:&audioError]) {
        NSLog(@"❌ 音频会话类别设置失败: %@", audioError);
        [self showAlert:@"音频配置失败"];
        return;
    }
    
    if (![audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&audioError]) {
        NSLog(@"❌ 音频会话激活失败: %@", audioError);
        [self showAlert:@"音频激活失败"];
        return;
    }
    
    // 初始化音频引擎
    if (!self.audioEngine) {
        self.audioEngine = [[AVAudioEngine alloc] init];
    }
    
    // 创建识别请求
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    self.recognitionRequest.shouldReportPartialResults = YES;
    
    self.audioInputNode = self.audioEngine.inputNode;
    
    // 启动识别任务
    __weak typeof(self) weakSelf = self;
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest
                                                               resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        BOOL isFinal = NO;
        
        if (result) {
            NSString *recognizedText = result.bestTranscription.formattedString;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf updateRecognizedText:recognizedText];
            });
            isFinal = result.isFinal;
            NSLog(@"📝 识别文本: %@, 完成: %@", recognizedText, @(isFinal));
        }
        
        if (error) {
            NSLog(@"❌ 识别错误: %@", error.localizedDescription);
        }
        
        if (isFinal || error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf finishRecording];
            });
        }
    }];
    
    // 准备音频引擎
    NSError *engineError = nil;
    if (![self.audioEngine startAndReturnError:&engineError]) {
        NSLog(@"❌ 音频引擎启动失败: %@", engineError);
        [self showAlert:@"音频引擎启动失败"];
        return;
    }
    
    // 获取音频格式
    AVAudioFormat *format = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:audioSession.sampleRate channels:1];
    
    NSLog(@"🎙️ 使用音频格式 - 采样率: %.0f Hz, 声道数: %u", format.sampleRate, format.channelCount);
    
    // 安装音频tap
    [self.audioInputNode installTapOnBus:0 bufferSize:1024 format:format block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [weakSelf.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [self switchToState:VoiceInputStateRecording];
}

- (void)stopRecording {
    NSLog(@"⏹️ 停止语音识别");
    [self.recognitionRequest endAudio];
    [self finishRecording];
}

- (void)finishRecording {
    // 清理音频引擎
    [self cleanupAudio];
    
    // 更新UI
    if (self.recognizedText.length > 0) {
        [self switchToState:VoiceInputStateCompleted];
    } else {
        [self switchToState:VoiceInputStateReady];
    }
}

- (void)cleanupAudio {
    if (self.audioEngine.isRunning) {
        NSError *error = nil;
        [self.audioEngine stop];
        [self.audioEngine reset];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    }
    
    if (self.audioInputNode) {
        [self.audioInputNode removeTapOnBus:0];
    }
}

#pragma mark - 提示框

- (void)showPermissionDeniedAlert {
    [self showAlert:@"需要麦克风权限\n请在设置-隐私中允许本应用访问麦克风"];
}

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self dismiss];
    }]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alert animated:YES completion:nil];
}

@end
