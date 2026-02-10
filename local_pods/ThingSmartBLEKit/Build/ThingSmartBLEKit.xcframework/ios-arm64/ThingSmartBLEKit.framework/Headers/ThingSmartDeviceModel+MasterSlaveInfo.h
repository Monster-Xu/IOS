//
//  ThingSmartDeviceModel+MasterSlaveInfo.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <ThingSmartDeviceCoreKit/ThingSmartDeviceCoreKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ThingSmartBLELocalOnlineType) {
    ThingSmartBLELocalOnlineTypeOffline,
    ThingSmartBLELocalOnlineTypeCloud,
    ThingSmartBLELocalOnlineTypeBle,
    ThingSmartBLELocalOnlineTypeBeacon,
    ThingSmartBLELocalOnlineTypeThroughMaster,
};


@interface ThingSmartDeviceModel (MasterSlaveInfo)

/// Query the online type of the device
- (ThingSmartBLELocalOnlineType)deviceOnlineType;

- (BOOL)isSupportMasterDevice;

@end

NS_ASSUME_NONNULL_END
