//
//  ThingSmartBLEManager+AlexaVoice.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <ThingSmartBLECoreKit/ThingSmartBLEManager.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ThingSmartVoiceTypeAlexa = 0,
    ThingSmartVoiceTypeChatgpt
} ThingSmartVoiceType;



typedef enum : NSUInteger {
    ThingSmartVoiceACKStateSuccess = 0,
    ThingSmartVoiceACKStateUnauthorized,
    ThingSmartVoiceACKStateNoNetwork,
    ThingSmartVoiceACKStateNetworkError,
} ThingSmartVoiceACKState;



@interface ThingSmartBLEVoiceModel : NSObject

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *dialogId;
@end

@interface ThingSmartBLEVoiceSpeakAckModel : ThingSmartBLEVoiceModel
@property (nonatomic, assign) ThingSmartVoiceACKState voiceAckState;
@end

@interface ThingSmartBLEVoiceSpeakStateModel : ThingSmartBLEVoiceModel
@property (nonatomic, assign) ThingSmartAudioState audioState;
@end

@interface ThingSmartBLEVoiceSpeakResultModel : ThingSmartBLEVoiceModel
// 0 - result : NSString,  1 - result : ThingBLEAudioWeatherModel,  2 - result : ThingBLEAudioToDoListModel
@property (nonatomic, strong) id result;
@property (nonatomic, assign) ThingAudioResultType type;
@property (nonatomic, copy) ThingSuccessHandler success;
@property (nonatomic, copy) ThingFailureError failure;

@end

@interface ThingSmartBLEVoiceStopModel : ThingSmartBLEVoiceModel
@property (nonatomic, assign) ThingAudioErrorCode errorCode;
@end


@protocol ThingSmartBLEVoiceDelegate <NSObject>

@optional


/// Choose devcie sends voice DPS
/// @param dps dps
/// @param deviceId device id
/// @param uuid device uuid
/// @param success  Called when the task is finished.
/// @param failure  Called when the task is interrupted by an error.
- (void)publishVoiceDps:(NSDictionary *)dps
                devicId:(NSString *)deviceId
                   uuid:(NSString *)uuid
                success:(nullable ThingSuccessHandler)success
                failure:(nullable ThingFailureError)failure;


/// alexa start speedch
/// @param voiceModel voice model
- (void)publishAudioStartSpeech:(ThingSmartBLEVoiceSpeakAckModel *)voiceModel;

/// alexa provide speech
/// @param voiceModel voice model
- (void)publishAudioProvideSpeech:(ThingSmartBLEVoiceModel *)voiceModel;

/// alex speech state
/// @param voiceModel voice model
- (void)publishAudioSpeechState:(ThingSmartBLEVoiceSpeakStateModel *)voiceModel;

/// alexa audio endpoint
/// @param voiceModel voice model
- (void)publishAudioEndpoint:(ThingSmartBLEVoiceModel *)voiceModel;

/// alexa audio result
/// @param voiceModel voice model
- (void)publishAudioResult:(ThingSmartBLEVoiceSpeakResultModel *)voiceModel;

/// alexa stop speech
/// @param voiceModel voice model
- (void)publishAudioStopSpeech:(ThingSmartBLEVoiceStopModel *)voiceModel;


/// alexa set alarm clock
/// @param model clockModel
/// @param deviceId device id
/// @param success success
/// @param failure failure
- (void)setAlarmClockWithAlarmClockModel:(ThingBLEAudioAlarmClockModel *)model deviceId:(NSString *)deviceId success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

/// alexa audio voice AuthorizationToken
/// @param type type
/// @param deviceId deviceId
/// @param success success
/// @param failure failure
- (void)getAudioVoiceAuthorizationToken:(ThingAudioTokenType)type deviceId:(NSString *)deviceId success:(ThingSuccessTokenModel)success failure:(ThingFailureError)failure;

/// alexa md5 token
/// @param md5Token md5Token
/// @param token token
/// @param deviceId device id
- (void)publishAudioMD5Token:(NSString *)md5Token token:(NSString *)token deviceId:(NSString *)deviceId  __deprecated_msg("This method is deprecated, Use publishAudioMD5Token:token:deviceId:success:failure: instead");
/// Pulish alexa md5 token
/// @param md5Token md5 token
/// @param token token
/// @param deviceId deviceId
/// @param success success
/// @param failure failure
- (void)publishAudioMD5Token:(NSString *)md5Token token:(NSString *)token deviceId:(NSString *)deviceId success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

/// alexa clear AuthorizationToken
/// @param deviceId device id
/// @param success success
/// @param failure failure
- (void)clearAuthorizationToken:(NSString *)deviceId success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

