//
//  ThingSmartBLEActiveDelegate.h
//  Pods
//
//  Created by yuguo on 2021/4/25.
//

#ifndef ThingSmartBLEActiveDelegate_h
#define ThingSmartBLEActiveDelegate_h

#import "ThingBLEDeviceInfoProtocol.h"
#import "ThingBLEAdvModel.h"
#import <ThingSmartUtil/ThingSmartUtil.h>
#import "ThingSmartBLECoreEnums.h"
#import "ThingBLEDevInfo.h"

typedef NS_ENUM(NSUInteger, ThingSmartBLEEncKeyType) {
    ThingSmartBLEEncKeyTypeActive = 1, //!< Activation key
    ThingSmartBLEEncKeyTypeRemove, //!< Removal key
};

NS_ASSUME_NONNULL_BEGIN

@protocol ThingBLEDeviceInfoProtocol;
/// Used to handle callbacks for some data desired during the activation/unbinding phase after decoupling from BLEKitCore, such as keys, registered GIDs, etc. This will be moved to public later.
@protocol ThingSmartBLEActiveDelegate <NSObject>

@optional

/// Pass the key to the SDK during the activation/unbinding process
/// @param advModel Device information
/// @param encKeyType Activation or removal
/// @param handler Business layer uses the handler to pass the key to the SDK
/// @param error Error
- (void)transEncKeyWithAdvModel:(ThingBLEAdvModel *)advModel
                     encKeyType:(ThingSmartBLEEncKeyType)encKeyType
                        handler:(nullable void(^)(id _Nullable key))handler
                        failure:(nullable ThingFailureError)error;

- (void)fetchBLEMeshNodeIdWithSuccess:(ThingSuccessID)success failure:(nullable ThingFailureError)failure;

/// Register the device to the cloud
- (void)registerToServe:(NSString *)uuid devId:(nullable NSString *)devId encryptedAuthKey:(NSString *)encryptedAuthKey productKey:(NSString *)productKey pv:(NSString *)pv sv:(NSString *)sv mac:(nullable NSString *)mac isRegisterKey:(BOOL)isRegisterKey isShare:(BOOL)isShare options:(NSDictionary *)options success:(ThingSuccessDict)success failure:(ThingFailureError)failure;

- (NSInteger)getExtModuleType:(NSString*)devId;

- (void)activateExtendedModule:(NSString*)devId automatic:(BOOL)automatic success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

- (void)activateExtendedWiFiModule:(NSString*)devId automatic:(BOOL)automatic ssid:(NSString*)ssid password:(NSString*)pwd success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

- (void)validateBLEBeaconCapability:(nullable ThingBLESecurityDevInfo *)devInfo;

/// Signature process during activation
/// @param deviceInfo Device information
/// @param success Success
/// @param failure Failure
- (void)handleChipEncrypt:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                  success:(ThingSuccessHandler)success
                  failure:(ThingFailureError)failure;

- (void)fetchNodeId:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

/// Synchronize device information. The business layer retrieves the device by devId and processes it before passing it to the SDK
/// @param devId Device ID
/// @param handler Business layer uses the handler to pass the device to the SDK
/// @param error Error
- (void)syncDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                 devId:(NSString *)devId
               handler:(nullable ThingSuccessID)handler
               failure:(nullable ThingFailureError)error;

/// Activation failure
/// @param devId Device ID
- (void)activeFailed:(NSString *)devId;

/// Device unbinding
/// @param deviceInfo Device information
/// @param handler Handler
/// @param error Error
- (void)unbindDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
             handler:(nullable ThingSuccessHandler)handler
             failure:(nullable ThingFailureError)error;

/// Update device information
/// @param deviceInfo Device information
- (void)updateDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo;

/// Report dp points
- (void)reportDps:(NSDictionary *)dps devId:(NSString *)devId dpsTime:(NSString *)dpsTime mode:(NSUInteger)mode reportType:(NSUInteger)type;

/// Report dp points (for local type devices without devId)
- (void)reportDps:(NSDictionary *)dps mac:(NSString *)mac dpsTime:(NSString *)dpsTime mode:(NSUInteger)mode reportType:(NSUInteger)type;

/// Report dp points with time as a map
- (void)reportDps:(NSDictionary *)dps devId:(NSString *)devId dpsTimeMap:(NSDictionary *)dpsTimeMap mode:(NSUInteger)mode reportType:(NSUInteger)type;

/// Update OTA information
/// @param deviceInfo Device information
/// @param otaType OTA type
/// @param otaVersion OTA version
- (void)updateOTAVersion:(id<ThingBLEDeviceInfoProtocol>)deviceInfo otaType:(ThingSmartBLEOTAType)otaType otaVersion:(NSString *)otaVersion;

/// Update device online status
/// @param deviceInfo Device information
/// @param isOnline Whether online
- (void)updateBLEOnlineStatus:(id<ThingBLEDeviceInfoProtocol>)deviceInfo isOnline:(BOOL)isOnline;

/// Discover big data channel
/// @param deviceInfo Device information
/// @param services Services
- (void)discoverBleChannel:(id<ThingBLEDeviceInfoProtocol>)deviceInfo services:(NSArray *)services;

/// Pass PSK information
/// @param SL Security level
/// @param handler Callback
/// @param error Failure
- (void)transferPSKInfoWithSL:(NSNumber *)SL
                      handler:(nullable ThingSuccessDict)handler
                      failure:(nullable ThingFailureError)error;

- (void)didScanWifiListSuccess:(NSArray *)wifiList
                       failure:(nullable NSError *)error;

/// OTA sign
- (void)queryOTASignWithDev:(id<ThingBLEDeviceInfoProtocol>)deviceInfo firmwareType:(NSInteger)firmwareType signType:(NSInteger)signType signVer:(NSInteger)signVer success:(ThingSuccessDict)success failure:(ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END

#endif /* ThingSmartBLEActiveDelegate_h */
