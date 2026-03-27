//
//  MineAvatarCell.m
//  AIToys
//
//  Created by 乔不赖 on 2025/7/14.
//

#import "MineAvatarCell.h"
#import "ATLanguageHelper.h"

@implementation MineAvatarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [PublicObj makeCornerToView:self.bgView withFrame:CGRectMake(0, 0, kScreenWidth-30, self.bgView.height) withRadius:16 position:1];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
