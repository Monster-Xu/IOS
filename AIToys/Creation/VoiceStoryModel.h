//
//  VoiceStoryModel.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 故事状态枚举
typedef NS_ENUM(NSInteger, StoryStatus) {
    StoryStatusPending = 0,       // 故事待生成
    StoryStatusGenerating = 1,    // 故事生成中
    StoryStatusGenerated = 2,     // 故事生成成功
    StoryStatusGenerateFailed = 3,// 故事生成失败
    StoryStatusAudioGenerating = 4,// 音频生成中
    StoryStatusCompleted = 5,     // 音频生成成功
    StoryStatusAudioFailed = 6    // 音频生成失败
};

// 故事类型枚举
typedef NS_ENUM(NSInteger, StoryType) {
    StoryTypeFairyTale = 1,       // 童话
    StoryTypeFable = 2,           // 寓言
    StoryTypeAdventure = 3,       // 冒险
    StoryTypeSuperhero = 4,       // 超级英雄
    StoryTypeScienceFiction = 5,  // 科幻
    StoryTypeEducational = 6,     // 教育
    StoryTypeBedtime = 7          // 睡前故事
};

@interface VoiceStoryModel : NSObject

// 基本信息
@property (nonatomic, assign) NSInteger storyId;
@property (nonatomic, copy) NSString *storyName;
@property (nonatomic, copy, nullable) NSString *storyContent;
@property (nonatomic, copy, nullable) NSString *storySummary;
@property (nonatomic, assign) StoryType storyType;
@property (nonatomic, copy, nullable) NSString *storyTypeDesc;
@property (nonatomic, copy) NSString *protagonistName;
@property (nonatomic, assign) NSInteger storyLength;
@property (nonatomic, copy, nullable) NSString *illustrationUrl;

// 声音和音频信息
@property (nonatomic, assign) NSInteger voiceId;
@property (nonatomic, copy, nullable) NSString *voiceName;
@property (nonatomic, copy, nullable) NSString *audioUrl;

// 状态信息
@property (nonatomic, assign) StoryStatus storyStatus;
@property (nonatomic, copy, nullable) NSString *statusDesc;
@property (nonatomic, copy, nullable) NSString *errorMsg;

// 公仔关联
@property (nonatomic, assign) NSInteger dollId;
@property (nonatomic, copy, nullable) NSString *dollName;

// 时间信息
@property (nonatomic, copy, nullable) NSString *createTime;
@property (nonatomic, copy, nullable) NSString *updateTime;

// 兼容旧版本的属性
@property (nonatomic, copy) NSString *status; // 兼容旧版本，映射到 statusDesc

// UI状态属性
@property (nonatomic, assign) BOOL isNew;       // 是否显示New标签
@property (nonatomic, assign) BOOL isPlaying;   // 是否正在播放

// 便利方法
- (NSString *)storyTypeDescription;
- (BOOL)canPlay;
- (BOOL)canEdit;
- (BOOL)isGenerating;
- (BOOL)hasFailed;

@end

NS_ASSUME_NONNULL_END
