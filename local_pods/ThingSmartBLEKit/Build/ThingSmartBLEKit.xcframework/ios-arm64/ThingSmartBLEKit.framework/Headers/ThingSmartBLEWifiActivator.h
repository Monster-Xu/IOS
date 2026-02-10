//
//  ThingSmartBLEWifiActivator.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <Foundation/Foundation.h>
#import <ThingSmartBLECoreKit/ThingSmartBLEActiveDelegate.h>
#import <ThingSmartDeviceCoreKit/ThingSmartDeviceCoreKit.h>

NS_ASSUME_NONNULL_BEGIN
@class ThingSmartBLEWifiActivator;
@class ThingBLEWifiConfigModel;
@class ThingBLETransportRequest;
@class ThingBLEConfigStateModel;


typedef NS_ENUM (NSInteger, ThingBLEWifiConfigResumeActionType){
    ThingBLEWifiConfigResumeActionTypeSetWifi = 0,
    ThingBLEWifiConfigResumeActionTypePlugPlay,
};

typedef void(^ThingBLEArrayCallback)(NSArray *_Nullable array, NSError *_Nullable error);


/// The delegate of the activation result for a dual-mode device.
@protocol ThingSmartBLEWifiActivatorDelegate <NSObject>

/// The result of activating the dual-mode device.
///
/// @param activator        The class.
/// @param deviceModel      Called when the task is finished. DeviceModel is returned.
/// @param error            Called when the task is interrupted by an error.
- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator didReceiveBLEWifiConfigDevice:(nullable ThingSmartDeviceModel *)deviceModel error:(nullable NSError *)error;

@optional

/// Get the Activation Token
/// @param success Called when the task finishes successfully.
/// @param failure Called when the task is interrupted by an error.
- (void)getBleWifiActivatorToken:(ThingSuccessString)success failure:(ThingFailureError)failure;

/// The device is not in network configuration mode.
/// @param activator  The class.
/// @param error  Called when the task is interrupted by an error.
- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator notConfigStateWithError:(NSError *)error;

/// Callback for scanning WiFi list.
/// @param activator  The class.
/// @param wifiList The WiFi list returned by the device.
/// @param uuid The UUID of the device.
/// @param error  Called when the task is interrupted by an error.
- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator didScanWifiList:(NSArray *)wifiList uuid:(NSString *)uuid error:(NSError *)error;

/// Callback for query extra net cap,etc 4G\NB..t.
/// @param activator  The class.
/// @param capbilities The capbilities dict returned by the device.if value is 0,this cap is support but not valued.
/// @param uuid The UUID of the device.
/// @param error  Called when the task is interrupted by an error.
- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator didQueryExtraNetCapbility:(NSDictionary *)capbilities uuid:(NSString *)uuid error:(NSError *)error;

/// Received the network configuration status reported by the device during the pairing process.
/// @param activator The class.
/// @param configState configState
- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator didReceiveConfigMiddleStateModel:(ThingBLEConfigStateModel *)configState;

@end

/// @brief ThingSmartBLEWifiActivator provides methods to implement the activation of dual-mode devices.
///
/// Each dual-mode device that provides both Bluetooth and Wi-Fi chips can publish the activation data through the Bluetooth channel and complete the activation through the Wi-Fi channel.
@interface ThingSmartBLEWifiActivator : NSObject

/// The delegate of the activation result for a dual-mode device.
@property (nonatomic, weak) id<ThingSmartBLEWifiActivatorDelegate> bleWifiDelegate;

/// The UUID for the device.
@property (nonatomic, strong) NSString *deviceUUID;

/// Auto reset switch for pairing failure. Default true
@property (nonatomic, assign) BOOL isNeedBleReset;

/// The single instance.
+ (instancetype)sharedInstance;

/// Connect device and query wifi list
/// @param UUID  The UUID of the device.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)connectAndQueryWifiListWithUUID:(NSString *)UUID
                                success:(ThingSuccessHandler)success
                                failure:(ThingFailureError)failure;

/// Connect device and query device extra net capbility
/// @param UUID  The UUID of the device.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)connectAndQueryExtraNetCapbilityWithUUID:(NSString *)UUID
                                         success:(ThingSuccessHandler)success
                                         failure:(ThingFailureError)failure;

