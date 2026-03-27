//
//  MineListCell.m
//  DistributionStore
//
//  Created by 乔不赖 on 2020/7/15.
//  Copyright © 2020 OceanCodes. All rights reserved.
//

#import "MineListCell.h"
#import "ATLanguageHelper.h"

@implementation MineListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.redPointView.layer.cornerRadius = self.redPointView.width *0.5;
    _titleLabel.textColor = UIColorFromRGBA(000000, 0.7);
    [self applyRTLArrowIfNeeded];
}

- (void)applyRTLArrowIfNeeded {
    UIImage *arrowImage = [UIImage imageNamed:@"cell_right_arrow"];
    if (!arrowImage) {
        return;
    }
    UIImage *targetImage = arrowImage;
    if (arrowImage && [ATLanguageHelper isRTLLanguage] && @available(iOS 9.0, *)) {
        targetImage = [arrowImage imageFlippedForRightToLeftLayoutDirection];
    }
    [self replaceArrowInView:self.contentView matchImage:arrowImage targetImage:targetImage];
}

- (void)replaceArrowInView:(UIView *)view matchImage:(UIImage *)image targetImage:(UIImage *)targetImage {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)subview;
            if ([self isArrowImage:imageView.image baseImage:image]) {
                imageView.image = targetImage;
            }
        }
        if (subview.subviews.count > 0) {
            [self replaceArrowInView:subview matchImage:image targetImage:targetImage];
        }
    }
}

- (BOOL)isArrowImage:(UIImage *)candidate baseImage:(UIImage *)baseImage {
    if (!candidate || !baseImage) {
        return NO;
    }
    if (candidate == baseImage || [candidate isEqual:baseImage]) {
        return YES;
    }
    NSData *baseData = UIImagePNGRepresentation(baseImage);
    NSData *candidateData = UIImagePNGRepresentation(candidate);
    if (baseData && candidateData) {
        return [baseData isEqualToData:candidateData];
    }
    return CGSizeEqualToSize(candidate.size, baseImage.size);
}

-(void)layoutSubviews{

    [super layoutSubviews];
    
    CGFloat cornerRaduis = 16.0;
    if(self.indexPath.row==0 && self.rowInSection==1) {//单组单行
        self.bgView.layer.cornerRadius = cornerRaduis;
        
    }else if(self.indexPath.row==0) {// 第一行
        [PublicObj makeCornerToView:self.bgView withFrame:CGRectMake(0, 0, kScreenWidth-30, self.bgView.height) withRadius:cornerRaduis position:1];
    }else if(self.indexPath.row == self.rowInSection-1) {// 最后一行

        [PublicObj makeCornerToView:self.bgView withFrame:CGRectMake(0, 0, kScreenWidth-30, self.bgView.height) withRadius:cornerRaduis position:2];

    }else{// 中间行
        
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
