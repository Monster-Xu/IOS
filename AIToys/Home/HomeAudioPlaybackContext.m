#import "HomeAudioPlaybackContext.h"

@implementation HomeAudioPlaybackContext

- (BOOL)hasPlaybackContent {
    return self.audioURL.length > 0 && self.storyTitle.length > 0;
}

- (void)reset {
    self.audioURL = nil;
    self.storyTitle = nil;
    self.coverImageURL = nil;
}

- (void)applyToMiniAppParams:(NSMutableDictionary *)params
        playbackMilliseconds:(NSInteger)playbackMilliseconds
                   isPlaying:(BOOL)isPlaying {
    if (!params) {
        return;
    }

    params[@"currentAudioId"] = self.audioURL ?: @"";
    params[@"milliseconds"] = @(playbackMilliseconds);
    params[@"isPlay"] = @(isPlaying);
}

- (NSDictionary *)playbackInfoWithHasPlayer:(BOOL)hasPlayer
                        playbackMilliseconds:(NSInteger)playbackMilliseconds
                                   isPlaying:(BOOL)isPlaying {
    return @{
        @"hasPlayer": @(hasPlayer),
        @"currentAudioId": self.audioURL ?: @"",
        @"milliseconds": @(playbackMilliseconds),
        @"isPlay": @(isPlaying),
        @"storyTitle": self.storyTitle ?: @""
    };
}

@end
