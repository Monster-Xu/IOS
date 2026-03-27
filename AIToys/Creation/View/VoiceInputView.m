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

@interface VoiceInputView () <AVAudioRecorderDelegate, CAAnimationDelegate>

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

// 波纹效果属性
@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *rippleLayers;
@property (nonatomic, strong) NSTimer *rippleTimer;
@property (nonatomic, strong) UIColor *rippleColor;
@property (nonatomic, assign) CGFloat maxRippleRadius;
@property (nonatomic, assign) NSTimeInterval rippleAnimationDuration;

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
        
        // 初始化波纹效果属性
        self.rippleLayers = [NSMutableArray array];
        self.rippleColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
        self.rippleAnimationDuration = 1.5;
        self.maxRippleRadius = 120;
        
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)dealloc {
    [self cleanupAudio];
    [self stopRippleAnimation];
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
    self.contentTextView.text = LocalString(@"请输入故事主要情节...");
    self.contentTextView.editable = NO;
    self.contentTextView.scrollEnabled = YES;
    [self.containerView addSubview:self.contentTextView];
    
    // 麦克风按钮
    self.voiceButton = [[UIButton alloc] init];
    self.voiceButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    self.voiceButton.layer.cornerRadius = 40;
    self.voiceButton.clipsToBounds = NO; // 允许波纹超出按钮边界
    [self.voiceButton setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
    [self.voiceButton setTintColor:[UIColor whiteColor]];
    
    // ✅ 修改为按住录音模式
    [self.voiceButton addTarget:self action:@selector(voiceButtonPressed) forControlEvents:UIControlEventTouchDown];
    [self.voiceButton addTarget:self action:@selector(voiceButtonReleased) forControlEvents:UIControlEventTouchUpInside];
    [self.voiceButton addTarget:self action:@selector(voiceButtonReleased) forControlEvents:UIControlEventTouchUpOutside];
    [self.voiceButton addTarget:self action:@selector(voiceButtonReleased) forControlEvents:UIControlEventTouchCancel];
    
    [self.containerView addSubview:self.voiceButton];
    
    // 取消按钮 - 图片+文字样式
    self.cancelButton = [[UIButton alloc] init];
    [self.cancelButton setImage:[UIImage imageNamed:@"取消"] forState:UIControlStateNormal];
    [self.cancelButton setTitle:LocalString(@"取消") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.cancelButton];
    
    // 状态标签
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = LocalString(@"按住说话");
    self.statusLabel.textColor = [UIColor grayColor];
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    [self.containerView addSubview:self.statusLabel];
}

- (void)setupConstraints {
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(400);
    }];
    
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(20);
        make.leading.mas_equalTo(self.containerView).offset(20);
        make.trailing.mas_equalTo(self.containerView).offset(-20);
        make.height.mas_equalTo(200);
    }];
    
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.top.mas_equalTo(self.contentTextView.mas_bottom).offset(20);
        make.width.height.mas_equalTo(80);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.voiceButton.mas_leading).offset(-50);
        make.centerY.equalTo(self.voiceButton);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(80);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.top.mas_equalTo(self.voiceButton.mas_bottom).offset(20);
        make.height.mas_equalTo(44);
    }];
    
    // 设置取消按钮的图片和文字布局
    [self setupCancelButtonLayout];
}

