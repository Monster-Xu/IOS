//
//  ThingSmartExtModuleManager.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *ThingBleExtModuleActiveKey NS_STRING_ENUM;
typedef NSDictionary<ThingBleExtModuleActiveKey, id> ThingBleExtModuleActiveDictionary;

FOUNDATION_EXPORT ThingBleExtModuleActiveKey _Nonnull const ThingBleExtModuleActiveWiFiSSIDKey;
FOUNDATION_EXPORT ThingBleExtModuleActiveKey _Nonnull const ThingBleExtModuleActiveWiFiPwdKey;

/// @{ThingBleExtModuleAutoActiveKey:@(YES/NO)}
FOUNDATION_EXPORT ThingBleExtModuleActiveKey _Nonnull const ThingBleExtModuleAutoActiveKey;

/// @{@"devId":@"xxx",@"state":@(1/0)}
FOUNDATION_EXPORT NSString *_Nonnull const ThingBleExtModuleStatusChangeNotification;

@protocol ThingSmartExtModuleStatusListeningDelegate <NSObject>

/// This protocol method will be called when the extended module is plugged or unplugged
/// @see <i>registerExtModuleStatusListeningDelegate:</i>  <i>unregisterExtModuleStatusListeningDelegate:</i>
/// @param devId device id
/// @param status 0:plug out 1:plug in
- (void)extendedModule:(NSString*)devId onStatusChange:(NSInteger)status;
@end



@interface ThingSmartExtModuleManager : NSObject

ThingSDK_SINGLETON

#pragma mark - listening delegate
/// Register an delegate to listen to the plug-in status of the extended module
/// @see <code>ThingSmartExtModuleStatusListeningDelegate</code>
/// @param delegate delegate
- (void)registerExtModuleStatusListeningDelegate:(id<ThingSmartExtModuleStatusListeningDelegate>)delegate;


/// If you do not need to get the plug-in status of the extension module, call this method
/// @param delegate delegate
- (void)unregisterExtModuleStatusListeningDelegate:(id<ThingSmartExtModuleStatusListeningDelegate>)delegate;


#pragma mark - activate
/// Activating the extended module via bluetooth.
/// If the extended module is WiFi, it will return an error because SSID and password need to be entered
/// @see <i>activeExtModuleByBLEActived:params:success:failure</i>
/// @warning This method can be called to activate the extended module only after the bluetooth main module is activated.
/// @param devId device id
/// @param success If successfully activated, this block is called.
/// @param failure If it cannot be activated, call back an error message.
- (void)activeExtenModuleByBLEActived:(NSString *)devId success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure DEPRECATED_MSG_ATTRIBUTE("use `activateExtendedModule:automatic:success:failure` instead");


/// Activate the extended module via bluetooth.
/// If the extended module is WiFi, activating the module requires entering SSID and password.
/// @warning This method can be called to activate the extended module only after the bluetooth main module is activated.
/// @param devId device id
/// @param params see {@link ThingBleExtModuleActiveKey} <code>ThingBleExtModuleActiveDictionary</code>
/// @param success If successfully activated, this block is called.
/// @param failure If activation fails, this block calls back an error
- (void)activateExtendedModule:(NSString *)devId params:(nullable ThingBleExtModuleActiveDictionary*)params success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;


/// Activate the extended module.
/// If it is WiFi, it will return an error because the SSID and password are not entered
/// @param devId device id
/// @param automatic YES Automatic NO manual. If NO, need to wait for the MQTT response result
/// @param success If successfully activated, this block is called.
/// @param failure If activation fails, this block calls back an error
- (void)activateExtendedModule:(NSString*)devId automatic:(BOOL)automatic success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;



/// Activate the extended WiFi module. SSID and password required.
/// @param devId device id
/// @param automatic YES Automatic NO manual. If NO, need to wait for the MQTT response result
/// @param ssid WiFi SSID
/// @param pwd WiFi password
/// @param success If successfully activated, this block is called.
/// @param failure If activation fails, this block calls back an error
- (void)activateExtendedWiFiModule:(NSString*)devId automatic:(BOOL)automatic ssid:(NSString*)ssid password:(NSString*)pwd success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;


/// Get the extended module type
///  -1：Module not found，0:Module not plugged in，1:NB，2:Wi-Fi，3:Cat.X, 04:Zigbee
/// @param devId device id
- (NSInteger)getExtModuleType:(NSString*)devId;


/// Save the module information data actively reported by the Bluetooth 0x50 command
/// @param data module info data
/// @param devId device id
- (void)saveExtendedModuleInfoData:(NSData*)data forDevice:(NSString*)devId;
@end

NS_ASSUME_NONNULL_END
