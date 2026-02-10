//
//  ThingSmartLanMessageModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The local network message.
@interface ThingSmartLanMessageModel : NSObject

/// The protocol.
@property (nonatomic, assign) NSInteger    protocol;

/// The device ID.
@property (nonatomic, strong) NSString     *devId;

/// The message body.
@property (nonatomic, strong) NSDictionary *body;

/// The message data.
@property (nonatomic, strong) NSData       *data;

@end

NS_ASSUME_NONNULL_END
