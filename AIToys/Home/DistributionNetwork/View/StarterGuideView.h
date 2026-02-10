//
//  StarterGuideView.h
//  AIToys
//
//  Created by xuxuxu on 2026/1/22.
//

#import <UIKit/UIKit.h>
typedef void (^nextBtnClick)(void);
NS_ASSUME_NONNULL_BEGIN

@interface StarterGuideView : UIView
@property (nonatomic,copy)nextBtnClick nextBlock;
-(void)show;

@end

NS_ASSUME_NONNULL_END
