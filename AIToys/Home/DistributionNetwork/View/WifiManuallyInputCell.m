//
//  WifiManuallyInputCell.m
//  AIToys
//
//  Created by qdkj on 2025/6/30.
//

#import "WifiManuallyInputCell.h"
#import "ATLanguageHelper.h"

@implementation WifiManuallyInputCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.text = LocalString(@"手动输入");
    BOOL isRTL = [ATLanguageHelper isRTLLanguage];
    self.contentView.semanticContentAttribute = isRTL ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
    self.titleLabel.textAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
