//
//  AudioPlayerView.m
//  AIToys
//
//  Created by Assistant on 2025/10/17.
//

#import "AudioPlayerView.h"
#import <Masonry/Masonry.h>

@interface AudioPlayerView () <AVAudioPlayerDelegate>

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

// 下载动画相关
@property (nonatomic, strong) CAGradientLayer *glowBorderLayer; // 流光边框层
@property (nonatomic, strong) CALayer *glowMaskLayer; // 遮罩层

// 音频相关
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, copy) NSString *audioURL;
@property (nonatomic, copy) NSString *storyTitle;
@property (nonatomic, copy) NSString *coverImageURL;

// 动画相关
// 移除了波形动画相关属性，简化设计

@end

@implementation AudioPlayerView

#pragma mark - Initialization

- (instancetype)initWithAudioURL:(NSString *)audioURL storyTitle:(NSString *)title coverImageURL:(NSString *)coverImageURL {
    self = [super init];
    if (self) {
        self.audioURL = audioURL;
        self.storyTitle = title ?: @"Story Audio";
        self.coverImageURL = coverImageURL;
        [self setupUI];
        [self setupAudioPlayer];
    }
    return self;
}

- (void)dealloc {
    [self.progressTimer invalidate];
    [self.audioPlayer stop];
}

#pragma mark - Setup Methods

- (void)setupUI {
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
    
    // 修改：边框为浅灰色
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
    
    // 添加手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)setupControlButtons {
    // 关闭按钮 - 右上角，使用自定义图片
        // 重要修改：将关闭按钮添加到 self 而不是 containerView
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *closeImage = [UIImage imageNamed:@"close_layer"];
        if (!closeImage) {
            // 如果找不到自定义图片，使用系统图片作为备用
            closeImage = [UIImage systemImageNamed:@"xmark.circle.fill"];
            // 调整系统图片的颜色和大小
            closeImage = [closeImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
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
    self.previousButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.previousButton setImage:[UIImage systemImageNamed:@"backward.fill"] forState:UIControlStateNormal];
    self.previousButton.tintColor = [UIColor systemBlueColor];
    [self.previousButton addTarget:self action:@selector(previousButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.previousButton];
    
    // 播放按钮 - 更大，蓝色背景
    self.playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.playButton setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
    self.playButton.tintColor = [UIColor whiteColor];
    self.playButton.backgroundColor = [UIColor systemBlueColor];
    self.playButton.layer.cornerRadius = 25; // 圆形按钮
    [self.playButton addTarget:self action:@selector(playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.playButton];
    
    // 下一首按钮
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextButton setImage:[UIImage systemImageNamed:@"forward.fill"] forState:UIControlStateNormal];
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
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.coverImageURL]];
   
    
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

#pragma mark - Loading Animation Methods

// 创建高级配色的跑马灯流光边框动画
- (void)createGlowBorderAnimation {
    if (self.glowBorderLayer) {
        NSLog(@"⚠️ 流光层已存在，跳过创建");
        return;
    }
    
    // 强制布局更新，确保 bounds 正确
    [self.backgroundView layoutIfNeeded];
    
    CGRect bounds = self.backgroundView.bounds;
    NSLog(@"🎨 创建高级跑马灯流光动画 - backgroundView bounds: %.2f x %.2f", bounds.size.width, bounds.size.height);
    
    if (bounds.size.width == 0 || bounds.size.height == 0) {
        NSLog(@"⚠️ backgroundView bounds 为空，延迟创建动画");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createGlowBorderAnimation];
        });
        return;
    }
    
    // 创建渐变层作为流光效果
    self.glowBorderLayer = [CAGradientLayer layer];
    self.glowBorderLayer.frame = bounds;
    self.glowBorderLayer.cornerRadius = 35;
    
    // 高级配色方案 - 深蓝紫渐变，更显高级感
    NSArray *colors = @[
        (id)[UIColor colorWithRed:0.1 green:0.1 blue:0.4 alpha:1.0].CGColor,     // 深蓝色
        (id)[UIColor colorWithRed:0.3 green:0.1 blue:0.5 alpha:1.0].CGColor,     // 蓝紫色
        (id)[UIColor colorWithRed:0.5 green:0.2 blue:0.6 alpha:1.0].CGColor,     // 紫色
        (id)[UIColor colorWithRed:0.2 green:0.4 blue:0.7 alpha:1.0].CGColor,     // 宝蓝色
        (id)[UIColor colorWithRed:0.1 green:0.3 blue:0.6 alpha:1.0].CGColor,     // 深宝蓝
        (id)[UIColor colorWithRed:0.1 green:0.1 blue:0.4 alpha:1.0].CGColor,     // 深蓝色
        (id)[UIColor colorWithRed:0.3 green:0.1 blue:0.5 alpha:1.0].CGColor,     // 蓝紫色
        (id)[UIColor colorWithRed:0.5 green:0.2 blue:0.6 alpha:1.0].CGColor      // 紫色
    ];
    self.glowBorderLayer.colors = colors;
    
    // 设置渐变位置，创建连续的色彩带
    self.glowBorderLayer.locations = @[@0.0, @0.125, @0.25, @0.375, @0.5, @0.625, @0.75, @0.875];
    
    // 设置渐变方向 - 水平方向，便于实现跑马灯效果
    self.glowBorderLayer.startPoint = CGPointMake(0, 0.5);
    self.glowBorderLayer.endPoint = CGPointMake(1, 0.5);
    
    // 创建边框遮罩
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    
    // 外边框路径
    UIBezierPath *outerPath = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:35];
    
    // 内边框路径（缩小形成边框效果）
    CGFloat borderWidth = 3.0;
    CGRect innerRect = CGRectInset(bounds, borderWidth, borderWidth);
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithRoundedRect:innerRect cornerRadius:35 - borderWidth];
    
    // 使用 evenOddFillRule 创建边框效果
    [outerPath appendPath:innerPath];
    outerPath.usesEvenOddFillRule = YES;
    
    maskLayer.path = outerPath.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    
    self.glowBorderLayer.mask = maskLayer;
    self.glowMaskLayer = maskLayer;
    
    // 添加到背景视图的最上层
    [self.backgroundView.layer addSublayer:self.glowBorderLayer];
    
    NSLog(@"✨ 已创建高级跑马灯流光边框动画层");
}

