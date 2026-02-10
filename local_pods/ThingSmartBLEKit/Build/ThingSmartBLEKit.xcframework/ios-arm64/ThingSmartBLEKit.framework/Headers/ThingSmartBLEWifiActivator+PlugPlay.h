//
//  ThingSmartBLEWifiActivator+PlugPlay.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <ThingSmartBLEKit/ThingSmartBLEKit.h>
#import "ThingSmartBLEWifiActivator.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartBLEWifiActivator (PlugPlay)

/// Activate zigbee sub device with ble channel.
/// The result will callback by ThingSmartBLEWifiActivatorDelegate.
///
/// @param advModel     Device advertisement model.
/// @param homeId       The Id for the current home.
/// @param device       Gateway device.
/// @param timeout      Timeout time.
- (void)activatorZigbeeSubDeviceWithBleChannel:(ThingBLEAdvModel *)advModel
                                        homeId:(long long)homeId
                                 gatewayDevice:(ThingSmartDevice *)device
                                       timeout:(NSTimeInterval)timeout;

/// Enabling zigbee sub device to switch to the zigbee distribution network.
///
/// @param advModel     Device advertisement model.
/// @param homeId       The Id for the current home.
/// @param success      This block will be called if success.
/// @param failure      This block will be called if some error occurred.
- (void)switchZigbeeSubDeviceToZigbeeActivator:(ThingBLEAdvModel *)advModel
                                        homeId:(long long)homeId
                                       success:(ThingSuccessHandler)success
                                       failure:(ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END
