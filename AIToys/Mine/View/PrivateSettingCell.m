//
//  PrivateSettingCell.m
//  AIToys
//
//  Created by qdkj on 2025/7/17.
//

#import "PrivateSettingCell.h"
#import "ATLanguageHelper.h"

@implementation PrivateSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    BOOL isRTL = [ATLanguageHelper isRTLLanguage];
    UISemanticContentAttribute semantic = isRTL ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
    self.contentView.semanticContentAttribute = semantic;
    self.bgView.semanticContentAttribute = semantic;
    self.titleLabel.semanticContentAttribute = semantic;
    self.subTitleLabel.semanticContentAttribute = semantic;
    self.titleLabel.textAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.subTitleLabel.textAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.subTitleLabel.numberOfLines = 0;
    self.subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
}

-(void)setModel:(MineItemModel *)model{
    _model = model;
    self.titleLabel.text = model.title;
    CGSize labSize = QDSize(model.title,self.titleLabel.font,CGSizeMake(kScreenWidth-140, MAXFLOAT));
    self.titleLabH.constant = MAX(20.0, ceil(labSize.height));
    self.subTitleLabel.text = model.value;
    self.switchView.on = model.isOn;
}

- (IBAction)switchChanged:(UISwitch *)sender {
    if (self.switchChangeBlock) {
        self.switchChangeBlock(sender.on);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
