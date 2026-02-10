//
// ThingSmartBLEManager.h
// ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)

#import <Foundation/Foundation.h>
#import "ThingBLEAdvModel.h"
#import "ThingBLEWeatherModel.h"
#import <ThingSmartUtil/ThingSmartUtil.h>
#import "ThingBLEDeviceInfoProtocol.h"
#import "ThingBLEFindMacDelegate.h"
#import "ThingSmartBLEAudioStartModel.h"
#import "ThingSmartBLEAudioManager.h"

typedef enum : NSUInteger {
    /// Is OTA controllable.
    ThingSmartBLECapabilityOTAControlled = 0,
    ThingSmartBLECapabilityLELogitify = 1,
    ThingSmartBLECapabilityBeaconable = 2,
    ThingSmartBLECapabilityLink = 3,
    ThingSmartBLECapabilityExtenModule = 4,
    ThingSmartBLECapabilityDpSendByDownTransport = 19, //!< bit19, 0: 0x0002 / 0x0027, 1: 0x801E_0x000c
    ThingSmartBLECapabilityLongRange = 20,
    ThingSmartBLECapabilityBLEMeshCtrl = 21
} ThingSmartBLECapability;


typedef NS_ENUM(NSInteger,ThingBLEScanType){
    ThingBLEScanTypeNoraml          = 1 << 0, //  0001  1
    ThingBLEScanTypeQRCode          = 1 << 1, //  0010  2
    ThingBLEScanTypeAllDevice       = 1 << 2, //  0100  4
};

typedef NS_ENUM(NSInteger,ThingBLEDeviceInfoState){
    ThingBLEDeviceInfoStateScanning         = 0,
    ThingBLEDeviceInfoStateInProcessing     = 1,
    ThingBLEDeviceInfoStateCompleted        = 2,
};

NS_ASSUME_NONNULL_BEGIN

typedef void (^ThingBLEBigDataProgressBlock)(float progress);

@class ThingSmartBLEManager;
@class ThingBLEWeatherModel;
@class ThingSmartDeviceModel;

/// The delegate for scanning and notifications of Bluetooth status changes.
@protocol ThingSmartBLEManagerDelegate <NSObject>

@optional

/// The notification for Bluetooth status changes.
///
/// @param isPoweredOn      Indicates the Bluetooth status. Valid values: `on` and `off`.
- (void)bluetoothDidUpdateState:(BOOL)isPoweredOn;

/// The result of disconnecting the device.
///
/// @param devId        The device ID.
/// @param error        An error occurs while processing the request.
- (void)onCentralDidDisconnectFromDevice:(NSString *)devId error:(NSError *)error;

/// The result of scanning inactive devices.
///
/// @param uuid         The device UUID.
/// @param productKey   The product ID for the device.
/// @deprecated This method is deprecated. Use ThingSmartBLEManager::didDiscoveryDeviceWithDeviceInfo: instead.
- (void)didDiscoveryDeviceWithUUID:(NSString *)uuid productKey:(NSString *)productKey __deprecated_msg("This method is deprecated, Use ThingSmartBLEManager::didDiscoveryDeviceWithDeviceInfo: instead");

/// The result of scanning inactive devices.
///
/// @param deviceInfo   The advertisingData model for the inactive device.
- (void)didDiscoveryDeviceWithDeviceInfo:(ThingBLEAdvModel *)deviceInfo;

/// The result of activating Bluetooth LE devices.
///
/// @param manager          The class.
/// @param deviceModel      Called when the task is finished. DeviceModel is returned.
/// @param error            Called when the task is interrupted by an error.
- (void)bleManager:(ThingSmartBLEManager *)manager didFinishActivateDevice:(nullable id)deviceModel error:(nullable NSError *)error;

/// Single BLE Device will be sleep when waiting pairing.Then state will change to ThingBLEDeviceInfoStateScanning
- (void)bleManager:(ThingSmartBLEManager *)manager uuid:(NSString *)uuid stateChanged:(ThingBLEDeviceInfoState)state;

/// Receives the transmission data from the device.
///
/// @param data     Transmission data that is sent by the device.
/// @param devId    The device ID.
- (void)bleReceiveTransparentData:(NSData *)data devId:(NSString *)devId;


/// Get weather information
/// @param devId  The device ID.
/// @param codes  codes
/// @param whetherUse Whether to request weather information using location information
/// @param completion completion
- (void)getWeatherWithDevId:(NSString *)devId codes:(NSString *)codes useLocation:(BOOL)whetherUse completion:(void(^)(ThingBLEWeatherModel * _Nullable weatherModel))completion __deprecated_msg("This method is deprecated, Use newGetWeatherWithDevId:codes:useLocation:completion: instead");

