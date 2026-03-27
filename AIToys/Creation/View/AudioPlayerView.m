//
//  AudioPlayerView.m
//  AIToys
//
//  Created by Assistant on 2025/10/17.
//

#import "AudioPlayerView.h"
#import <Masonry/Masonry.h>
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@interface AudioPlayerView () <AVAudioPlayerDelegate, UIGestureRecognizerDelegate>

// UI 组件
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIVisualEffectView *backgroundView;
@property (nonatomic, strong) UIImageView *coverImageView; // 封面图
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *previousButton; // 上一首按钮
@property (nonatomic, strong) UIButton *nextButton; // 下一首按钮
@property (nonatomic, strong) UIButton *closeButton; // 关闭按钮
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UILabel *timeLabel; // 合并的时间标签
@property (nonatomic, strong) MASConstraint *timeLabelCenterXConstraint; // 时间标签的X轴约束

// 移除流光动画相关属性

// 音频相关
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, copy) NSString *audioURL;
@property (nonatomic, copy) NSString *storyTitle;
@property (nonatomic, copy) NSString *coverImageURL;

// 下载控制
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, assign) BOOL isCancelledByUser; // 用户是否主动关闭

// 自定义位置相关
@property (nonatomic, assign) CGRect customFrame;
@property (nonatomic, assign) CGPoint customPosition;
@property (nonatomic, assign) BOOL useCustomFrame;

// 新增后台播放相关属性
@property (nonatomic, assign) BOOL isBackgroundAudioConfigured;
@property (nonatomic, strong) NSDictionary *nowPlayingInfo;
@property (nonatomic, assign) BOOL isBackgroundPlayMode; // 新增：是否为后台播放模式

// 新增拖动相关属性
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) CGPoint dragStartPoint;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

// 新增内部拖动相关属性
@property (nonatomic, assign) CGFloat dragResistanceEdge;    // 边缘阻力系数
@property (nonatomic, assign) CGFloat dragDecelerationRate;  // 减速系数
@property (nonatomic, assign) CGPoint lastPanPoint;         // 上一次拖动点
@property (nonatomic, strong) CADisplayLink *displayLink;   // 用于平滑动画的定时器

// 全局单例管理
@property (nonatomic, strong, class, readonly) NSMutableSet<AudioPlayerView *> *activePlayerInstances;

// 远程控制目标引用
@property (nonatomic, strong) id playCommandTarget;
@property (nonatomic, strong) id pauseCommandTarget;
@property (nonatomic, strong) id togglePlayPauseCommandTarget;
@property (nonatomic, strong) id previousTrackCommandTarget;
@property (nonatomic, strong) id nextTrackCommandTarget;

// 提示信息配置
@property (nonatomic, copy) NSString *previousButtonMessage;
@property (nonatomic, copy) NSString *nextButtonMessage;

@end

// 全局单例管理的实现
static NSMutableSet<AudioPlayerView *> *_activePlayerInstances = nil;

@implementation AudioPlayerView

#pragma mark - 全局单例管理

+ (NSMutableSet<AudioPlayerView *> *)activePlayerInstances {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _activePlayerInstances = [[NSMutableSet alloc] init];
    });
    return _activePlayerInstances;
}

// 停止所有其他播放器实例
+ (void)stopAllOtherPlayers:(AudioPlayerView *)currentPlayer {
    NSSet *instances = [self.activePlayerInstances copy]; // 创建副本以避免并发修改
    for (AudioPlayerView *player in instances) {
        if (player != currentPlayer) {
            NSLog(@"🛑 停止其他播放器实例");
            [player stop];
            [player removeRemoteTransportControls];
            [player removeFromSuperview];
            [self.activePlayerInstances removeObject:player];
        }
    }
}

// 注册播放器实例
- (void)registerInstance {
    [AudioPlayerView.activePlayerInstances addObject:self];
    NSLog(@"📝 注册播放器实例，当前总数: %lu", (unsigned long)AudioPlayerView.activePlayerInstances.count);
}

// 注销播放器实例
- (void)unregisterInstance {
    [self removeRemoteTransportControls];
    [AudioPlayerView.activePlayerInstances removeObject:self];
    NSLog(@"🗑️ 注销播放器实例，当前总数: %lu", (unsigned long)AudioPlayerView.activePlayerInstances.count);
}

#pragma mark - Initialization

- (instancetype)initWithAudioURL:(NSString *)audioURL storyTitle:(NSString *)title coverImageURL:(NSString *)coverImageURL {
    self = [super init];
    if (self) {
        // 停止所有其他播放器实例
        [AudioPlayerView stopAllOtherPlayers:self];
        
        self.audioURL = audioURL;
        self.storyTitle = title ?: LocalString(@"故事音频");
        self.coverImageURL = coverImageURL;
        self.isCancelledByUser = NO; // 初始化为未取消
        self.isBackgroundPlayMode = NO; // 默认不是后台播放模式
        
//        // 初始化提示信息
//        self.previousButtonMessage = @"已是第一首";
//        self.nextButtonMessage = @"已是最后一首";
        
        // 初始化拖动行为控制属性
        self.enableEdgeSnapping = NO;   // 默认不启用边缘吸附，允许自由拖动
        self.allowOutOfBounds = NO;     // 默认不允许超出边界
        self.enableFullScreenDrag = YES; // 默认启用全屏拖动
        
        // 初始化拖动参数
        self.dragResistanceEdge = 0.3;   // 边缘阻力系数
        self.dragDecelerationRate = 0.92; // 减速系数（0-1，越小减速越快）
        
        // 注册实例
        [self registerInstance];
        
        [self setupUI];
        [self setupAudioPlayer];
    }
    return self;
}

// 新增的后台播放初始化方法
- (instancetype)initWithAudioURL:(NSString *)audioURL backgroundPlay:(BOOL)backgroundPlay {
    self = [super init];
    if (self) {
        // 停止所有其他播放器实例
        [AudioPlayerView stopAllOtherPlayers:self];
        
        self.audioURL = audioURL;
        self.storyTitle = LocalString(@"故事音频");
        self.coverImageURL = nil;
        self.isCancelledByUser = NO;
        self.isBackgroundPlayMode = backgroundPlay;
        
//        // 初始化提示信息
//        self.previousButtonMessage = @"已是第一首";
//        self.nextButtonMessage = @"已是最后一首";
        
        // 注册实例
        [self registerInstance];
        
        if (!backgroundPlay) {
            // 如果不是后台播放模式，设置UI
            // 初始化拖动行为控制属性
            self.enableEdgeSnapping = NO;
            self.allowOutOfBounds = NO;
            self.enableFullScreenDrag = YES;
            
            // 初始化拖动参数
            self.dragResistanceEdge = 0.3;
            self.dragDecelerationRate = 0.92;
            
            [self setupUI];
        }
        
        [self setupAudioPlayer];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"🗑️ AudioPlayerView dealloc 开始");
    
    // 先移除远程控制，防止被保留
//    [self removeRemoteTransportControls];
    
    // 注销实例
    [self unregisterInstance];
    
    [self.progressTimer invalidate];
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    [self.downloadTask cancel]; // 取消下载任务
    
    // 停止显示链
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    
    // 移除手势和通知观察者
    if (self.panGesture) {
        [self.backgroundView removeGestureRecognizer:self.panGesture];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 清除系统播放器信息和远程控制
//    [self clearNowPlayingInfo];
    
    NSLog(@"🗑️ AudioPlayerView 已销毁");
}

#pragma mark - Setup Methods

- (void)setupUI {
    // 如果是后台播放模式，跳过UI创建
    if (self.isBackgroundPlayMode) {
        NSLog(@"🎵 后台播放模式，跳过UI创建");
        return;
    }
    
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor]; // 透明背景，不变黑
    self.alpha = 0;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    NSLog(@"🚀 setupUI - 屏幕尺寸: %.2f x %.2f", screenWidth, screenHeight);
    
    // 创建毛玻璃背景 - 横向胶囊形状
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
    self.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.backgroundView.layer.cornerRadius = 35; // 更大的圆角，形成胶囊形状
    self.backgroundView.clipsToBounds = YES;
    [self addSubview:self.backgroundView];
    
    // 容器视图
    self.containerView = self.backgroundView.contentView;
    
    // 设置浅灰色边框，始终保持显示
    self.backgroundView.layer.borderWidth = 2.0;
    self.backgroundView.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor;
    
    // 卡片悬浮效果
    self.backgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.backgroundView.layer.shadowOffset = CGSizeMake(0, 4);
    self.backgroundView.layer.shadowRadius = 12;
    self.backgroundView.layer.shadowOpacity = 0.3;
    
    [self setupCoverImageView];
    [self setupTitleLabel];
    [self setupProgressControls];
    [self setupControlButtons];
    [self setupConstraints];
    
    // 添加拖动手势
        [self setupDragGesture];
        
        // 添加手势
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [self addGestureRecognizer:tapGesture];
}

