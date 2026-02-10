//
// ThingSmartBLEDeviceProtocol.h
// ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)

#import <ThingBluetooth/ThingBluetooth.h>
#import "ThingSmartBLEManager.h"

@class ThingBLEScan;
@class ThingBLEAgent;
@protocol ThingSmartBLEDeviceProtocol;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Scan Protocol

/// @brief ThingSmartBLEDeviceProtocol provides protocol methods to implement multiple functions, such as activation, device control, and over-the-air (OTA) updates.
@protocol ThingSmartBLEScanProtocol <NSObject>

typedef void(^ThingBLEScanResultHandher)(id<ThingSmartBLEDeviceProtocol> deviceInfo);

/// Results of inactive device scanning.
///
/// @param agent        The scanning agent.
/// @param scan         The scanning class.
/// @param peripheral   The scanned Bluetooth peripheral.
/// @param error        The scan error.
/// @param handler      The scan callback.
- (void)bleAgent:(ThingBLEAgent *)agent bleScan:(ThingBLEScan *)scan didScanBLEDevicePeripheral:(ThingBLEPeripheral *)peripheral error:(NSError *)error scanResultHandher:(ThingBLEScanResultHandher)handler;


@optional
-(NSMutableArray *)thirdDevicesScanServiceUUID;

@end

#pragma mark -------------------------------------------------------------


#pragma mark - Active Protocol

@protocol ThingSmartBLEActiveProtocol <NSObject>

/// Activates the Bluetooth LE device.
///
/// @param deviceInfo       The advertisingData model for the Bluetooth LE device.
/// @param homeId           The ID of the current home.
/// @param success          Called when the task is finished. DeviceModel is returned.
/// @param failure          Called when the task is interrupted by an error.
- (void)startActiveWithDevice:(id<ThingSmartBLEDeviceProtocol>)deviceInfo
                       homeId:(long long)homeId
                      success:(nullable ThingSuccessID)success
                      failure:(nullable ThingFailureError)failure;

@end

#pragma mark -------------------------------------------------------------


#pragma mark - Config Protocol

@protocol ThingSmartBLEConfigProtocol <NSObject>

/// Has scanned the target device.
/// @param uuid  uuid
- (BOOL)hasScannedBLEDeviceWithUUID:(NSString *)uuid;

/// Sends a DP.
///
/// @param deviceInfo   The Thing Bluetooth LE-based device object.
/// @param dps          The DP dictionary.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)publishDpsWithDeviceInfo:(id<ThingSmartBLEDeviceProtocol>)deviceInfo
                             dps:(NSDictionary *)dps
                             success:(ThingSuccessHandler)success
                             failure:(ThingFailureError)failure;

/// Queries device DP data through Bluetooth channels.
///
/// @param deviceInfo   The Thing Bluetooth LE-based device object.
/// @param dpIds        The array of DP IDs to be queried.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)publishQueryDpCommand:(id<ThingSmartBLEDeviceProtocol>)deviceInfo
                        dpIds:(NSArray *)dpIds
                      success:(ThingSuccessHandler)success
                      failure:(ThingFailureError)failure;

/// Connects to a device.
///
/// @param deviceInfo   The Thing Bluetooth LE-based device object.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)connectWithDeviceInfo:(id<ThingSmartBLEDeviceProtocol>)deviceInfo
                      success:(ThingSuccessHandler)success
                      failure:(ThingFailureError)failure;

/// Disconnects a device.
///
/// @param deviceInfo   The Thing Bluetooth LE-based device object.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)disconnectWithDeviceInfo:(id<ThingSmartBLEDeviceProtocol>)deviceInfo
                         success:(ThingSuccessHandler)success
                         failure:(ThingFailureError)failure;

/// Removes a device.
///
/// @param deviceInfo   The Thing Bluetooth LE-based device object.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)removeWithDeviceInfo:(id<ThingSmartBLEDeviceProtocol>)deviceInfo
                     success:(ThingSuccessHandler)success
                     failure:(ThingFailureError)failure;

/// Restores factory settings
///
/// @param deviceInfo   The Thing Bluetooth LE-based device object.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)resetWithDeviceInfo:(id<ThingSmartBLEDeviceProtocol>)deviceInfo
                    success:(ThingSuccessHandler)success
                    failure:(ThingFailureError)failure;

/// Sends an OTA package to update the firmware.
///
/// The values of `otaData`, `otaType`, and `otaVersion` can be obtained from ThingSmartFirmwareUpgradeModel. You can get ThingSmartFirmwareUpgradeModel by using ThingSmartDevice::getFirmwareUpgradeInfo:failure:.
///
/// @note Your device must be connected over Bluetooth before the update.
///
/// @param deviceInfo   The Thing Bluetooth LE-based device object.
/// @param otaData      The OTA package data.
/// @param otaType      The OTA update type.
/// @param otaVersion   The OTA version.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)sendOTAPackWithDeviceInfo:(id<ThingSmartBLEDeviceProtocol>)deviceInfo
                          otaData:(NSData *)otaData
                          otaType:(ThingSmartBLEOTAType)otaType
                       otaVersion:(NSString *)otaVersion
                          success:(ThingSuccessHandler)success
                          failure:(ThingFailureError)failure;

/// Returns the Received Signal Strength Indicator (RSSI) value of the Bluetooth LE device.
///
/// @param deviceInfo       The Thing Bluetooth LE-based device object.
///
/// @return The RSSI value of the Bluetooth LE device.
- (NSInteger)peripheralRSSI:(id<ThingSmartBLEDeviceProtocol>)deviceInfo;

/// Returns the local connection status of the Bluetooth LE device by deviceInfo.
///
/// @param deviceInfo       The Thing Bluetooth LE-based device object.
///
/// @return The local connection status of the Bluetooth LE device.
- (BOOL)deviceOnlineState:(id<ThingSmartBLEDeviceProtocol>)deviceInfo;

/// Ability to acquire Bluetooth device: hexadecimal.
/// @param uuid The device uuid.
/// @param success Called when the task finishes successfully.
/// @param failure Called when the task is interrupted by an error.
- (void)getBLECapabilityWithUUID:(NSString *)uuid success:(ThingSuccessString)success failure:(ThingFailureError)failure;


@end

#pragma mark -------------------------------------------------------------


#pragma mark - Device Protocol

@protocol ThingSmartBLEDeviceProtocol <NSObject>

/// The Thing Bluetooth LE agent.
@property (nonatomic, strong) ThingBLEAgent                        *agent;

/// The Thing Bluetooth LE peripheral.
@property (atomic, strong) ThingBLEPeripheral                   *peripheral;

/// The Thing Bluetooth LE advertising model.
@property (nonatomic, strong) ThingBLEAdvModel                     *advModel;

/// The Thing active protocol-based manager object.
@property (nonatomic, strong) id<ThingSmartBLEActiveProtocol>    activeManager;

/// The Thing config protocol-based manager object.
@property (nonatomic, strong) id<ThingSmartBLEConfigProtocol>    configManager;


@optional
/// The methods to initialize ThingSmartBLEDeviceProtocol-based device objects.
///
/// @param activeManager      The Thing active protocol-based manager object.
/// @param configManager      The Thing config protocol-based manager object.
- (instancetype)initWithActiveManager:(id<ThingSmartBLEActiveProtocol>)activeManager
                        configManager:(id<ThingSmartBLEConfigProtocol>)configManager;

@end

NS_ASSUME_NONNULL_END
