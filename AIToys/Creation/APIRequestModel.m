//
//  APIRequestModel.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import "APIRequestModel.h"

@implementation CreateStoryRequestModel

- (instancetype)init {
    if (self = [super init]) {
        _storyType = StoryTypeFairyTale;
        _storyLength = 180;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name 
                     summary:(NSString *)summary 
                        type:(StoryType)type 
              protagonistName:(NSString *)protagonistName 
                      length:(NSInteger)length 
              illustrationUrl:(NSString *)illustrationUrl {
    if (self = [super init]) {
        _storyName = [name copy];
        _storySummary = [summary copy];
        _storyType = type;
        _protagonistName = [protagonistName copy];
        _storyLength = length;
        _illustrationUrl = [illustrationUrl copy];
    }
    return self;
}

- (BOOL)isValid {
    return [self validationError] == nil;
}

- (NSString *)validationError {
    if (self.storyName.length == 0 || self.storyName.length > 120) {
        return @"故事名称长度必须在1-120字符之间";
    }
    
    if (self.storySummary.length == 0 || self.storySummary.length > 2400) {
        return @"故事概述长度必须在1-2400字符之间";
    }
    
    if (self.protagonistName.length == 0 || self.protagonistName.length > 30) {
        return @"主角姓名长度必须在1-30字符之间";
    }
    
    NSArray *validLengths = @[@90, @180, @270, @360];
    if (![validLengths containsObject:@(self.storyLength)]) {
        return @"故事时长必须是90、180、270或360秒";
    }
    
    if (self.illustrationUrl.length == 0) {
        return @"插画URL不能为空";
    }
    
    return nil;
}

- (NSDictionary *)toDictionary {
    return @{
        @"storyName": self.storyName ?: @"",
        @"storySummary": self.storySummary ?: @"",
        @"storyType": @(self.storyType),
        @"protagonistName": self.protagonistName ?: @"",
        @"storyLength": @(self.storyLength),
        @"illustrationUrl": self.illustrationUrl ?: @""
    };
}

@end

@implementation UpdateStoryRequestModel

- (instancetype)initWithStoryId:(NSInteger)storyId {
    if (self = [super init]) {
        _storyId = storyId;
    }
    return self;
}

- (BOOL)hasChanges {
    return self.storyName != nil || 
           self.storyContent != nil || 
           self.illustrationUrl != nil || 
           self.voiceId > 0;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:@(self.storyId) forKey:@"storyId"];
    
    if (self.storyName) {
        dict[@"storyName"] = self.storyName;
    }
    if (self.storyContent) {
        dict[@"storyContent"] = self.storyContent;
    }
    if (self.illustrationUrl) {
        dict[@"illustrationUrl"] = self.illustrationUrl;
    }
    if (self.voiceId > 0) {
        dict[@"voiceId"] = @(self.voiceId);
    }
    
    return [dict copy];
}

@end

@implementation CreateVoiceRequestModel

- (instancetype)initWithName:(NSString *)name 
                   avatarUrl:(NSString *)avatarUrl 
                audioFileUrl:(NSString *)audioFileUrl {
    if (self = [super init]) {
        _voiceName = [name copy];
        _avatarUrl = [avatarUrl copy];
        _audioFileUrl = [audioFileUrl copy];
    }
    return self;
}

- (BOOL)isValid {
    return [self validationError] == nil;
}

- (NSString *)validationError {
    if (self.voiceName.length == 0 || self.voiceName.length > 30) {
        return @"声音名称长度必须在1-30字符之间";
    }
    
    if (self.avatarUrl.length == 0) {
        return @"头像URL不能为空";
    }
    
    if (self.audioFileUrl.length == 0) {
        return @"录音文件URL不能为空";
    }
    
    return nil;
}

- (NSDictionary *)toDictionary {
    return @{
        @"voiceName": self.voiceName ?: @"",
        @"avatarUrl": self.avatarUrl ?: @"",
        @"audioFileUrl": self.audioFileUrl ?: @""
    };
}

@end

@implementation UpdateVoiceRequestModel

- (instancetype)initWithVoiceId:(NSInteger)voiceId {
    if (self = [super init]) {
        _voiceId = voiceId;
    }
    return self;
}

- (BOOL)hasChanges {
    return self.voiceName != nil || 
           self.avatarUrl != nil || 
           self.audioFileUrl != nil;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:@(self.voiceId) forKey:@"voiceId"];
    
    if (self.voiceName) {
        dict[@"voiceName"] = self.voiceName;
    }
    if (self.avatarUrl) {
        dict[@"avatarUrl"] = self.avatarUrl;
    }
    if (self.audioFileUrl) {
        dict[@"audioFileUrl"] = self.audioFileUrl;
    }
    
    return [dict copy];
}

@end

@implementation SynthesizeStoryRequestModel

- (instancetype)initWithStoryId:(NSInteger)storyId voiceId:(NSInteger)voiceId {
    if (self = [super init]) {
        _storyId = storyId;
        _voiceId = voiceId;
    }
    return self;
}

- (BOOL)isValid {
    return self.storyId > 0 && self.voiceId > 0;
}

- (NSDictionary *)toDictionary {
    return @{
        @"storyId": @(self.storyId),
        @"voiceId": @(self.voiceId)
    };
}

@end

@implementation DeleteRequestModel

- (instancetype)initWithResourceId:(NSInteger)resourceId {
    if (self = [super init]) {
        _resourceId = resourceId;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    return @{@"storyId": @(self.resourceId)}; // 根据具体接口调整key名
}

@end

@implementation PageRequestModel

- (instancetype)init {
    if (self = [super init]) {
        _pageNum = 1;
        _pageSize = 20;
    }
    return self;
}

- (instancetype)initWithPageNum:(NSInteger)pageNum pageSize:(NSInteger)pageSize {
    if (self = [super init]) {
        _pageNum = pageNum;
        _pageSize = pageSize;
    }
    return self;
}

- (NSDictionary *)toQueryParameters {
    return @{
        @"pageNum": @(self.pageNum),
        @"pageSize": @(self.pageSize)
    };
}

@end