- (void)setupControlButtons {
    // 关闭按钮 - 右上角，使用自定义图片
        // 重要修改：将关闭按钮添加到 self 而不是 containerView
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *closeImage = [UIImage imageNamed:@"close_layer"];
        [self.closeButton setImage:closeImage forState:UIControlStateNormal];
        self.closeButton.tintColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
        self.closeButton.backgroundColor = [UIColor whiteColor]; // 添加白色背景确保可见性
        self.closeButton.layer.cornerRadius = 12; // 圆形按钮
        self.closeButton.layer.shadowColor = [UIColor blackColor].CGColor;
        self.closeButton.layer.shadowOffset = CGSizeMake(0, 2);
        self.closeButton.layer.shadowRadius = 4;
        self.closeButton.layer.shadowOpacity = 0.3;
        [self.closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton]; // 重要：添加到 self 而不是 containerView
    
    // 上一首按钮
    self.previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.previousButton setImage:[UIImage imageNamed:@"上一首"] forState:UIControlStateNormal];
    self.previousButton.tintColor = [UIColor systemBlueColor];
    [self.previousButton addTarget:self action:@selector(previousButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.previousButton];
    
    // 播放按钮 - 更大，蓝色背景
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
//    self.playButton.tintColor = [UIColor whiteColor];
//    self.playButton.backgroundColor = [UIColor systemBlueColor];
    self.playButton.layer.cornerRadius = 25; // 圆形按钮
    [self.playButton addTarget:self action:@selector(playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.playButton];
    
    // 下一首按钮
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextButton setImage:[UIImage imageNamed:@"下一首"] forState:UIControlStateNormal];
    self.nextButton.tintColor = [UIColor systemBlueColor];
    [self.nextButton addTarget:self action:@selector(nextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.nextButton];
}

- (void)setupCoverImageView {
    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.layer.cornerRadius = 30; // 圆形封面
    self.coverImageView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    // 使用默认封面图，或者从网络加载
    if (self.coverImageURL&&self.coverImageURL.length>0) {
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.coverImageURL]];
    }else{
        self.coverImageView.image = [UIImage imageNamed:@"lanch_logo"] ;
    }
    
   
    
    [self.containerView addSubview:self.coverImageView];
}

- (void)setupTitleLabel {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.storyTitle;
    self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.titleLabel.textColor = [UIColor labelColor];
    self.titleLabel.numberOfLines = 1;
    [self.containerView addSubview:self.titleLabel];
}


- (void)setupProgressControls {
    // 进度滑块 - 蓝色，滑块按钮也是蓝色
    self.progressSlider = [[UISlider alloc] init];
    self.progressSlider.minimumValue = 0;
    self.progressSlider.maximumValue = 1;
    self.progressSlider.value = 0;
    self.progressSlider.tintColor = [UIColor systemBlueColor];
    self.progressSlider.minimumTrackTintColor = [UIColor systemBlueColor];
    self.progressSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.8 alpha:1];
    self.progressSlider.thumbTintColor = [UIColor systemBlueColor]; // 设置滑块按钮颜色为蓝色
    [self.progressSlider addTarget:self action:@selector(progressSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.progressSlider addTarget:self action:@selector(progressSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.progressSlider addTarget:self action:@selector(progressSliderTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.containerView addSubview:self.progressSlider];
    
    // 创建自定义滑块按钮图片
    [self setupCustomSliderThumb];
    
    // 时间标签 - 显示在进度条滑块按钮上，更小的字体以适应更多文字
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.text = @"00:00/00:00";
    self.timeLabel.font = [UIFont systemFontOfSize:7 weight:UIFontWeightBold]; // 稍微小一点的字体
    self.timeLabel.textColor = [UIColor whiteColor]; // 白色文字，在蓝色滑块上显示
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.backgroundColor = [UIColor clearColor]; // 透明背景
    self.timeLabel.userInteractionEnabled = NO; // 不响应用户交互
    [self.containerView addSubview:self.timeLabel];
}

// 创建自定义滑块按钮
- (void)setupCustomSliderThumb {
    // 初始化时创建默认大小的滑块按钮
    [self updateSliderThumbForTime:@"00:00/00:00"];
}

// 根据时间长度动态创建滑块按钮
- (void)updateSliderThumbForTime:(NSString *)timeText {
    // 计算文字宽度（使用与标签相同的字体）
    CGSize textSize = [timeText sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:7 weight:UIFontWeightBold]}];
    
    // 滑块按钮宽度 = 文字宽度 + 边距，最小宽度为40，最大宽度为80（因为要显示两个时间）
    CGFloat thumbWidth = MAX(40, MIN(80, textSize.width + 16));
    CGFloat thumbHeight = 28;
    
    // 创建自定义滑块按钮
    UIImage *thumbImage = [self createThumbImageWithSize:CGSizeMake(thumbWidth, thumbHeight)];
    [self.progressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.progressSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
}

// 创建滑块按钮图片
- (UIImage *)createThumbImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 绘制蓝色圆角矩形
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:size.height/2];
    [[UIColor systemBlueColor] setFill];
    [path fill];
    
    // 添加边框
    [[UIColor whiteColor] setStroke];
    path.lineWidth = 2;
    [path stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



- (void)setupConstraints {
    // 获取屏幕宽度进行对比
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        // 背景视图约束 - 使用autoresizingMask避免约束冲突
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.backgroundView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8],
            [self.backgroundView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8],
            [self.backgroundView.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:-30],
            [self.backgroundView.heightAnchor constraintEqualToConstant:70]
        ]];
    
    // 封面图 - 左侧圆形
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView).offset(5);
        make.centerY.equalTo(self.containerView);
        make.width.height.mas_equalTo(60);
    }];
    
    // 标题 - 封面图右侧，但要避开关闭按钮
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.coverImageView.mas_trailing).offset(12);
        make.top.equalTo(self.containerView).offset(8);
        make.trailing.lessThanOrEqualTo(self.closeButton.mas_leading).offset(-8);
    }];
    
    // 关闭按钮 - 直接定位到背景视图的右上角
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backgroundView).offset(-10); // 在背景视图上方10点
            make.trailing.equalTo(self.backgroundView).offset(-10); // 在背景视图右方10点
            make.width.height.mas_equalTo(24);
        }];
    
    // 进度条 - 标题下方，占据更多可用空间
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
        make.trailing.equalTo(self.previousButton.mas_leading).offset(-15);
        make.height.mas_equalTo(20);
    }];
    
    // 时间标签 - 显示在进度条滑块按钮中心
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        self.timeLabelCenterXConstraint = make.centerX.equalTo(self.progressSlider);
        make.centerY.equalTo(self.progressSlider);
        make.width.mas_greaterThanOrEqualTo(30);
        make.height.mas_equalTo(12);
    }];
    
    // 下一首按钮 - 最右侧
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.containerView).offset(-15);
        make.centerY.equalTo(self.containerView);
        make.width.height.mas_equalTo(30);
    }];
    
    // 播放按钮 - 下一首左侧，较大
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.nextButton.mas_leading).offset(-12);
        make.centerY.equalTo(self.containerView);
        make.width.height.mas_equalTo(50);
    }];
    
    // 上一首按钮 - 播放按钮左侧
    [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.playButton.mas_leading).offset(-12);
        make.centerY.equalTo(self.containerView);
        make.width.height.mas_equalTo(30);
    }];
}

- (void)setupAudioPlayer {
    // 设置音频会话
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                     withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                           error:&error];
    if (error) {
        NSLog(@"音频会话设置错误: %@", error.localizedDescription);
    }
    
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"音频会话激活错误: %@", error.localizedDescription);
    }
    // 设置音频会话 - 修改为支持后台播放
    [self setupBackgroundAudioSession];
    // 加载音频文件
    [self loadAudioFromURL:self.audioURL];
    // 设置远程控制
//    [self setupRemoteTransportControls];
}

