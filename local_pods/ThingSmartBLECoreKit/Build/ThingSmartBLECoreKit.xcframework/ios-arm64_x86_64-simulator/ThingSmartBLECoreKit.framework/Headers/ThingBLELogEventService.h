//
//  ThingBLELogEventService.h
//  ThingSmartBLEKit
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Common event
#define Thing_LOG_EVENT_BLE_CONFIG_START   @"bc78b0af622a504d8d1d7dc12bf84f0c"
#define Thing_LOG_EVENT_BLE_CONFIG_SUCCESS @"3c99d3ab3debaf41d896296b490d2a85"
#define Thing_LOG_EVENT_BLE_CONFIG_FAILURE @"f22f53893cedc95aa34844b792f341ba"

// BLE private event
#define Thing_LOG_EVENT_BLE_CONFIG                         @"a5edb7fb59a6b10ff6959150ddf73388"
#define Thing_LOG_EVENT_BLE_CONNECT                        @"c29bb3a9fe300fcc9dee70068309a5c5"
#define Thing_LOG_EVENT_BLE_OTA                            @"09ab59808da00453664333dcf339af58"

#define Thing_LOG_EVENT_BLE_PAIR                           @"thing_7651589qm7wa7xorzixwskllleyw76z5"
#define Thing_LOG_EVENT_BLE_TRANSPARENT_CHANNEL            @"thing_0a93u96flzoye2tgy0aoo1h4gwgk2hxd"

#define Thing_LOG_EVENT_BLE_CHANNEL_COMPAT                 @"thing_z4fmjx9co2sishnkk6u347swzlvy1vac"

// Config type
#define Thing_LOG_TYPE_BLE_CONFIG                          @"ble_config_ble"
#define Thing_LOG_TYPE_BLE_PLUS_CONFIG                     @"ble_config_ble_plus"
#define Thing_LOG_TYPE_BLE_SECURIThing_CONFIG              @"ble_config_ble_security"
#define Thing_LOG_TYPE_BLE_DEVDERT_CONFIG                  @"ble_config_ble_devcert"
#define Thing_LOG_TYPE_BLE_PLUGPLAY_CONFIG                 @"ble_config_ble_plugplay"
#define Thing_LOG_TYPE_BLE_PLUGPLAY_WIFI_CONFIG            @"ble_config_ble_plugplay_wifi"
#define Thing_LOG_TYPE_BLE_ZIGBEE_CONFIG                   @"ble_config_ble_zb"

// By beacon type
#define Thing_LOG_TYPE_BEACON_CONFIG                       @"ble_config_beacon"

// Connect type
#define Thing_LOG_TYPE_BLE_CONNECT                         @"ble_connect_ble"
#define Thing_LOG_TYPE_BLE_PLUS_CONNECT                    @"ble_connect_ble_plus"
#define Thing_LOG_TYPE_BLE_SECURIThing_CONNECT             @"ble_connect_ble_security"
#define Thing_LOG_TYPE_BLE_DEVDERT_CONNECT                 @"ble_connect_ble_devcert"

// OTA type
#define Thing_LOG_TYPE_BLE_OTA                             @"ble_ota_v1"
#define Thing_LOG_TYPE_BLE_PRO_OTA                         @"ble_ota_v1_pro"
#define Thing_LOG_TYPE_BLE_PLUS_OTA                        @"ble_ota_v1_plus"
#define Thing_LOG_TYPE_BLE_SECURIThing_OTA                 @"ble_ota_v2"
#define Thing_LOG_TYPE_BLE_MCU_OTA                         @"ble_ota_mcu_v2"
#define Thing_LOG_TYPE_BLE_CHANNEL_OTA                     @"ble_ota_channel_v2"
#define Thing_LOG_TYPE_BLE_SECURIThing_OTA_V4             @"ble_ota_v4"
#define Thing_LOG_TYPE_BLE_MCU_OTA_V4                      @"ble_ota_mcu_v4"
#define Thing_LOG_TYPE_BLE_CHANNEL_OTA_V4                  @"ble_ota_channel_v4"

