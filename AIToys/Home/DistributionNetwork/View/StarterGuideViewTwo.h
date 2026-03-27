//
//  StarterGuideViewTwo.h
//  AIToys
//
//  Created by xuxuxu on 2026/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StarterGuideViewTwo : UIView

@property (weak, nonatomic) IBOutlet UIImageView *addImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIButton *skipBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

-(void)show;
@end

NS_ASSUME_NONNULL_END