- (void)loadAudioFromURL:(NSString *)urlString {
    if (!urlString || urlString.length == 0) {
        NSLog(@"音频URL为空");
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        NSLog(@"无效的音频URL: %@", urlString);
        return;
    }
    
    // 如果是网络URL，需要先下载
    if ([urlString hasPrefix:@"http"]) {
        [self downloadAndPlayAudioFromURL:url];
    } else {
        // 本地文件
        [self createAudioPlayerWithURL:url];
    }
}

- (void)downloadAndPlayAudioFromURL:(NSURL *)url {
    NSLog(@"🔄 开始下载音频: %@", url.absoluteString);
    
    // 重置取消标志
    self.isCancelledByUser = NO;
    
    self.downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // ✅ 检查用户是否已经关闭了播放器
        if (self.isCancelledByUser) {
            NSLog(@"⏹️ 用户已关闭播放器，取消播放");
            return;
        }
        
        if (error) {
            NSLog(@"❌ 音频下载错误: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showErrorMessage:[NSString stringWithFormat:@"音频下载失败: %@", error.localizedDescription]];
            });
            return;
        }
        
        if (!location) {
            NSLog(@"❌ 下载位置为空");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showErrorMessage:@"音频下载失败"];
            });
            return;
        }
        
        // 将临时文件移动到缓存目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths firstObject];
        NSString *fileName = [NSString stringWithFormat:@"temp_audio_%@.mp3", [[NSUUID UUID] UUIDString]];
        NSString *destinationPath = [cachesDirectory stringByAppendingPathComponent:fileName];
        NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
        
        NSError *moveError;
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:destinationURL error:&moveError];
        
        if (moveError) {
            NSLog(@"❌ 移动音频文件错误: %@", moveError.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showErrorMessage:[NSString stringWithFormat:@"音频文件处理失败: %@", moveError.localizedDescription]];
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // ✅ 再次检查用户是否已经关闭了播放器
            if (self.isCancelledByUser) {
                NSLog(@"⏹️ 用户已关闭播放器，取消播放");
                // 清理下载的临时文件
                [[NSFileManager defaultManager] removeItemAtURL:destinationURL error:nil];
                return;
            }
            
            NSLog(@"✅ 音频下载成功，开始播放");
            [self createAudioPlayerWithURL:destinationURL];
        });
    }];
    
    [self.downloadTask resume];
}

- (void)showErrorMessage:(NSString *)message {
    self.titleLabel.text = message;
    self.titleLabel.textColor = [UIColor systemRedColor];
    
    // 3秒后隐藏播放器
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hide];
    });
}

// 显示提示信息（例如："已是第一首"）
- (void)showToastMessage:(NSString *)message {
    // 如果是后台播放模式，不显示UI提示
    if (self.isBackgroundPlayMode) {
        NSLog(@"🔔 提示信息: %@", message);
        return;
    }
    
    // 保存原始标题和颜色
    NSString *originalTitle = self.titleLabel.text;
    UIColor *originalColor = self.titleLabel.textColor;
    
    // 显示提示信息
    self.titleLabel.text = message;
    self.titleLabel.textColor = [UIColor systemOrangeColor];
    
    // 添加弹跳动画效果
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = @[@1.0, @1.1, @1.0];
    bounceAnimation.keyTimes = @[@0.0, @0.5, @1.0];
    bounceAnimation.duration = 0.6;
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.titleLabel.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
    
    // 2秒后恢复原始文字和颜色
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 使用渐变动画恢复
        [UIView transitionWithView:self.titleLabel
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
            self.titleLabel.text = originalTitle;
            self.titleLabel.textColor = originalColor;
        } completion:nil];
    });
}

- (void)createAudioPlayerWithURL:(NSURL *)url {
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (error) {
        NSLog(@"创建音频播放器错误: %@", error.localizedDescription);
        [self showErrorMessage:[NSString stringWithFormat:@"播放失败: %@", error.localizedDescription]];
        return;
    }
    
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    
    // 更新总时长和进度条最大值
    NSTimeInterval duration = self.audioPlayer.duration;
    self.progressSlider.maximumValue = duration;
    
    // 初始化时间显示（当前时间/总时长）
    NSString *initialTimeText = [NSString stringWithFormat:@"00:00/%@", [self formatTime:duration]];
    self.timeLabel.text = initialTimeText;
    [self updateSliderThumbForTime:initialTimeText];
    
    NSLog(@"音频加载成功，时长: %.1f秒", duration);
    
    // 初始化锁屏界面信息
    [self updateNowPlayingInfo];
    
    // 自动开始播放
    [self play];
}

#pragma mark - Public Methods

- (void)showInView:(UIView *)parentView {
    [parentView addSubview:self];
    
    // 确保视图层级正确
    [parentView bringSubviewToFront:self];
    
    // 先设置到屏幕底部
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.frame = screenBounds;
    
    // 强制布局更新
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    // 设置初始位置在屏幕下方
    CGRect initialFrame = self.backgroundView.frame;
    initialFrame.origin.y = screenBounds.size.height;
    self.backgroundView.frame = initialFrame;
    
    // 动画显示
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.alpha = 1.0;
        [self resetToBottomPosition];
    } completion:^(BOOL finished) {
        // 确保布局正确
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }];
}

// 重置位置到屏幕底部 - 修复版本
- (void)resetToBottomPosition {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat safeAreaBottom = 0;
    
    if (@available(iOS 11.0, *)) {
        safeAreaBottom = self.safeAreaInsets.bottom;
    }
    
    // 直接设置frame，避免约束冲突
    CGRect newFrame = self.backgroundView.frame;
    newFrame.origin.y = screenBounds.size.height - safeAreaBottom - newFrame.size.height - 30;
    newFrame.origin.x = 8;
    newFrame.size.width = screenBounds.size.width - 16;
    
    self.backgroundView.frame = newFrame;
}
// 自定义Frame显示
- (void)showInView:(UIView *)parentView withFrame:(CGRect)frame {
    self.customFrame = frame;
    self.useCustomFrame = YES;
    
    // 先移除旧的约束
    [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(frame.origin.x);
        make.top.equalTo(self).offset(frame.origin.y);
        make.width.mas_equalTo(frame.size.width);
        make.height.mas_equalTo(frame.size.height);
    }];
    
    [parentView addSubview:self];
    
    // 先确保背景视图有正确的初始transform
    self.backgroundView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    // 动画显示
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1.0;
        self.backgroundView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.backgroundView.transform = CGAffineTransformIdentity;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }];
}

// 自定义Position显示（中心点）
- (void)showInView:(UIView *)parentView atPosition:(CGPoint)position {
    self.customPosition = position;
    self.useCustomFrame = NO;
    
    // 先移除旧的约束
    [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(position.x - [UIScreen mainScreen].bounds.size.width / 2);
        make.centerY.equalTo(self).offset(position.y - [UIScreen mainScreen].bounds.size.height / 2);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width - 16);
        make.height.mas_equalTo(70);
    }];
    
    [parentView addSubview:self];
    
    // 先确保背景视图有正确的初始transform
    self.backgroundView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    // 动画显示
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1.0;
        self.backgroundView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.backgroundView.transform = CGAffineTransformIdentity;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }];
}

// 打印宽度对比日志
- (void)logWidthComparison {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat playerViewWidth = CGRectGetWidth(self.frame);
    CGFloat backgroundViewWidth = CGRectGetWidth(self.backgroundView.frame);
    CGFloat progressSliderWidth = CGRectGetWidth(self.progressSlider.frame);
    
    // 获取安全区域边距
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.safeAreaInsets;
    }
    
    // 获取背景视图的实际frame和center信息
    CGRect backgroundFrame = self.backgroundView.frame;
    
    NSLog(@"📏 === 宽度对比 ===");
    NSLog(@"🖥️ 屏幕宽度: %.2f", screenWidth);
    NSLog(@"🎵 播放器总宽度: %.2f", playerViewWidth);
    NSLog(@"🫧 背景视图宽度: %.2f", backgroundViewWidth);
    NSLog(@"🫧 背景视图frame: x=%.2f, y=%.2f, w=%.2f, h=%.2f", backgroundFrame.origin.x, backgroundFrame.origin.y, backgroundFrame.size.width, backgroundFrame.size.height);
    NSLog(@"📊 进度条宽度: %.2f", progressSliderWidth);
    NSLog(@"🛡️ 安全区域 left: %.2f, right: %.2f", safeAreaInsets.left, safeAreaInsets.right);
    NSLog(@"🧮 期望背景宽度: %.2f (屏幕宽度 - 16)", screenWidth - 16);
    NSLog(@"🧮 考虑安全区域期望宽度: %.2f", screenWidth - 16 - safeAreaInsets.left - safeAreaInsets.right);
    NSLog(@"📏 实际差值: %.2f", screenWidth - backgroundViewWidth);
    NSLog(@"📏 左边距: %.2f, 右边距: %.2f", backgroundFrame.origin.x, screenWidth - (backgroundFrame.origin.x + backgroundFrame.size.width));
    NSLog(@"📏 ==================");
    
    // 如果宽度仍然不正确，尝试手动设置
    if (ABS(backgroundViewWidth - (screenWidth - 16)) > 1.0) {
        NSLog(@"⚠️ 宽度不正确，尝试重新设置约束...");
        [self fixBackgroundViewWidth];
    }
}

