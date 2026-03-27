//
//  VoiceManagementTableViewCell.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "VoiceManagementTableViewCell.h"
#import "VoiceModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface VoiceManagementTableViewCell ()

// 数据
@property (nonatomic, strong) VoiceModel *voiceModel;

// ✅ 编辑模式状态
@property (nonatomic, assign) BOOL isEditingMode;
@property (nonatomic, assign) BOOL isSelected;

@end

@implementation VoiceManagementTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // ✅ 设置圆角
    self.contentView.layer.cornerRadius = 20;
    self.contentView.clipsToBounds = YES;
    
    // 设置选中样式
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 初始化UI
    [self setupUI];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}



#pragma mark - 初始化UI

- (void)setupUI {
    // 设置背景颜色
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    // 设置按钮交互
    if (self.editButton) {
        [self.editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.playButton) {
        [self.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // ✅ 设置选择按钮
    if (self.chooseButton) {
        [self.chooseButton addTarget:self action:@selector(chooseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        // 初始状态隐藏选择按钮
        self.chooseButton.hidden = YES;
    }
    
    // ✅ 初始化编辑模式状态
    self.isEditingMode = NO;
    self.isSelected = NO;
}



#pragma mark - 数据绑定

/// ✅ 配置cell显示声音数据
- (void)configureWithVoiceModel:(VoiceModel *)voice {
    self.voiceModel = voice;
    
    if (!voice) {
        return;
    }
    
    // 根据createTime判断是否是当天创建的
        if (voice.createTime) {
            // 直接使用doubleValue，无论createTime是NSString还是NSNumber
            NSTimeInterval createTimeInterval = [voice.createTime doubleValue];
            
            // 🔧 处理毫秒时间戳：如果数值大于10位数，说明是毫秒时间戳，需要除以1000
            if (createTimeInterval > 9999999999) { // 10位数以上认为是毫秒时间戳
                createTimeInterval = createTimeInterval / 1000.0;
            }
            
            NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:createTimeInterval];
            
            // 获取当天的开始时间（00:00:00）
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *today = [NSDate date];
            NSDate *startOfToday = [calendar startOfDayForDate:today];
            
            // 获取明天的开始时间（用于判断范围）
            NSDate *startOfTomorrow = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startOfToday options:0];
            
            // 如果创建日期在今天范围内，则显示badge
            BOOL isCreatedToday = ([createDate compare:startOfToday] != NSOrderedAscending) && 
                                  ([createDate compare:startOfTomorrow] == NSOrderedAscending);
            
            
            self.createNewImageView.hidden = !isCreatedToday;
        } else {
            NSLog(@"⚠️ 音色 %@ 没有createTime数据", voice.voiceName ?: @"未知");
            self.createNewImageView.hidden = YES;
        }
    
    // 设置声音名称
    if (self.voiceNameLabel) {
        self.voiceNameLabel.text = voice.voiceName ?: LocalString(@"未命名");
        self.voiceNameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        self.voiceNameLabel.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
    }
    
    // 设置头像
    if (self.avatarImageView) {
        // ✅ 先清除上一个cell的头像图片，避免重用时的显示错乱
        self.avatarImageView.image = nil;
        
        if (voice.avatarUrl && voice.avatarUrl.length > 0) {
            // 异步加载网络图片
            [self loadImageFromURL:voice.avatarUrl];
        } else {
            // 使用默认图片
            self.avatarImageView.image = [UIImage imageNamed:@"默认头像"];
        }
    }
    
    // 根据音色状态更新UI
    [self updateUIForVoiceStatus:voice];
}



#pragma mark - 根据状态更新UI

/// 根据音色克隆状态更新UI显示
- (void)updateUIForVoiceStatus:(VoiceModel *)voice {
    // 先重置所有按钮状态
    [self resetButtonsState];
    
    
    
    
    
    switch (voice.cloneStatus) {
        case VoiceCloneStatusFailed:
            [self configureFailedState];
            break;
            
        case VoiceCloneStatusCloning:
            [self configureCloningState];
            break;
            
        case VoiceCloneStatusSuccess:
        case VoiceCloneStatusPending:
        default:
            // ✅ 成功状态、待克隆状态等不显示statusView，只配置按钮
            [self configureNormalState:voice];
            break;
    }
}

/// 重置按钮状态和statusView
- (void)resetButtonsState {
    // 隐藏状态视图
    self.statusView.hidden = YES;
    
    // ✅ 重置失败图标状态
    if (self.faildImgView) {
        self.faildImgView.hidden = YES;
    }
    
    // ✅ 重置statusLabel约束到默认状态
    if (self.statusLabelLeadingConstraint) {
        self.statusLabelLeadingConstraint.constant = 16; // 默认间距
    }
    
    // ✅ 重置statusLabel的文本显示属性到默认状态
    if (self.statusLabel) {
        self.statusLabel.text = @"";
        self.statusLabel.numberOfLines = 1;
        self.statusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.statusLabel.adjustsFontSizeToFitWidth = NO;
    }
    
    // 重置编辑按钮
    self.editButton.enabled = NO;
    self.editButton.hidden = NO;
    [self.editButton setImage:[UIImage imageNamed:@"create_edit"] forState:UIControlStateNormal];
    
    // 重置播放按钮
    self.playButton.enabled = NO;
    self.playButton.hidden = NO;
    self.playButton.selected = NO; // ✅ 重置selected状态
    [self.playButton setImage:[UIImage imageNamed:@"create_play"] forState:UIControlStateNormal];
    self.playButton.tintColor = [UIColor lightGrayColor];
    
    // ✅ 重置选择按钮
    if (self.chooseButton) {
        self.chooseButton.hidden = !self.isEditingMode;
        [self updateChooseButtonState];
    }
    
    NSLog(@"🔄 按钮状态和statusView已重置");
}

/// 配置克隆失败状态
- (void)configureFailedState {
    NSLog(@"🔴 音色状态: 克隆失败");
    
    // ✅ 显示statusView
    self.statusView.hidden = NO;
    
    // ✅ 设置红色背景，透明度20%
    self.statusView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2];
    
    // ✅ 显示失败图标
    self.faildImgView.hidden = NO;
    
    // ✅ 设置状态文字和颜色
    self.statusLabel.text = LocalString(@"声音克隆失败，请重新开始录音");
    self.statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]; // 红色文字
    
    // ✅ 设置label的文本显示属性，防止与图标重合
    self.statusLabel.numberOfLines = 1; // 确保只显示一行
    self.statusLabel.lineBreakMode = NSLineBreakByTruncatingTail; // 尾部截断，显示省略号
    self.statusLabel.adjustsFontSizeToFitWidth = NO; // 不自动调整字体大小
    
    // ✅ 失败状态：设置statusLabel相对于失败图标的约束
    if (self.statusLabelLeadingConstraint) {
        // statusLabel应该在失败图标右侧，保持12px间距
        self.statusLabelLeadingConstraint.constant = 42;
        NSLog(@"🔧 失败状态：设置statusLabel左边距 = 12px");
    }
    
    // 按钮状态：编辑可用（失败后可以重新编辑），播放禁用
    self.editButton.enabled = YES;
    
    self.playButton.enabled = NO;
    self.playButton.tintColor = [UIColor lightGrayColor];
    
    NSLog(@"🔴 失败状态配置完成");
}
/// 配置克隆中状态
- (void)configureCloningState {
    NSLog(@"🟡 音色状态: 克隆中");
    
    // ✅ 显示statusView
    self.statusView.hidden = NO;
    
    // ✅ 设置黄色背景，透明度20%
    self.statusView.backgroundColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.2];
    
    // ✅ 隐藏失败图标（克隆中不需要显示图标）
    self.faildImgView.hidden = YES;
    
    // ✅ 设置状态文字和颜色
    self.statusLabel.text = LocalString(@"声音克隆中");
    self.statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:1.0]; // 黄色文字
    
    // ✅ 设置label的文本显示属性
    self.statusLabel.numberOfLines = 1; // 确保只显示一行
    self.statusLabel.lineBreakMode = NSLineBreakByTruncatingTail; // 尾部截断，显示省略号
    self.statusLabel.adjustsFontSizeToFitWidth = NO; // 不自动调整字体大小
    
    // ✅ 克隆中状态：statusLabel左边距应该直接到statusView的边距（约16px）
    if (self.statusLabelLeadingConstraint) {
        self.statusLabelLeadingConstraint.constant = 16;  // 直接到statusView左边的间距
        NSLog(@"🔧 克隆中状态：设置statusLabel左边距 = 16px");
    }
    
    // 按钮状态：编辑和播放都禁用（克隆中不能操作）
    self.editButton.hidden = YES;
    self.playButton.hidden = YES;
    
    NSLog(@"🟡 克隆中状态配置完成");
}


