//
//  ThingSmartSingleTransfer.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ThingSmartTransferState) {
    ThingSmartTransferConnected = 1, // The connected state.
    ThingSmartTransferDisconnected, // The disconnected state.
};

@class ThingSmartSingleTransfer;
@protocol ThingSmartTransferDelegate<NSObject>

/// When the connection state changes, the delegate is executed.
/// @param transfer Data is transferred.
/// @param state The transfer state in Thing Smart.
- (void)transfer:(ThingSmartSingleTransfer *)transfer didUpdateConnectState:(ThingSmartTransferState)state;

/// When device data is received, the delegate is executed.
/// @param transfer Data is transferred.
/// @param devId The device ID.
/// @param data The received data.
- (void)transfer:(ThingSmartSingleTransfer *)transfer didReciveDataWithDevId:(NSString *)devId data:(NSData *)data;

@end

__deprecated_msg("The channel already merged. We will provide a new way to support it.")
@interface ThingSmartSingleTransfer : NSObject

/// @deprecated The data flow channel that is currently deprecated.
///
/// You can use ThingSmartMQTTChannelDelegate to receive data.
///
@property (nonatomic, weak) id<ThingSmartTransferDelegate> delegate;

#if TARGET_OS_IOS

/// Starts the connection.
- (void)startConnect;

/// The connection state.
/// @return The connection result.
- (BOOL)isConnected;

/// Close the channels. The merged channels are not closed to ensure the normal device subscription process.
- (void)close __deprecated_msg("will remove it");;

/// Subscribes to the device.
/// @param devId The device ID.
- (void)subscribeDeviceWithDevId:(NSString *)devId;

/// Unsubscribes from the device.
/// @param devId The device ID.
- (void)unsubscribeDeviceWithDevId:(NSString *)devId;

#endif

@end

