//
//  ThingSmartBLEManager+Biz.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <ThingSmartBLEKit/ThingSmartBLEKit.h>
#import <ThingSmartBLECoreKit/ThingSmartBLEManager.h>
#import <ThingSmartBLEKit/ThingSmartExtModuleManager.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, ThingBLEAudioTransparentDataCmd) {
    ThingBLEAudioTransparentDataCmdStartSpeech,
    ThingBLEAudioTransparentDataCmdProvideSpeech,
    ThingBLEAudioTransparentDataCmdEndpointSpeech,
    ThingBLEAudioTransparentDataCmdStopSpeech,
    ThingBLEAudioTransparentDataCmdNotifySpeechState
};

@interface ThingSmartPublishVoiceModel : NSObject
@property (nonatomic, strong)NSData * voiceData;
@property (nonatomic, assign)BOOL isNeedAck;
@property (nonatomic, assign)ThingBLEAudioTransparentDataCmd audioTransparentDataCmd;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) ThingSuccessHandler success;
@property (nonatomic, strong) ThingFailureError failure;

@end

@interface ThingSmartBLEManager (Biz)


#define  kNotificationSharedListUpdate          @"kNotificationSharedListUpdate"

/// Starts listening for broadcast packages for Bluetooth LE devices.
///
/// If an inactive device is scanned, the device information is returned by `ThingSmartBLEManagerDelegate::didDiscoveryDeviceWithDeviceInfo:`.
///
/// If an active device is scanned, the device is automatically connected.
///
/// @param clearCache Specifies whether to clean up the broadcast packets of scanned devices.
- (void)startListening:(BOOL)clearCache;

/// Starts listening for broadcast packages for Bluetooth LE devices.
///
/// If an inactive device is scanned, the device information is returned by `ThingSmartBLEManagerDelegate::didDiscoveryDeviceWithDeviceInfo:`.
///
/// If an active device is scanned, the device is automatically connected.
/// @param scanType  Specifies whether to scan type. Noraml type is general device. QRCode type is supports code scanning devices.
/// @param clearCache Specifies whether to clean up the broadcast packets of scanned devices.
- (void)startListeningWithType:(ThingBLEScanType)scanType cacheStatu:(BOOL)clearCache;

/// Starts listening for broadcast packages for active Bluetooth LE devices during interval
/// @param interval scan time.If interval < 0, set it to the default 40s
/// @param scanHandle called when find ble device broadcast,return devId of find device
/// @param finishHandle  called when the task is finished
- (void)scanActivatedDeviceWithTimeInterval:(NSTimeInterval)interval
                                scanHandler:(ThingSuccessString)scanHandle
                              finishHandler:(ThingSuccessHandler)finishHandle;

/// Stop listening for broadcast packages for BLE devices.
///
/// @param clearCache Specifies whether to clean up the broadcast packets of scanned devices.
- (void)stopListening:(BOOL)clearCache;

/// Connects to a device.
///
/// @param uuid         The UUID of the device.
/// @param productKey   The product ID of the device.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)connectBLEWithUUID:(NSString *)uuid
                productKey:(NSString *)productKey
                   success:(nullable ThingSuccessHandler)success
                   failure:(nullable ThingFailureHandler)failure;

/// Connects to a shadow device.
///
/// @param deviceId   Connected Device ID
/// @param uuid         The UUID of the device.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)connectBLEWithDeviceId:(NSString *)deviceId
                          uuid:(NSString *)uuid
                       success:(nullable ThingSuccessHandler)success
                       failure:(nullable ThingFailureError)failure;


/// Disconnects a device.
///
/// @param uuid         The UUID of the device.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)disconnectBLEWithUUID:(NSString *)uuid
                      success:(nullable ThingSuccessHandler)success
                      failure:(nullable ThingFailureError)failure;



