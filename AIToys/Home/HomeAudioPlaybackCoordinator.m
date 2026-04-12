#import "HomeAudioPlaybackCoordinator.h"
#import "HomeAudioPlaybackContext.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface HomeAudioPlaybackCoordinator ()

@property (nonatomic, strong) HomeAudioPlaybackContext *playbackContext;
@property (nonatomic, assign, readwrite, getter=isAudioSessionActive) BOOL audioSessionActive;

@end

@implementation HomeAudioPlaybackCoordinator

- (instancetype)init {
    self = [super init];
    if (self) {
        _playbackContext = [[HomeAudioPlaybackContext alloc] init];
        _audioSessionActive = NO;
    }
    return self;
}

- (void)markAudioSessionActive {
    self.audioSessionActive = YES;
}

- (void)markAudioSessionInactive {
    self.audioSessionActive = NO;
}

- (BOOL)reactivateAudioSessionIfNeededForPlayerExists:(BOOL)hasPlayer {
    if (!hasPlayer || self.isAudioSessionActive) {
        return NO;
    }

    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                            mode:AVAudioSessionModeDefault
                                         options:AVAudioSessionCategoryOptionMixWithOthers
                                           error:&error];
    if (error) {
        NSLog(@"⚠️ 音频会话设置失败: %@", error.localizedDescription);
        return NO;
    }

    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"⚠️ 音频会话激活失败: %@", error.localizedDescription);
        return NO;
    }

    self.audioSessionActive = YES;
    NSLog(@"✅ 音频会话重新激活成功");
    return YES;
}

- (void)updatePlaybackContextWithAudioURL:(NSString *)audioURL
                               storyTitle:(NSString *)storyTitle
                            coverImageURL:(NSString *)coverImageURL {
    self.playbackContext.audioURL = audioURL;
    self.playbackContext.storyTitle = storyTitle;
    self.playbackContext.coverImageURL = coverImageURL;
}

- (BOOL)shouldRestorePlayerForNowPlayingInfo:(NSDictionary *)nowPlayingInfo {
    if (![self.playbackContext hasPlaybackContent] || nowPlayingInfo.count == 0) {
        return NO;
    }

    NSString *currentTitle = nowPlayingInfo[MPMediaItemPropertyTitle];
    return currentTitle.length > 0 && [currentTitle isEqualToString:self.playbackContext.storyTitle];
}

- (BOOL)shouldRestorePlayerFromSystemState {
    if (![self.playbackContext hasPlaybackContent]) {
        return NO;
    }

    AVAudioSession *session = [AVAudioSession sharedInstance];
    if (session.isOtherAudioPlaying) {
        return NO;
    }

    NSDictionary *nowPlayingInfo = [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo;
    return [self shouldRestorePlayerForNowPlayingInfo:nowPlayingInfo];
}

- (BOOL)isNowPlayingActivelyPlaying {
    NSDictionary *nowPlayingInfo = [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo;
    NSNumber *playbackRate = nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate];
    return playbackRate && playbackRate.floatValue > 0;
}

- (void)resetPlaybackContext {
    [self.playbackContext reset];
}

- (void)clearNowPlayingInfo {
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
    NSLog(@"🧹 已清理系统媒体控制中心的播放信息");
}

- (void)handleAudioSessionInterruption:(NSNotification *)notification
                          pauseHandler:(dispatch_block_t)pauseHandler {
    NSNumber *interruptionType = notification.userInfo[AVAudioSessionInterruptionTypeKey];
    if (!interruptionType) {
        return;
    }

    switch ([interruptionType integerValue]) {
        case AVAudioSessionInterruptionTypeBegan:
            NSLog(@"🔕 音频会话被中断开始");
            if (pauseHandler) {
                pauseHandler();
            }
            self.audioSessionActive = NO;
            break;

        case AVAudioSessionInterruptionTypeEnded: {
            NSLog(@"🔔 音频会话中断结束");
            NSNumber *interruptionOptions = notification.userInfo[AVAudioSessionInterruptionOptionKey];
            if (interruptionOptions && ([interruptionOptions unsignedIntegerValue] & AVAudioSessionInterruptionOptionShouldResume)) {
                NSError *error = nil;
                [[AVAudioSession sharedInstance] setActive:YES error:&error];
                if (!error) {
                    self.audioSessionActive = YES;
                    NSLog(@"🎵 音频会话已恢复，可以继续播放");
                } else {
                    NSLog(@"⚠️ 音频会话恢复失败: %@", error.localizedDescription);
                }
            }
            break;
        }

        default:
            break;
    }
}

@end
