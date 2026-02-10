//
//  ThingSmartFirmwareUpgradeModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#ifndef ThingSmart_ThingSmartFirmwareUpgradeModel
#define ThingSmart_ThingSmartFirmwareUpgradeModel

#import <Foundation/Foundation.h>
#import "ThingSmartDeviceModelUtils.h"

@class ThingSmartFirmwareUpgradeModel;

/// The device firmware update information. (Provided for `home owner role` or `administrator role`  users.)
@interface ThingSmartFirmwareUpgradeModel : NSObject

/// The update copywriting.
@property (nonatomic, strong) NSString  *desc;

/// The device type copywriting.
@property (nonatomic, strong) NSString *typeDesc;

/// Valid values: `0`: no later version. `1`: a later version available. `2`: updating. `5`: waiting for the device to wake up.
@property (nonatomic, assign) ThingSmartDeviceUpgradeStatus upgradeStatus;

/// The firmware version that is used in the later version.
@property (nonatomic, strong) NSString  *version;

/// The current firmware version in use.
@property (nonatomic, strong) NSString  *currentVersion;

/// The update timeout. Unit: seconds.
@property (nonatomic, assign) NSInteger timeout;

/// The upgrade reminder recommend. Used to display UI different.
/// - 0: update remind. (General present a Alert to user, user can select upgrade or not.)
/// - 2: forced update. (General present a Alert to user, but user can only select upgrade.)
/// - 3: update detection. (General use a Little Red Mark to express there has a new version.)
@property (nonatomic, assign) NSInteger upgradeType;

/// The firmware type.
/// Notice: only have meanning when `upgradeMode == ThingSmartDeviceUpgradeModeNormal`
@property (nonatomic, assign) NSInteger type;

// The device type. 0: normal device. 1: low-power non-keep-alive device.
@property (nonatomic, assign) NSInteger devType;

/// The download URL of the update firmware for Bluetooth devices.
@property (nonatomic, strong) NSString *url;

/// The firmware MD5 message-digest algorithm.
@property (nonatomic, strong) NSString *md5;

/// The size of the firmware package. Unit: bytes.
@property (nonatomic, strong) NSString *fileSize;

/// Firmware sign.
@property (nonatomic, strong) NSString *sign;

/// The last update time of the DP.
@property (nonatomic, assign) long long lastUpgradeTime;

/// The firmware release date.
@property (nonatomic, assign) long long firmwareDeployTime;

/// Indicates whether the update device is controllable. `1` : controllable. `0` : not controllable.
@property (nonatomic, assign) BOOL controlType;

/// The description of waiting for device wake-up. The low-power non-keep-alive device is in the state of "waiting for device wake-up" before an update.
@property (nonatomic, strong) NSString *waitingDesc;

/// The notification text in the firmware update.
@property (nonatomic, strong) NSString *upgradingDesc;

/// if the device has the ability to upgrade.can not upgrade like low power. It will be nil when device has not dp check.
@property (nonatomic, strong) NSNumber *canUpgrade;

/// The remind when device can not upgrade.Value can be nil.
@property (nonatomic, copy) NSString *remind;

/// The firmware sign hmac
@property (nonatomic, copy) NSString *hmac;

/// The firmware support differential packet or not
@property (nonatomic, assign) BOOL diffOta;

/// The firmware's local file path for upgrade used lan way.
@property (nonatomic, strong) NSString *filePath;

/// The notification text in the device download firmware. Currently, only NB-IoT devices are supported.
@property (nonatomic, strong) NSString *downloadingDesc __deprecated_msg("This property is deprecated, Use upgradingDesc instead");

/// The firmware upgrade mode. (normal upgrade, pid version upgrade, ... )
/// - Normal (0): The upgrade for the Device modules.
/// - PidVersion (1): The upgrade for the Product info.
@property (nonatomic, assign) ThingSmartDeviceUpgradeMode upgradeMode;

/// The cloud auto switch
@property (nonatomic, assign) BOOL autoSwitch;

/// The firmware  can not be upgraded by BLE directly or not.
@property (nonatomic, assign) BOOL disableBleDirectOTA;

@end

/// The device firmware update information. (Provided for `common member role` users)
@interface ThingSmartMemberCheckFirmwareInfo : NSObject
/// The firmware type. (or called `channel`)
@property (nonatomic, assign) NSInteger type;
/// The firmware update status.
@property (nonatomic, assign) ThingSmartDeviceUpgradeStatus upgradeStatus;
/// The firmware version that is used in the later version.
@property (nonatomic, strong) NSString *version;
/// The firmware upgrade text.
@property (nonatomic, strong, nullable) NSString *upgradeText;
@end

/// The device firmware update info, result for `-checkBatchFirmwareWithSuccess:failure:`.  (Provided for `home owner role` or `administrator role`  users.)
@interface ThingSmartFirmwareCheckResult : NSObject
/// Support group ota or not.
@property (nonatomic, assign) BOOL supportGroup;
/// The group name.
/// If `supportGroup = YES`, `group = "gwId + hash(deviceList)"`
/// If `supportGroup = NO`, `group = "devId"`
@property (nonatomic, strong, nullable) NSString *group;
/// The firmwares list.
@property (nonatomic, strong, nonnull) NSArray<ThingSmartFirmwareUpgradeModel *> *upgradeList;
/// These devices can be batch firmware upgrade in a same group.
@property (nonatomic, strong, nullable) NSArray<NSDictionary *> *deviceList; // [{"devId": xxx, "name": yyy, "gid": 1234, "gname": "home_name"}]
@end

/// The result for `-startBatchFirmwareUpgradeWithDevIds:success:failure`.  (Provided for `home owner role` or `administrator role`  users.)
@interface ThingSmartBatchFirmwareConfirmResult : NSObject
/// These devices cannot be submitted for batch upgrade tasks. Please use `-startFirmwareUpgrade:` to upgrade.
@property (nonatomic, strong, nonnull) NSArray<NSString *> *unsubmitDevIds;
/// These devices were successfully submitted for batch upgrades.
@property (nonatomic, strong, nonnull) NSArray<NSString *> *comfirmSuccessDevIds;
/// These devices failed to submit batch upgrades.
@property (nonatomic, strong, nonnull) NSArray<NSString *> *comfirmFailureDevIds;
@end

#endif
