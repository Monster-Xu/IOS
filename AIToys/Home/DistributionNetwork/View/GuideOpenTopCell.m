//
//  GuideOpenTopCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/29.
//

#import "GuideOpenTopCell.h"

@implementation GuideOpenTopCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.75;
    self.titleLabel.lineBreakMode = NSLineBreakByClipping;
    self.subTitleLab.numberOfLines = 2;
    self.subTitleLab.lineBreakMode = NSLineBreakByWordWrapping;
    [self.titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-20.0].active = YES;
    [self.subTitleLab.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-20.0].active = YES;
}

- (void)setIsBluetooth:(BOOL)isBluetooth{
    _isBluetooth = isBluetooth;
    self.titleLabel.text = self.isBluetooth ? LocalString(@"建议开启蓝牙")  : LocalString(@"建议开启并配置Wi-Fi");
    self.subTitleLab.text = self.isBluetooth ? LocalString(@"部分Wi-Fi设备蓝牙开启后更容易添加") : LocalString(@"Wi-Fi设备需要开启");
    self.imgView.image = self.isBluetooth ? QD_IMG(@"guide_open_bluetooth") : QD_IMG(@"guide_open_wifi");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