/// 配置正常状态（成功、待克隆等不需要显示statusView的情况）
- (void)configureNormalState:(VoiceModel *)voice {
    NSLog(@"⚪ 音色状态: 正常（不显示statusView）");
    
    // ✅ 隐藏statusView
    self.statusView.hidden = YES;
    
    // ✅ 编辑模式下隐藏编辑和播放按钮，显示选择按钮
    if (self.isEditingMode) {
        self.editButton.hidden = YES;
        self.playButton.hidden = YES;
        self.chooseButton.hidden = NO;
        NSLog(@"⚪ 编辑模式下的正常状态配置完成");
        return;
    }
    
    // ✅ 正常模式下显示编辑和播放按钮，隐藏选择按钮
    self.editButton.hidden = NO;
    self.playButton.hidden = NO;
    self.chooseButton.hidden = YES;
    
    // 根据具体状态配置按钮
    switch (voice.cloneStatus) {
        case VoiceCloneStatusSuccess:
            // ✅ 成功状态：编辑和播放都可用
            NSLog(@"🟢 克隆成功状态 - 按钮全部可用");
            self.editButton.enabled = YES;
            self.editButton.tintColor = [UIColor systemBlueColor];
            
            self.playButton.enabled = YES;
            self.playButton.tintColor = [UIColor systemBlueColor];
            
            // ✅ 根据播放状态设置按钮的selected状态
            self.playButton.selected = voice.isPlaying;
            
            break;
            
        case VoiceCloneStatusPending:
            // 待克隆状态：编辑可用，播放禁用
            NSLog(@"🟡 待克隆状态 - 编辑可用");
            self.editButton.enabled = YES;
            self.editButton.tintColor = [UIColor systemBlueColor];
            
            self.playButton.enabled = NO;
            self.playButton.tintColor = [UIColor lightGrayColor];
            break;
            
        default:
            // 其他状态保持禁用
            NSLog(@"❓ 未知状态 - 按钮禁用");
            break;
    }
}

