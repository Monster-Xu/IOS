//
//  ThingBLEActiveProtocol.h
//  Pods
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)
//

#ifndef ThingBLEActiveProtocol_h
#define ThingBLEActiveProtocol_h
#import <ThingSmartUtil/ThingSmartUtil.h>
#import "ThingSmartBLEActiveDelegate.h"
#import "ThingBLEWifiConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

// TODO: The error types for configuration failure can be summarized into an enum

@class ThingSmartBLELocalDevice;
typedef void(^ ThingSmartLocalBLEDeviceConnectedHandler)(ThingSmartBLELocalDevice *localDevice);

@protocol ThingBLEActiveProtocol;
@protocol ThingBLEDeviceInfoProtocol;
@protocol ThingSmartBLEActiveDelegate;
@class ThingBLEAdvModel;

@protocol ThingBLEActiveDelegate <NSObject>

@optional

- (void)activeManager:(id<ThingBLEActiveProtocol>)active stage:(NSInteger)stage notConfigStateWithError:(NSError *)error;

- (void)activeManager:(id<ThingBLEActiveProtocol>)active deviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo state:(NSInteger)state;

- (void)activeManager:(id<ThingBLEActiveProtocol>)active restartScanning:(BOOL)clearCache;

// Check if the single-point device has already been activated by another link (e.g., gateway)
/// @param active activeManager
/// @param uuid Device information
/// @return Device Model ActiveTime
- (long long)activeManager:(id<ThingBLEActiveProtocol>)active checkBLESubDeviceActivedState:(nonnull NSString *)uuid;

- (void)activeManager:(id<ThingBLEActiveProtocol>)active deviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo didScanWifiListSuccess:(NSArray *)wifiList failure:(nullable NSError *)error;

- (void)activeManager:(id<ThingBLEActiveProtocol>)active deviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo didQueryExtraNetCapbilitySuccess:(NSDictionary *)capbility failure:(nullable NSError *)error;

/// Configuration result callback
/// @param active activeManager
/// @param deviceInfo Device information
/// @param result Result
/// @param error Error
- (void)activeManager:(id<ThingBLEActiveProtocol>)active deviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo didActiveSuccess:(nullable id)result failure:(nullable NSError *)error;

/// Configuration failure callback
/// @param active activeManager
/// @param deviceInfo Device information
/// @param result Result
/// @param error Error
- (void)activeManager:(id<ThingBLEActiveProtocol>)active deviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo activeFailRes:(nullable NSDictionary *)result failure:(nullable NSError *)error;

@end

/// Activation protocol; old methods currently cannot be moved due to downgrade issues and must remain in Core temporarily
@protocol ThingBLEActiveProtocol <NSObject>

@optional

@property (nonatomic, weak) id<ThingBLEActiveDelegate> delegate; /// < Configuration delegate
@property (nonatomic, weak) id<ThingSmartBLEActiveDelegate> handlerDelegate; //!< Delegate for external data supplementation during the process
@property (nonatomic, copy) NSString *miniPairId; //! MiniProgram pair ID
@property (nonatomic, copy) NSString *ccode;

/// Start configuration (Core)
/// @param deviceInfo   The device to be configured
/// @param handlerDelegate Delegate object for obtaining supplementary information
- (void)startActiveWithDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
              handlerDelegate:(nullable id<ThingSmartBLEActiveDelegate>)handlerDelegate;

/// Dual-mode configuration pre-connection (Core)
/// @param deviceInfo   The device to be configured
- (void)startPreActiveWithDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                         success:(nullable ThingSuccessID)success
                         failure:(nullable ThingFailureError)failure;

/// Start Active Device when Bluetooth is connected on the device and the app
/// @param token Token
/// @param ssid SSID
/// @param pwd Password
- (void)pairWithToken:(NSString *)token ssid:(NSString *)ssid pwd:(NSString *)pwd;

- (void)pairWithTokenWithDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo token:(NSString *)token ssid:(NSString *)ssid pwd:(NSString *)pwd;

- (void)pairExtraNetDualWithTokenWithDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo token:(NSString *)token parmas:(NSDictionary *)params;

/// Start Active Device when Bluetooth is connected on the device and the app
/// @param conf  Wifi Config Info
- (void)pairWithConfigInfo:(ThingBLEWifiConfigModel *)configInfo;

/// Start configuration (Core)
/// @param deviceInfo   The device to be configured
/// @param ssid         Router hotspot name
/// @param passwd       Router hotspot password
/// @param token        Configuration Token
/// @param handlerDelegate Delegate object for obtaining supplementary information
/// @param success Success callback
/// @param failure Failure callback
- (void)startActiveWithDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                         ssid:(NSString *)ssid
                       passwd:(NSString *)passwd
                        token:(NSString *)token
              handlerDelegate:(id<ThingSmartBLEActiveDelegate>)handlerDelegate
                      success:(nullable ThingSuccessID)success
                      failure:(nullable ThingFailureError)failure;

/// Start Active Device
/// @param deviceInfo Device information
/// @param configInfo Wifi Config Info
/// @param handlerDelegate Handler delegate
/// @param success Success callback
/// @param failure Failure callback
- (void)startActiveWithDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                   configInfo:(ThingBLEWifiConfigModel *)configInfo
              handlerDelegate:(id<ThingSmartBLEActiveDelegate>)handlerDelegate
                      success:(nullable ThingSuccessID)success
                      failure:(nullable ThingFailureError)failure;

