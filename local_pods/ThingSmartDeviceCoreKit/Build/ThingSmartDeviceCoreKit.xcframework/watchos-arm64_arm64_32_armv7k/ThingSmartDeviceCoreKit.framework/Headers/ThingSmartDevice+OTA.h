//
//  ThingSmartDevice+OTA.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <ThingSmartDeviceCoreKit/ThingSmartDeviceCoreKit.h>
#import "ThingSmartFirmwareUpgradeModel.h"
#import "ThingSmartFirmwareUpgradeStatusModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartDevice (OTA)

/// Returns firmware upgrade information. ( for general device.)
/// Contains current firmwares and upgradeable firmwares.
/// Notice:
///     equal to `checkFirmwareUpgradeWithExtraInfo:nil success:success failure:failure`
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)checkFirmwareUpgrade:(void (^)(NSArray<ThingSmartFirmwareUpgradeModel *> *firmwares))success
                     failure:(nullable ThingFailureError)failure;


/// Returns firmware upgrade information. ( for general device and some special device. )
/// Contains current firmwares and upgradeable firmwares.
/// Exta info's ussage:
///     1. extra info = nil
///         For most general device.
///     2. extra info =  {"types": "0,1, ....", "versions": "0.0.1,0.0.2, ...."}.
///         For the AP Directly device, which used local lan to upgrade.
///         You can use `-getDeviceLocalFirmwareInfo:failure:` to get and cached the info `type` & `currentVersion`.
/// @param extraInfo Some special device need extra info to check firmwares.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)checkFirmwareUpgradeWithExtraInfo:(nullable NSDictionary *)extraInfo
                                  success:(void (^)(NSArray<ThingSmartFirmwareUpgradeModel *> *firmwares))success
                                  failure:(nullable ThingFailureError)failure;

/// Start device firmware upgrade. ( for general device and some special device. )
/// Notice:
///     1. You can use the ThingSmartDevice's delegate ( `- device:otaUpdateStatusChanged:` ) to receive the status and progress.
///     2. Please use `-checkFirmwareUpgrade:failure:` or `-checkFirmwareUpgradeWithExtraInfo:success:failure` before call this.
/// @param firmwares firmwares from `-checkFirmwareUpgrade:failure:` or `-checkFirmwareUpgradeWithExtraInfo:success:failure`
- (void)startFirmwareUpgrade:(NSArray<ThingSmartFirmwareUpgradeModel *> *)firmwares;

/// Confirm continue or not when a upgrading task callback the warning error ` ThingOTAErrorCodeSignalStrengthNotSatisfy  `.
/// @param isContinue continue or not.
- (void)confirmWarningUpgradeTask:(BOOL)isContinue;

/// Cancel firmware upgrade
/// Notice: it only support for the task status equal to ` ThingSmartDeviceUpgradeStatusWaitingExectue `
- (void)cancelFirmwareUpgrade:(ThingSuccessHandler)success
                      failure:(nullable ThingFailureError)failure;

/// Fetch the firmware upgrading task's status or progress. ( progress maybe 0 )
/// Notice: it only support for the task status equal to `ThingSmartDeviceUpgradeStatusUpgrading` or `ThingSmartDeviceUpgradeStatusWaitingExectue`
/// @param success Called when the task's status/progress can provide
/// @param failure Called when the task's status/progress can't provide
- (void)getFirmwareUpgradingStatus:(void (^)(ThingSmartFirmwareUpgradeStatusModel *status))success
                           failure:(nullable ThingFailureError)failure;


/// Fetch the device's local firmware version info. ( now only used for the AP Directly device )
/// Notice:
///     1. The device need link to app by the LAN.
///     2. get avaliable infos from the `model.type` and `model.currentVersion` properties.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)getDeviceLocalFirmwareInfo:(void (^)(NSArray<ThingSmartFirmwareUpgradeModel *> *infos))success
                           failure:(ThingFailureError)failure;

/// Determine if the device can check the firmware.
- (BOOL)isSupportCheckFirmware;

/// Returns firmware information.
/// Notice:
///     This api is for `common member role` user use.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)memberCheckFirmwareStatus:(void (^)(NSArray<ThingSmartMemberCheckFirmwareInfo *> *infos))success
                          failure:(ThingFailureError)failure;

- (void)updateBootOTAWithSingleBootStatus:(BOOL)bootOTABeing ;

/// Returns firmware upgrade information.
/// Include normal firmwares, pid firmwares, and sub devices which support batch firmware updagrede in one group.
///
/// **Note**
///     1. Not support to check firmwares for the AP Directly device  (AP Directly device: device.meta.allKeys.contain("isSupportDirectlyDevice" == 1). Please use `-checkFirmwareUpgradeWithExtraInfo:success:failure:`
///     2. If the result return `firmwareInfo.supportGroup == YES`, you can use `-startBatchFirmwareUpgradeWithSubDevice:success:failure:` to batch upgrade some devices( `firmwareInfo.deviceList`)
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)checkBatchFirmwareWithSuccess:(void (^)(ThingSmartFirmwareCheckResult *firmwareInfo))success
                              failure:(nullable ThingFailureError)failure;

/// Confirm batch upgrades for input devices.
///
/// **Note: ** Support the device itset that can be connected to the Internet OR sub-devices under the gateway.
///
/// @param devIds device list.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
+ (void)startBatchFirmwareUpgradeWithDevIds:(NSArray<NSString *> *)devIds
                                    success:(void (^)(ThingSmartBatchFirmwareConfirmResult *result))success
                                    failure:(nullable ThingFailureError)failure;

/// Pre check device can be upgrade.
///
/// Now support check:
/// - ThingOTAErrorCodeMultimodeDeviceWifiOffline
/// - ThingOTAErrorCodeSingleBleDeviceLimit
///
/// @param firmwares fimwares
- (nullable NSError *)preCheckDeviceCanBeUpgrade:(NSArray<ThingSmartFirmwareUpgradeModel *> *)firmwares;

@end

NS_ASSUME_NONNULL_END
