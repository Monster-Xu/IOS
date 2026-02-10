//
//  NSError+BLEError.h
//  ThingSmartBLEKit
//
//

#import <Foundation/Foundation.h>

#define ThingBLEErrorDomain @"com.ble.www"

// Bluetooth service error codes (new version)
typedef NS_ENUM(NSInteger, ThingBLEError) {
    ThingBLEErrorConnectFail   = 101001, // Failed to connect to Bluetooth peripheral
    ThingBLEErrorConnectPerailTimeOut = 101002, // Timeout during Bluetooth connection to peripheral
    ThingBLEErrorDiscoverServiceFail = 101003, // Error discovering Bluetooth service (service is empty or failed)
    ThingBLEErrorDiscoverCharacterFail = 101004, // Error discovering Bluetooth characteristic (no matching read/write characteristic found or failed)
    ThingBLEErrorNotifyCharacterFail = 101005, // Error setting Bluetooth characteristic
    ThingBLEErrorQueryDevInfoFail = 101006, // Failed to query Bluetooth device information
    ThingBLEErrorQueryDevInfoTimeOut = 101007, // Timeout while querying Bluetooth device information
    ThingBLEErrorPairFail = 101008, // Bluetooth pairing command failed
    ThingBLEErrorPairTimeOut = 101009, // Bluetooth pairing command timeout
    ThingBLEErrorConnectTimeOut = 101010, // Total Bluetooth connection timeout
    
    ThingBLEErrorDeviceNotExist = 101011, // Device does not exist
    ThingBLEErrorDeviceInfoNotExist = 101012, // No Bluetooth object
    ThingBLEErrorNotPowerOn = 101013, // Bluetooth is not turned on
    ThingBLEErrorCapabilityDisabled = 101014, // Device does not have Bluetooth capability
    ThingBLEErrorScanTimeOut = 101015, // Bluetooth scan timeout, target device not found
    ThingBLEErrorDeviceIsNotActive = 101016, // Bluetooth connected device is not configured
    ThingBLEErrorUnableConnectDuringOTA = 101017, // Bluetooth connection behavior is not allowed during OTA
    ThingBLEErrorParamInvalid = 101018, // Invalid input parameter
};

/**
 * APP error code enumeration definition
 */
