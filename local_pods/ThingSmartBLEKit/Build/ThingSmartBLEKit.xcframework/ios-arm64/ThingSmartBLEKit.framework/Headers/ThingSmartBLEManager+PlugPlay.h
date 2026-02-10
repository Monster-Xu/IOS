//
//  ThingSmartBLEManager+PlugPlay.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <ThingSmartBLECoreKit/ThingSmartBLEManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartBLEManager (PlugPlay)


/// Activates the Bluetooth mode for a dual-mode device.
///
/// @param advModel    The device advertisement model.
/// @param homeId      The ID of the current home.
/// @param token       The token.
/// @param success     Called when the task is finished. DeviceModel is returned.
/// @param failure     Called when the task is interrupted by an error.
- (void)activatorDualDeviceWithBleChannel:(ThingBLEAdvModel *)advModel
                                   homeId:(long long)homeId
                                    token:(NSString *)token
                                  success:(void(^)(ThingSmartDeviceModel *deviceModel))success
                                  failure:(ThingFailureError)failure;

- (void)activatorZigbeeSubDeviceWithBleChannel:(id<ThingBLEDeviceInfoProtocol>)dev
                                        homeId:(long long)homeId
                                       success:(ThingSuccessID)success
                                       failure:(ThingFailureError)failure;

- (void)switchZigbeeSubDeviceToZigbeeActivator:(id<ThingBLEDeviceInfoProtocol>)dev
                                        homeId:(long long)homeId
                                       success:(ThingSuccessHandler)success
                                       failure:(ThingFailureError)failure;

/// Activates the Wi-Fi channel of a dual-mode device for which the Bluetooth channel is activated.
///
/// @param devId       The device ID.
/// @param ssid        The name of the router.
/// @param password    The password for the device.
/// @param timeout     The timeout value.
/// @param success     Called when the task is finished. DeviceModel is returned.
/// @param failure     Called when the task is interrupted by an error.
- (void)activeDualDeviceWifiChannel:(NSString *)devId
                               ssid:(NSString *)ssid
                           password:(NSString *)password
                            timeout:(NSTimeInterval)timeout
                            success:(void(^)(ThingSmartDeviceModel *deviceModel))success
                            failure:(ThingFailureError)failure;



@end

NS_ASSUME_NONNULL_END
