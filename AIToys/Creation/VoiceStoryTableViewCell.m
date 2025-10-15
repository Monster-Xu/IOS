//
//  VoiceStoryTableViewCell.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/1.
//

#import "VoiceStoryTableViewCell.h"
#import "VoiceStoryModel.h"

@implementation VoiceStoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 默认不是批量编辑模式
        _isBatchEditingMode = NO;
        
        // 设置 cell 背景为透明，显示父视图背景色
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 配置选择样式
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.tintColor = [UIColor systemBlueColor];
    
    // 创建白色卡片容器视图
    UIView *cardContainerView = [[UIView alloc] init];
    cardContainerView.backgroundColor = [UIColor whiteColor];
    cardContainerView.layer.cornerRadius = 20;
    cardContainerView.layer.masksToBounds = YES;
    [self.contentView addSubview:cardContainerView];
    
    // 使用Masonry设置卡片容器的约束：左右各16，上下填满（无边距）
    [cardContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.top.equalTo(self.contentView);      // ✅ 移除上边距
        make.bottom.equalTo(self.contentView);   // ✅ 移除下边距
    }];
    
    // 封面图
    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.layer.cornerRadius = 8;
    self.coverImageView.image = [UIImage imageNamed:@"home_toys_img"];
    self.coverImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [cardContainerView addSubview:self.coverImageView];
    
    // New标签
    self.badgeImageView = [[UIImageView alloc] init];
    self.badgeImageView.image = [UIImage imageNamed:@"create_new"];
    self.badgeImageView.hidden = YES;
    [cardContainerView addSubview:self.badgeImageView];
    
    
    // ⭐️ 状态视图 - 显示在封面图下方
    self.statusView = [[UIView alloc] init];
    self.statusView.layer.cornerRadius = 4;
    self.statusView.hidden = YES;
    [cardContainerView addSubview:self.statusView];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont systemFontOfSize:14]; // 更小的字体
    self.statusLabel.textAlignment = NSTextAlignmentLeft;
    self.statusLabel.numberOfLines = 2; // 允许两行显示
    [self.statusView addSubview:self.statusLabel];
    
    // 使用Masonry设置statusLabel约束
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.statusView).offset(4);
        make.right.equalTo(self.statusView).offset(-4);
        make.top.equalTo(self.statusView).offset(3);
        make.bottom.equalTo(self.statusView).offset(-3);
    }];
    
    // 标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.numberOfLines = 2;
    [cardContainerView addSubview:self.titleLabel];
    
    // 副标题
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.borderWidth = 1;
    self.subtitleLabel.borderColor = [UIColor blueColor];
    self.subtitleLabel.font = [UIFont systemFontOfSize:13];
    [cardContainerView addSubview:self.subtitleLabel];
    
    // 编辑按钮
    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.editButton setImage:[UIImage imageNamed:@"create_edit"] forState:UIControlStateNormal];
    self.editButton.tintColor = [UIColor systemGrayColor];
    [self.editButton addTarget:self action:@selector(editButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cardContainerView addSubview:self.editButton];
    
    // 播放按钮
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage imageNamed:@"create_play"] forState:UIControlStateNormal];
    self.playButton.tintColor = [UIColor systemGrayColor];
    [self.playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cardContainerView addSubview:self.playButton];
    
    [self setupConstraintsWithContainer:cardContainerView];
}

- (void)setupConstraintsWithContainer:(UIView *)cardContainer {
    // 封面图 - 左上角
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cardContainer).offset(12);
        make.top.equalTo(cardContainer).offset(12);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(64);
    }];
    
    // New标签 - 在封面图上层
    [self.badgeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView).offset(0);
        make.top.equalTo(self.coverImageView).offset(0);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(20);
    }];
    
    // 播放按钮 - 最右侧居中（先布局，因为标题需要参考它）
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cardContainer).offset(-16);
        make.centerY.equalTo(cardContainer);
        make.width.height.mas_equalTo(24);
    }];
    
    // 编辑按钮 - 播放按钮左侧居中
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.playButton.mas_left).offset(-12);
        make.centerY.equalTo(cardContainer);
        make.width.height.mas_equalTo(24);
    }];
    
    // 标题 - 封面图右侧顶部对齐
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView.mas_right).offset(12);
        make.top.equalTo(cardContainer).offset(14);
        make.right.equalTo(self.editButton.mas_left).offset(-8);
    }];
    
    // 副标题 - 标题下方
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
//        make.right.equalTo(self.titleLabel);
    }];
    
    // 状态视图 - 卡片底部，左右各12边距
    [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cardContainer).offset(12);
        make.right.equalTo(cardContainer).offset(-12);
        make.bottom.equalTo(cardContainer).offset(-6);
        make.height.mas_equalTo(20);
    }];
}

- (void)setModel:(VoiceStoryModel *)model {
    _model = model;
    
    self.titleLabel.text = model.storyName;
    
    if (model.illustrationUrl && model.illustrationUrl.length > 0) {
        self.coverImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    }
    
    self.badgeImageView.hidden = !model.isNew;
    
    if (model.storyStatus ==1) {
        [self configureGeneratingState];
    } else if (model.storyStatus ==3) {
        [self configureFailedState];
    } else if (model.storyStatus ==2||model.storyStatus==5) {
        [self configureCompletedState];
    } else {
        [self configurePendingState];
    }
}