/// Activates the Bluetooth LE device.
/// @param uuid The UUID of the device.
/// @param homeId The ID of the current home.
/// @param productKey The product ID of the device.
/// @param success Called when the task is finished. DeviceModel is returned.
/// @param failure Called when the task is interrupted by an error.
/// @deprecated This method is deprecated. Use ThingSmartBLEManager::activeBLE:homeId:success:failure: instead.
- (void)activeBLEWithUUID:(NSString *)uuid
                   homeId:(long long)homeId
               productKey:(NSString *)productKey
                  success:(nullable void(^)(ThingSmartDeviceModel *deviceModel))success
                  failure:(nullable ThingFailureHandler)failure __deprecated_msg("This method is deprecated, Use ThingSmartBLEManager::activeBLE:homeId:success:failure instead");

/// Activates the Bluetooth LE device.
///
/// @param deviceInfo       The advertisingData model for the Bluetooth LE device.
/// @param homeId           The ID for the current home.
/// @param success          Called when the task is finished. DeviceModel is returned.
/// @param failure          Called when the task is interrupted by an error.
- (void)activeBLE:(ThingBLEAdvModel *)deviceInfo
           homeId:(long long)homeId
          success:(nullable void(^)(ThingSmartDeviceModel *deviceModel))success
          failure:(nullable ThingFailureHandler)failure;

/// Publishes the transmitted data.
///
/// @param devId        The device ID.
/// @param data         The data to be transmitted to the device.
/// @param success      The data that is returned by the device.
/// @param failure      Called when the task is interrupted by an error.
- (void)publishBleTransparentData:(NSString *)devId
                             data:(NSData *)data
                          success:(nullable ThingSuccessData)success
                          failure:(nullable ThingFailureError)failure;

/// Queries the device DP data through Bluetooth channels.
///
/// @param devId        The device ID.
/// @param dpIds        The array of DP IDs to be queried.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)publishQueryDpCommand:(NSString *)devId
                        dpIds:(NSArray *)dpIds
                      success:(nullable ThingSuccessBOOL)success
                      failure:(nullable ThingFailureError)failure;

/// Returns the RSSI value of the Bluetooth LE device.
///
/// @param uuid        The UUID of the device.
///
/// @return The RSSI value of the Bluetooth LE device.
- (NSInteger)getPeripheralRSSI:(NSString *)uuid;

/// Returns the local connection status of the Bluetooth LE device by device UUID.
///
/// @param uuid        The UUID of the device.
///
/// @return The local connection status of the Bluetooth LE device.
- (BOOL)deviceStatueWithUUID:(NSString *)uuid;

/// Queries the device information before the activation.
///
/// @param uuid         The UUID of the device.
/// @param productKey   The product ID for the device.
/// @param success      Called when the task is finished. The device name string is returned.
/// @param failure      Called when the task is interrupted by an error.
///
/// @deprecated This method is deprecated. Use ThingSmartBLEManager::queryDeviceInfoWithUUID:productKey:success:failure: instead.
- (void)queryNameWithUUID:(NSString *)uuid
               productKey:(NSString *)productKey
                  success:(nullable void(^)(NSString *name))success
                  failure:(nullable ThingFailureError)failure __deprecated_msg("This method is deprecated, Use ThingSmartBLEManager::queryDeviceInfoWithUUID:productKey:success:failure instead");

/// Queries the device information before activation
///
/// @param uuid         The UUID of the device.
/// @param productId    The product ID for the device.
/// @param success      Called when the task is finished. A dictionary of device information is returned.
/// @param failure      Called when the task is interrupted by an error.
- (void)queryDeviceInfoWithUUID:(NSString *)uuid
                      productId:(NSString *)productId
                        success:(nullable ThingSuccessDict)success
                        failure:(nullable ThingFailureError)failure;

/// Publish  data  to the BLE device   eg: scene data
/// @param data   data
/// @param devId   The device Id for the device.
/// @param success   When publish successfully, this block will be called success.
/// @param failure   This block will be called if some error occurred.
- (void)publishIoTTransparentData:(NSData *)data
                            devId:(NSString *)devId
                          success:(nullable ThingSuccessHandler)success
                          failure:(nullable ThingFailureError)failure;