// Config step
#define Thing_BLE_CONFIG_STEP_CHECK                        @"ble_check"
#define Thing_BLE_CONFIG_STEP_TIMEOUT                      @"ble_timeout"
#define Thing_BLE_CONFIG_STEP_CONFIG_CANCEL                @"ble_config_cancel"
#define Thing_BLE_CONFIG_STEP_CONNECT                      @"ble_connect"
#define Thing_BLE_CONFIG_STEP_SERVICE                      @"ble_discover_service"
#define Thing_BLE_CONFIG_STEP_CHARACT                      @"ble_discover_character"
#define Thing_BLE_CONFIG_STEP_NOTIFY                       @"ble_notify_error"
#define Thing_BLE_CONFIG_STEP_GET_KEY_FAILURE              @"ble_get_key"
#define Thing_BLE_CONFIG_STEP_GET_DEVINFO                  @"ble_get_devinfo"
#define Thing_BLE_CONFIG_STEP_SET_PWD                      @"ble_set_pwd"
#define Thing_BLE_CONFIG_STEP_REGISTER_ERROR               @"ble_register"
#define Thing_BLE_CONFIG_STEP_PAIR                         @"ble_pair"
#define Thing_BLE_CONFIG_STEP_DEVCERT                      @"ble_devcert"
#define Thing_BLE_CONFIG_STEP_ACTIVE                       @"ble_active"
#define Thing_BLE_CONFIG_STEP_ACTIVE_BIND                  @"ble_active_bind"
#define Thing_BLE_CONFIG_STEP_ACTIVE_GUEST_BIND            @"ble_active_guest_bind"
#define Thing_BLE_CONFIG_STEP_DEVCERT                      @"ble_devcert"
#define Thing_BLE_CONFIG_STEP_UNKNOWN                      @"ble_unknown"

#define THING_BLE_SERVER_GET_DEVINFO                      @"ble_service_get_devinfo";

#define Thing_BLE_CONFIG_STEP_PP_CHECK                     @"ble_pp_check"                     /// Exception when passing parameters during business layer calls
#define Thing_BLE_CONFIG_STEP_PP_GET_DEVINFO               @"ble_pp_get_devinfo"               /// 0x001A Command error
#define Thing_BLE_CONFIG_STEP_PP_ACTIVE                    @"ble_pp_active"                    /// Error reported by thing.m.dm.device.active interface
#define Thing_BLE_CONFIG_STEP_PP_ACTIVE_INFO               @"ble_pp_active_info"               /// 0x001B Command error (fragmentation error)
#define Thing_BLE_CONFIG_STEP_PP_ENV                       @"ble_pp_env"                       /// Error reported by thing.m.env.get interface
#define Thing_BLE_CONFIG_STEP_PP_PSK_API                   @"ble_pp_psk_api"                   /// Security level interface error
#define Thing_BLE_CONFIG_STEP_PP_SEND_WIFI_INFO            @"ble_pp_send_wifi_info"            /// 0x001C Command sending error
#define Thing_BLE_CONFIG_STEP_PP_DEVICE_WIFI_INFO          @"ble_pp_device_wifi_info_error"    /// 0x001C Device returns Wi-Fi JSON parsing error
#define Thing_BLE_CONFIG_STEP_PP_TIMEOUT                   @"ble_pp_timeout"                   /// Plugplay polling timeout

#define Thing_BLE_CONFIG_STEP_ZB_CHECK                     @"ble_zb_check"                     /// Exception when passing parameters during business layer calls
#define Thing_BLE_CONFIG_STEP_ZB_GW_NOT_SUPPORT            @"ble_zb_gw_not_sup"                /// The current gateway does not support plugplay functionality
#define Thing_BLE_CONFIG_STEP_ZB_GET_DEVINFO               @"ble_zb_get_devinfo"               /// 0x0000 Command error in obtaining Zigbee sub-device information
#define Thing_BLE_CONFIG_STEP_ZB_PUBLISH_MAC               @"ble_zb_mac"                       /// Failed to send command 64 to the gateway to configure the sub-device
#define Thing_BLE_CONFIG_STEP_ZB_GW_ERROR                  @"ble_zb_gw_error"                  /// Gateway returns command 65 with an error
#define Thing_BLE_CONFIG_STEP_ZB_GW_INFO                   @"ble_zb_gw_info"                   /// Incomplete gateway information returned by the gateway via command 65
#define Thing_BLE_CONFIG_STEP_ZB_SEND_GW_INFO              @"ble_zb_send_gw_info"              /// Failed to send gateway information to the sub-device via command 0x0040
#define Thing_BLE_CONFIG_STEP_ZB_DEVICE_GW_INFO            @"ble_zb_device_gw_info_error"      /// Error returned by the sub-device when sending gateway information via command 0x0040
#define Thing_BLE_CONFIG_STEP_ZB_TIMEOUT                   @"ble_zb_timeout"                   /// Plugplay polling sub-device online timeout

