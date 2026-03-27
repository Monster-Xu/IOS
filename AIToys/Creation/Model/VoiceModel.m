//
//  VoiceModel.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import "VoiceModel.h"

@implementation VoiceModel

- (instancetype)init {
    if (self = [super init]) {
        _voiceId = 0;
        _cloneStatus = VoiceCloneStatusPending;
        _bindStoryCount = 0;
        _sampleText = LocalString(@"你好，让我们一起玩吧");
    }
    return self;
}

- (BOOL)canDelete {
    return self.bindStoryCount == 0;
}

- (BOOL)canUse {
    return self.cloneStatus == VoiceCloneStatusSuccess;
}

- (BOOL)isCloning {
    return self.cloneStatus == VoiceCloneStatusCloning;
}

- (NSString *)cloneStatusDescription {
    if (self.statusDesc) {
        return self.statusDesc;
    }
    
    switch (self.cloneStatus) {
        case VoiceCloneStatusPending:
            return LocalString(@"待克隆");
        case VoiceCloneStatusCloning:
            return LocalString(@"克隆中");
        case VoiceCloneStatusSuccess:
            return LocalString(@"克隆成功");
        case VoiceCloneStatusFailed:
            return LocalString(@"克隆失败");
        default:
            return LocalString(@"待克隆");
    }
}

@end