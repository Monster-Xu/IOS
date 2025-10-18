//
//  VoiceManagementTableViewCell.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "VoiceManagementTableViewCell.h"
#import "VoiceModel.h"

@interface VoiceManagementTableViewCell ()

// UI元素
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;    // 头像图片
@property (weak, nonatomic) IBOutlet UILabel *voiceNameLabel;        // 音色名称
@property (weak, nonatomic) IBOutlet UIButton *editButton;           // 编辑按钮
@property (weak, nonatomic) IBOutlet UIButton *playButton;           // 播放按钮

// 数据
@property (nonatomic, strong) VoiceModel *voiceModel;

@end

@implementation VoiceManagementTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
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
    
    // 设置按钮
    if (self.editButton) {
        [self.editButton setUserInteractionEnabled:NO];
    }
    if (self.playButton) {
        [self.playButton setUserInteractionEnabled:NO];
    }
}

#pragma mark - 数据绑定

/// ✅ 配置cell显示声音数据
- (void)configureWithVoiceModel:(VoiceModel *)voice {
    self.voiceModel = voice;
    
    if (!voice) {
        return;
    }
    
    // 设置声音名称
    if (self.voiceNameLabel) {
        self.voiceNameLabel.text = voice.voiceName ?: @"未命名";
        self.voiceNameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        self.voiceNameLabel.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
    }
    
    // 设置头像
    if (self.avatarImageView) {
        if (voice.avatarUrl && voice.avatarUrl.length > 0) {
            // 异步加载网络图片
            [self loadImageFromURL:voice.avatarUrl];
        } else {
            // 使用默认图片
            self.avatarImageView.image = [UIImage imageNamed:@"home_toys_img"];
        }
    }
    
    // 根据音色状态更新UI
    [self updateUIForVoiceStatus:voice];
}

#pragma mark - 根据状态更新UI

/// 根据音色克隆状态更新UI显示
- (void)updateUIForVoiceStatus:(VoiceModel *)voice {
    // 根据音色状态，更新相关UI元素
    
    switch (voice.cloneStatus) {
        case VoiceCloneStatusPending:
            // 待克隆 - 显示待克隆标签
            [self updateStatusLabel:@"待克隆" color:[UIColor colorWithRed:0xFF/255.0 green:0xB8/255.0 blue:0x00/255.0 alpha:1.0]];
            break;
            
        case VoiceCloneStatusCloning:
            // 克隆中 - 显示克隆中状态
            [self updateStatusLabel:@"克隆中..." color:[UIColor colorWithRed:0x00/255.0 green:0xA8/255.0 blue:0xFF/255.0 alpha:1.0]];
            break;
            
        case VoiceCloneStatusSuccess:
            // 克隆成功 - 显示可用
            [self updateStatusLabel:@"" color:[UIColor clearColor]];
            break;
            
        case VoiceCloneStatusFailed:
            // 克隆失败 - 显示失败提示
            [self updateStatusLabel:@"克隆失败" color:[UIColor colorWithRed:0xEA/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:1.0]];
            break;
    }
}

/// 更新状态标签
- (void)updateStatusLabel:(NSString *)status color:(UIColor *)color {
    // 如果需要在cell中添加状态标签，可以在这里实现
    // 例如：添加一个状态标签或者修改现有标签的显示
    NSLog(@"音色状态: %@", status);
}

#pragma mark - 网络图片加载

/// 异步加载网络图片
- (void)loadImageFromURL:(NSString *)urlString {
    if (!urlString || urlString.length == 0) {
        self.avatarImageView.image = [UIImage imageNamed:@"home_toys_img"];
        return;
    }
    
    // 使用SDWebImage或AFNetworking加载图片（根据项目中使用的库）
    // 这里以SDWebImage为例
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 使用异步加载（需要根据项目中的图片加载库进行调整）
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                self.avatarImageView.image = image;
            } else {
                self.avatarImageView.image = [UIImage imageNamed:@"home_toys_img"];
            }
        });
    });
    
    // 如果项目使用了SDWebImage，可以取消上面的代码，使用以下代码：
    // #import <SDWebImage/UIImageView+WebCache.h>
    // [self.avatarImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"home_toys_img"]];
}

@end
