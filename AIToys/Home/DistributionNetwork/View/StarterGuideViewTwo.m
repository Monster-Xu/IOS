//
//  StarterGuideViewTwo.m
//  AIToys
//
//  Created by xuxuxu on 2026/1/22.
//

#import "StarterGuideViewTwo.h"
#import "ATLanguageHelper.h"

@implementation StarterGuideViewTwo

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle]loadNibNamed:@"StartGuideViewTwo" owner:nil options:nil]objectAtIndex:0];
        self.frame = frame;
        [self.skipBtn setTitle:LocalString(@"跳过") forState:UIControlStateNormal];
        [self.doneBtn setTitle:LocalString(@"完成") forState:UIControlStateNormal];
        NSString *imageSuffix = [self guideImageSuffix];
        self.bottomImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"guide_down2_%@", imageSuffix]];
        self.addImageView.transform = [ATLanguageHelper isRTLLanguage] ? CGAffineTransformMakeScale(-1, 1) : CGAffineTransformIdentity;
    }
    return self;
    
}
- (NSString *)guideImageSuffix {
    NSString *langType = [ATLanguageHelper miniAppLangType].lowercaseString ?: @"en";
    if ([langType hasPrefix:@"ar"]) {
        return @"ar";
    }
    if ([langType hasPrefix:@"fr"]) {
        return @"fr";
    }
    if ([langType hasPrefix:@"de"]) {
        return @"gm";
    }
    if ([langType hasPrefix:@"es"]) {
        return @"sp";
    }
    return @"en";
}

-(void)show
{
    self.topConstraint.constant = (kScreenWidth-30) *151/343.0+180+30;
    if ([ATLanguageHelper isRTLLanguage]) {
        self.addLeadingConstraint.constant = CGRectGetWidth(self.bounds) - 95.0 - CGRectGetWidth(self.addImageView.bounds);
    } else {
        self.addLeadingConstraint.constant = 95.0;
    }
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
}

- (IBAction)skipBtnClick:(id)sender {
    [self removeFromSuperview];
    
}
- (IBAction)doneBtcClick:(id)sender {
    [self removeFromSuperview];
}
@end