// 修复背景视图宽度的方法
- (void)fixBackgroundViewWidth {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat targetWidth = screenWidth - 16;
    
    NSLog(@"🔍 调试信息 - 修复前:");
    NSLog(@"🔍 背景视图约束数量: %lu", (unsigned long)self.backgroundView.constraints.count);
    NSLog(@"🔍 播放器约束数量: %lu", (unsigned long)self.constraints.count);
    NSLog(@"🔍 当前transform: %@", NSStringFromCGAffineTransform(self.backgroundView.transform));
    
    // 重置transform
    self.backgroundView.transform = CGAffineTransformIdentity;
    NSLog(@"🔧 已重置transform");
    
    // 移除现有约束并重新设置
    [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(8);           // 直接使用left/right
        make.trailing.equalTo(self).offset(-8);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-30);
        make.height.mas_equalTo(70);
    }];
    
    NSLog(@"🔧 使用left/right约束重新设置");
    
    // 强制布局更新
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self.backgroundView setNeedsLayout];
    [self.backgroundView layoutIfNeeded];
    
    NSLog(@"🔧 重新设置约束完成，目标宽度: %.2f", targetWidth);
    
    // 延迟验证
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat newWidth = CGRectGetWidth(self.backgroundView.frame);
        CGRect newFrame = self.backgroundView.frame;
        NSLog(@"✅ 修复后背景视图宽度: %.2f", newWidth);
        NSLog(@"✅ 修复后背景视图frame: x=%.2f, y=%.2f, w=%.2f, h=%.2f",
              newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height);
        
        // 如果还是不对，尝试最后的方案
        if (ABS(newWidth - targetWidth) > 1.0) {
            NSLog(@"⚠️ 约束仍然无效，尝试直接设置frame");
            [self forceSetBackgroundFrame];
        }
    });
}

// 强制设置背景视图frame的最后方案
- (void)forceSetBackgroundFrame {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat targetWidth = screenWidth - 16;
    CGFloat x = 8;
    CGFloat y = self.backgroundView.frame.origin.y;
    CGFloat height = 70;
    
    CGRect newFrame = CGRectMake(x, y, targetWidth, height);
    self.backgroundView.frame = newFrame;
    
    NSLog(@"🚨 强制设置frame: x=%.2f, y=%.2f, w=%.2f, h=%.2f", x, y, targetWidth, height);
    
    // 验证结果
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect finalFrame = self.backgroundView.frame;
        NSLog(@"✅ 最终frame: x=%.2f, y=%.2f, w=%.2f, h=%.2f",
              finalFrame.origin.x, finalFrame.origin.y, finalFrame.size.width, finalFrame.size.height);
    });
}

- (void)hide {
    // ✅ 设置取消标志，防止下载完成后继续播放
    self.isCancelledByUser = YES;
    
    // ✅ 取消正在进行的下载任务
    if (self.downloadTask) {
        [self.downloadTask cancel];
        self.downloadTask = nil;
        NSLog(@"⏹️ 已取消音频下载任务");
    }
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGPoint hideCenter = CGPointMake(screenBounds.size.width / 2,
                                       screenBounds.size.height + self.bounds.size.height / 2);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
            self.center = hideCenter;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self stop];
            
            // 清除系统播放器信息
//            [self clearNowPlayingInfo];
            
            if ([self.delegate respondsToSelector:@selector(audioPlayerDidClose)]) {
                [self.delegate audioPlayerDidClose];
            }
        }];
}

- (void)play {
    if (self.audioPlayer) {
        // 在开始播放前，停止所有其他播放器
        [AudioPlayerView stopAllOtherPlayers:self];
        
        // 设置远程控制（确保只有当前播放器响应）
//        [self setupRemoteTransportControls];
        
        [self.audioPlayer play];
        [self startProgressTimer];
        
        // 只在非后台播放模式下更新UI
        if (!self.isBackgroundPlayMode) {
            [self updatePlayButtonImage:YES];
        }
        
        // 更新锁屏界面信息
        [self updateNowPlayingInfo];
        
        if ([self.delegate respondsToSelector:@selector(audioPlayerDidStartPlaying)]) {
            [self.delegate audioPlayerDidStartPlaying];
        }
    }
}

// 后台播放方法（直接播放，不显示UI）
- (void)playInBackground {
    if (self.audioPlayer) {
        // 停止所有其他播放器
        [AudioPlayerView stopAllOtherPlayers:self];
        
        // 配置后台音频会话
        [self setupBackgroundAudioSession];
        
        // 设置远程控制
//        [self setupRemoteTransportControls];
        
        [self.audioPlayer play];
        [self startProgressTimer];
        
        NSLog(@"🎵 开始后台播放音频");
        
        if ([self.delegate respondsToSelector:@selector(audioPlayerDidStartPlaying)]) {
            [self.delegate audioPlayerDidStartPlaying];
        }
    }
}

- (void)pause {
    if (self.audioPlayer) {
        [self.audioPlayer pause];
        [self stopProgressTimer];
        
        // 只在非后台播放模式下更新UI
        if (!self.isBackgroundPlayMode) {
            [self updatePlayButtonImage:NO];
            // 更新锁屏界面信息
            [self updateNowPlayingInfo];
        }
        
        if ([self.delegate respondsToSelector:@selector(audioPlayerDidPause)]) {
            [self.delegate audioPlayerDidPause];
        }
    }
}

- (void)stop {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer.currentTime = 0;
        [self stopProgressTimer];
        
        // 只在非后台播放模式下更新UI
        if (!self.isBackgroundPlayMode) {
            [self updatePlayButtonImage:NO];
            [self updateProgress];
        }
        
        // 清除系统播放器信息
//        [self clearNowPlayingInfo];
        
        // 停止播放时注销实例
        [self unregisterInstance];
    }
}
-(void)rePlay{
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer.currentTime = 0;
        [self stopProgressTimer];
        [self updatePlayButtonImage:NO];
        [self updateProgress];
        [self play];
    }
    
}
- (BOOL)isPlaying {
    return self.audioPlayer.isPlaying;
}

// 🎵 获取当前播放时间（秒）
- (NSTimeInterval)getCurrentPlaybackTime {
    if (!self.audioPlayer) {
        return 0;
    }
    return self.audioPlayer.currentTime;
}

// 🎵 获取总播放时长（秒）
- (NSTimeInterval)getTotalDuration {
    if (!self.audioPlayer) {
        return 0;
    }
    return self.audioPlayer.duration;
}

#pragma mark - Private Methods

