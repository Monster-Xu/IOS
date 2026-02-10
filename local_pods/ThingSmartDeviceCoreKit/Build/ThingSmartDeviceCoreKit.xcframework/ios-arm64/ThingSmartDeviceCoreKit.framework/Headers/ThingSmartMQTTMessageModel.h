//
//  ThingSmartMQTTMessageModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The MQTT message.
@interface ThingSmartMQTTMessageModel : NSObject

/// The protocol.
@property (nonatomic, assign) NSInteger    protocol;

/// The message type.
@property (nonatomic, strong) NSString     *type;

/// The message data.
@property (nonatomic, strong) id           data;

/// The device ID.
@property (nonatomic, strong) NSString     *devId;

@end

NS_ASSUME_NONNULL_END