// notifyFlag : 0 - invalid value； 1 - Have notice， 2 - Notification clear。
/// alexa notification status
/// @param notifyFlag notify Flag
/// @param isPermanentVision permanent vision
/// @param isPlayAudio play audio
/// @param deviceId device id
/// @param success success
/// @param failure failure
- (void)setNotificationStatus:(int)notifyFlag isPermanentVision:(BOOL)isPermanentVision isPlayAudio:(BOOL)isPlayAudio deviceId:(NSString *)deviceId success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;


/// alexa success device id
/// @param deviceId device id
/// @param token token
- (void)sendAlexaSuccessWithDeviceId:(NSString *)deviceId andToken:(NSString *)token;

@end




@interface ThingSmartBLEManager (AlexaVoice)


- (id<ThingSmartBLEVoiceDelegate>)buildVoiceEntityWithType:(ThingSmartVoiceType)voiceType;

/// alexa start speedch
/// @param status status
/// @param deviceId deviceId
/// @param dialogId dialog Id
- (void)publishAudioStartSpeech:(int)status deviceId:(NSString *)deviceId dialogId:(NSString *)dialogId;

/// alexa provide speech
/// @param deviceId device id
/// @param dialogId dialog id
- (void)publishAudioProvideSpeech:(NSString *)deviceId dialogId:(NSString *)dialogId;

/// alex speech state
/// @param state state
/// @param deviceId devic id
- (void)publishAudioSpeechState:(ThingSmartAudioState)state deviceId:(NSString *)deviceId;

/// alexa audio endpoint
/// @param deviceId device id
/// @param dialogId dialog id
- (void)publishAudioEndpoint:(NSString *)deviceId dialogId:(NSString *)dialogId;
// 0 - result : NSString,  1 - result : ThingBLEAudioWeatherModel,  2 - result : ThingBLEAudioToDoListModel
/// alexa audio result
/// @param result result
/// @param type type
/// @param deviceId device id
- (void)publishAudioResult:(id)result type:(ThingAudioResultType)type deviceId:(NSString *)deviceId;

/// alexa stop speech
/// @param errorCode error code
/// @param deviceId device Id
/// @param dialogId dialog Id
- (void)publishAudioStopSpeech:(ThingAudioErrorCode)errorCode deviceId:(NSString *)deviceId dialogId:(NSString *)dialogId;

/// alexa set alarm clock
/// @param model clockModel
/// @param deviceId device id
/// @param success success
/// @param failure failure
- (void)setAlarmClockWithAlarmClockModel:(ThingBLEAudioAlarmClockModel *)model deviceId:(NSString *)deviceId success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

/// alexa audio voice AuthorizationToken
/// @param type type
/// @param deviceId deviceId
/// @param success success
/// @param failure failure
- (void)getAudioVoiceAuthorizationToken:(ThingAudioTokenType)type deviceId:(NSString *)deviceId success:(ThingSuccessTokenModel)success failure:(ThingFailureError)failure;

/// alexa md5 token
/// @param md5Token md5Token
/// @param token token
/// @param deviceId device id
- (void)publishAudioMD5Token:(NSString *)md5Token token:(NSString *)token deviceId:(NSString *)deviceId  __deprecated_msg("This method is deprecated, Use publishAudioMD5Token:token:deviceId:success:failure: instead");
/// Pulish alexa md5 token
/// @param md5Token md5 token
/// @param token token
/// @param deviceId deviceId
/// @param success success
/// @param failure failure
- (void)publishAudioMD5Token:(NSString *)md5Token token:(NSString *)token deviceId:(NSString *)deviceId success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

/// alexa clear AuthorizationToken
/// @param deviceId device id
/// @param success success
/// @param failure failure
- (void)clearAuthorizationToken:(NSString *)deviceId success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

// notifyFlag : 0 - invalid value； 1 - Have notice， 2 - Notification clear。
/// alexa notification status
/// @param notifyFlag notify Flag
/// @param isPermanentVision permanent vision
/// @param isPlayAudio play audio
/// @param deviceId device id
/// @param success success
/// @param failure failure
- (void)setNotificationStatus:(int)notifyFlag isPermanentVision:(BOOL)isPermanentVision isPlayAudio:(BOOL)isPlayAudio deviceId:(NSString *)deviceId success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;


/// alexa success device id
/// @param deviceId device id
/// @param token token
- (void)sendAlexaSuccessWithDeviceId:(NSString *)deviceId andToken:(NSString *)token;

@end



NS_ASSUME_NONNULL_END