- (void)updatePlayButtonImage:(BOOL)isPlaying {
    // 后台播放模式下不更新UI
    if (self.isBackgroundPlayMode || !self.playButton) {
        return;
    }
    
    NSString *imageName = isPlaying ? @"暂停" : @"播放";
    [self.playButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)startProgressTimer {
    [self stopProgressTimer];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)stopProgressTimer {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

- (void)updateProgress {
    if (!self.audioPlayer) return;
    
    NSTimeInterval currentTime = self.audioPlayer.currentTime;
    NSTimeInterval duration = self.audioPlayer.duration;
    
    if (duration > 0) {
        // 只在非后台播放模式下更新UI
        if (!self.isBackgroundPlayMode && self.progressSlider) {
            self.progressSlider.value = currentTime;
            // 更新时间标签显示当前时间并跟随滑块位置
            [self updateTimeLabelPosition];
        }
        
        // 定期更新锁屏界面信息（每0.5秒更新一次）
        static NSTimeInterval lastUpdateTime = 0;
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
        if (now - lastUpdateTime > 0.5) {
            [self updateNowPlayingInfo];
            lastUpdateTime = now;
        }
        
        if ([self.delegate respondsToSelector:@selector(audioPlayerDidUpdateProgress:currentTime:totalTime:)]) {
            CGFloat progress = currentTime / duration;
            [self.delegate audioPlayerDidUpdateProgress:progress currentTime:currentTime totalTime:duration];
        }
    }
}

- (NSString *)formatTime:(NSTimeInterval)timeInterval {
    NSInteger minutes = (NSInteger)timeInterval / 60;
    NSInteger seconds = (NSInteger)timeInterval % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

// 更新时间标签位置，跟随滑块移动
- (void)updateTimeLabelPosition {
    // 后台播放模式下不需要更新UI
    if (self.isBackgroundPlayMode || !self.audioPlayer || !self.timeLabelCenterXConstraint) return;
    
    // 更新时间文本（显示当前时间/总时长）
    NSTimeInterval currentTime = self.audioPlayer.currentTime;
    NSTimeInterval duration = self.audioPlayer.duration;
    NSString *timeText = [NSString stringWithFormat:@"%@/%@", [self formatTime:currentTime], [self formatTime:duration]];
    self.timeLabel.text = timeText;
    
    // 根据时间长度动态更新滑块按钮大小
    [self updateSliderThumbForTime:timeText];
    
    // 计算滑块当前位置的百分比
    CGFloat sliderProgress = 0;
    if (self.progressSlider.maximumValue > 0) {
        sliderProgress = self.progressSlider.value / self.progressSlider.maximumValue;
    }
    
    // 获取进度条的实际宽度（动态计算）
    CGFloat sliderWidth = CGRectGetWidth(self.progressSlider.frame);
    if (sliderWidth <= 0) {
        // 如果布局还没有完成，延迟执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateTimeLabelPosition];
        });
        return;
    }
    
    NSLog(@"📊 updateTimeLabelPosition - 进度条宽度: %.2f, 背景视图宽度: %.2f", sliderWidth, CGRectGetWidth(self.backgroundView.frame));
    
    // 计算当前滑块按钮的宽度（根据时间文本长度，使用与标签相同的字体）
    CGSize textSize = [timeText sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:7 weight:UIFontWeightBold]}];
    CGFloat thumbWidth = MAX(40, MIN(80, textSize.width + 16));
    CGFloat trackWidth = sliderWidth - thumbWidth;
    
    // 计算滑块按钮中心相对于进度条左边的偏移量
    CGFloat thumbCenterOffset = (thumbWidth / 2) + (trackWidth * sliderProgress);
    
    // 更新约束，相对于进度条的左边
    [self.timeLabelCenterXConstraint uninstall];
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        self.timeLabelCenterXConstraint = make.centerX.equalTo(self.progressSlider.mas_leading).offset(thumbCenterOffset);
    }];
    
    // 强制布局更新
    [self.timeLabel.superview layoutIfNeeded];
}

#pragma mark - Actions

- (void)playButtonTapped {
    if (!self.audioPlayer.isPlaying &&self.audioPlayer.currentTime>=60) {
        [self rePlay];
    } else if(self.audioPlayer.isPlaying){
        [self pause];
    }else{
        [self play];
    }
}

- (void)previousButtonTapped {
    NSLog(@"上一首按钮点击");
    
    // 显示提示信息
//    [self showToastMessage:self.previousButtonMessage];
    
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidTapPrevious)]) {
        [self.delegate audioPlayerDidTapPrevious];
    }
}

- (void)nextButtonTapped {
    NSLog(@"下一首按钮点击");
    
    // 显示提示信息
//    [self showToastMessage:self.nextButtonMessage];
    
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidTapNext)]) {
        [self.delegate audioPlayerDidTapNext];
    }
}

- (void)closeButtonTapped {
    [self hide];
}

- (void)progressSliderChanged:(UISlider *)slider {
    if (self.audioPlayer) {
        self.audioPlayer.currentTime = slider.value;
        [self updateTimeLabelPosition]; // 立即更新时间标签位置
    }
}

- (void)progressSliderTouchDown:(UISlider *)slider {
    [self stopProgressTimer];
}

- (void)progressSliderTouchUp:(UISlider *)slider {
    if (self.audioPlayer.isPlaying) {
        [self startProgressTimer];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopProgressTimer];
    
    // 只在非后台播放模式下更新UI
    if (!self.isBackgroundPlayMode) {
        [self updatePlayButtonImage:NO];
        // 重置播放位置
        self.audioPlayer.currentTime = 0;
        [self updateProgress];
    }
    
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidFinish)]) {
        [self.delegate audioPlayerDidFinish];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    NSLog(@"音频播放解码错误: %@", error.localizedDescription);
}

#pragma mark - Background Audio Methods

// 设置后台音频会话
- (void)setupBackgroundAudioSession {
    if (self.isBackgroundAudioConfigured) {
        return;
    }
    
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    // 设置音频会话类别为播放，支持后台播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback
                  withOptions:AVAudioSessionCategoryOptionMixWithOthers |
                              AVAudioSessionCategoryOptionAllowBluetooth |
                              AVAudioSessionCategoryOptionAllowAirPlay
                        error:&error];
    
    if (error) {
        NSLog(@"❌ 音频会话类别设置失败: %@", error.localizedDescription);
    }
    
    // 激活音频会话
    [audioSession setActive:YES error:&error];
    if (error) {
        NSLog(@"❌ 音频会话激活失败: %@", error.localizedDescription);
    }
    
    // 注册音频中断通知
    [self setupAudioInterruptionNotifications];
    
    self.isBackgroundAudioConfigured = YES;
    NSLog(@"✅ 后台音频会话已配置");
}

// 移除远程控制目标的方法
- (void)removeRemoteTransportControls {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    // 移除所有已添加的目标
    if (self.playCommandTarget) {
        [commandCenter.playCommand removeTarget:self.playCommandTarget];
        self.playCommandTarget = nil;
    }
    
    if (self.pauseCommandTarget) {
        [commandCenter.pauseCommand removeTarget:self.pauseCommandTarget];
        self.pauseCommandTarget = nil;
    }
    
    if (self.togglePlayPauseCommandTarget) {
        [commandCenter.togglePlayPauseCommand removeTarget:self.togglePlayPauseCommandTarget];
        self.togglePlayPauseCommandTarget = nil;
    }
    
    if (self.previousTrackCommandTarget) {
        [commandCenter.previousTrackCommand removeTarget:self.previousTrackCommandTarget];
        self.previousTrackCommandTarget = nil;
    }
    
    if (self.nextTrackCommandTarget) {
        [commandCenter.nextTrackCommand removeTarget:self.nextTrackCommandTarget];
        self.nextTrackCommandTarget = nil;
    }
    
    // 禁用命令
    commandCenter.playCommand.enabled = NO;
    commandCenter.pauseCommand.enabled = NO;
    commandCenter.togglePlayPauseCommand.enabled = NO;
    commandCenter.previousTrackCommand.enabled = NO;
    commandCenter.nextTrackCommand.enabled = NO;
    
    NSLog(@"✅ 已移除远程控制目标");
}

// 设置远程控制（锁屏界面和控制中心）
- (void)setupRemoteTransportControls {
    // 先移除旧的目标
    [self removeRemoteTransportControls];
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    // 使用 weak self 避免循环引用
    __weak typeof(self) weakSelf = self;
    
    // 播放命令 - 保存目标引用
    self.playCommandTarget = [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSLog(@"🎵 远程控制：播放");
            [strongSelf play];
            return MPRemoteCommandHandlerStatusSuccess;
        }
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }];
    
    // 暂停命令 - 保存目标引用
    self.pauseCommandTarget = [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSLog(@"⏸️ 远程控制：暂停");
            [strongSelf pause];
            return MPRemoteCommandHandlerStatusSuccess;
        }
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }];
    
    // 切换播放/暂停命令 - 保存目标引用
    self.togglePlayPauseCommandTarget = [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSLog(@"⏯️ 远程控制：切换播放/暂停");
            if (strongSelf.audioPlayer.isPlaying) {
                [strongSelf pause];
            } else {
                [strongSelf play];
            }
            return MPRemoteCommandHandlerStatusSuccess;
        }
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }];
    
    // 上一曲命令 - 保存目标引用
    self.previousTrackCommandTarget = [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSLog(@"⏮️ 远程控制：上一曲");
            [strongSelf previousButtonTapped];
            return MPRemoteCommandHandlerStatusSuccess;
        }
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }];
    
    // 下一曲命令 - 保存目标引用
    self.nextTrackCommandTarget = [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSLog(@"⏭️ 远程控制：下一曲");
            [strongSelf nextButtonTapped];
            return MPRemoteCommandHandlerStatusSuccess;
        }
        return MPRemoteCommandHandlerStatusNoSuchContent;
    }];
    
    // 启用命令
    commandCenter.playCommand.enabled = YES;
    commandCenter.pauseCommand.enabled = YES;
    commandCenter.togglePlayPauseCommand.enabled = YES;
    commandCenter.previousTrackCommand.enabled = YES;
    commandCenter.nextTrackCommand.enabled = YES;
    
    NSLog(@"✅ 远程控制已设置（已保存目标引用）");
}