// 开始高级跑马灯流光边框动画
- (void)startGlowBorderAnimation {
    [self createGlowBorderAnimation];
    
    if (!self.glowBorderLayer) {
        NSLog(@"⚠️ 流光层创建失败，无法启动动画");
        return;
    }
    
    // 下载时隐藏浅灰色边框，显示流光效果
    self.backgroundView.layer.borderColor = [UIColor clearColor].CGColor;
    
    // 创建跑马灯动画 - 通过移动渐变位置实现
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    animation.fromValue = @[@0.0, @0.125, @0.25, @0.375, @0.5, @0.625, @0.75, @0.875];
    animation.toValue = @[@0.125, @0.25, @0.375, @0.5, @0.625, @0.75, @0.875, @1.0];
    animation.duration = 2.0; // 稍微慢一点，更显高级感
    animation.repeatCount = HUGE_VALF;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    // 添加微妙的颜色变化动画，让色彩更加高级
    CAKeyframeAnimation *colorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"colors"];
    
    // 高级配色方案1 - 深蓝紫系
    NSArray *colorSet1 = @[
        (id)[UIColor colorWithRed:0.1 green:0.1 blue:0.4 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.3 green:0.1 blue:0.5 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.5 green:0.2 blue:0.6 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.2 green:0.4 blue:0.7 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.1 green:0.3 blue:0.6 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.1 green:0.1 blue:0.4 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.3 green:0.1 blue:0.5 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.5 green:0.2 blue:0.6 alpha:1.0].CGColor
    ];
    
    // 高级配色方案2 - 稍微提亮
    NSArray *colorSet2 = @[
        (id)[UIColor colorWithRed:0.15 green:0.15 blue:0.45 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.35 green:0.15 blue:0.55 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.55 green:0.25 blue:0.65 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.25 green:0.45 blue:0.75 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.15 green:0.35 blue:0.65 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.15 green:0.15 blue:0.45 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.35 green:0.15 blue:0.55 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.55 green:0.25 blue:0.65 alpha:1.0].CGColor
    ];
    
    colorAnimation.values = @[colorSet1, colorSet2, colorSet1];
    colorAnimation.keyTimes = @[@0.0, @0.5, @1.0];
    colorAnimation.duration = 4.0; // 更慢的颜色变化
    colorAnimation.repeatCount = HUGE_VALF;
    colorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // 组合动画
    [self.glowBorderLayer addAnimation:animation forKey:@"marqueeAnimation"];
    [self.glowBorderLayer addAnimation:colorAnimation forKey:@"colorAnimation"];
    
    NSLog(@"✨ 高级跑马灯流光边框动画已开始");
}

// 停止流光边框动画
- (void)stopGlowBorderAnimation {
    if (self.glowBorderLayer) {
        [self.glowBorderLayer removeAllAnimations];
        [self.glowBorderLayer removeFromSuperlayer];
        self.glowBorderLayer = nil;
        self.glowMaskLayer = nil;
        
        // 停止动画后恢复浅灰色边框
        self.backgroundView.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor;
        
        NSLog(@"✨ 流光边框动画已停止，恢复浅灰色边框");
    }
}