#pragma mark - 类方法

/// 判断指定音色是否需要显示statusView（用于动态调整cell高度）
+ (BOOL)needsStatusViewForVoice:(VoiceModel *)voice {
    if (!voice) {
        return NO;
    }
    
    // ✅ 只有克隆中和失败状态需要显示statusView
    return (voice.cloneStatus == VoiceCloneStatusCloning || 
            voice.cloneStatus == VoiceCloneStatusFailed);
}

#pragma mark - 网络图片加载

/// 异步加载网络图片（使用缓存）
- (void)loadImageFromURL:(NSString *)urlString {
    if (!urlString || urlString.length == 0) {
        self.avatarImageView.image = [UIImage imageNamed:@"默认头像"];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    // ✅ 使用SDWebImage加载图片，自动处理缓存
    [self.avatarImageView sd_setImageWithURL:url
                            placeholderImage:[UIImage imageNamed:@"默认头像"]
                                   completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
    }];
}

#pragma mark - 按钮点击事件

/// 编辑按钮点击事件
- (void)editButtonAction:(UIButton *)sender {
    NSLog(@"🖊️ 编辑按钮被点击 - 音色: %@, 状态: %ld", self.voiceModel.voiceName, (long)self.voiceModel.cloneStatus);
    
    if (self.editButtonTapped && self.voiceModel) {
        self.editButtonTapped(self.voiceModel);
    }
}

/// 播放按钮点击事件
- (void)playButtonAction:(UIButton *)sender {
    NSLog(@"▶️ 播放按钮被点击 - 音色: %@, 状态: %ld", self.voiceModel.voiceName, (long)self.voiceModel.cloneStatus);
    
    if (self.playButtonTapped && self.voiceModel) {
        self.playButtonTapped(self.voiceModel);
    }
}

#pragma mark - ✅ 编辑模式管理