/// Get device capability through Bluetooth channel.
/// @param uuid The device uuid.
/// @param success Called when the task finishes successfully.
/// @param failure Called when the task is interrupted by an error.
- (void)getBLECapabilityWithUUID:(NSString *)uuid
                         success:(nullable ThingSuccessString)success
                         failure:(nullable ThingFailureError)failure;

/// Get whether Bluetooth is currently being OTA upgraded.
/// @param uuid The device uuid.
- (BOOL)otaUpgradeStatusWithUUID:(NSString *)uuid;


/// start ble beacon scan,the dp data will be reported if scanned.
/// The data of all ble beacon devices in the current account will be scanned.
- (void)startBleBeaconListening;

/// stop ble beacon scan
- (void)stopBleBeaconListening;

/// start ble beacon scan
/// @param deviceId The device id
- (void)startBleBeaconListeningWithDeviceId:(NSString *)deviceId;

/// stop ble beacon scan
/// @param deviceId The device id
- (void)stopBleBeaconListeningWithDeviceId:(NSString *)deviceId;



/// Activates the Bluetooth LE device.
///
/// @param advertisingData      The advertisingData model for the Bluetooth LE device.
/// @param homeId                          The ID for the current home.
/// @param success                        Called when the task is finished. DeviceModel is returned.
/// @param failure                        Called when the task is interrupted by an error.
- (void)activeBLEWithAdvertisingData:(NSData *)advertisingData
                              homeId:(long long)homeId
                             success:(void(^)(ThingSmartDeviceModel *deviceModel))success
                             failure:(ThingFailureHandler)failure;

/// File transfer
/// @param devId The device ID.
/// @param fileId The file ID.
/// @param fileIdentifier The file identifier.
/// @param fileVersion The file version.
/// @param fileData The file data.
/// @param progressBlock The progress callback
/// @param success Called when the task is finished. DeviceModel is returned.
/// @param failure Called when the task is interrupted by an error.
- (void)publishFileWithDevId:(NSString *)devId
                      fileId:(NSInteger)fileId
              fileIdentifier:(NSString *)fileIdentifier
                 fileVersion:(NSInteger)fileVersion
                    fileData:(NSData *)fileData
               progressBlock:(nullable void(^)(float progress))progressBlock
                     success:(ThingSuccessHandler)success
                     failure:(ThingFailureError)failure;

/// File transfer
/// @param devId The device ID.
/// @param fileId The file ID.
/// @param fileIdentifier The file identifier.
/// @param fileVersion The file version.
/// @param fileData The file data.
/// @param fileType The file type. If you do not contract filetype with hardware,please use the  "-(void)publishFileWithDevId:fileId:fileIdentifier:fileVersion:fileData:progressBlock:success:failure:"  api without filetype.
/// @param progressBlock The progress callback
/// @param success Called when the task is finished. DeviceModel is returned.
/// @param failure Called when the task is interrupted by an error.
- (void)publishFileWithDevId:(NSString *)devId
                      fileId:(NSInteger)fileId
              fileIdentifier:(NSString *)fileIdentifier
                 fileVersion:(NSInteger)fileVersion
                    fileData:(NSData *)fileData
                    fileType:(unsigned int)fileType
               progressBlock:(nullable void(^)(float progress))progressBlock
                     success:(ThingSuccessHandler)success
                     failure:(ThingFailureError)failure;

/// Stop file transfer
/// @param devId The device ID.
- (void)stopFileTransfer:(NSString *)devId;

/// Send transparent data  (Support  multiple packages).
///
/// @param data          Transparent data.
/// @param devId        The device Id for the device.
/// @param success    Called when the task finishes successfully.
/// @param failure    Called when the task is interrupted by an error.
- (void)publishTransparentData:(NSData *)data 
                         devId:(NSString *)devId
                       success:(ThingSuccessHandler)success
                       failure:(ThingFailureError)failure;

- (void)publishAudioTransparentData:(ThingSmartPublishVoiceModel *)publishVoiceModel;


