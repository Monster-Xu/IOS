#import <Foundation/Foundation.h>

@class HomeAudioPlaybackContext;

NS_ASSUME_NONNULL_BEGIN

@interface HomeAudioPlaybackCoordinator : NSObject

@property (nonatomic, strong, readonly) HomeAudioPlaybackContext *playbackContext;
@property (nonatomic, assign, readonly, getter=isAudioSessionActive) BOOL audioSessionActive;

- (void)markAudioSessionActive;
- (void)markAudioSessionInactive;
- (BOOL)reactivateAudioSessionIfNeededForPlayerExists:(BOOL)hasPlayer;
- (void)updatePlaybackContextWithAudioURL:(NSString *)audioURL
                               storyTitle:(NSString *)storyTitle
                            coverImageURL:(NSString *)coverImageURL;
- (BOOL)shouldRestorePlayerFromSystemState;
- (BOOL)isNowPlayingActivelyPlaying;
- (void)resetPlaybackContext;
- (void)clearNowPlayingInfo;
- (void)handleAudioSessionInterruption:(NSNotification *)notification
                          pauseHandler:(dispatch_block_t)pauseHandler;

@end

NS_ASSUME_NONNULL_END
