//
//  VoiceManagementTableViewCell.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/13.
//

#import "VoiceManagementTableViewCell.h"

@implementation VoiceManagementTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.cornerRadius = 20;
    self.contentView.clipsToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