- (void)newGetWeatherWithDevId:(NSString *)devId codes:(NSString *)codes useLocation:(BOOL)whetherUse completion:(void(^)(NSDictionary * _Nullable weatherData))completion;


/// Data source for the device list
- (NSArray <ThingSmartDeviceModel *>*)bleManagerDeviceListDataSource;

@end

@protocol ThingSmartBLELocalDataDelegate <NSObject>

@optional

/// Localized data storage
/// @param devId The device ID
/// @param dps dps
- (NSDictionary *)filterUploadServerData:(NSString *)devId dps:(NSDictionary *)dps __deprecated_msg("This method is deprecated, Use filterUploadServerData:dps:dpsTime: instead");

/// According to the scene, the dps and dpsTime will be transparently transmitted and processed and returned
/// @param devId The device ID
/// @param dps  dps
/// @param dpstime dps time
- (NSDictionary *)filterUploadServerData:(NSString *)devId dps:(NSDictionary *)dps dpsTime:(NSString *)dpstime;

/// Do you need to report big data to the app?
/// @param devId The device ID.
- (BOOL)isBigDataReportApp:(NSString *)devId;

/// Big data reported.
/// @param dic Big data content.
- (void)reportBigDataChannelDic:(NSDictionary *)dic;


@end

@protocol ThingSmartBLEAlexaAudioDelegate <NSObject>

@optional

- (void)audioStartSpeech:(ThingSmartBLEAudioStartModel *)model;

- (void)audioProvideSpeech:(ThingSmartBLEAudioProvideModel *)model;

- (void)audioStopSpeech:(NSString *)dialogId deviceId:(NSString *)deviceId errorCode:(ThingAudioErrorCode)error;

- (void)audioData:(NSData *)data deviceId:(NSString *)deviceId audioFormat:(ThingAudioAudioFormat)audioFormat;

@end

@protocol ThingSmartBLEAudioNotifyDelegate <NSObject>

@optional

- (void)audioStartSpeech:(ThingSmartBLEAudioStartModel *)voicemodel;

- (void)audioProvideSpeech:(ThingSmartBLEAudioProvideModel *)voicemodel;

- (void)audioEndpointSpeech:(ThingSmartBLEAudioProvideModel *)voicemodel;

- (void)audioStopSpeech:(ThingSmartBLEAudioNotifyModel *)voiceModel;

- (void)audioData:(ThingSmartBLEAudioDataModel *)voiceModel;

- (void)audioDpsUpdateWithDeviceId:(NSString *)deviceId uuid:(NSString *)uuid dps:(NSDictionary *)dps;

@end

typedef void (^ThingBLEScanHandler)(id<ThingBLEDeviceInfoProtocol> devInfo, BOOL isWillRestoreState);

typedef void (^ThingBLEBWScanHandler)(ThingBLEBeaconWiFiAdvFrame *frame);

@interface ThingSmartBleConnectParams : NSObject

@property (nonatomic, strong) id<ThingBLEDeviceInfoProtocol> deviceInfo;
@property (nonatomic, strong) id<ThingSmartBLEActiveDelegate> handlerDelegate;
@property (nonatomic, assign) NSUInteger capability;
@property (nonatomic, strong) NSString *productId;
@property (nonatomic, strong) NSString *localKey;
@property (nonatomic, strong) NSString *secretKey;
@property (nonatomic, strong) NSDictionary *configMetas;
//is shadow device
@property (nonatomic, assign) BOOL isShadowDevice;
@property (nonatomic, copy) ThingBLEScanHandler scanHandler;
@property (nonatomic, copy) ThingSuccessHandler success;
@property (nonatomic, copy) ThingFailureHandler failure;


@end

/// @brief ThingSmartBLEManager provides methods to manage Bluetooth LE devices by using multiple functions, such as activation, device control, and OTA updates.
///
/// The types of OTA updates: firmware and MCU.
@interface ThingSmartBLEManager : NSObject

/// The single instance.
+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString *bleMeshNetKey;

/// A Boolean value that indicates whether the mobile phone's Bluetooth is enabled or disabled.
@property (nonatomic, assign, readonly) BOOL isPoweredOn;

/// Whether to disable bluetooth. Default NO
@property (nonatomic, assign) BOOL disableBLECapability;

/// The delegate for scanning and notifications of Bluetooth status changes.
@property (nonatomic, weak) id<ThingSmartBLEManagerDelegate> delegate;

