//
//  StarterGuideView.m
//  AIToys
//
//  Created by xuxuxu on 2026/1/22.
//

#import "StarterGuideView.h"
#import "ATLanguageHelper.h"

@implementation StarterGuideView

static NSInteger const kStarterGuideTopImageTag = 1001;
static NSInteger const kStarterGuideBottomImageTag = 1002;
static NSInteger const kStarterGuideSkipButtonTag = 1003;
static NSInteger const kStarterGuideNextButtonTag = 1004;

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"StarterGuideView" owner:nil options:nil] firstObject];
        self.topImageView = [self viewWithTag:kStarterGuideTopImageTag];
        self.bottomImageView = [self viewWithTag:kStarterGuideBottomImageTag];
        self.skipBtn = [self viewWithTag:kStarterGuideSkipButtonTag];
        self.nextBtn = [self viewWithTag:kStarterGuideNextButtonTag];
        self.frame = frame;
        [self.skipBtn setTitle:LocalString(@"跳过") forState:UIControlStateNormal];
        [self.nextBtn setTitle:LocalString(@"下一步") forState:UIControlStateNormal];
        NSString *imageSuffix = [self guideImageSuffix];
        self.topImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"guide_top_%@", imageSuffix]];
        self.bottomImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"guide_down_%@", imageSuffix]];
        if (@available(iOS 15.0, *)) {
            self.skipBtn.configuration.title = LocalString(@"跳过");
            self.nextBtn.configuration.title = LocalString(@"下一步");
        }
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

- (IBAction)skipBtnClick:(id)sender {
    [self removeFromSuperview];
}
-(void)show
{
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
}
- (IBAction)nextBtnClick:(id)sender {
    if (self.nextBlock) {
        self.nextBlock();
    }
    [self removeFromSuperview];
}


@end
