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

@interface CreateVoiceViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *chooseImageBtn;
@property (weak, nonatomic) IBOutlet UIButton *speekBtn;
@property (weak, nonatomic) IBOutlet UILabel *voiceTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *speekLabel;
@property (weak, nonatomic) IBOutlet UIButton *deletPickImageBtn;

// 语音识别相关
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) AVAudioEngine *audioEngine;

// 录音计时
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, assign) NSInteger remainingTime;
@property (nonatomic, assign) NSInteger recordedTime;
@property (nonatomic, assign) BOOL isRecording;

@end

@implementation CreateVoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"创建音色";
    self.view.backgroundColor = [UIColor colorWithRed:0xF6/255.0 green:0xF7/255.0 blue:0xFB/255.0 alpha:1.0];
    
    // 初始时隐藏删除按钮
    self.deletPickImageBtn.hidden = YES;
    [self.deletPickImageBtn addTarget:self action:@selector(deletPickImage) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupNavigationBar];
    [self setupButtons];
    [self setupSpeechRecognizer];
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
    
    // 设置录音按钮（长按手势）
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.1;
    [self.speekBtn addGestureRecognizer:longPress];
}

- (void)setupSpeechRecognizer {
    // 初始化语音识别器（中文）
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

- (void)saveButtonTapped:(UIButton *)sender {
    // 保存功能实现
    NSLog(@"保存按钮被点击");
    // TODO: 实现保存逻辑
}

- (void)chooseImageButtonTapped:(UIButton *)sender {
    // 检查相册权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        [self presentImagePicker];
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    [self presentImagePicker];
                } else {
                    [self showPhotoAccessDeniedAlert];
                }
            });
        }];
    } else {
        [self showPhotoAccessDeniedAlert];
    }
}

- (void)presentImagePicker {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)showPhotoAccessDeniedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法访问相册"
                                                                   message:@"请在设置中允许访问相册"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 删除选中的图片，恢复默认状态
- (void)deletPickImage {
    // 恢复默认图片
    UIImage *defaultImage = [UIImage imageNamed:@"create_ad"];
    [self.chooseImageBtn setImage:defaultImage forState:UIControlStateNormal];
    [self.chooseImageBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    // 隐藏删除按钮
    self.deletPickImageBtn.hidden = YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    if (!selectedImage) {
        selectedImage = info[UIImagePickerControllerOriginalImage];
    }
    
    if (selectedImage) {
        // 更新按钮图片
        [self.chooseImageBtn setImage:selectedImage forState:UIControlStateNormal];
        // 清空默认背景图片
        [self.chooseImageBtn setBackgroundImage:nil forState:UIControlStateNormal];
        // 显示删除按钮
        self.deletPickImageBtn.hidden = NO;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Speech Recognition

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
    [audioSession setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionDuckOthers error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    if (error) {
        NSLog(@"音频会话配置失败: %@", error);
        return;
    }
    
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
                strongSelf.voiceTextLabel.text = result.bestTranscription.formattedString;
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
    self.speekLabel.text = @"录音中，松开结束录音（5s）";
    
    // 启动计时器
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRecordingTime) userInfo:nil repeats:YES];
}

- (void)updateRecordingTime {
    self.recordedTime++;
    self.remainingTime--;
    
    if (self.remainingTime > 0) {
        self.speekLabel.text = [NSString stringWithFormat:@"录音中，松开结束录音（%lds）", (long)self.remainingTime];
    } else {
        // 时间到，自动停止
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
        [self showAlert:@"录音时间太短，至少需要5秒"];
        [self resetRecordingState];
        return;
    }
    
    // 停止音频引擎和识别
    [self.audioEngine stop];
    [self.recognitionRequest endAudio];
    
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

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
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
}

@end