- (void)setupCancelButtonLayout {
    // 需要在布局完成后设置，确保能获取到正确的尺寸
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize imageSize = self.cancelButton.imageView.frame.size;
        CGSize titleSize = [self.cancelButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.cancelButton.titleLabel.font}];
        
        // 计算偏移量，实现图片在上文字在下的效果
        CGFloat spacing = 5.0; // 图片和文字之间的间距
        
        self.cancelButton.titleEdgeInsets = UIEdgeInsetsMake(imageSize.height + spacing, -imageSize.width, 0, 0);
        self.cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, titleSize.height + spacing, -titleSize.width);
    });
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
        self.contentTextView.text = LocalString(@"请输入故事主要情节...");
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
    
    // ✅ 先移除所有事件，避免重复绑定
    [self.voiceButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    switch (state) {
        case VoiceInputStateReady:
            [self.voiceButton setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
            self.statusLabel.text = LocalString(@"按住说话");
            [self updateRecognizedText:@""];
            
            // 显示取消按钮
            self.cancelButton.hidden = NO;
            
            // 重新绑定按住录音事件
            [self.voiceButton addTarget:self action:@selector(voiceButtonPressed) forControlEvents:UIControlEventTouchDown];
            [self.voiceButton addTarget:self action:@selector(voiceButtonReleased) forControlEvents:UIControlEventTouchUpInside];
            [self.voiceButton addTarget:self action:@selector(voiceButtonReleased) forControlEvents:UIControlEventTouchUpOutside];
            [self.voiceButton addTarget:self action:@selector(voiceButtonReleased) forControlEvents:UIControlEventTouchCancel];
            break;
            
        case VoiceInputStateRecording:
            [self.voiceButton setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
            self.statusLabel.text = LocalString(@"录音中...松开结束");
            
            // 隐藏取消按钮
            self.cancelButton.hidden = YES;
            
            // 保持按住录音事件
            [self.voiceButton addTarget:self action:@selector(voiceButtonPressed) forControlEvents:UIControlEventTouchDown];
            [self.voiceButton addTarget:self action:@selector(voiceButtonReleased) forControlEvents:UIControlEventTouchUpInside];
            [self.voiceButton addTarget:self action:@selector(voiceButtonReleased) forControlEvents:UIControlEventTouchUpOutside];
            [self.voiceButton addTarget:self action:@selector(voiceButtonReleased) forControlEvents:UIControlEventTouchCancel];
            break;
            
        case VoiceInputStateCompleted:
            [self.voiceButton setImage:[UIImage systemImageNamed:@"checkmark"] forState:UIControlStateNormal];
            self.statusLabel.text = LocalString(@"点击完成");
            
            // 显示取消按钮
            self.cancelButton.hidden = NO;
            
            // 只绑定点击事件用于完成确认
            [self.voiceButton addTarget:self action:@selector(voiceButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            break;
    }
}

#pragma mark - 按钮事件

/// ✅ 按下麦克风按钮 - 开始录音
- (void)voiceButtonPressed {
    NSLog(@"🎤 按下麦克风按钮");
    
    // 视觉反馈 - 只缩放，不变色
    [UIView animateWithDuration:0.1 animations:^{
        self.voiceButton.transform = CGAffineTransformMakeScale(0.95, 0.95);
    }];
    
    // 开始波纹动画
    [self startRippleAnimation];
    
    [self checkAndStartRecording];
}

/// ✅ 释放麦克风按钮 - 停止录音
- (void)voiceButtonReleased {
    NSLog(@"🎤 释放麦克风按钮");
    
    // 恢复按钮外观 - 只恢复尺寸
    [UIView animateWithDuration:0.2 animations:^{
        self.voiceButton.transform = CGAffineTransformIdentity;
    }];
    
    // 停止波纹动画
    [self stopRippleAnimation];
    
    if (self.currentState == VoiceInputStateRecording) {
        [self stopRecording];
    }
}

/// ✅ 保留原来的点击方法用于完成确认
- (void)voiceButtonTapped {
    // 只在完成状态下处理点击事件
    if (self.currentState == VoiceInputStateCompleted) {
        if (self.completionBlock) {
            self.completionBlock(self.recognizedText);
        }
        [self dismiss];
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
        [self showAlert:LocalString(@"语音识别不可用")];
        return;
    }
    
    // 配置音频会话
    NSError *audioError = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    if (![audioSession setCategory:AVAudioSessionCategoryRecord
                       withOptions:AVAudioSessionCategoryOptionDuckOthers
                             error:&audioError]) {
        NSLog(@"❌ 音频会话类别设置失败: %@", audioError);
        [self showAlert:LocalString(@"音频配置失败")];
        return;
    }
    
    if (![audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&audioError]) {
        NSLog(@"❌ 音频会话激活失败: %@", audioError);
        [self showAlert:LocalString(@"音频激活失败")];
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
        [self showAlert:LocalString(@"音频引擎启动失败")];
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
        
        // ✅ 如果没有识别到内容，提示用户
        self.statusLabel.text = LocalString(@"未识别到内容，请重试。");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.currentState == VoiceInputStateReady) {
                self.statusLabel.text = LocalString(@"按住说话");
            }
        });
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
    [self showAlert:LocalString(@"需要麦克风权限。\n请在“设置-隐私”中允许本应用访问麦克风。")];
}

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalString(@"提示")
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:LocalString(@"确定")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self dismiss];
    }]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 波纹动画效果

