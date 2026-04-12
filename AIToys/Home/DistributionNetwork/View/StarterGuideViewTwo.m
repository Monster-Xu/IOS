//
//  StarterGuideViewTwo.m
//  AIToys
//
//  Created by xuxuxu on 2026/1/22.
//

#import "StarterGuideViewTwo.h"
#import "ATLanguageHelper.h"

@implementation StarterGuideViewTwo

static NSInteger const kStarterGuideTwoBottomImageTag = 2001;
static NSInteger const kStarterGuideTwoSkipButtonTag = 2002;
static NSInteger const kStarterGuideTwoDoneButtonTag = 2003;
static NSInteger const kStarterGuideTwoAddImageTag = 2004;

- (CGFloat)addImageWidthForLayout {
    [self.addImageView layoutIfNeeded];
    CGFloat width = CGRectGetWidth(self.addImageView.bounds);
    if (width > 0) {
        return width;
    }

    for (NSLayoutConstraint *constraint in self.addImageView.constraints) {
        if (constraint.firstItem == self.addImageView && constraint.firstAttribute == NSLayoutAttributeWidth) {
            return constraint.constant;
        }
    }

    if (self.addImageView.image.size.width > 0) {
        return self.addImageView.image.size.width;
    }

    return 44.0;
}

- (void)updateAddImagePosition {
    self.addLeadingConstraint.active = NO;
    self.addLeftConstraint.active = ![ATLanguageHelper isRTLLanguage];
    self.addRightConstraint.active = [ATLanguageHelper isRTLLanguage];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"StartGuideViewTwo" owner:nil options:nil] firstObject];
        self.bottomImageView = [self viewWithTag:kStarterGuideTwoBottomImageTag];
        self.skipBtn = [self viewWithTag:kStarterGuideTwoSkipButtonTag];
        self.doneBtn = [self viewWithTag:kStarterGuideTwoDoneButtonTag];
        self.addImageView = [self viewWithTag:kStarterGuideTwoAddImageTag];
        self.frame = frame;
        self.addLeftConstraint = [self.addImageView.leftAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leftAnchor constant:95.0];
        self.addRightConstraint = [self.addImageView.rightAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.rightAnchor constant:-95.0];
        [self.skipBtn setTitle:LocalString(@"跳过") forState:UIControlStateNormal];
        [self.doneBtn setTitle:LocalString(@"完成") forState:UIControlStateNormal];
        NSString *imageSuffix = [self guideImageSuffix];
        self.bottomImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"guide_down2_%@", imageSuffix]];
        self.addImageView.transform = [ATLanguageHelper isRTLLanguage] ? CGAffineTransformMakeScale(-1, 1) : CGAffineTransformIdentity;
        if (@available(iOS 15.0, *)) {
            self.skipBtn.configuration.title = LocalString(@"跳过");
            self.doneBtn.configuration.title = LocalString(@"完成");
        }
    }
    return self;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateAddImagePosition];
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
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self updateAddImagePosition];
    [self layoutIfNeeded];
}

- (IBAction)skipBtnClick:(id)sender {
    [self removeFromSuperview];
    
}
- (IBAction)doneBtcClick:(id)sender {
    [self removeFromSuperview];
}
@end