// Connect step
#define Thing_BLE_CONNECT_STEP_CONNECT                     @"ble_connect"
#define Thing_BLE_CONNECT_STEP_SERVICE                     @"ble_discover_service"
#define Thing_BLE_CONNECT_STEP_CHARACT                     @"ble_discover_character"
#define Thing_BLE_CONNECT_STEP_NOTIFY                      @"ble_notify_error"
#define Thing_BLE_CONNECT_STEP_GET_DEVINFO                 @"ble_get_devinfo"
#define Thing_BLE_CONNECT_STEP_GET_DEVINFO_TIMEOUT         @"ble_get_devinfo_timeout"
#define Thing_BLE_CONNECT_STEP_PAIR                        @"ble_pair"
#define Thing_BLE_CONNECT_STEP_PAIR_TIMEOUT                @"ble_pair_timeout"
#define Thing_BLE_CONNECT_STEP_DEVCERT                     @"ble_devcert"
#define Thing_BLE_CONNECT_STEP_TIMEOUT                     @"ble_timeout"
#define Thing_BLE_CONNECT_STEP_DEVICE_NOT_EXIST            @"ble_device_not_exist"

// Channel compatibility type
#define Thing_BLE_COMPAT_TYPE_CONNECT                       @"ble_compat_connect"
#define Thing_BLE_COMPAT_TYPE_QUERYDEVICEINFO              @"ble_compat_get_deviceInfo"
#define Thing_BLE_COMPAT_TYPE_TIMEOUT                       @"ble_compat_timeout"

// Channel compatibility error codes
#define Thing_BLE_COMPAT_ERRORCODE_NULLSERVICE             @"ble_discover_service_null"   /// Service discovery is empty
#define Thing_BLE_COMPAT_ERRORCODE_CHARACT                 @"ble_discover_character_wrong" /// Characteristic discovery failed or is empty
#define Thing_BLE_COMPAT_ERRORCODE_NOTIFYCHARACT           @"ble_discover_notify_character_wrong"  /// Notify characteristic discovery failed
#define Thing_BLE_COMPAT_ERRORCODE_PAIR_TIMEOUT            @"ble_pair_timeout" /// Pairing command timeout
#define Thing_BLE_COMPAT_ERRORCODE_TOTAL_TIMEOUT           @"ble_connect_total_timeout" /// Bluetooth total connection timeout

@interface ThingBLELogEventService : NSObject

@property (nonatomic, strong)   NSDate      *freeDate;
@property (nonatomic, copy)     NSString    *event;
@property (nonatomic, copy)     NSString    *type;
@property (nonatomic, copy)     NSString    *step;
@property (nonatomic, copy)     NSString    *pid;
@property (nonatomic, copy)     NSString    *uuid;
@property (nonatomic, copy)     NSString    *errorMsg;
@property (nonatomic, assign)   BOOL        isSuccess;
@property (nonatomic, copy)     NSString    *pairID;

@property (nonatomic, copy)     NSString    *category;
@property (nonatomic, copy)     NSString    *subCategory;
@property (nonatomic, copy)     NSString    *thirdCategory;
/// OTA
@property (nonatomic, copy)     NSString    *firmwareSize;
@property (nonatomic, copy)     NSString    *firmwareVersion;
// Distinguish whether the device connection is through a secure connection or a non-secure connection
@property (nonatomic, assign) NSInteger bleV2Crpt;

- (void)logEvent;
- (void)updateLogEventWithError:(NSError *)error;

@end

@interface ThingBLECompatEventService : NSObject

@property (nonatomic, copy)     NSString    *event;
@property (nonatomic, copy)     NSString    *devId;
@property (nonatomic, copy)     NSString    *pid;
@property (nonatomic, copy)     NSString    *uuid;
@property (nonatomic, copy)     NSString    *category;
@property (nonatomic, copy)     NSString    *subCategory;
@property (nonatomic, copy)     NSString    *thirdCategory;
@property (nonatomic, copy)     NSString    *type;
@property (nonatomic, copy)     NSString    *errorCode;
@property (nonatomic, copy)     NSString    *errorMsg;
@property (nonatomic, assign)   BOOL        isSuccess;

- (void)logEvent;

@end

// Model related to device category for event tracking
@interface ThingBLEDeviceCategoryInfo : NSObject

@property (nonatomic, copy)     NSString    *devId;
@property (nonatomic, copy)     NSString    *category;
@property (nonatomic, copy)     NSString    *subCategory;
@property (nonatomic, copy)     NSString    *thirdCategory;

@end

NS_ASSUME_NONNULL_END