- (void)configureGeneratingState {
    // ⭐️ 状态提示显示在封面图下方
    self.subtitleLabel.hidden = YES; // 隐藏 Voice 信息
    self.statusView.hidden = NO;
    self.statusView.backgroundColor = [UIColor colorWithRed:1.0 green:0.95 blue:0.8 alpha:1.0]; // 浅橙色
    self.statusView.layer.cornerRadius = 4;
    self.statusLabel.text = @"  Story Generation...";
    self.statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0]; // 橙色文字
    
    // 隐藏编辑按钮
    self.editButton.hidden = YES;
    
    // 禁用播放按钮
    self.playButton.enabled = NO;
    self.playButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.playButton setImage:[UIImage systemImageNamed:@"play.circle.fill"] forState:UIControlStateNormal];
}

- (void)configureFailedState {
    // ⭐️ 状态提示显示在封面图下方
    self.subtitleLabel.hidden = YES; // 隐藏 Voice 信息
    self.statusView.hidden = NO;
    self.statusView.backgroundColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0]; // 浅红色
    self.statusLabel.text = @"   Failed, Try Again";
    self.statusLabel.textColor = [UIColor systemRedColor];
    
    // 显示编辑按钮
    self.editButton.hidden = NO;
    
    // 禁用播放按钮
    self.playButton.enabled = NO;
    self.playButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.playButton setImage:[UIImage systemImageNamed:@"play.circle.fill"] forState:UIControlStateNormal];
}

- (void)configureCompletedState {
    // ⭐️ 隐藏状态视图，显示副标题
    self.statusView.hidden = YES;
    self.subtitleLabel.hidden = NO;
    
    // 设置声音信息
    if (self.model.voiceName && self.model.voiceName.length > 0 && ![self.model.voiceName isEqualToString:@"--"]) {
        self.subtitleLabel.text = [NSString stringWithFormat:@"Voice - %@", self.model.voiceName];
        self.subtitleLabel.textColor = [UIColor systemBlueColor];
    } else {
        self.subtitleLabel.text = @"No Voice";
        self.subtitleLabel.textColor = [UIColor systemGrayColor];
    }
    
    // 显示编辑按钮
    self.editButton.hidden = NO;
    
    // 启用播放按钮
    self.playButton.enabled = YES;
    
    // 根据播放状态设置按钮样式
    if (self.model.isPlaying) {
        [self.playButton setImage:[UIImage imageNamed:@"create_pause"] forState:UIControlStateNormal];
        self.playButton.tintColor = [UIColor systemBlueColor];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"create_play"] forState:UIControlStateNormal];
        self.playButton.tintColor = [UIColor systemGrayColor];
    }
}

- (void)configurePendingState {
    // ⭐️ 隐藏状态视图，显示副标题
    self.statusView.hidden = YES;
    self.subtitleLabel.hidden = NO;
    self.subtitleLabel.text = @"No Voice";
    self.subtitleLabel.textColor = [UIColor systemGrayColor];
    
    // 显示编辑按钮
    self.editButton.hidden = NO;
    
    // 禁用播放按钮
    self.playButton.enabled = NO;
    self.playButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.playButton setImage:[UIImage systemImageNamed:@"play.circle.fill"] forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)editButtonTapped:(UIButton *)sender {
    if (self.settingsButtonTapped) {
        self.settingsButtonTapped();
    }
}

- (void)playButtonTapped:(UIButton *)sender {
    if (self.playButtonTapped) {
        self.playButtonTapped();
    }
}

#pragma mark - Editing Mode

// ⭐️ 核心方法：使用明确的标记判断编辑模式
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    NSLog(@"Cell setEditing: %@, isBatchEditingMode: %@",
          editing ? @"YES" : @"NO",
          self.isBatchEditingMode ? @"YES" : @"NO");
    
    // 清晰的判断逻辑：
    // 1. 批量编辑模式（isBatchEditingMode = YES）：隐藏按钮，显示选择框
    // 2. 左滑删除（editing = YES, isBatchEditingMode = NO）：显示按钮
    // 3. 正常模式（editing = NO）：显示按钮
    
    if (self.isBatchEditingMode && editing) {
        // 批量编辑模式：隐藏操作按钮
        NSLog(@"📱 批量编辑模式 - 隐藏按钮");
        self.playButton.hidden = YES;
        self.editButton.hidden = YES;
    } else {
        // 左滑删除或正常模式：显示按钮
        NSLog(@"📱 %@ - 显示按钮", editing ? @"左滑删除" : @"正常模式");
        
        // 根据故事状态决定按钮的可见性和可用性
        if (self.model) {
            if ([self.model.status isEqualToString:@"generating"]) {
                // 生成中：隐藏编辑按钮，显示禁用的播放按钮
                self.editButton.hidden = YES;
                self.playButton.hidden = NO;
                self.playButton.enabled = NO;
            } else if ([self.model.status isEqualToString:@"completed"]) {
                // 完成：显示所有按钮
                self.editButton.hidden = NO;
                self.playButton.hidden = NO;
                self.playButton.enabled = YES;
            } else {
                // 其他状态：显示编辑按钮，禁用播放按钮
                self.editButton.hidden = NO;
                self.playButton.hidden = NO;
                self.playButton.enabled = NO;
            }
        } else {
            // 没有模型数据：显示所有按钮
            self.editButton.hidden = NO;
            self.playButton.hidden = NO;
        }
    }
}

// 重置方法
- (void)prepareForReuse {
    [super prepareForReuse];
    
    // 重置批量编辑标记
    self.isBatchEditingMode = NO;
    
    // 重置按钮状态
    self.playButton.hidden = NO;
    self.editButton.hidden = NO;
    
    NSLog(@"Cell prepareForReuse - 重置状态");
}

@end
