//
//  NSError+ThingOTA.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define ThingOTAErrorDomain @"com.ota.www"

typedef NS_ENUM(NSUInteger, ThingOTAErrorCode) {
    /// Device's all firmwares is latest.
    ThingOTAErrorCodeAllLatest = 5000,
    /// Checked no firmware.
    ThingOTAErrorCodeCheckNoFirmware = 5001,
    /// Only one device can upgrade same time. (BLE device, BleMesh Sub device, SigMesh Sub device)
    ThingOTAErrorCodeOnlyOneCanUpgradeSameTime = 5002,
    /// App download firmware fail. (BLE device, BleMesh Sub device, SigMesh Sub device)
    ThingOTAErrorCodeDownloadFail = 5003,
    /// Fetch device if need signal limit fail.  ( can't continue )
    ThingOTAErrorCodeFetchIfNeedSignalLimitFail = 5004,
    /// The device signal strength not satisfy the limit.（ alert continue or not, let user confirm, then call function `- confirmWarningUpgradeTask:`）
    ThingOTAErrorCodeSignalStrengthNotSatisfy = 5005,
    /// Link to the device failed.  (BLE device, BleMesh Sub device, SigMesh Sub device)
    ThingOTAErrorCodeLinkDeviceFail = 5006,
    /// Switch BLE device
    ThingOTAErrorCodeBLESubSwitchTimeOut = 5007,
    /// The downloaded firmware's MD5 checked failed.
    ThingOTAErrorCodeDownloadCheckMD5Error = 5009,
    /// Send firmware to device failed.  (BLE device, BleMesh Sub device, SigMesh Sub device)
    ThingOTAErrorCodeSendUpgradePackageError = 5010,
    /// The device is  offline.
    ThingOTAErrorCodeDeviceOffline = 5012,
    /// The pre verify before upgrade failed.
    ThingOTAErrorCodeDeivcePreVerifyFail = 5013,
    /// Phone's bluetooth is not open.
    ThingOTAErrorCodeBluetoothNotOpen = 5014,
    /// Failed when check the device need upgrade firmware list. ( Deprecated )
    ThingOTAErrorCodeCheckUpdateFail = 5015,
    /// Device upgrade timeout. ( Deprecated )
    ThingOTAErrorCodeUpgradeTimeout = 5016,
    /// Failed when request comfirm upgrade device api. ( The server error code in `error.localizedFailureReason`, error msg in `error.localizedDescription` )
    ThingOTAErrorCodeComfirmUpgradeApiResponseFail = 5017,
    /// While device upgrading, the device report fail reason by mqtt.
    ThingOTAErrorCodeDeviceUpgradingReportFail = 5018,
    /// Batch check fimware api request timeout.
    ThingOTAErrorCodeBatchCheckFirmwareTimeout = 5019,
    /// Multi-mode device are not online in the cloud.
    ThingOTAErrorCodeMultimodeDeviceWifiOffline = 5020,
    /// This bluetooth device can only upgrade through a gateway.
    ThingOTAErrorCodeSingleBleDeviceLimit = 5021,
    
    /// The general OTA failed.
    ThingOTAErrorCodeCommonError = 5099,
};


@interface NSError (ThingOTA)

+ (instancetype)thingsdk_OTAErrorWithCode:(ThingOTAErrorCode)code msg:(nullable NSString *)msg reason:(nullable NSString *)reason;

+ (instancetype)thingsdk_OTAErrorWithCode:(ThingOTAErrorCode)code msg:(nullable NSString *)msg;

+ (instancetype)thingsdk_OTADefaultErrorWithCode:(ThingOTAErrorCode)code;

@end

NS_ASSUME_NONNULL_END
