//
//  VoiceInputView.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "VoiceInputView.h"
#import <Masonry/Masonry.h>

@interface VoiceInputView ()

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

@end

@implementation VoiceInputView

#pragma mark - 初始化方法

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

#pragma mark - UI设置

- (void)setupUI {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    // 背景遮罩
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.backgroundView.alpha = 0;
    [self addSubview:self.backgroundView];
    
    // 点击背景关闭
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.backgroundView addGestureRecognizer:tapGesture];
    
    // 容器视图
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 20;
    self.containerView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner; // 只有顶部圆角
    [self addSubview:self.containerView];
    
    // 文本显示区域
    self.contentTextView = [[UITextView alloc] init];
    self.contentTextView.backgroundColor = [UIColor clearColor];
    self.contentTextView.font = [UIFont systemFontOfSize:16];
    self.contentTextView.textColor = [UIColor blackColor];
    self.contentTextView.text = @"请说话...";
    self.contentTextView.textAlignment = NSTextAlignmentLeft;
    self.contentTextView.editable = NO;
    self.contentTextView.scrollEnabled = YES;
    self.contentTextView.showsVerticalScrollIndicator = YES;
    [self.containerView addSubview:self.contentTextView];
    
    // 语音按钮
    self.voiceButton = [[UIButton alloc] init];
    self.voiceButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0]; // 蓝色
    self.voiceButton.layer.cornerRadius = 40; // 80pt直径，40pt半径
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
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
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
        make.height.mas_equalTo(44);
    }];
}

#pragma mark - 公共方法

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [keyWindow addSubview:self];
    
    // 初始位置：容器在屏幕底部
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(400);
    }];
    [self layoutIfNeeded];
    
    // 动画显示
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundView.alpha = 1;
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self).offset(0);
        }];
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
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
        
        // 滚动到底部
        if (self.contentTextView.text.length > 0) {
            NSRange bottom = NSMakeRange(self.contentTextView.text.length - 1, 1);
            [self.contentTextView scrollRangeToVisible:bottom];
        }
    }
}

- (void)switchToState:(VoiceInputState)state {
    self.currentState = state;
    
    switch (state) {
        case VoiceInputStateReady: {
            [self.voiceButton setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
            self.statusLabel.text = @"按住说话";
            [self updateRecognizedText:@""];
            break;
        }
        case VoiceInputStateRecording: {
            [self.voiceButton setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
            self.statusLabel.text = @"按住说话";
            // 录音中可能会实时更新识别文本
            break;
        }
        case VoiceInputStateCompleted: {
            [self.voiceButton setImage:[UIImage systemImageNamed:@"checkmark"] forState:UIControlStateNormal];
            self.statusLabel.text = @"点击完成";
            break;
        }
    }
}

#pragma mark - 按钮事件

- (void)voiceButtonTapped {
    switch (self.currentState) {
        case VoiceInputStateReady: {
            // 开始录音
            [self switchToState:VoiceInputStateRecording];
            [self startRecording];
            break;
        }
        case VoiceInputStateRecording: {
            // 停止录音并处理识别结果
            [self stopRecording];
            break;
        }
        case VoiceInputStateCompleted: {
            // 完成语音输入
            if (self.completionBlock) {
                self.completionBlock(self.recognizedText);
            }
            [self dismiss];
            break;
        }
    }
}

- (void)cancelButtonTapped {
    if (self.currentState == VoiceInputStateRecording) {
        [self stopRecording];
    }
    
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self dismiss];
}

- (void)backgroundTapped {
    [self cancelButtonTapped];
}

#pragma mark - 录音控制

- (void)startRecording {
    // 这里应该实现真实的语音识别功能
    // 目前使用模拟数据
    NSLog(@"开始录音...");
    
    // 模拟逐渐识别文字的过程
    [self performSelector:@selector(simulateRecognition1) withObject:nil afterDelay:1.0];
}

- (void)stopRecording {
    // 停止语音识别
    NSLog(@"停止录音");
    
    // 取消所有延迟执行
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (self.recognizedText.length > 0) {
        [self switchToState:VoiceInputStateCompleted];
    } else {
        [self switchToState:VoiceInputStateReady];
    }
}

#pragma mark - 模拟语音识别（用于演示）

- (void)simulateRecognition1 {
    [self updateRecognizedText:@"内容内容内容"];
    [self performSelector:@selector(simulateRecognition2) withObject:nil afterDelay:1.0];
}

- (void)simulateRecognition2 {
    [self updateRecognizedText:@"内容内容内容内容内容内容内容内容内容内容"];
    [self performSelector:@selector(simulateRecognition3) withObject:nil afterDelay:1.0];
}

- (void)simulateRecognition3 {
    [self updateRecognizedText:@"内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容"];
    [self performSelector:@selector(simulateRecognitionComplete) withObject:nil afterDelay:1.0];
}

- (void)simulateRecognitionComplete {
    [self stopRecording];
}

@end
