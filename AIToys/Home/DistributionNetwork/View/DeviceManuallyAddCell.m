//
//  DeviceManuallyAddCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/28.
//

#import "DeviceManuallyAddCell.h"
#import "DeviceManuallyAddItem.h"
#import "ATLanguageHelper.h"

@interface DeviceManuallyAddCell()




@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIFont *baseGuideFont;

@end
@implementation DeviceManuallyAddCell




- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.text = LocalString(@"搜索设备时间过长仍未发现设备");
    self.subTitleLabel.text = LocalString(@"请参考");
    [self.devicebtnClick setTitle:LocalString(@"设备重置指南") forState:UIControlStateNormal];
    if (@available(iOS 15.0, *)) {
        self.devicebtnClick.configuration.title = LocalString(@"设备重置指南");
    }
    self.baseGuideFont = self.subTitleLabel.font;
    self.titleLabel.font = self.baseGuideFont;
    self.devicebtnClick.titleLabel.font = self.baseGuideFont;
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.titleLabel.lineBreakMode = NSLineBreakByClipping;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.subTitleLabel.font = self.baseGuideFont;
    self.subTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.subTitleLabel.textAlignment = [ATLanguageHelper isRTLLanguage] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    [self removeLayoutConstraintsForView:self.subTitleLabel];
    [self removeLayoutConstraintsForView:self.devicebtnClick];
    self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.devicebtnClick.translatesAutoresizingMaskIntoConstraints = YES;
}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat contentWidth = CGRectGetWidth(self.contentView.bounds);
    CGFloat horizontalInset = 16.0;
    CGFloat gap = 10.0;
    CGFloat availableWidth = MAX(0.0, contentWidth - horizontalInset * 2.0);
    UIFont *baseFont = self.baseGuideFont ?: [UIFont systemFontOfSize:12.0];
    NSString *titleText = self.titleLabel.text ?: @"";
    NSString *subTitleText = self.subTitleLabel.text ?: @"";
    NSString *buttonText = [self.devicebtnClick titleForState:UIControlStateNormal] ?: self.devicebtnClick.currentTitle ?: @"";
    NSDictionary *baseAttributes = @{NSFontAttributeName: baseFont};
    CGFloat titleNaturalWidth = ceil([titleText sizeWithAttributes:baseAttributes].width);
    CGFloat subTitleNaturalWidth = ceil([subTitleText sizeWithAttributes:baseAttributes].width);
    CGFloat buttonNaturalWidth = ceil([buttonText sizeWithAttributes:baseAttributes].width) + 4.0;
    CGFloat groupNaturalWidth = subTitleNaturalWidth + gap + buttonNaturalWidth;
    CGFloat commonScale = 1.0;
    if (titleNaturalWidth > 0.0) {
        commonScale = MIN(commonScale, availableWidth / titleNaturalWidth);
    }
    if (groupNaturalWidth > 0.0) {
        commonScale = MIN(commonScale, availableWidth / groupNaturalWidth);
    }
    commonScale = MAX(0.72, MIN(1.0, commonScale));

    CGFloat scaledPointSize = floor(baseFont.pointSize * commonScale * 10.0) / 10.0;
    UIFont *scaledFont = [UIFont fontWithDescriptor:baseFont.fontDescriptor size:scaledPointSize];
    self.titleLabel.font = scaledFont;
    self.subTitleLabel.font = scaledFont;
    self.devicebtnClick.titleLabel.font = scaledFont;

    CGFloat titleWidth = MAX(0.0, contentWidth - horizontalInset * 2.0);
    CGFloat titleHeight = ceil(scaledFont.lineHeight);
    self.titleLabel.frame = CGRectMake(horizontalInset, CGRectGetMinY(self.titleLabel.frame), titleWidth, titleHeight);

    CGSize buttonSize = [self.devicebtnClick sizeThatFits:CGSizeMake(CGFLOAT_MAX, 27.0)];
    CGFloat maxButtonWidth = MAX(88.0 * commonScale, availableWidth * 0.62);
    CGFloat buttonWidth = MIN(ceil(MAX(buttonSize.width, self.devicebtnClick.intrinsicContentSize.width)), maxButtonWidth);
    CGFloat labelAvailableWidth = MAX(44.0 * commonScale, availableWidth - buttonWidth - gap);
    CGSize subTitleSize = [self.subTitleLabel sizeThatFits:CGSizeMake(labelAvailableWidth, titleHeight)];
    self.subTitleLabel.frame = CGRectMake(0.0, 0.0, MIN(labelAvailableWidth, ceil(subTitleSize.width)), ceil(subTitleSize.height));
    CGFloat groupWidth = CGRectGetWidth(self.subTitleLabel.bounds) + gap + buttonWidth;
    CGFloat startX = floor((contentWidth - groupWidth) * 0.5);
    CGFloat centerY = CGRectGetMidY(self.devicebtnClick.frame) > 0 ? CGRectGetMidY(self.devicebtnClick.frame) : CGRectGetMaxY(self.titleLabel.frame) + 12.0;
    CGFloat labelHeight = ceil(CGRectGetHeight(self.subTitleLabel.bounds));
    CGFloat buttonHeight = 27.0;
    self.subTitleLabel.frame = CGRectMake(startX, centerY - labelHeight * 0.5, ceil(CGRectGetWidth(self.subTitleLabel.bounds)), labelHeight);
    self.devicebtnClick.frame = CGRectMake(CGRectGetMaxX(self.subTitleLabel.frame) + gap, centerY - buttonHeight * 0.5, buttonWidth, buttonHeight);
}

- (void)removeLayoutConstraintsForView:(UIView *)view {
    NSMutableArray<NSLayoutConstraint *> *constraintsToRemove = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.contentView.constraints) {
        if (constraint.firstItem == view || constraint.secondItem == view) {
            [constraintsToRemove addObject:constraint];
        }
    }
    [self.contentView removeConstraints:constraintsToRemove];
}

- (IBAction)deviceBtnClick:(id)sender {
    if (self.devicebtnClick) {
        self.devicebtnClickClickBlock();
    }
}

@end
