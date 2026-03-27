//
//  UserEmailCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/16.
//

#import "UserEmailCell.h"
#import "ATLanguageHelper.h"

@implementation UserEmailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIImage *arrowImage = [UIImage imageNamed:@"cell_right_arrow"];
    if (arrowImage && [ATLanguageHelper isRTLLanguage] && @available(iOS 9.0, *)) {
        arrowImage = [arrowImage imageFlippedForRightToLeftLayoutDirection];
    }
    self.rightImgView.image = arrowImage;
}

-(void)setModel:(MineItemModel *)model{
    _model = model;
    self.titleLabel.text = model.title;
    self.subTitleLabel.text = model.value;
    self.statusLabel.text = LocalString(@"已绑定");
    self.rightImgView.hidden = [PublicObj isEmptyObject:model.toVC];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
