//
//  ThingSmartBLEManager+CustomChannel.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <ThingSmartBLECoreKit/ThingSmartBLEManager.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ThingBLECentralWriteCallback)(NSError *error);
typedef void(^ThingBLECentralCallback)(NSData * __nullable data, NSError * __nullable error);

@interface ThingSmartBLEManager (CustomChannel)

/// Read data from a Bluetooth device.
/// @param deviceId device Id
/// @param serviceUUID Reads the service value for <i>service</i>.
/// @param characteristicUUID Reads the characteristic value for <i>characteristic</i>.
/// @param callback callback
- (void)readWithDeviceId:(NSString *)deviceId
             serviceUUID:(NSString *)serviceUUID
             charactUUID:(NSString *)characteristicUUID
              completion:(ThingBLECentralCallback)callback;

/// Writes data to a Bluetooth device.
/// @param deviceId device Id
/// @param data transmit data
/// @param serviceUUID write the service value for <i>service</i>.
/// @param characteristicUUID The characteristic whose characteristic value will be written.
/// @param callback callback，when callback is nil，CBCharacteristicWriteType is CBCharacteristicWriteWithoutResponse，else  CBCharacteristicWriteType is  CBCharacteristicWriteWithResponse.
- (void)writeWithDeviceId:(NSString *)deviceId
                     data:(NSData *)data
              serviceUUID:(NSString *)serviceUUID
              charactUUID:(NSString *)characteristicUUID
               completion:(ThingBLECentralWriteCallback)callback;

/// setNotify to a Bluetooth device.
/// @param deviceId device Id
/// @param enabled  transmit data
/// @param serviceUUID  the service value for <i>service</i>.
/// @param characteristicUUID he characteristic whose characteristic value will be notify.
/// @param callback callback
- (void)notifyWithDeviceId:(NSString *)deviceId
               notifyValue:(BOOL)enabled
               serviceUUID:(NSString *)serviceUUID
               charactUUID:(NSString *)characteristicUUID
                completion:(ThingBLECentralCallback)callback;

@end

NS_ASSUME_NONNULL_END
