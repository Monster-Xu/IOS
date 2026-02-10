//
//  ThingBLEAudioAuthorizationTokenModel.h
//  ThingSmartBLEKit
//
//  Created by tjl on 2021/7/9.
//

#import <Foundation/Foundation.h>
#import "ThingBLEAudioVoiceTokenModel.h"
#import "ThingSmartBLEAudioManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThingBLEAudioAuthorizationTokenModel : NSObject

@property (nonatomic, copy) NSString *uuid __attribute__((deprecated("Use -deviceId."))); ;

@property (nonatomic, copy) NSString *deviceId;

@property (nonatomic, assign) ThingAudioTokenType type;

@property (nonatomic, strong) ThingBLEAudioVoiceTokenModel *tokenModel;

@property (nonatomic, copy) ThingSuccessTokenModel successBlock;

@property (nonatomic, copy) ThingFailureError failureBlock;

@end

NS_ASSUME_NONNULL_END
