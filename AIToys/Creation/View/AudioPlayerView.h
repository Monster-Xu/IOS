//
//  AudioPlayerView.h
//  AIToys
//
//  Created by Assistant on 2025/10/17.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AudioPlayerViewDelegate <NSObject>
@optional
- (void)audioPlayerDidStartPlaying;
- (void)audioPlayerDidPause;
- (void)audioPlayerDidFinish;
- (void)audioPlayerDidUpdateProgress:(CGFloat)progress currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;
- (void)audioPlayerDidClose;
@end

@interface AudioPlayerView : UIView

@property (nonatomic, weak) id<AudioPlayerViewDelegate> delegate;


// 新增的初始化方法
- (instancetype)initWithAudioURL:(NSString *)audioURL storyTitle:(NSString *)title coverImageURL:(NSString *)coverImageURL;

// 显示和隐藏方法
- (void)showInView:(UIView *)parentView;
- (void)hide;

// 播放控制方法
- (void)play;
- (void)pause;
- (void)stop;

// 是否正在播放
- (BOOL)isPlaying;

// 测试光效动画（调试用）
- (void)testGlowAnimation;

@end

NS_ASSUME_NONNULL_END