// 更新锁屏界面和控制中心信息
- (void)updateNowPlayingInfo {
    if (!self.audioPlayer) {
        return;
    }
    
    NSMutableDictionary *nowPlayingInfo = [NSMutableDictionary dictionary];
    
    // 设置基本信息
    [nowPlayingInfo setValue:self.storyTitle forKey:MPMediaItemPropertyTitle];
    [nowPlayingInfo setValue:LocalString(@"故事") forKey:MPMediaItemPropertyArtist]; // 可以设置为应用名称或其他
    [nowPlayingInfo setValue:LocalString(@"音频书") forKey:MPMediaItemPropertyAlbumTitle];
    
    // 设置时长和当前播放时间
    [nowPlayingInfo setValue:@(self.audioPlayer.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    [nowPlayingInfo setValue:@(self.audioPlayer.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [nowPlayingInfo setValue:@(self.audioPlayer.isPlaying ? 1.0 : 0.0) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    // 设置封面图片
    if (self.coverImageView.image) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:self.coverImageView.image.size
                                                                     requestHandler:^UIImage * _Nonnull(CGSize size) {
            return self.coverImageView.image;
        }];
        [nowPlayingInfo setValue:artwork forKey:MPMediaItemPropertyArtwork];
    } else {
        // 如果没有封面图，使用默认图片
        UIImage *defaultImage = [UIImage imageNamed:@"default_cover"] ?: [UIImage systemImageNamed:@"music.note"];
        if (defaultImage) {
            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(100, 100)
                                                                         requestHandler:^UIImage * _Nonnull(CGSize size) {
                return defaultImage;
            }];
            [nowPlayingInfo setValue:artwork forKey:MPMediaItemPropertyArtwork];
        }
    }
    
    self.nowPlayingInfo = nowPlayingInfo;
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
}

// 清除锁屏界面和控制中心信息
- (void)clearNowPlayingInfo {
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
    
    // 调用移除远程控制方法
    [self removeRemoteTransportControls];
    
    NSLog(@"✅ 已清除系统播放器信息和远程控制");
}

// 设置音频中断通知
- (void)setupAudioInterruptionNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioSessionInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
}

// 处理音频中断
- (void)handleAudioSessionInterruption:(NSNotification *)notification {
    NSInteger interruptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    
    if (interruptionType == AVAudioSessionInterruptionTypeBegan) {
        // 中断开始（如来电），暂停播放
        NSLog(@"🔇 音频中断开始");
        if (self.audioPlayer.isPlaying) {
            [self pause];
        }
    } else if (interruptionType == AVAudioSessionInterruptionTypeEnded) {
        // 中断结束，检查是否应该恢复播放
        NSInteger interruptionOption = [[notification.userInfo valueForKey:AVAudioSessionInterruptionOptionKey] integerValue];
        if (interruptionOption == AVAudioSessionInterruptionOptionShouldResume) {
            NSLog(@"🔊 音频中断结束，恢复播放");
            [self play];
        }
    }
}

// 处理音频路由变化
- (void)handleRouteChange:(NSNotification *)notification {
    NSInteger routeChangeReason = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    if (routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        // 耳机拔出等设备断开，暂停播放
        NSLog(@"🎧 音频设备断开，暂停播放");
        [self pause];
    }
}
#pragma mark - Drag Gesture Methods

// 设置拖动手势 - 全新优化版本
- (void)setupDragGesture {
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panGesture.minimumNumberOfTouches = 1;
    self.panGesture.maximumNumberOfTouches = 1;
    
    // 优化手势设置
    self.panGesture.cancelsTouchesInView = NO;
    self.panGesture.delaysTouchesBegan = NO;
    self.panGesture.delaysTouchesEnded = NO;
    
    // 设置手势代理
    self.panGesture.delegate = self;
    
    // 根据是否启用全屏拖动来决定添加到哪个视图
    if (self.enableFullScreenDrag) {
        // 添加到整个播放器视图，支持全屏拖动
        [self addGestureRecognizer:self.panGesture];
        NSLog(@"✅ 全屏拖动手势已设置");
    } else {
        // 只添加到背景视图
        [self.backgroundView addGestureRecognizer:self.panGesture];
        NSLog(@"✅ 背景视图拖动手势已设置");
    }
    
    // 确保视图可以接收用户交互
    self.userInteractionEnabled = YES;
    self.backgroundView.userInteractionEnabled = YES;
}

// 处理拖动手势 - 丝滑优化版本
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    CGPoint velocity = [gesture velocityInView:self.superview];
    CGPoint location = [gesture locationInView:self.superview];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self handleDragBegan:location];
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            [self handleDragChanged:translation velocity:velocity];
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [self handleDragEndedWithVelocity:velocity];
            break;
        }
            
        default:
            break;
    }
}

// 开始拖动
- (void)handleDragBegan:(CGPoint)location {
    // 停止任何进行中的动画
    [self.layer removeAllAnimations];
    
    // 记录初始状态
    self.dragStartPoint = self.center;
    self.originalFrame = self.frame;
    self.lastPanPoint = location;
    self.isDragging = YES;
    
    // 添加拖动开始的视觉反馈
    [UIView animateWithDuration:0.2
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        // 轻微放大和降低透明度
        self.backgroundView.transform = CGAffineTransformMakeScale(1.05, 1.05);
        self.backgroundView.alpha = 0.95;
        
        // 增强阴影效果
        self.backgroundView.layer.shadowOpacity = 0.4;
        self.backgroundView.layer.shadowRadius = 16;
        self.backgroundView.layer.shadowOffset = CGSizeMake(0, 6);
    } completion:nil];
    
    NSLog(@"🎯 开始拖动 - 位置: (%.2f, %.2f)", self.center.x, self.center.y);
}

// 拖动中
- (void)handleDragChanged:(CGPoint)translation velocity:(CGPoint)velocity {
    CGPoint newCenter = CGPointMake(self.dragStartPoint.x + translation.x,
                                   self.dragStartPoint.y + translation.y);
    
    // 应用边界约束
    newCenter = [self applyBoundaryConstraints:newCenter withVelocity:velocity];
    
    // 平滑更新位置
    [self updatePositionSmoothly:newCenter];
    
    // 根据拖动速度和方向添加动态视觉反馈
    [self updateVisualFeedbackWithVelocity:velocity];
}

// 拖动结束
- (void)handleDragEndedWithVelocity:(CGPoint)velocity {
    self.isDragging = NO;
    
    // 恢复视觉状态
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        self.backgroundView.transform = CGAffineTransformIdentity;
        self.backgroundView.alpha = 1.0;
        
        // 恢复正常阴影
        self.backgroundView.layer.shadowOpacity = 0.3;
        self.backgroundView.layer.shadowRadius = 12;
        self.backgroundView.layer.shadowOffset = CGSizeMake(0, 4);
    } completion:nil];
    
    // 处理惯性滑动
    [self handleInertialMovementWithVelocity:velocity];
    
    NSLog(@"🎯 拖动结束 - 最终位置: (%.2f, %.2f)", self.center.x, self.center.y);
}

