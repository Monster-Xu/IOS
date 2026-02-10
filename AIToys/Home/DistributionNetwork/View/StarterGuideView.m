//
//  StarterGuideView.m
//  AIToys
//
//  Created by xuxuxu on 2026/1/22.
//

#import "StarterGuideView.h"

@implementation StarterGuideView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self = [[[NSBundle mainBundle]loadNibNamed:@"StarterGuideView" owner:nil options:nil]objectAtIndex:0];
        self.frame = frame;
        
    }
    return self;
    
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
