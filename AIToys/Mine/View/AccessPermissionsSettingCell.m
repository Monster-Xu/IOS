//
//  AccessPermissionsSettingCell.m
//  AIToys
//
//  Created by qdkj on 2025/7/17.
//

#import "AccessPermissionsSettingCell.h"
#import "ATLanguageHelper.h"

@implementation AccessPermissionsSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    BOOL isRTL = [ATLanguageHelper isRTLLanguage];
    UISemanticContentAttribute semantic = isRTL ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
    self.contentView.semanticContentAttribute = semantic;
    self.bgView.semanticContentAttribute = semantic;
    self.titleLabel.semanticContentAttribute = semantic;
    self.subTitleLabel.semanticContentAttribute = semantic;
    self.statusLabel.semanticContentAttribute = semantic;
    self.titleLabel.textAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.subTitleLabel.textAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.statusLabel.textAlignment = isRTL ? NSTextAlignmentLeft : NSTextAlignmentRight;
    UIImage *arrowImage = [UIImage imageNamed:@"cell_right_arrow"];
    if (arrowImage && isRTL && @available(iOS 9.0, *)) {
        arrowImage = [arrowImage imageFlippedForRightToLeftLayoutDirection];
    }
    self.rightImgView.image = arrowImage;
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.subTitleLabel.numberOfLines = 0;
    self.subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.statusLabel.numberOfLines = 1;
    self.statusLabel.adjustsFontSizeToFitWidth = YES;
    self.statusLabel.minimumScaleFactor = 0.7;
}

-(void)setModel:(MineItemModel *)model{
    _model = model;
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = model.value;
    self.statusLabel.text = model.isOn ? LocalString(@"已开启"): LocalString(@"去设置");
    [self updateStatusLabelWidth];
}

- (NSLayoutConstraint *)statusLabelWidthConstraint {
    for (NSLayoutConstraint *constraint in self.statusLabel.constraints) {
        if (constraint.firstItem == self.statusLabel && constraint.firstAttribute == NSLayoutAttributeWidth) {
            return constraint;
        }
    }
    return nil;
}

- (void)updateStatusLabelWidth {
    NSLayoutConstraint *widthConstraint = [self statusLabelWidthConstraint];
    if (!widthConstraint) {
        return;
    }
    CGFloat availableWidth = 118.0;
    CGSize fittingSize = [self.statusLabel sizeThatFits:CGSizeMake(availableWidth, CGFLOAT_MAX)];
    widthConstraint.constant = MIN(MAX(40.0, ceil(fittingSize.width) + 4.0), availableWidth);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