/// 更新编辑模式状态
- (void)updateEditingMode:(BOOL)isEditingMode isSelected:(BOOL)isSelected {
    NSLog(@"📝 Cell编辑模式状态更新开始 - 编辑模式: %@ -> %@, 选中状态: %@ -> %@", 
          self.isEditingMode ? @"是" : @"否", isEditingMode ? @"是" : @"否",
          self.isSelected ? @"是" : @"否", isSelected ? @"是" : @"否");
    
    self.isEditingMode = isEditingMode;
    self.isSelected = isSelected;
    
    // 更新按钮显示状态
    if (isEditingMode) {
        // 编辑模式：隐藏编辑和播放按钮，显示选择按钮
        self.editButton.hidden = YES;
        self.playButton.hidden = YES;
        self.chooseButton.hidden = NO;
        NSLog(@"📝 编辑模式：显示选择按钮，隐藏编辑播放按钮");
    } else {
        // 正常模式：显示编辑和播放按钮，隐藏选择按钮
        self.editButton.hidden = NO;
        self.playButton.hidden = NO;
        self.chooseButton.hidden = YES;
        NSLog(@"📝 正常模式：显示编辑播放按钮，隐藏选择按钮");
    }
    
    // 更新选择按钮状态
    [self updateChooseButtonState];
    
    // 如果退出编辑模式且有音色数据，重新配置按钮状态
    if (!isEditingMode && self.voiceModel) {
        NSLog(@"📝 退出编辑模式，重新配置按钮状态");
        [self updateUIForVoiceStatus:self.voiceModel];
    }
    
    NSLog(@"📝 Cell编辑模式状态更新完成");
}

/// 更新选择按钮的图片状态
- (void)updateChooseButtonState {
    NSLog(@"🔍 开始更新选择按钮状态 - chooseButton存在: %@, 选中状态: %@", 
          self.chooseButton ? @"是" : @"否", self.isSelected ? @"是" : @"否");
    
    if (!self.chooseButton) {
        NSLog(@"❌ chooseButton为空，无法更新状态");
        return;
    }
    
    if (self.isSelected) {
        // 选中状态：显示choose_sel图片
        UIImage *selectedImage = [UIImage imageNamed:@"choose_sel"];
        NSLog(@"🔍 选中状态图片存在: %@", selectedImage ? @"是" : @"否");
        [self.chooseButton setImage:selectedImage forState:UIControlStateNormal];
        NSLog(@"✅ 选择按钮状态: 已选中");
    } else {
        // 未选中状态：显示choose_normal图片
        UIImage *normalImage = [UIImage imageNamed:@"choose_normal"];
        NSLog(@"🔍 未选中状态图片存在: %@", normalImage ? @"是" : @"否");
        [self.chooseButton setImage:normalImage forState:UIControlStateNormal];
        NSLog(@"⭕ 选择按钮状态: 未选中");
    }
    
    // 强制刷新按钮显示
    [self.chooseButton setNeedsLayout];
    [self.chooseButton layoutIfNeeded];
}

/// 选择按钮点击事件
- (void)chooseButtonAction:(UIButton *)sender {
    NSLog(@"✅ 选择按钮被点击 - 音色: %@, 当前状态: %@", 
          self.voiceModel.voiceName, self.isSelected ? @"已选中" : @"未选中");
    
    // ✅ 选择按钮点击需要手动触发cell的点击事件
    // 获取当前cell在tableView中的indexPath
    UITableView *tableView = nil;
    UIView *superview = self.superview;
    while (superview && ![superview isKindOfClass:[UITableView class]]) {
        superview = superview.superview;
    }
    
    if ([superview isKindOfClass:[UITableView class]]) {
        tableView = (UITableView *)superview;
        NSIndexPath *indexPath = [tableView indexPathForCell:self];
        
        if (indexPath) {
            NSLog(@"🔄 手动触发cell选中事件 - section: %ld", (long)indexPath.section);
            // 手动调用tableView的didSelectRowAtIndexPath
            if ([tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                [tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
            }
        } else {
            NSLog(@"❌ 无法获取cell的indexPath");
        }
    } else {
        NSLog(@"❌ 无法找到父级tableView");
    }
}

#pragma mark - 重用准备

/// 准备重用时重置状态
- (void)prepareForReuse {
    [super prepareForReuse];
    
    // ✅ 清除头像图片，避免重用时显示错乱
    self.avatarImageView.image = nil;
    
    // 重置回调
    self.editButtonTapped = nil;
    self.playButtonTapped = nil;
    
    // 重置数据
    self.voiceModel = nil;
    
    // ✅ 重置编辑模式状态
    self.isEditingMode = NO;
    self.isSelected = NO;
    
    // 重置UI状态
    [self resetButtonsState];
    
    NSLog(@"🔄 Cell准备重用，状态已重置");
}



#pragma mark - ✅ 圆角设置管理

/// 重写setEditing方法，在需要时重新设置圆角
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    // ✅ 如果圆角丢失，重新设置
    if (self.contentView.layer.cornerRadius != 20) {
        self.contentView.layer.cornerRadius = 20;
        self.contentView.clipsToBounds = YES;
        NSLog(@"✂️ Cell编辑状态改变，重新设置圆角");
    }
}

@end