/// publish Transport data with custom subCmd Data and payload
/// @param devId The device Id for the device.
/// @param subCmdData subCmd data
/// @param payloadDict payload data
/// @param success  Called when the task finishes successfully.
/// @param failure  Called when the task is interrupted by an error.
- (void)publishDataUseTransportPipeWithDevId:(NSString *)devId
                                      subCmd:(NSData *)subCmdData
                                 payloadDict:(NSDictionary *)payloadDict
                                     success:(nullable ThingSuccessHandler)success
                                     failure:(nullable ThingFailureError)failure;


/// Update system time to device
/// @param deviceId   The device id
- (void)publishSystemTimeWithDeviceId:(NSString *)deviceId;

///  Initiative activation fitting
/// @param deviceId main device Id
- (void)handActiveFittingWithMainDeviceId:(NSString *)deviceId;



#pragma mark - activate extended module

- (NSInteger)getExtModuleType:(NSString*)devId;

/// Activate the extended module.
/// If it is WiFi, it will return an error because the SSID and password are not entered
/// @param devId device id
/// @param automatic activate mode. If NO, need to wait for the result of MQTT response activation
/// @param success If successfully activated, this block is called.
/// @param failure If activation fails, this block calls back an error
- (void)activateExtendedModule:(NSString*)devId automatic:(BOOL)automatic success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;



/// Activate the extended WiFi module. SSID and password required.
/// @param devId device id
/// @param automatic activate mode. If NO, need to wait for the result of MQTT response activation
/// @param ssid WiFi SSID
/// @param pwd WiFi password
/// @param success If successfully activated, this block is called.
/// @param failure If activation fails, this block calls back an error
- (void)activateExtendedWiFiModule:(NSString*)devId automatic:(BOOL)automatic ssid:(NSString*)ssid password:(NSString*)pwd success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;


#pragma mark - master slave handler

/// Bind master-slave devices
/// @param slaveDeviceId slave device id
/// @par5rDeviceId  master device id
/// @param success If successfully bind, this block is called.
/// @param failure If bind fails, this block calls back an error
- (void)bindSlaveDeviceWithSlaveDeviceId:(NSString *)slaveDeviceId
                          masterDeviceId:(NSString *)masterDeviceId
                                 success:(nullable ThingSuccessHandler)success
                                 failure:(nullable ThingFailureError)failure;

/// Unbind master_slave devices
/// @param slaveDeviceId slave device id
/// @param success  If successfully Unbind, this block is called.
/// @param failure If Unbind fails, this block calls back an error
- (void)unBindSlaveDeviceWithSlaveDeviceId:(NSString *)slaveDeviceId
                                   success:(nullable ThingSuccessHandler)success
                                   failure:(nullable ThingFailureError)failure;


/// Query all slave device information under the master device
/// @param masterDeviceId master deviceId
/// @param success success
/// @param failure failure
- (void)querySlaveInfoWithMasterDeviceId:(NSString *)masterDeviceId
                                 success:(nullable ThingSuccessHandler)success
                                 failure:(nullable ThingFailureError)failure;

/// Query all slave device dps under the master device
/// @param slaveDeviceId master deviceId
/// @param success success
/// @param failure failure
- (void)querySlaveDpsWithSlaveDeviceId:(NSString *)slaveDeviceId
                               success:(nullable ThingSuccessBOOL)success
                               failure:(nullable ThingFailureError)failure;

/// Record ble connect event
- (void)recordBleConnectEventWithDevId:(NSString *)devId
                                   src:(NSInteger)src
                                 actId:(nullable NSString *)actId
                                 extra:(nullable NSDictionary *)extra;

/// Disconnect all ble devices exclud some devices.
/// @param excludeDevIds no need disconnect ble devices.
- (void)disconnectAllBleDevicesExcludeDevIds:(nullable NSArray<NSString *> *)excludeDevIds;

/// Fetch Device bind Statuts,and return pid(if have)
- (void)syncDeviceBindStatus:(ThingBLEAdvModel *)adv success:(nullable ThingSuccessID)success failure:(nullable ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END
