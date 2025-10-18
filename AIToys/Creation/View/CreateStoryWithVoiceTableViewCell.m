//
//  CreateStoryWithVoiceTableViewCell.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "CreateStoryWithVoiceTableViewCell.h"

@implementation CreateStoryWithVoiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    // 设置圆角
    self.headerImageView.layer.cornerRadius = self.headerImageView.frame.size.width / 2;
    self.headerImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    if (selected) {
//        [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"choose_sel"] forState:UIControlStateNormal];
//    } else {
//        [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"choose_normal"] forState:UIControlStateNormal];
//    }

    // Configure the view for the selected state
}

#pragma mark - Public Methods

/**
 配置音色数据
 @param voiceModel 音色模型对象
 @param isSelected 是否选中
 */
- (void)configureWithVoiceModel:(id)voiceModel isSelected:(BOOL)isSelected {
    // 配置音色头像
    if ([voiceModel respondsToSelector:@selector(avatarUrl)]) {
        NSString *avatarUrl = [voiceModel valueForKey:@"avatarUrl"];
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl]
                                placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    } else if ([voiceModel respondsToSelector:@selector(imageUrl)]) {
        NSString *imageUrl = [voiceModel valueForKey:@"imageUrl"];
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                                placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    }
    
    // 配置选中状态按钮
//    self.selectBtn.selected = isSelected;
    
    // 设置选择按钮图片
    if (isSelected) {
        [self.selectBtn setImage:[UIImage imageNamed:@"device_added"] forState:UIControlStateNormal];
    } else {
        [self.selectBtn setImage:[UIImage imageNamed:@"choose_normal"] forState:UIControlStateNormal];
    }
    
//    // 可以根据选中状态更改样式
//    if (isSelected) {
//        self.contentView.layer.borderWidth = 2.0;
//        self.contentView.layer.borderColor = [UIColor colorWithRed:0x1E/255.0
//                                                              green:0xAA/255.0
//                                                               blue:0xFD/255.0
//                                                              alpha:1.0].CGColor;
//    } else {
//        self.contentView.layer.borderWidth = 0;
//        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
//    }
}

@end
