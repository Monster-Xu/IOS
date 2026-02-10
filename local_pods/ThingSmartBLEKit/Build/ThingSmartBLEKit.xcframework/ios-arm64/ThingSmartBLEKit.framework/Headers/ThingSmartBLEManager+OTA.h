//
//  ThingSmartBLEManager+OTA.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <ThingSmartBLECoreKit/ThingSmartBLEManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartBLEManager (OTA)

/// Sends an OTA package to update the firmware.
///
/// The value of `otaData` can be obtained from ThingSmartFirmwareUpgradeModel. You can get ThingSmartFirmwareUpgradeModel by using ThingSmartDevice::getFirmwareUpgradeInfo:failure:.
///
/// @note Your device must be connected over Bluetooth before the update.
///
/// @param uuid         The UUID of the device.
/// @param otaData      The OTA package data.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
///
/// @deprecated This method is deprecated, Use ThingSmartBLEManager::sendOTAPack:deviceModel:upgradeModel:success:failure: instead.
- (void)sendOTAPack:(NSString *)uuid
            otaData:(NSData *)otaData
            success:(ThingSuccessHandler)success
            failure:(ThingFailureHandler)failure __deprecated_msg("This method is deprecated, Use ThingSmartBLEManager::sendOTAPack:deviceModel:upgradeModel:success:failure: instead");

/// Sends an OTA package to update the firmware.
///
/// The value of `otaData` can be obtained from ThingSmartFirmwareUpgradeModel. You can get ThingSmartFirmwareUpgradeModel by using ThingSmartDevice::getFirmwareUpgradeInfo:failure:.
///
/// @note Your device must be connected over Bluetooth before the update.
///
/// @param uuid         The UUID of the device.
/// @param pid          The product ID of the device.
/// @param otaData      The OTA package data.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
///
/// @deprecated This method is deprecated, Use ThingSmartBLEManager::sendOTAPack:deviceModel:upgradeModel:success:failure: instead.
- (void)sendOTAPack:(NSString *)uuid
                pid:(NSString *)pid
            otaData:(NSData *)otaData
            success:(ThingSuccessHandler)success
            failure:(ThingFailureHandler)failure __deprecated_msg("This method is deprecated, Use ThingSmartBLEManager::sendOTAPack:deviceModel:upgradeModel:success:failure: instead");

/// Sends an OTA package to update the firmware.
///
/// The values of `otaData`, `otaType`, and `otaVersion` can be obtained from ThingSmartFirmwareUpgradeModel. You can get ThingSmartFirmwareUpgradeModel by using ThingSmartDevice::getFirmwareUpgradeInfo:failure:.
///
/// @note Your device must be connected over Bluetooth before the update.
///
/// @param uuid         The UUID of the device.
/// @param pid          The product ID of the device.
/// @param otaData      The OTA package data.
/// @param otaType      The OTA update type.
/// @param otaVersion   The OTA version.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
///
/// @deprecated This method is deprecated, Use ThingSmartBLEManager::sendOTAPack:deviceModel:upgradeModel:success:failure: instead.
- (void)sendOTAPack:(NSString *)uuid
                pid:(NSString *)pid
            otaData:(NSData *)otaData
            otaType:(ThingSmartBLEOTAType)otaType
         otaVersion:(NSString *)otaVersion
            success:(ThingSuccessHandler)success
            failure:(ThingFailureHandler)failure __deprecated_msg("This method is deprecated, Use ThingSmartBLEManager::sendOTAPack:deviceModel:upgradeModel:success:failure: instead");

/// Send OTA package to upgrade firmware.
/// @param otaData otaData.
/// @param deviceModel Device Model.
/// @param upgradeModel Firmware upgrade model.
/// @param success Called when the task finishes successfully.
/// @param failure Called when the task is interrupted by an error.
- (void)sendOTAPack:(NSData *)otaData
        deviceModel:(ThingSmartDeviceModel *)deviceModel
       upgradeModel:(ThingSmartFirmwareUpgradeModel *)upgradeModel
            success:(ThingSuccessHandler)success
            failure:(ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END