@property (nonatomic, weak) id<ThingSmartBLELocalDataDelegate> localDataDelegate;

@property (nonatomic, weak) id<ThingSmartBLEAlexaAudioDelegate> alexaAudioDelegate;

@property (nonatomic, weak) id<ThingSmartBLEAudioNotifyDelegate> commonAudioDelegate;

// support mac for device
@property (nonatomic, weak) id<ThingBLEFindMacDelegate> findMacDelegatel;

@property (nonatomic, copy) ThingFailureHandler failureHandler;

@property (nonatomic, copy) void (^success)(id deviceModel);


@property (nonatomic, copy) NSString *currentDialogId;

@property (nonatomic, strong) NSMutableDictionary *resultDic;

@property (nonatomic, assign, readonly) BOOL isScanning;

@property (nonatomic, strong) ThingBLEScanHandler scanHandler;




- (BOOL)checkBLEStatus;


- (void)startListenCore:(BOOL)cache
                handler:(nullable ThingBLEScanHandler)handler
           configNotify:(id<ThingSmartBLEConfigPackageNotify>)notify
               scanType:(ThingBLEScanType)scanType;

- (void)startListenCore:(BOOL)cache
                handler:(ThingBLEScanHandler)handler
      beaconWiFiHandler:(ThingBLEBWScanHandler)bwHandler
           configNotify:(id<ThingSmartBLEConfigPackageNotify>)notify
               scanType:(ThingBLEScanType)scanType;


- (void)startEnhancedQRListenWithCache:(BOOL)cache
                               handler:(ThingBLEScanHandler)handler
                          configNotify:(id<ThingSmartBLEConfigPackageNotify>)notify
                              scanType:(ThingBLEScanType)scanType;

/// Ble device scan with time out
/// @param interval timeout
/// @param scanHandle 
/// @param finishHandle failure description
- (void)startScanWithInterval:(NSTimeInterval)interval
                 scanHandler:(ThingBLEScanHandler)scanHandle
                finishHandler:(ThingSuccessHandler)finishHandle;

- (void)stopListenCore:(BOOL)clearCache;

- (void)setScanDelegate:(id)delegate __deprecated_msg("This method is deprecated, the scan delegate is already set at initialization time");

- (void)connectWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo localKey:(NSString *)localKey __deprecated_msg("This method is deprecated,please use connectWithDeviceInfo:localKey:secKey:sign:"); ;

- (void)connectWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                     localKey:(NSString *)localKey
                       secKey:(nullable NSString *)secKey
                         sign:(NSString *)sign;

- (void)connectWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                     localKey:(nullable NSString *)localKey
                       secKey:(nullable NSString *)secKey
                         sign:(nullable NSString *)sign
                      success:(nullable ThingSuccessHandler)success
                      failure:(nullable ThingFailureHandler)failure;

- (void)forceDeleteWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

- (void)connectWithUUID:(NSString *)uuid
             capability:(NSUInteger)capability
              productId:(NSString *)productId
               localKey:(NSString *)localKey
            configMetas:(NSDictionary *)configMetas
        handlerDelegate:(id<ThingSmartBLEActiveDelegate>)handlerDelegate
            scanHandler:(nullable ThingBLEScanHandler)handler
                success:(nullable ThingSuccessHandler)success
                failure:(nullable ThingFailureHandler)failure __deprecated_msg("This method is deprecated, Use connectWithDeviceInfo:capability:productId:localKey:configMetas:handlerDelegate:scanHandler:success:failure: instead");;

- (void)connectWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                   capability:(NSUInteger)capability
                    productId:(NSString *)productId
                     localKey:(NSString *)localKey
                  configMetas:(NSDictionary *)configMetas
              handlerDelegate:(id<ThingSmartBLEActiveDelegate>)handlerDelegate
                  scanHandler:(nullable ThingBLEScanHandler)scanHandler
                      success:(nullable ThingSuccessHandler)success
                      failure:(nullable ThingFailureHandler)failure;

-(void)connectWithParamsModel:(ThingSmartBleConnectParams *)paramsModel success:(nullable ThingSuccessHandler)success
                      failure:(nullable ThingFailureHandler)failure ;

/// Disconnect device
///
/// @param uuid         The UUID for the device.
/// @param success      When disconnect successfully, this block will be called success.
/// @param failure      This block will be called if some error occurred.
- (void)disconnectWithUUID:(NSString *)uuid
                   success:(nullable ThingSuccessHandler)success
                   failure:(nullable ThingFailureError)failure __deprecated_msg("This method is deprecated, Use disconnectWithDeviceInfo:success:failure: instead");

