//
//  ThingSmartBLEDevice.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <ThingSmartDeviceCoreKit/ThingSmartDeviceCoreKit.h>
@interface ThingShadowDeviceParams : ThingDeviceConnectParams
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *deviceId;

@end

/// @brief The Bluetooth LE device is inherited from ThingSmartDevice.
@interface ThingSmartBLEDevice : ThingSmartDevice

- (void)connectShadowDeviceWithParams:(ThingShadowDeviceParams *)connectParams
                              success:(ThingSuccessHandler)success
                              failure:(ThingFailureError)failure;

@end
