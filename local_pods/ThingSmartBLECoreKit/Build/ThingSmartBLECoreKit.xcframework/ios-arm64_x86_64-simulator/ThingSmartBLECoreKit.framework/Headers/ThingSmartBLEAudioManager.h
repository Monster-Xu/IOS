//
//  ThingSmartBLEAudioManager.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)
//

#import <Foundation/Foundation.h>
#import "ThingSmartBLEAudioStartModel.h"
#import "ThingBLEAudioVoiceTokenModel.h"
#import "ThingBLEAudioAlarmClockModel.h"
#import "ThingBLEAudioToDoListModel.h"
#import "ThingBLEAudioWeatherModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ThingSuccessTokenModel)(ThingBLEAudioVoiceTokenModel *tokenModel);

@protocol ThingSmartBLEAudioManagerDelegate <NSObject>

- (void)audioStartSpeech:(ThingSmartBLEAudioStartModel *)model;

- (void)audioProvideSpeech:(ThingSmartBLEAudioProvideModel *)model;

- (void)audioStopSpeech:(NSString *)dialogId uuid:(NSString *)uuid errorCode:(ThingAudioErrorCode)error;

- (void)audioData:(NSData *)data uuid:(NSString *)uuid audioFormat:(ThingAudioAudioFormat)audioFormat;

//token

@end

@interface ThingSmartBLEAudioManager : NSObject

/// Single instance.
+ (instancetype)sharedInstance;

@property (nonatomic, weak) id<ThingSmartBLEAudioManagerDelegate> delegate;

- (void)publishAudioStartSpeech:(int)status uuid:(NSString *)uuid dialogId:(NSString *)dialogId;

- (void)publishAudioProvideSpeech:(NSString *)uuid dialogId:(NSString *)dialogId;

- (void)publishAudioSpeechState:(ThingSmartAudioState)state uuid:(NSString *)uuid;

- (void)publishAudioEndpoint:(NSString *)uuid dialogId:(NSString *)dialogId;
// 0 - result : NSString,  1 - result : ThingBLEAudioWeatherModel,  2 - result : ThingBLEAudioToDoListModel
- (void)publishAudioResult:(id)result type:(ThingAudioResultType)type uuid:(NSString *)uuid;

- (void)publishAudioStopSpeech:(ThingAudioErrorCode)errorCode uuid:(NSString *)uuid dialogId:(NSString *)dialogId;

- (void)setAlarmClockWithAlarmClockModel:(ThingBLEAudioAlarmClockModel *)model uuid:(NSString *)uuid success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

- (void)getAudioVoiceAuthorizationToken:(ThingAudioTokenType)type uuid:(NSString *)uuid success:(ThingSuccessTokenModel)success failure:(ThingFailureError)failure;

- (void)publishAudioMD5Token:(NSString *)md5Token token:(NSString *)token uuid:(NSString *)uuid;

- (void)clearAuthorizationToken:(NSString *)uuid success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

// notifyFlag : 0 - invalid value； 1 - Have notice， 2 - Notification clear。
- (void)setNotificationStatus:(int)notifyFlag isPermanentVision:(BOOL)isPermanentVision isPlayAudio:(BOOL)isPlayAudio uuid:(NSString *)uuid success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;



@end

NS_ASSUME_NONNULL_END