/// Disconnect device
///
/// @param deviceInfo        The deviceInfo.
/// @param success              When disconnect successfully, this block will be called success.
/// @param failure              This block will be called if some error occurred.
- (void)disconnectWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                         success:(nullable ThingSuccessHandler)success
                         failure:(nullable ThingFailureError)failure;

/// Active device
- (void)activeBLEWithDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
            handlerDelegate:(id<ThingSmartBLEActiveDelegate>)handlerDelegate;

/// Publish the transmitted data.
///
/// @param uuid         The UUID for the device.
/// @param data         Data to be transmitted to the device.
/// @param success      Transmission data returned by the device.
/// @param failure      This block will be called if some error occurred.
- (void)publishBleTransparentDataWithUUID:(NSString *)uuid
                                     data:(NSData *)data
                                  success:(nullable ThingSuccessData)success
                                  failure:(nullable ThingFailureError)failure __deprecated_msg("This method is deprecated, Use publishBleTransparentDataWithDeviceInfo:data:success:failure: instead");

/// Publish the transmitted data.
///
/// @param deviceInfo        The deviceInfo.
/// @param data         Data to be transmitted to the device.
/// @param success      Transmission data returned by the device.
/// @param failure      This block will be called if some error occurred.
- (void)publishBleTransparentDataWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                                           data:(NSData *)data
                                        success:(nullable ThingSuccessData)success
                                        failure:(nullable ThingFailureError)failure;

/// Query device dp data by Bluetooth channel.
///
/// @param uuid             The UUID for the device.
/// @param dpsData      Array of dpId's to be queried.
/// @param success      When query successfully, this block will be called.
/// @param failure      This block will be called if some error occurred.
- (void)publishQueryDpCommandWithUUID:(NSString *)uuid
                              dpsData:(NSMutableData *)dpsData
                              success:(nullable ThingSuccessBOOL)success
                              failure:(nullable ThingFailureError)failure __deprecated_msg("This method is deprecated, Use publishQueryDpCommandWithDeviceInfo:dpsData:success:failure: instead");


/// publish Transport data
/// @param deviceInfo The deviceInfo.
/// @param subCmdData sub cmd data
/// @param payloadDict payload dict
/// @param success When query successfully, this block will be called.
/// @param failure  This block will be called if some error occurred.
- (void)publishDataUseTransportPipeWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                                           subCmd:(NSData *)subCmdData
                                      payloadDict:(NSDictionary *)payloadDict
                                          success:(nullable ThingSuccessHandler)success
                                          failure:(nullable ThingFailureError)failure;

/// Query device dp data by Bluetooth channel.
///
/// @param deviceInfo        The deviceInfo.
/// @param dpsData      Array of dpId's to be queried.
/// @param success      When query successfully, this block will be called.
/// @param failure      This block will be called if some error occurred.
- (void)publishQueryDpCommandWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                                    dpsData:(NSMutableData *)dpsData
                                    success:(nullable ThingSuccessBOOL)success
                                    failure:(nullable ThingFailureError)failure __deprecated_msg("This method is deprecated, Use publishQueryDpCommandWithDeviceInfo:dpIds:success:failure: instead");

/// Query device dp data by Bluetooth channel. ( support 0x0003 / 0x0004 / 0x801E^0x000E )
/// @param deviceInfo        The deviceInfo.
/// @param dpsData      Array of dpId's to be queried.
/// @param success      When query successfully, this block will be called.
/// @param failure      This block will be called if some error occurred.
- (void)publishQueryDpCommandWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                                      dpIds:(nullable NSArray *)dpIds
                                    success:(nullable ThingSuccessBOOL)success
                                    failure:(nullable ThingFailureError)failure;

/// Get Bluetooth device capability value.This method is used to analyze the Bluetooth capability of the device.
/// @param i Enumeration value of Bluetooth capability to be obtained
/// @param hex The ability to analyze
- (BOOL)bleCapabilityIsSupport:(ThingSmartBLECapability)i hex:(NSString *)hex;


- (void)sendPacketInfoWithDev:(id<ThingBLEDeviceInfoProtocol>)dev
                         data:(NSData *)data
                         type:(ThingBLEConfigType)type
               packageMaxSize:(NSInteger)maxSize
                      success:(nullable ThingSuccessHandler)success
                      failure:(nullable ThingFailureError)failure;

- (BOOL)pairBLEAdvertisingData:(NSData *)advertisingData;




@end

NS_ASSUME_NONNULL_END
