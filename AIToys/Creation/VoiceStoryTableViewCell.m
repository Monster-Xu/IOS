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
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    
    // 封面图
    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.layer.cornerRadius = 8;
    self.coverImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [self.contentView addSubview:self.coverImageView];
    
    // New标签（在封面图上层）
    self.badgeView = [[UIView alloc] init];
    self.badgeView.backgroundColor = [UIColor systemOrangeColor];
    self.badgeView.layer.cornerRadius = 10;
    self.badgeView.hidden = YES;
    [self.contentView addSubview:self.badgeView];
    
    self.badgeLabel = [[UILabel alloc] init];
    self.badgeLabel.text = @"New";
    self.badgeLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.badgeView addSubview:self.badgeLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.badgeLabel.centerXAnchor constraintEqualToAnchor:self.badgeView.centerXAnchor],
        [self.badgeLabel.centerYAnchor constraintEqualToAnchor:self.badgeView.centerYAnchor]
    ]];
    
    // 标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.numberOfLines = 2;
    [self.contentView addSubview:self.titleLabel];
    
    // 副标题（Voice - Dad 或 No Voice）
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:self.subtitleLabel];
    
    // 状态视图（生成中/失败）
    self.statusView = [[UIView alloc] init];
    self.statusView.layer.cornerRadius = 6;
    self.statusView.hidden = YES;
    [self.contentView addSubview:self.statusView];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont systemFontOfSize:13];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statusView addSubview:self.statusLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.statusView.leadingAnchor constant:12],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.statusView.trailingAnchor constant:-12],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.statusView.topAnchor constant:6],
        [self.statusLabel.bottomAnchor constraintEqualToAnchor:self.statusView.bottomAnchor constant:-6]
    ]];
    
    // 编辑按钮
    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.editButton setImage:[UIImage systemImageNamed:@"pencil"] forState:UIControlStateNormal];
    self.editButton.tintColor = [UIColor systemGrayColor];
    [self.editButton addTarget:self action:@selector(editButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.editButton];
    
    // 播放/暂停按钮
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage systemImageNamed:@"play.circle.fill"] forState:UIControlStateNormal];
    self.playButton.tintColor = [UIColor systemGrayColor];
    [self.playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.playButton];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    self.coverImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusView.translatesAutoresizingMaskIntoConstraints = NO;
    self.editButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.badgeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        // 封面图
        [self.coverImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.coverImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.coverImageView.widthAnchor constraintEqualToConstant:60],
        [self.coverImageView.heightAnchor constraintEqualToConstant:60],
        
        // New标签
        [self.badgeView.leadingAnchor constraintEqualToAnchor:self.coverImageView.leadingAnchor constant:4],
        [self.badgeView.topAnchor constraintEqualToAnchor:self.coverImageView.topAnchor constant:4],
        [self.badgeView.widthAnchor constraintEqualToConstant:40],
        [self.badgeView.heightAnchor constraintEqualToConstant:20],
        
        // 标题
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.coverImageView.trailingAnchor constant:12],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.editButton.leadingAnchor constant:-8],
        
        // 副标题
        [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:4],
        
        // 状态视图
        [self.statusView.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.statusView.topAnchor constraintEqualToAnchor:self.subtitleLabel.bottomAnchor constant:6],
        [self.statusView.trailingAnchor constraintEqualToAnchor:self.editButton.leadingAnchor constant:-8],
        
        // 编辑按钮
        [self.editButton.trailingAnchor constraintEqualToAnchor:self.playButton.leadingAnchor constant:-12],
        [self.editButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.editButton.widthAnchor constraintEqualToConstant:30],
        [self.editButton.heightAnchor constraintEqualToConstant:30],
        
        // 播放按钮
        [self.playButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.playButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.playButton.widthAnchor constraintEqualToConstant:36],
        [self.playButton.heightAnchor constraintEqualToConstant:36]
    ]];
}

- (void)setModel:(VoiceStoryModel *)model {
    _model = model;
    
    // 设置标题
    self.titleLabel.text = model.storyName;
    
    // 设置封面图
    if (model.illustrationUrl && model.illustrationUrl.length > 0) {
        // TODO: 使用SDWebImage加载图片
        // [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.illustrationUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        self.coverImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    }
    
    // New标签
    self.badgeView.hidden = !model.isNew;
    
    // 根据状态设置UI
    if ([model.status isEqualToString:@"generating"]) {
        // 生成中状态
        [self configureGeneratingState];
    } else if ([model.status isEqualToString:@"failed"]) {
        // 失败状态
        [self configureFailedState];
    } else if ([model.status isEqualToString:@"completed"]) {
        // 完成状态
        [self configureCompletedState];
    } else {
        // 待处理状态
        [self configurePendingState];
    }
}

- (void)configureGeneratingState {
    // 隐藏副标题，显示状态视图
    self.subtitleLabel.hidden = YES;
    self.statusView.hidden = NO;
    self.statusView.backgroundColor = [UIColor colorWithRed:1.0 green:0.95 blue:0.8 alpha:1.0]; // 浅橙色背景
    self.statusView.layer.cornerRadius = 4; // 圆角
    self.statusLabel.text = @"Story Generation...";
    self.statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.0 alpha:1.0]; // 橙色文字
    
    // 隐藏编辑按钮
    self.editButton.hidden = YES;
    
    // 禁用播放按钮
    self.playButton.enabled = NO;
    self.playButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.playButton setImage:[UIImage systemImageNamed:@"play.circle.fill"] forState:UIControlStateNormal];
}

- (void)configureFailedState {
    // 隐藏副标题，显示状态视图
    self.subtitleLabel.hidden = YES;
    self.statusView.hidden = NO;
    self.statusView.backgroundColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0]; // 浅红色
    self.statusLabel.text = @"Generation Failed, Please Try Again";
    self.statusLabel.textColor = [UIColor systemRedColor];
    
    // 显示编辑按钮
    self.editButton.hidden = NO;
    
    // 禁用播放按钮
    self.playButton.enabled = NO;
    self.playButton.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.playButton setImage:[UIImage systemImageNamed:@"play.circle.fill"] forState:UIControlStateNormal];
}

- (void)configureCompletedState {
    // 隐藏状态视图，显示副标题
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
        [self.playButton setImage:[UIImage systemImageNamed:@"pause.circle.fill"] forState:UIControlStateNormal];
        self.playButton.tintColor = [UIColor systemBlueColor];
    } else {
        [self.playButton setImage:[UIImage systemImageNamed:@"play.circle.fill"] forState:UIControlStateNormal];
        self.playButton.tintColor = [UIColor systemGrayColor];
    }
}

- (void)configurePendingState {
    // 隐藏状态视图，显示副标题
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    // 在编辑模式下隐藏播放和编辑按钮，让位给选择控件
    if (editing) {
        self.playButton.hidden = YES;
        self.editButton.hidden = YES;
    } else {
        self.playButton.hidden = NO;
        self.editButton.hidden = NO;
    }
}

@end

