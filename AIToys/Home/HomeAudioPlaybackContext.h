#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeAudioPlaybackContext : NSObject

@property (nonatomic, copy, nullable) NSString *audioURL;
@property (nonatomic, copy, nullable) NSString *storyTitle;
@property (nonatomic, copy, nullable) NSString *coverImageURL;

- (BOOL)hasPlaybackContent;
- (void)reset;
- (void)applyToMiniAppParams:(NSMutableDictionary *)params
        playbackMilliseconds:(NSInteger)playbackMilliseconds
                   isPlaying:(BOOL)isPlaying;
- (NSDictionary *)playbackInfoWithHasPlayer:(BOOL)hasPlayer
                        playbackMilliseconds:(NSInteger)playbackMilliseconds
                                   isPlaying:(BOOL)isPlaying;

@end

NS_ASSUME_NONNULL_END