- (void)startRippleAnimation {
    // 立即创建第一个波纹
    [self createRipple];
    
    // 设置定时器持续创建波纹
    self.rippleTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(createRipple) userInfo:nil repeats:YES];
}

- (void)stopRippleAnimation {
    [self.rippleTimer invalidate];
    self.rippleTimer = nil;
    
    // 移除所有波纹图层
    for (CAShapeLayer *layer in self.rippleLayers) {
        [layer removeFromSuperlayer];
    }
    [self.rippleLayers removeAllObjects];
}

- (void)createRipple {
    CAShapeLayer *rippleLayer = [CAShapeLayer layer];
    
    // 获取按钮在容器视图中的中心点
    CGPoint buttonCenterInContainer = CGPointMake(
        CGRectGetMidX(self.voiceButton.frame),
        CGRectGetMidY(self.voiceButton.frame)
    );
    
    CGFloat initialRadius = CGRectGetWidth(self.voiceButton.frame) / 2.0;
    
    // 以(0,0)为中心创建路径，稍后通过position属性定位
    UIBezierPath *initialPath = [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                               radius:initialRadius
                                                           startAngle:0
                                                             endAngle:M_PI * 2
                                                            clockwise:YES];
    
    UIBezierPath *finalPath = [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                             radius:self.maxRippleRadius
                                                         startAngle:0
                                                           endAngle:M_PI * 2
                                                          clockwise:YES];
    
    rippleLayer.path = initialPath.CGPath;
    rippleLayer.fillColor = [UIColor clearColor].CGColor;
    rippleLayer.strokeColor = self.rippleColor.CGColor;
    rippleLayer.lineWidth = 2.0;
    rippleLayer.opacity = 0.8;
    
    // 设置波纹图层的位置为按钮中心
    rippleLayer.position = buttonCenterInContainer;
    
    // 将波纹添加到容器视图，确保在按钮下方
    [self.containerView.layer insertSublayer:rippleLayer below:self.voiceButton.layer];
    
    [self.rippleLayers addObject:rippleLayer];
    
    // 创建动画组
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = self.rippleAnimationDuration;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    
    // 路径动画（扩散）
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (__bridge id)initialPath.CGPath;
    pathAnimation.toValue = (__bridge id)finalPath.CGPath;
    
    // 透明度动画（渐隐）
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @0.8;
    opacityAnimation.toValue = @0.0;
    
    // 线宽动画（变细）
    CABasicAnimation *lineWidthAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    lineWidthAnimation.fromValue = @2.0;
    lineWidthAnimation.toValue = @0.5;
    
    animationGroup.animations = @[pathAnimation, opacityAnimation, lineWidthAnimation];
    
    // 动画完成后移除图层
    animationGroup.delegate = self;
    [rippleLayer setValue:rippleLayer forKey:@"rippleLayer"];
    
    [rippleLayer addAnimation:animationGroup forKey:@"ripple"];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        CAShapeLayer *rippleLayer = [anim valueForKey:@"rippleLayer"];
        if (rippleLayer) {
            [rippleLayer removeFromSuperlayer];
            [self.rippleLayers removeObject:rippleLayer];
        }
    }
}

@end