/// Connect device and query device extra net capbility
/// @param UUID  The UUID of the device.
/// @param timeout default is -1,not timeout
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)connectAndQueryExtraNetCapbilityWithUUID:(NSString *)UUID
                                         timeout:(NSTimeInterval)timeout
                                         success:(ThingSuccessHandler)success
                                         failure:(ThingFailureError)failure;

/// Connect device and query wifi list
/// @param UUID  The UUID of the device.
/// @param timeout default is -1,not timeout
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)connectAndQueryWifiListWithUUID:(NSString *)UUID
                                timeout:(NSTimeInterval)timeout
                                success:(ThingSuccessHandler)success
                                failure:(ThingFailureError)failure;

/// Activates the dual-mode device.
///
/// @param UUID         The UUID of the device.
/// @param homeId       The ID of the current home.
/// @param productId    The product ID of the device.
/// @param ssid         The name of the router.
/// @param password     The password of the device.
/// @param bleActive    whether Plugplay activation required
/// @param timeout      The timeout value.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)startConfigBLEWifiDeviceWithUUID:(NSString *)UUID
                                  homeId:(long long)homeId
                               productId:(NSString *)productId
                                    ssid:(NSString *)ssid
                                password:(NSString *)password
                               bleActive:(BOOL)bleActive
                                 timeout:(NSTimeInterval)timeout
                                 success:(ThingSuccessHandler)success
                                 failure:(ThingFailureHandler)failure;

/// Activates the dual-mode device.
///
/// @param UUID         The UUID of the device.
/// @param homeId       The ID of the current home.
/// @param productId    The product ID of the device.
/// @param ssid         The name of the router.
/// @param password     The password of the device.
/// @param timeout      The timeout value.
/// @param success      Called when the task is finished.
/// @param failure      Called when the task is interrupted by an error.
- (void)startConfigBLEWifiDeviceWithUUID:(NSString *)UUID
                                  homeId:(long long)homeId
                               productId:(NSString *)productId
                                    ssid:(NSString *)ssid
                                password:(NSString *)password
                                 timeout:(NSTimeInterval)timeout
                                 success:(ThingSuccessHandler)success
                                 failure:(ThingFailureHandler)failure;

/// Activates the dual-mode device.
/// @param configuration Device networking configuration parameters
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)startConfigBLEWifiDeviceWithConfiguration:(id<ThingSmartBLEPairConfiguration>)configuration
                                          success:(ThingSuccessHandler)success
                                          failure:(ThingFailureHandler)failure;

/// Start activates device when token is exists
/// @param configuration Device networking configuration parameters
- (void)pairDeviceWithConfiguration:(id<ThingSmartBLEPairConfiguration>)configuration;

/// Start activates device when token is exists
/// @param UUID The UUID of the device.
/// @param token The token value.
/// @param ssid The name of the router.
/// @param pwd The password of the device.
/// @param timeout The timeout value.
- (void)pairDeviceWithUUID:(NSString *)UUID token:(NSString *)token ssid:(NSString *)ssid pwd:(NSString *)pwd timeout:(long)timeout;

/// Stop polling the actived device.
- (void)stopDiscover;


/// Resume ble-wifi device config
/// @param actionType The type of resume event, see ThingBLEWifiConfigResumeActionType
/// @param configModel The model of config，see ThingBLEWifiConfigModel
/// return 0:success  1:params invalidate  2:device is not exist  3:device not support
- (int)resumeConfigBLEWifiDeviceWithActionType:(ThingBLEWifiConfigResumeActionType)actionType
                                    configModel:(ThingBLEWifiConfigModel *)configModel;


/// Query wifi list of device scan during the config
/// @param requestModel The model of request
/// @param completion Called when the task is complete,
///                  IF error is not nil,it means the task is interrupted by an error.
///                  IF error is nil,the responseData is  NSArray <ThingBLEWifiModel *> *

- (void)queryWifiListForDeviceScan:(ThingBLETransportRequest *)requestModel
                        completion:(ThingBLEArrayCallback)completion;


@end

NS_ASSUME_NONNULL_END
