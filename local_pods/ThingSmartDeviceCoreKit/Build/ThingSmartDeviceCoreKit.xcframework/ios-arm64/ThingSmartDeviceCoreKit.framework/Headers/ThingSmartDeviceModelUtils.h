//
//  ThingSmartDeviceModelUtils.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#ifndef ThingSmartDeviceModelUtils_h
#define ThingSmartDeviceModelUtils_h

/// The device update status.
typedef enum : NSUInteger {
    /// Default: No update is required.
    ThingSmartDeviceUpgradeStatusDefault = 0,
    /// Ready: The hardware is ready.
    ThingSmartDeviceUpgradeStatusReady = 1,
    /// Upgrading: The update is in progress.
    ThingSmartDeviceUpgradeStatusUpgrading = 2,
    /// Success: The update is completed.
    ThingSmartDeviceUpgradeStatusSuccess = 3,
    /// Failure: The update has an exception.
    ThingSmartDeviceUpgradeStatusFailure = 4,
    /// NB-IoT devices wait to execute NB-IoT tasks. Device tasks have been sent but not yet executed.
    ThingSmartDeviceUpgradeStatusWaitingExectue = 5,
    /// NB-IoT devices have downloaded NB-IoT firmware.
    ThingSmartDeviceUpgradeStatusDownloaded = 6,
    /// Timeout: The update timed out.
    ThingSmartDeviceUpgradeStatusTimeout = 7,
    
    /// InQueue: The update is in the queue.
    ThingSmartDeviceUpgradeStatusInQueue = 13,
    /// Prepare: The update is prepare.
    ThingSmartDeviceUpgradeStatusPrepare = 14,
    
    /// LocalPrepare: The app local prepare status. (when the device is linking, switch to sub device, app downloding firmware ....)
    ThingSmartDeviceUpgradeStatusLocalPrepare = 100,
} ThingSmartDeviceUpgradeStatus;

/// The device update mode.
typedef NS_ENUM(NSUInteger, ThingSmartDeviceUpgradeMode) {
    /// Generic firmware update. (General update such as MCU, WiFi, BLE and other hardware module firmware in the device.)
    ThingSmartDeviceUpgradeModeNormal   = 0,
    /// Update PID-specific firmware. (General update such as product schema, panel settings, multilingual settings, and shortcut control)
    ThingSmartDeviceUpgradeModePidVersion = 1,
};

#endif /* ThingSmartDeviceModelUtils_h */