typedef enum {
    
    // User actively cancels configuration
    THING_BLE_CONFIG_CANCEL = 100,
    
    // Bluetooth connection failure
    THING_BLE_CONNECT_FAILURE = 101,
    
    // Error discovering Bluetooth service
    THING_BLE_FIND_SERVICE_FAILURE = 102,
    
    // Failed to open Bluetooth communication channel
    THING_BLE_CHARACTER_FAILURE = 103,
    
    // Failed to get device information
    THING_BLE_QRY_DEV_INFO_FAILURE = 104,
    
    // Pairing failed
    THING_BLE_PAIR_FAILURE = 105,
    
    // Configuration timeout
    THING_BLE_TIMEOUT = 106,
    
    // Failed to send configuration information
    THING_BLE_CONFIG_INFO_FAILURE = 107,
    
    // Token expired
    THING_BLE_TOKEN_INVALID = 108,
    
    // Failed to get Bluetooth encryption key
    THING_BLE_GET_KEY_FAILURE = 109,
    
    // Device does not exist
    THING_BLE_DEVICE_NOT_EXIST = 110,
    
    // Device cloud registration failed
    THING_BLE_REGISTER_FAILURE = 111,
    
    // Device cloud activation failed
    THING_BLE_ACTIVE_FAILTURE = 112,
    
    // Device is strongly bound
    THING_BLE_ALREADY_BIND = 113,
    
    // Bluetooth state change
    THING_BLE_CHECK_FAILURE = 114,
    
    // Failed to synchronize device information
    THING_BLE_SYNC_DEVICE_FAILURE = 115,
    
    // Multi-protocol device has been configured through other means
    THING_BLE_ALREADY_CONFIG_FAILURE = 116,
    
    // OTA upgrade failed
    THING_BLE_OTA_FAILURE = 117,
    
    // OTA upgrade timeout
    THING_BLE_OTA_TIMEOUT = 118,
    
    // Wi-Fi configuration parameter validation failed
    THING_BLE_WIFI_CONFIG_CHECK_FAILURE = 119,
    
    // Failed to send key
    THING_BLE_PWD_FAILURE = 120,
    
    // Failed to discover Bluetooth connection object
    THING_BLE_FIND_PERP_FAILURE = 121,
    
    // No Bluetooth object
    THING_BLE_DEVICEINFO_NOT_EXIST = 122,
    
    // Guests do not support strong binding
    THING_BLE_GUEST_NOT_SUPPORT_STRONG_BIND = 123,
    
    THING_BLE_COMMON_FAILURE = 124,
    
    // Notify open failure
    THING_BLE_NOTIFY_OPEN_FAILURE = 125,
    
    // Hardware encryption device end error
    THING_BLE_CHIP_DEVICE_FAILURE = 126,
    
    // Hardware encryption cloud end error
    THING_BLE_CHIP_CLOUD_FAILURE = 127,
    
    // Non cat.1 device dual-mode configuration failed, password not entered
    THING_BLE_DUAL_ACTIVAT_PSD_FAILURE = 128,
    
    // Failed to get token
    THING_BLE_GET_TOKEN_FAILURE = 129,
    
    // Configuration parameter error
    THING_BLE_PP_PARAM_ERROR = 130,
    
    // Failed to query device Wi-Fi information
    THING_BLE_PP_QUERY_WIFI_INFO_FAILURE = 131,
    
    // Error from thing.m.dm.device.active interface
    THING_BLE_PP_ACTIVE_FAIL = 132,
    
    // Failed to send device activation information
    THING_BLE_PP_SEND_ACTIVE_INFO_FAIL = 133,
    
    // Device cloud online failure leading to timeout
    THING_BLE_DEVICE_MQ_ONLINE_FAIL = 134,
    
    // 
    THING_BLE_QRY_DEV_INFO_TIMEOUT = 135,
    
    // Pairing command timeout
    THING_BLE_PAIR_TIMEOUT = 136,
    
    THING_BLE_PP_QUERY_WIFI_INFO_TIMEOUT = 137,
    
    // Timeout for sending device activation information
    THING_BLE_PP_SEND_ACTIVE_INFO_TIMEOUT = 138,
    
    // Failed to get cloud device information during activation process
    THING_BLE_SERVER_GET_DEVINFO_FAILURE = 139,
    
    // Failed to get binding status, no permission
    THING_BLE_SERVER_BIND_STATUS_FAILURE = 140,
    
    // thing.m.device.security.config fetch failed
    THING_BLE_FETCH_SL_API_FAILURE = 141,

    // subcmd 0x0001 send failed (psk3.0 dual-mode device configuration)
    THING_BLE_CONFIG_INFO_SL_FAILURE = 142,

    // subcmd 0x0002 send failed (psk3.0 PnP cloud activation)
    THING_BLE_PP_CONFIG_WIFI_SL_FAILURE = 143,
    
    // Timeout for querying the surrounding Wi-Fi list of the device
    THING_BLE_QUERY_WIFILIST_TIMEOUT = 144,
    
    // Bluetooth device not fully paired (secure channel not established)
    THING_BLE_DEVICE_NOT_PAIR = 145,
    
    // This Bluetooth device does not support this function
    THING_BLE_NOT_SUPPORT_ABILITY = 146,
    
    // Timeout for collecting device logs
    THING_BLE_DEVICE_LOG_TIMEOUT = 147,
    
    // Device networking phase timeout (connecting to router phase timeout)
    THING_BLE_DEVICE_CONNECT_ROUTER_TIMEOUT = 148,
    
    // Device activation phase timeout (cloud connection phase timeout)
    THING_BLE_DEVICE_ACTIVE_TIMEOUT = 149,
    
    THING_BLE_FITTTING_CLOUDFAIL = 160,
    
    THING_BLE_FITTTING_DEVICENODE_FAIL = 161,
    
    // Device response OTA exception
    THING_BLE_OTA_DEVICE_STATE_FAIL = 200,
    
    // Device file verification failed
    THING_BLE_OTA_DEVICE_FILE_CHECK_FAIL,
    
    // Device offset exception
    THING_BLE_OTA_OFFSET_INDEX_FAIL,
    
    // Device returns large packet ACK failure
    THING_BLE_OTA_ACK_FAIL,
    
    // Firmware sending failure
    THING_BLE_OTA_SEND_FAIL,
    
    // Device ultimately returns upgrade failure
    THING_BLE_OTA_RESULT_FAIL,
    
    // OTA timeout
    BLE_OTA_TIME_OUT,
    
    // PID verification failed
    THING_BLE_OTA_PID_ERROR,
    
    // Large data transfer failure
    THING_BLE_BIGDATA_RESULT_FAIL,
    
    // BLEMesh proxy node configuration failed
    THING_BLE_MESH_PROXY_CONFIG_FAIL = 220,
    
    // BLEMesh proxy node configuration length error
    THING_BLE_MESH_PROXY_LEN_WRONG,
    
    // BLEMesh proxy node configuration illegal address
    THING_BLE_MESH_PROXY_ADDR_ILLEGAL,
    
    // BLEMesh proxy node configuration list storage full
    THING_BLE_MESH_PROXY_LIST_LIMIT,
    
    // BLEMesh proxy node configuration address does not exist
    THING_BLE_MESH_PROXY_ADDR_NOTEXIST,
    
    // BLEMesh proxy node does not exist
    THING_BLE_MESH_PROXY_NODE_NOTEXIST,
    
    // BLEMesh proxy node configuration unknown error
    THING_BLE_MESH_PROXY_ADDR_UNKNOW,
    
    // BLEMesh group operation failed
    THING_BLE_MESH_GROUP_OPREATION_FAIL = 230,
    
    // BLEMesh group operation length error
    THING_BLE_MESH_GROUP_OPREATION_LEN_WRONG,
    
    // BLEMesh group operation illegal address
    THING_BLE_MESH_GROUP_OPREATION_ADDR_ILLEGAL,
    
    // BLEMesh group address storage full
    THING_BLE_MESH_GROUP_OPREATION_LIST_LIMIT,
    
    // BLEMesh group operation timeout
    THING_BLE_MESH_GROUP_OPREATION_TIMEOUT,
    
    // BLEMesh group operation unknown error
    THING_BLE_MESH_GROUP_OPREATION_UNKNOW,
    
    THING_BLE_PACKAGE_MTP_ERROR = 300,
    
    THING_BLE_PP_SEND_DEV_ACTIVE_INFO_ERROR = 301,
    
    /// Gateway does not support Zigbee dual-mode configuration
    THING_BLE_ZIGBEE_GATEWAY_NOT_SUPPORET = 400,
    
    /// Received error from Zigbee sub-device device information
    THING_BLE_RECEIVE_ZIGBEE_INFO_FAIL = 401,
    
    /// Received error from Zigbee sub-device command information
    THING_BLE_RECEIVE_ZIGBEE_COMMAND_FAIL = 402,
    
    /// Received configuration error reported by Zigbee gateway
    THING_BLE_RECEIVE_ZIGBEE_GATEWAY_ERROR = 403,
    
    /// Received data parsing error reported by Zigbee gateway
    THING_BLE_RECEIVE_ZIGBEE_GATEWAY_INFO_ERROR = 404,
    
    /// Zigbee dual-mode configuration, failed to send gateway information
    THING_BLE_SEND_ZIGBEE_GATEWAY_INFO_FAIL = 405,
    
    /// Zigbee dual-mode configuration, device replies with invalid gateway information
    THING_BLE_SEND_ZIGBEE_GATEWAY_INFO_ERROR = 406,
    
    /// Parameter error
    THING_BLE_PARAM_ERROR = 407,
    
    /// Device not authorized
    THING_BLE_UUID_NO_EXIST = 420,
    
    /// Device is in OTA
    THING_BLE_INSTRUCTION_STATE_OTA_FAIL = 600,
    
    /// Device is in OTA
    THING_BLE_INSTRUCTION_OFFLINE_FAIL,
    
    THING_BLE_READ_BROADCAST_FAIL = 700,
    
    THING_BLE_FIND_CHARACTERISTIC_FAIL,
    
    // Scanned device, processing online logic, online timeout
    THING_BLE_ONLINE_TIMEOUT,
    
    THING_BLE_DEVICE_RESET,
    
    // Multiple connections triggered in a short time
    THING_BLE_CONNECT_BUSY = 704,
} ThingBLEErrorCode;

@interface NSError (BLEError)

+ (instancetype)thingsdk_BLEErrorWithErrorCode:(ThingBLEErrorCode)errorCode errorMsg:(NSString *)errorMsg;

+ (NSError *)thingsdk_BLEErrorWithErrorCode:(ThingBLEErrorCode)errorCode;

+ (NSError *)thingsdk_BLEDefaultErrorWithErrorCode:(ThingBLEErrorCode)errorCode;

+ (NSError *)errorWithErrorCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg;

// Expand the userInfo dictionary content in the old error
+ (NSError *)errorUpdateUserInfo:(NSDictionary *)addUserInfo withError:(NSError *)error;
@end
