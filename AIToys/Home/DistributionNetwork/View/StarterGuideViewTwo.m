//
//  StarterGuideViewTwo.m
//  AIToys
//
//  Created by xuxuxu on 2026/1/22.
//

#import "StarterGuideViewTwo.h"

@implementation StarterGuideViewTwo

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle]loadNibNamed:@"StartGuideViewTwo" owner:nil options:nil]objectAtIndex:0];
        self.frame = frame;
    }
    return self;
    
}
-(void)show
{
    self.topConstraint.constant = (kScreenWidth-30) *151/343.0+180+30;
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
}

- (IBAction)skipBtnClick:(id)sender {
    [self removeFromSuperview];
    
}
- (IBAction)doneBtcClick:(id)sender {
    [self removeFromSuperview];
}
@end