// 应用边界约束
- (CGPoint)applyBoundaryConstraints:(CGPoint)center withVelocity:(CGPoint)velocity {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.safeAreaInsets;
    }
    
    CGFloat playerWidth = CGRectGetWidth(self.backgroundView.frame);
    CGFloat playerHeight = CGRectGetHeight(self.backgroundView.frame);
    
    CGFloat padding = self.allowOutOfBounds ? 20 : 8; // 允许超出的边距
    
    CGFloat minX = safeAreaInsets.left + playerWidth/2 - padding;
    CGFloat maxX = screenBounds.size.width - safeAreaInsets.right - playerWidth/2 + padding;
    CGFloat minY = safeAreaInsets.top + playerHeight/2 - padding;
    CGFloat maxY = screenBounds.size.height - safeAreaInsets.bottom - playerHeight/2 + padding;
    
    CGPoint constrainedCenter = center;
    
    // 使用弹性约束，在边界附近增加阻力
    if (constrainedCenter.x < minX) {
        CGFloat overDistance = minX - constrainedCenter.x;
        constrainedCenter.x = minX - overDistance * self.dragResistanceEdge;
    } else if (constrainedCenter.x > maxX) {
        CGFloat overDistance = constrainedCenter.x - maxX;
        constrainedCenter.x = maxX + overDistance * self.dragResistanceEdge;
    }
    
    if (constrainedCenter.y < minY) {
        CGFloat overDistance = minY - constrainedCenter.y;
        constrainedCenter.y = minY - overDistance * self.dragResistanceEdge;
    } else if (constrainedCenter.y > maxY) {
        CGFloat overDistance = constrainedCenter.y - maxY;
        constrainedCenter.y = maxY + overDistance * self.dragResistanceEdge;
    }
    
    return constrainedCenter;
}

// 平滑更新位置
- (void)updatePositionSmoothly:(CGPoint)targetCenter {
    // 使用插值来平滑位置更新
    CGPoint currentCenter = self.center;
    CGFloat smoothingFactor = 0.85; // 平滑系数，越大越平滑但响应越慢
    
    CGPoint smoothedCenter = CGPointMake(
        currentCenter.x + (targetCenter.x - currentCenter.x) * smoothingFactor,
        currentCenter.y + (targetCenter.y - currentCenter.y) * smoothingFactor
    );
    
    self.center = smoothedCenter;
}

// 根据速度更新视觉反馈
- (void)updateVisualFeedbackWithVelocity:(CGPoint)velocity {
    CGFloat speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
    CGFloat maxSpeed = 2000;
    CGFloat speedRatio = MIN(speed / maxSpeed, 1.0);
    
    // 根据速度调整视觉效果
    CGFloat targetAlpha = 0.95 - speedRatio * 0.05;
    CGFloat targetScale = 1.05 + speedRatio * 0.03;
    
    // 使用CATransaction来避免动画累积
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.backgroundView.alpha = targetAlpha;
    self.backgroundView.transform = CGAffineTransformMakeScale(targetScale, targetScale);
    [CATransaction commit];
}

// 处理惯性移动
- (void)handleInertialMovementWithVelocity:(CGPoint)velocity {
    CGFloat speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
    
    if (speed < 200) {
        // 速度太小，直接处理边界回弹
        [self handleBoundaryBounceback];
        return;
    }
    
    // 启动惯性滑动
    [self startInertialAnimationWithVelocity:velocity];
}

// 启动惯性动画
- (void)startInertialAnimationWithVelocity:(CGPoint)velocity {
    // 创建显示链用于平滑的60fps动画
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateInertialMovement:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    // 存储初始速度
    objc_setAssociatedObject(self, "velocityX", @(velocity.x), OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, "velocityY", @(velocity.y), OBJC_ASSOCIATION_RETAIN);
    
    NSLog(@"🚀 开始惯性滑动 - 初始速度: (%.1f, %.1f)", velocity.x, velocity.y);
}

// 更新惯性移动（每帧调用）
- (void)updateInertialMovement:(CADisplayLink *)displayLink {
    // 获取当前速度
    CGFloat velocityX = [objc_getAssociatedObject(self, "velocityX") floatValue];
    CGFloat velocityY = [objc_getAssociatedObject(self, "velocityY") floatValue];
    
    // 计算时间间隔
    CGFloat deltaTime = displayLink.duration;
    
    // 应用减速
    velocityX *= pow(self.dragDecelerationRate, deltaTime * 60); // 标准化到60fps
    velocityY *= pow(self.dragDecelerationRate, deltaTime * 60);
    
    // 计算新位置
    CGPoint currentCenter = self.center;
    CGPoint newCenter = CGPointMake(
        currentCenter.x + velocityX * deltaTime,
        currentCenter.y + velocityY * deltaTime
    );
    
    // 应用边界约束
    newCenter = [self applyBoundaryConstraints:newCenter withVelocity:CGPointMake(velocityX, velocityY)];
    
    // 更新位置
    self.center = newCenter;
    
    // 检查是否需要停止动画
    CGFloat speed = sqrt(velocityX * velocityX + velocityY * velocityY);
    BOOL isAtBoundary = [self isAtBoundary:newCenter];
    
    if (speed < 50 || isAtBoundary) {
        // 速度太小或碰到边界，停止惯性动画
        if (self.displayLink) {
            [self.displayLink invalidate];
            self.displayLink = nil;
        }
        [self handleBoundaryBounceback];
        return;
    }
    
    // 更新速度
    objc_setAssociatedObject(self, "velocityX", @(velocityX), OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, "velocityY", @(velocityY), OBJC_ASSOCIATION_RETAIN);
}



// 检查是否在边界附近
- (BOOL)isAtBoundary:(CGPoint)center {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.safeAreaInsets;
    }
    
    CGFloat playerWidth = CGRectGetWidth(self.backgroundView.frame);
    CGFloat playerHeight = CGRectGetHeight(self.backgroundView.frame);
    
    CGFloat minX = safeAreaInsets.left + playerWidth/2;
    CGFloat maxX = screenBounds.size.width - safeAreaInsets.right - playerWidth/2;
    CGFloat minY = safeAreaInsets.top + playerHeight/2;
    CGFloat maxY = screenBounds.size.height - safeAreaInsets.bottom - playerHeight/2;
    
    return (center.x <= minX || center.x >= maxX || center.y <= minY || center.y >= maxY);
}

// 处理边界回弹
- (void)handleBoundaryBounceback {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.safeAreaInsets;
    }
    
    CGFloat playerWidth = CGRectGetWidth(self.backgroundView.frame);
    CGFloat playerHeight = CGRectGetHeight(self.backgroundView.frame);
    
    CGFloat minX = safeAreaInsets.left + playerWidth/2;
    CGFloat maxX = screenBounds.size.width - safeAreaInsets.right - playerWidth/2;
    CGFloat minY = safeAreaInsets.top + playerHeight/2;
    CGFloat maxY = screenBounds.size.height - safeAreaInsets.bottom - playerHeight/2;
    
    CGPoint currentCenter = self.center;
    CGPoint targetCenter = currentCenter;
    BOOL needsBounce = NO;
    
    if (currentCenter.x < minX) {
        targetCenter.x = minX;
        needsBounce = YES;
    } else if (currentCenter.x > maxX) {
        targetCenter.x = maxX;
        needsBounce = YES;
    }
    
    if (currentCenter.y < minY) {
        targetCenter.y = minY;
        needsBounce = YES;
    } else if (currentCenter.y > maxY) {
        targetCenter.y = maxY;
        needsBounce = YES;
    }
    
    if (needsBounce) {
        // 执行边缘吸附或边界回弹
        if (self.enableEdgeSnapping) {
            targetCenter = [self calculateSnapTargetWithCurrentCenter:currentCenter];
        }
        
        [UIView animateWithDuration:0.6
                              delay:0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            self.center = targetCenter;
        } completion:^(BOOL finished) {
            NSLog(@"🎯 边界回弹完成 - 最终位置: (%.2f, %.2f)", self.center.x, self.center.y);
        }];
    }
}

// 计算边缘吸附的目标位置 - 优化版本
- (CGPoint)calculateSnapTargetWithCurrentCenter:(CGPoint)currentCenter {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat screenMidX = screenBounds.size.width / 2;
    CGFloat screenMidY = screenBounds.size.height / 2;
    
    CGFloat playerWidth = CGRectGetWidth(self.backgroundView.frame);
    CGFloat playerHeight = CGRectGetHeight(self.backgroundView.frame);
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.safeAreaInsets;
    }
    
    // 计算到各边的距离
    CGFloat distanceToLeft = currentCenter.x;
    CGFloat distanceToRight = screenBounds.size.width - currentCenter.x;
    CGFloat distanceToTop = currentCenter.y;
    CGFloat distanceToBottom = screenBounds.size.height - currentCenter.y;
    
    CGPoint targetCenter = currentCenter;
    
    // 找到最近的边
    CGFloat minDistance = MIN(MIN(distanceToLeft, distanceToRight), MIN(distanceToTop, distanceToBottom));
    
    if (minDistance == distanceToLeft) {
        // 吸附到左边
        targetCenter.x = safeAreaInsets.left + playerWidth/2 + 10;
    } else if (minDistance == distanceToRight) {
        // 吸附到右边
        targetCenter.x = screenBounds.size.width - safeAreaInsets.right - playerWidth/2 - 10;
    } else if (minDistance == distanceToTop) {
        // 吸附到顶部
        targetCenter.y = safeAreaInsets.top + playerHeight/2 + 10;
    } else {
        // 吸附到底部
        targetCenter.y = screenBounds.size.height - safeAreaInsets.bottom - playerHeight/2 - 10;
    }
    
    return targetCenter;
}
#pragma mark - Touch Handling