/// Batch configuration (Core)
/// @param deviceInfo   The device to be configured
/// @param ssid         Router hotspot name
/// @param passwd       Router hotspot password
/// @param token        Configuration Token
/// @param handlerDelegate Delegate object for obtaining supplementary information
/// @param success Success callback
/// @param failure Failure callback
- (void)multiActiveWithDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                         ssid:(NSString *)ssid
                       passwd:(NSString *)passwd
                        token:(NSString *)token
              handlerDelegate:(id<ThingSmartBLEActiveDelegate>)handlerDelegate
                      success:(nullable ThingSuccessID)success
                      failure:(nullable ThingFailureError)failure;

/// Start Batch Active Device
/// @param deviceInfo Device information
/// @param configInfo Wifi Config Info
/// @param handlerDelegate Handler delegate
/// @param success Success callback
/// @param failure Failure callback
- (void)multiActiveWithDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                   configInfo:(ThingBLEWifiConfigModel *)configInfo
              handlerDelegate:(id<ThingSmartBLEActiveDelegate>)handlerDelegate
                      success:(nullable ThingSuccessID)success
                      failure:(nullable ThingFailureError)failure;

/// Zigbee dual-mode sub-device Bluetooth pairing (Core)
/// (Includes Bluetooth connection, obtaining sub-device information, pairing operation)
/// @param deviceInfo  The device to be configured
/// @param success     Success callback
/// @param failure     Failure callback
- (void)pairZigbeeSubDeviceWithBleChannel:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                                  success:(nullable ThingSuccessID)success
                                  failure:(nullable ThingFailureError)failure;

/// Send gateway information to Zigbee dual-mode sub-device
/// @param deviceInfo  The device to be configured
/// @param gatewayInfo  Gateway information
/// @param success     Success callback
/// @param failure     Failure callback
- (void)publishGatewayInfoWithBleChannel:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                             gatewayInfo:(NSDictionary *)gatewayInfo
                                 success:(ThingSuccessBOOL)success
                                 failure:(ThingFailureError)failure;

/// Connect to device (dual-mode, PlugPlay) (Core)
/// @param dev The device to be configured
/// @param success Success callback
/// @param failure Failure callback
- (void)connectToDevice:(id<ThingBLEDeviceInfoProtocol>)dev
                success:(ThingSuccessHandler)success
                failure:(ThingFailureError)failure;

/// Backup activation (PlugPlay) (Core)
/// @param dev The device to be configured
/// @param success Success callback
/// @param failure Failure callback
- (void)activeBLEBackUp:(id<ThingBLEDeviceInfoProtocol>)dev
                  token:(NSString *)token
                success:(nullable ThingSuccessID)success
                failure:(ThingFailureError)failure;

/// Dual-mode activation (PlugPlay) (Core)
/// @param devId Device ID
/// @param result Result
/// @param ssid Router hotspot name
/// @param password Router hotspot password
/// @param callback Status callback
/// @param failure Failure callback
- (void)activeDualDeviceWifiChannel:(NSString *)devId
                             result:(id)result
                               ssid:(NSString *)ssid
                           password:(NSString *)password
                        listenState:(void(^)(void))callback
                            failure:(ThingFailureError)failure;

/// Clear reconnection device data
- (void)cleanReconnectDevice:(NSString *)uuid;

/// End configuration
- (void)stopActive;

/// Cancel the ongoing activation process.
- (void)cancelActive;

/// Send configuration information (BLE + WiFi dual-mode configuration) supports multiple sends of configuration information
/// @param ssid The SSID of the router
/// @param passwd The password of the router
/// @param token The token of the configuration
- (void)sendConfigWifiInfoWithSsid:(NSString *)ssid
                            passwd:(NSString *)passwd
                             token:(NSString *)token;

- (void)sendWifiConfigInfo:(NSDictionary *)info deviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo;

- (void)queryStateWithDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
             handlerDelegate:(id<ThingSmartBLEActiveDelegate>)handlerDelegate
                     success:(nullable ThingSuccessID)success
                     failure:(nullable ThingFailureError)failure;

@end


@protocol ThingLocalBLEActiveProtocol <NSObject>

@optional

@property (nonatomic, assign) BOOL isLocalConnecting;

/// Local device connect
/// - Parameters:
///   - deviceInfo: Device information
///   - success: Success callback
///   - failure: Failure callback
- (void)connectDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
        schemaHandler:(nullable ThingSuccessDict)schemaHandler
              success:(nullable ThingSmartLocalBLEDeviceConnectedHandler)success
              failure:(nullable ThingFailureError)failure;

- (void)configMachineKey:(NSString *)machineKey;

- (void)configSchema:(NSDictionary *)schema;

- (void)receiveDevicePubKey:(NSData *)keyData;

- (void)receiveDeviceMachineKeyCheckResult:(NSData *)data;

- (void)receiveDeviceSchemaCheckResult:(NSData *)data;

- (void)receiveDeviceSchema:(NSData *)data;

@end

NS_ASSUME_NONNULL_END

#endif /* ThingBLEActiveProtocol_h */
