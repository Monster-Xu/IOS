//
//  ThingBLEAudioVoiceToken.h
//  ThingSmartBLEKit
//
//  Created by tjl on 2021/7/3.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ThingAudioTokenType_MD5Token = 0,
    ThingAudioTokenType_MD5Tken_And_Token,
} ThingAudioTokenType;

NS_ASSUME_NONNULL_BEGIN

@interface ThingBLEAudioVoiceTokenModel : NSObject

@property (nonatomic, assign) ThingAudioTokenType type;

@property (nonatomic, copy) NSString *md5Token;

@property (nonatomic, copy) NSString *token;

@end

NS_ASSUME_NONNULL_END
