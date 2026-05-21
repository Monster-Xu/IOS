//
//  HomeToysItem.m
//  AIToys
//
//  Created by 乔不赖 on 2025/6/21.
//

#import "HomeToysItem.h"
#import "ATLanguageHelper.h"

@implementation HomeToysItem

- (void)awakeFromNib {
    [super awakeFromNib];
    BOOL isRTL = [ATLanguageHelper isRTLLanguage];
    self.contentView.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    self.topLeftView.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    self.nameLabel.textAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.storyNumLabel.textAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.timeNumLabel.textAlignment = isRTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.topLeftTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self applyImageDirectionForRTL:isRTL];
    self.topLeftTitleLabel.text = LocalString(@"DIY公仔");
    self.storyNamLabel.text = LocalString(@"故事");
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateTopBadgePositionForRTL:[ATLanguageHelper isRTLLanguage]];
}

- (void)applyImageDirectionForRTL:(BOOL)isRTL {
    CGAffineTransform imageTransform = isRTL ? CGAffineTransformMakeScale(-1.0, 1.0) : CGAffineTransformIdentity;
    self.bgImgView.transform = imageTransform;
    self.toysImgView.transform = imageTransform;
    self.topLeftImgView.transform = imageTransform;
    self.topLeftTitleLabel.transform = CGAffineTransformIdentity;
    self.rankBgImgView.image = [UIImage imageNamed:@"device_sort_bg"];
    self.rankBgImgView.transform = imageTransform;
}

- (void)updateTopBadgePositionForRTL:(BOOL)isRTL {
    UIView *containerView = self.topLeftView.superview;
    if (!containerView) {
        return;
    }

    CGRect frame = self.topLeftView.frame;
    frame.origin.x = isRTL ? CGRectGetWidth(containerView.bounds) - CGRectGetWidth(frame) : 0.0;
    self.topLeftView.frame = frame;
}

-(void)setIndex:(NSInteger)index{
    _index = index;
    self.rankLabel.text = [NSString stringWithFormat:@"%li",index + 1];
}

-(void)setIsEdit:(BOOL)isEdit{
    _isEdit = isEdit;
    [self starAnimation:isEdit];
    if(isEdit){
        self.rankView.hidden = YES;
        self.chooseImgView.hidden = NO;
    }else{
        self.rankView.hidden = NO;
        self.chooseImgView.hidden = YES;
    }
}

-(void)setIsSel:(BOOL)isSel{
    _isSel = isSel;
    if(isSel){
        self.chooseImgView.highlighted = YES;
    }else{
        self.chooseImgView.highlighted = NO;
    }
}

-(void)setModel:(HomeDollModel *)model{
    _model = model;
    self.topLeftView.hidden = ![model.dollModel.type isEqualToString:@"creative"];
    self.nameLabel.text = model.dollModel.name;
    [self.bgImgView sd_setImageWithURL:[NSURL URLWithString:model.dollModel.backgroundImg]];
    [self.toysImgView sd_setImageWithURL:[NSURL URLWithString:model.dollModel.coverImg]];
    self.storyNumLabel.text = [NSString stringWithFormat:@"%ld",(long)model.totalStoryNum];
    NSInteger totalMinutes = ceil(model.totalStoryDuration / 60.0);

    if (totalMinutes < 1) {
        totalMinutes = 1; // 小于1分钟显示为1分钟
    }
    if(model.totalStoryDuration==0){
        totalMinutes = 0;
    }

    self.timeNumLabel.text = [self localizedStoryDurationTextWithTotalMinutes:totalMinutes];
}

- (NSString *)localizedStoryDurationTextWithTotalMinutes:(NSInteger)totalMinutes {
    if (![ATLanguageHelper isRTLLanguage]) {
        return [NSString stringWithFormat:@"%ld %@", (long)totalMinutes, LocalString(@"分钟")];
    }
    NSInteger hours = totalMinutes / 60;
    NSInteger minutes = totalMinutes % 60;
    if (hours > 0) {
        return [NSString stringWithFormat:@"%ld س %ld د", (long)hours, (long)minutes];
    }
    return [NSString stringWithFormat:@"%ld د", (long)minutes];
}

-(void)starAnimation:(BOOL)animaiton
{
    if (animaiton) {
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //抖动的话添加一个旋转角度给他就好
        basicAnimation.fromValue = @(-M_PI_4/30);
        basicAnimation.toValue = @(M_PI_4/30);
        basicAnimation.duration = 0.15;
        basicAnimation.repeatCount = MAXFLOAT;
        basicAnimation.autoreverses = YES;
        [self.layer addAnimation:basicAnimation forKey:[NSString stringWithFormat:@"%li",(long)index + 1]];

    }else{
        [self.layer removeAllAnimations];
    }

}


@end
