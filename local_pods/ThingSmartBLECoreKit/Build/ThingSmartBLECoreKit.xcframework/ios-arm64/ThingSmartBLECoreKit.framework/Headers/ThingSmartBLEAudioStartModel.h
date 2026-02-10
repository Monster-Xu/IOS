//
//  ThingSmartBLEAudioStartModel.h
//  ThingSmartBLEKit
//
//  Created by tjl on 2021/4/28.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    Thing_PCM_L16_16KHZ_MONO = 0,
    Thing_OPUS_16KHZ_32KBPS_CBR_0_20MS,
    Thing_OPUS_16KHZ_16KBPS_CBR_0_20MS,
    Thing_MSBC,
} ThingAudioAudioFormat;

typedef enum : NSUInteger {
    Thing_Audio_Profile_CLOSE_TALK = 0,
    Thing_Audio_Profile_NEAR_FIELD,
    Thing_Audio_Profile_FAR_FIELD,
} ThingAudioAudioProfile;


typedef enum : NSUInteger {
    ThingSmartAvsStateIdle = 0,
    ThingSmartAvsStateListening,
    ThingSmartAvsStateProcessing,
    ThingSmartAvsStateSpeaking,
} ThingSmartAudioState;

typedef enum : NSUInteger {
    ThingAudioErrorCode_Success = 0,
    ThingAudioErrorCode_Unknow,
    ThingAudioErrorCode_Internal,
    ThingAudioErrorCode_Unsupported,
    ThingAudioErrorCode_UserCancelled,
    ThingAudioErrorCode_NotFound,
    ThingAudioErrorCode_Invalid,
    ThingAudioErrorCode_Busy,
} ThingAudioErrorCode;

typedef enum : NSUInteger {
    ThingAudioResultType_Voice = 0,
    ThingAudioResultType_Weather,
    ThingAudioResultType_List,
    ThingAudioResultType_Other,
} ThingAudioResultType;

typedef enum : NSUInteger {
    ThingSmartAvsCmdStartSpeech = 1,
    ThingSmartAvsCmdProvideSpeech,
    ThingSmartAvsCmdEndpointSpeech,
    ThingSmartAvsCmdStopSpeech,
    ThingSmartAvsCmdNotifySpeech,
    ThingSmartAvsCmdStopSpeech_IsAck,
} ThingSmartAudioCMD;

typedef enum : NSInteger {
    ThingAudioCommonCmd_ClearToken = 0,
    ThingAudioCommonCmd_NotificationStatus = 1,
} ThingAudioCommonCmd;


typedef enum : NSUInteger {
    ThingSmartAudioNotifyTypeAlexa = 0,
    ThingSmartAudioNotifyTypeChatgpt
} ThingSmartAudioNotifyType;

NS_ASSUME_NONNULL_BEGIN


@interface ThingSmartBLEAudioNotifyModel : NSObject

@property (nonatomic, copy) NSString *dialogId;
@property (nonatomic, copy) NSString *deviceId;
//add uuid
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, assign) ThingSmartAudioNotifyType audioType;

@end


@interface ThingSmartBLEAudioStartModel : ThingSmartBLEAudioNotifyModel

@property (nonatomic, assign) ThingAudioAudioFormat audioFormat;

@property (nonatomic, assign) ThingAudioAudioProfile audioProfile;
// NO : Play
@property (nonatomic, assign) BOOL isSuppressEarcon;

@property (nonatomic, assign) BOOL isPlayVoice;


@end

@interface ThingSmartBLEAudioProvideModel : ThingSmartBLEAudioNotifyModel

@property (nonatomic, assign) ThingAudioAudioFormat audioFormat;

@property (nonatomic, assign) ThingAudioAudioProfile audioProfile;


@end

@interface ThingSmartBLEAudioDataModel : ThingSmartBLEAudioNotifyModel

@property (nonatomic, strong) NSData *audioData;
@property (nonatomic, assign) ThingAudioAudioFormat audioFormat;

@end

@interface ThingSmartBLEAudioErrorModel : ThingSmartBLEAudioNotifyModel

@property (nonatomic, assign) ThingAudioErrorCode errorCode;

@end


NS_ASSUME_NONNULL_END