- (void)setupConstraints {
    // 获取屏幕宽度进行对比
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    // 背景视图约束
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(8);
        make.right.equalTo(self).offset(-8);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-30);
        make.height.mas_equalTo(70);
    }];
    
    // 封面图 - 左侧圆形
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(5);
        make.centerY.equalTo(self.containerView);
        make.width.height.mas_equalTo(60);
    }];
    
    // 标题 - 封面图右侧，但要避开关闭按钮
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView.mas_right).offset(12);
        make.top.equalTo(self.containerView).offset(8);
        make.right.lessThanOrEqualTo(self.closeButton.mas_left).offset(-8);
    }];
    
    // 关闭按钮 - 直接定位到背景视图的右上角
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backgroundView).offset(-10); // 在背景视图上方10点
            make.right.equalTo(self.backgroundView).offset(-10); // 在背景视图右方10点
            make.width.height.mas_equalTo(24);
        }];
    
    // 进度条 - 标题下方，占据更多可用空间
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
        make.right.equalTo(self.previousButton.mas_left).offset(-15);
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
        make.right.equalTo(self.containerView).offset(-15);
        make.centerY.equalTo(self.containerView);
        make.width.height.mas_equalTo(30);
    }];
    
    // 播放按钮 - 下一首左侧，较大
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.nextButton.mas_left).offset(-12);
        make.centerY.equalTo(self.containerView);
        make.width.height.mas_equalTo(50);
    }];
    
    // 上一首按钮 - 播放按钮左侧
    [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.playButton.mas_left).offset(-12);
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
    
    // 加载音频文件
    [self loadAudioFromURL:self.audioURL];
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
    
    // 开始流光边框动画
    [self startGlowBorderAnimation];
    
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 下载完成后停止流光动画
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopGlowBorderAnimation];
        });
        
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
            NSLog(@"✅ 音频下载成功，开始播放");
            [self createAudioPlayerWithURL:destinationURL];
        });
    }];
    
    [downloadTask resume];
}

- (void)showErrorMessage:(NSString *)message {
    // 停止流光动画
    [self stopGlowBorderAnimation];
    
    self.titleLabel.text = message;
    self.titleLabel.textColor = [UIColor systemRedColor];
    
    // 3秒后隐藏播放器
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hide];
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
    
    // 自动开始播放
    [self play];
}

#pragma mark - Public Methods

- (void)showInView:(UIView *)parentView {
    [parentView addSubview:self];
    
    // 先确保背景视图有正确的初始transform
    self.backgroundView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    // 动画显示
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1.0;
        self.backgroundView.transform = CGAffineTransformIdentity; // 重置为标准transform
    } completion:^(BOOL finished) {
        // 确保transform完全重置
        self.backgroundView.transform = CGAffineTransformIdentity;
        
        // 强制布局更新
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
        // 延迟一点再检查，确保布局完成
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self logWidthComparison];
        });
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
        make.left.equalTo(self).offset(8);           // 直接使用left/right
        make.right.equalTo(self).offset(-8);
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
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
        self.backgroundView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self stop];
        
        if ([self.delegate respondsToSelector:@selector(audioPlayerDidClose)]) {
            [self.delegate audioPlayerDidClose];
        }
    }];
}

- (void)play {
    if (self.audioPlayer) {
        [self.audioPlayer play];
        [self startProgressTimer];
        [self updatePlayButtonImage:YES];
        
        if ([self.delegate respondsToSelector:@selector(audioPlayerDidStartPlaying)]) {
            [self.delegate audioPlayerDidStartPlaying];
        }
    }
}

- (void)pause {
    if (self.audioPlayer) {
        [self.audioPlayer pause];
        [self stopProgressTimer];
        [self updatePlayButtonImage:NO];
        
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
        [self updatePlayButtonImage:NO];
        [self updateProgress];
    }
}

- (BOOL)isPlaying {
    return self.audioPlayer.isPlaying;
}

#pragma mark - Private Methods

- (void)updatePlayButtonImage:(BOOL)isPlaying {
    NSString *imageName = isPlaying ? @"pause.fill" : @"play.fill";
    [self.playButton setImage:[UIImage systemImageNamed:imageName] forState:UIControlStateNormal];
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
        self.progressSlider.value = currentTime;
        
        // 更新时间标签显示当前时间并跟随滑块位置
        [self updateTimeLabelPosition];
        
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
    if (!self.audioPlayer || !self.timeLabelCenterXConstraint) return;
    
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
        self.timeLabelCenterXConstraint = make.centerX.equalTo(self.progressSlider.mas_left).offset(thumbCenterOffset);
    }];
    
    // 强制布局更新
    [self.timeLabel.superview layoutIfNeeded];
}

#pragma mark - Actions

- (void)playButtonTapped {
    if (self.audioPlayer.isPlaying) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)previousButtonTapped {
    NSLog(@"上一首按钮点击");
    // 可以通过代理通知外部处理上一首逻辑
}

- (void)nextButtonTapped {
    NSLog(@"下一首按钮点击");
    // 可以通过代理通知外部处理下一首逻辑
}

- (void)closeButtonTapped {
    [self hide];
}

- (void)backgroundTapped:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    if (!CGRectContainsPoint(self.backgroundView.frame, location)) {
        // 点击播放器外部区域不隐藏，因为现在背景是透明的
        // [self hide];
    }
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
    [self updatePlayButtonImage:NO];
    
    // 重置播放位置
    self.audioPlayer.currentTime = 0;
    [self updateProgress];
    
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidFinish)]) {
        [self.delegate audioPlayerDidFinish];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    NSLog(@"音频播放解码错误: %@", error.localizedDescription);
}

@end
