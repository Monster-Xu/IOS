//
//  ThingSmartMQTTConfig.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//


#import <Foundation/Foundation.h>

#if TARGET_OS_IOS
#import <ThingSmartMQTTChannelKit/ThingSmartMQTTChannelKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 ThingSmartMQTTConfiguration Universal & Legacy necessarily info
 - Universal Mode:
     appTag: "industry"...
     terminalId: "xxx-xxx-xx"
     accessId: "accessId"
     appSecret: "appSecret"
     uid: "uid"
     token: "token"
     timestamp: 1234567890
 - Legacy Mode:
     appTag: nil
     terminalId: "xxx-xxx-xx" (uuid)
     accessId: "appKey"
     appSecret: "appSecret"
     uid: "uid"
     token: "sid"
     ecode: "ecode"
     partnerIdentity: "partnerIdentity"
 */
@interface ThingSmartMQTTConfiguration : NSObject
/// The app's tag. (e.g. "industry", etc ...) when it is nil then use legacy mqtt
@property (nonatomic, strong, nullable) NSString *appTag;
/// The phone's terminal id. (also = uuid )
@property (nonatomic, strong) NSString *terminalId;
/// The app's access id. (also = appKey)
@property (nonatomic, strong) NSString *accessId;
/// The app's secret.
@property (nonatomic, strong) NSString *appSecret;
/// The logined user's id.
@property (nonatomic, strong, nullable) NSString *uid;
/// The logined user's token. (also = sid)
@property (nonatomic, strong) NSString *token;
/// The time stamp.( Fetch from server isrecommended. The length is 10. )
@property (nonatomic, assign) NSInteger timestamp;
/// The ecode.
@property (nonatomic, strong, nullable) NSString *ecode;
/// The partner identity.
@property (nonatomic, strong, nullable) NSString *partnerIdentity;

@property (nonatomic, strong) NSString *mbHost;
@property (nonatomic, strong, nullable) NSString *mbIp;
@property (nonatomic, assign) int mbPort;
@property (nonatomic, assign) BOOL useSSL;

@property (nonatomic, strong, nullable) NSString *quicHost;
@property (nonatomic, strong, nullable) NSString *quicIp;
@property (nonatomic, assign) int quicPort;
@property (nonatomic, assign) BOOL useQUIC;

@property (nonatomic, strong, nullable) NSString *appChannelTag;

@end

@protocol ThingSmartMQTTConfigTransferProtocol <NSObject>
@optional
/// called when need mqtt configuration.
- (nullable ThingSmartMQTTConfiguration *)transferMQTTConfiguration;
@end

@class ThingSmartMQTTConfigModel;
@interface ThingSmartMQTTConfig : NSObject

ThingSDK_SINGLETON

- (instancetype)initWithMQTTChannel:(ThingSmartMQTTChannel *)channel;

/// setup mqtt connect configuration transfer
/// @param transfer mqtt confuguration transfer
- (void)setMqttConfigTransfer:(id<ThingSmartMQTTConfigTransferProtocol>)transfer;

/// connect mqtt server.
- (void)connect;

/// close the mqtt connect.
- (void)close;

@end

NS_ASSUME_NONNULL_END

#endif