// 重写hitTest方法，优化全屏拖动体验
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // 如果播放器不可见或不接受用户交互，返回nil
    if (self.alpha < 0.01 || !self.userInteractionEnabled || self.hidden) {
        return nil;
    }
    
    // 如果正在拖动，优先处理拖动
    if (self.isDragging) {
        return self;
    }
    
    // 检查点击是否在关闭按钮上（关闭按钮优先级最高）
    if (self.closeButton) {
        CGPoint closeButtonPoint = [self convertPoint:point toView:self.closeButton];
        if (CGRectContainsPoint(self.closeButton.bounds, closeButtonPoint)) {
            return self.closeButton;
        }
    }
    
    // 检查点击是否在播放器背景视图内
    CGPoint backgroundPoint = [self convertPoint:point toView:self.backgroundView];
    if (CGRectContainsPoint(self.backgroundView.bounds, backgroundPoint)) {
        // 检查是否点击在控制按钮上
        NSArray *controlButtons = @[self.playButton, self.previousButton, self.nextButton];
        for (UIButton *button in controlButtons) {
            if (button) {
                CGPoint buttonPoint = [self convertPoint:point toView:button];
                if (CGRectContainsPoint(button.bounds, buttonPoint)) {
                    return button; // 返回具体按钮
                }
            }
        }
        
        // 检查是否点击在进度条上
        if (self.progressSlider) {
            CGPoint sliderPoint = [self convertPoint:point toView:self.progressSlider];
            if (CGRectContainsPoint(self.progressSlider.bounds, sliderPoint)) {
                return self.progressSlider;
            }
        }
        
        // 在背景视图内但不在具体控件上，支持拖动
        return self.enableFullScreenDrag ? self : self.backgroundView;
    }
    
    // 全屏拖动模式下，即使点击在播放器外部也可能需要处理拖动
    if (self.enableFullScreenDrag && !CGRectContainsPoint(self.backgroundView.frame, point)) {
        // 检查是否在合理的拖动范围内（例如播放器周围50像素的区域）
        CGRect expandedFrame = CGRectInset(self.backgroundView.frame, -50, -50);
        if (CGRectContainsPoint(expandedFrame, point)) {
            return self; // 在扩展区域内，支持拖动
        }
    }
    
    // 点击在播放器外部，返回nil让下层视图处理
    return nil;
}

// 修改背景点击方法
- (void)backgroundTapped:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    
    // 检查是否点击在背景视图或关闭按钮上
    BOOL hitBackground = CGRectContainsPoint(self.backgroundView.frame, location);
    BOOL hitCloseButton = self.closeButton && CGRectContainsPoint(self.closeButton.frame, location);
    
    // 只有在点击播放器外部区域时才隐藏
    if (!hitBackground && !hitCloseButton) {
        [self hide];
    }
}
// 添加调试信息方法（简化版）
- (void)logDragDebugInfoWithGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [gesture translationInView:self.superview];
        CGPoint velocity = [gesture velocityInView:self.superview];
        
        NSString *stateString = (gesture.state == UIGestureRecognizerStateBegan) ? @"开始" : @"结束";
        NSLog(@"🎯 拖动%@ - 位置:(%.1f,%.1f) 位移:(%.1f,%.1f) 速度:(%.1f,%.1f)",
              stateString, self.center.x, self.center.y, translation.x, translation.y, velocity.x, velocity.y);
    }
}
#pragma mark - UIGestureRecognizerDelegate

// 允许手势与其他手势同时识别
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 如果是拖动手势，只允许与点击手势同时识别
    if (gestureRecognizer == self.panGesture) {
        return [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
    }
    return NO;
}

// 决定手势是否应该开始 - 全屏拖动优化版本
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGesture) {
        CGPoint location = [gestureRecognizer locationInView:self];
        
        // 全屏拖动模式下的逻辑
        if (self.enableFullScreenDrag) {
            // 检查是否在控制按钮上
            NSArray *controlButtons = @[self.playButton, self.previousButton, self.nextButton, self.closeButton];
            for (UIButton *button in controlButtons) {
                if (button) {
                    CGPoint buttonLocation = [gestureRecognizer locationInView:button];
                    if (CGRectContainsPoint(button.bounds, buttonLocation)) {
                        return NO; // 在按钮上，不启动拖动
                    }
                }
            }
            
            // 检查是否在进度条上
            if (self.progressSlider) {
                CGPoint sliderLocation = [gestureRecognizer locationInView:self.progressSlider];
                if (CGRectContainsPoint(self.progressSlider.bounds, sliderLocation)) {
                    return NO; // 在进度条上，不启动拖动
                }
            }
            
            // 全屏拖动模式下，其他区域都可以拖动
            return YES;
        } else {
            // 非全屏拖动模式，只有在背景视图内且不在控件上才能拖动
            CGPoint backgroundLocation = [self convertPoint:location fromView:self];
            if (!CGRectContainsPoint(self.backgroundView.frame, backgroundLocation)) {
                return NO; // 不在背景视图内
            }
            
            // 检查是否在进度条上
            CGRect sliderFrame = [self convertRect:self.progressSlider.frame fromView:self.progressSlider.superview];
            if (CGRectContainsPoint(sliderFrame, backgroundLocation)) {
                return NO;
            }
            
            // 检查是否在其他按钮上
            for (UIView *subview in self.containerView.subviews) {
                if ([subview isKindOfClass:[UIButton class]]) {
                    CGRect buttonFrame = [self convertRect:subview.frame fromView:subview.superview];
                    if (CGRectContainsPoint(buttonFrame, backgroundLocation)) {
                        return NO;
                    }
                }
            }
            
            return YES;
        }
    }
    return YES;
}

#pragma mark - Drag Configuration Methods

// 配置拖动行为
- (void)configureDragBehaviorWithEdgeSnapping:(BOOL)enableSnapping
                              allowOutOfBounds:(BOOL)allowBounds
                             enableFullScreen:(BOOL)enableFullScreen {
    self.enableEdgeSnapping = enableSnapping;
    self.allowOutOfBounds = allowBounds;
    self.enableFullScreenDrag = enableFullScreen;
    
    // 重新设置拖动手势
    if (self.panGesture) {
        if (enableFullScreen) {
            [self.backgroundView removeGestureRecognizer:self.panGesture];
            [self addGestureRecognizer:self.panGesture];
        } else {
            [self removeGestureRecognizer:self.panGesture];
            [self.backgroundView addGestureRecognizer:self.panGesture];
        }
    }
    
    NSLog(@"🎛️ 拖动行为已配置 - 边缘吸附:%@, 允许超界:%@, 全屏拖动:%@",
          enableSnapping ? @"是" : @"否",
          allowBounds ? @"是" : @"否",
          enableFullScreen ? @"是" : @"否");
}

// 设置拖动参数
- (void)setDragParameters:(CGFloat)edgeResistance decelerationRate:(CGFloat)deceleration {
    self.dragResistanceEdge = MAX(0.1, MIN(1.0, edgeResistance)); // 限制在0.1-1.0之间
    self.dragDecelerationRate = MAX(0.8, MIN(0.98, deceleration)); // 限制在0.8-0.98之间
    
    NSLog(@"🎛️ 拖动参数已更新 - 边缘阻力:%.2f, 减速率:%.2f",
          self.dragResistanceEdge, self.dragDecelerationRate);
}

#pragma mark - Toast Message Configuration Methods

//// 设置上一首按钮的提示信息
//- (void)setPreviousButtonMessage:(NSString *)message {
//    self.previousButtonMessage = message ?: @"已是第一首";
//    NSLog(@"🔔 上一首提示信息已设置: %@", self.previousButtonMessage);
//}
//
//// 设置下一首按钮的提示信息
//- (void)setNextButtonMessage:(NSString *)message {
//    self.nextButtonMessage = message ?: @"已是最后一首";
//    NSLog(@"🔔 下一首提示信息已设置: %@", self.nextButtonMessage);
//}

@end
