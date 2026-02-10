//
//  ThingBLECryptologyProtcol.h
//  ThingSmartBLEKit
//
//

#ifndef ThingBLECryptologyProtcol_h
#define ThingBLECryptologyProtcol_h
#import "ThingSmartBLEMutliTsfDefine.h"

@protocol ThingBLEDeviceInfoProtocol;

typedef enum : NSUInteger {
    ThingBLEConfigType_QRY_DEV_INFO        = 0,
    ThingBLEConfigType_PAIR                = 1,
    ThingBLEConfigType_CMD                 = 2,
    ThingBLEConfigType_STAT                = 3, //ALL_DP
    ThingBLEConfigType_SET_PWD             = 4,
    ThingBLEConfigType_UNPAIR              = 5,
    ThingBLEConfigType_RESET               = 6,
    ThingBLEConfigType_OTA_SINGLEBOOT      = 24,
    ThingBLEConfigType_OTA_START           = 12,
    ThingBLEConfigType_OTA_INFO            = 13,
    ThingBLEConfigType_OTA_INFO_AES        = 14,
    ThingBLEConfigType_OTA_INFO_ASY        = 15,
    ThingBLEConfigType_OTA_OFFSET          = 16,
    ThingBLEConfigType_OTA_DATA            = 17,
    ThingBLEConfigType_OTA_END             = 18,
    ThingBLEConfigType_OTA_SIGN_CHECK      = 0x0018,
    ThingBLEConfigType_OTA_SIGN_UPDATE     = 0x0019,
    ThingBLEConfigType_TEST                = 19,
    ThingBLEConfigType_FORCE_UNPAIR        = 20,
    ThingBLEConfigType_CERT_ONE            = 21,
    ThingBLEConfigType_CERT_TWO            = 22,
    ThingBLEConfigType_CERT_THREE          = 23,
    ThingBLEConfigType_PP_QUERY_INFO       = 26,
    ThingBLEConfigType_PP_ACTIVE_INFO      = 27,
    ThingBLEConfigType_PP_NET_INFO         = 28,
    ThingBLEConfigType_PRI_DATA_TRANS_INFO = 29,
    ThingBLEConfigType_PP_WIFI_STATE_REPORT= 30,
    ThingBLEConfigType_NET                 = 33,
    ThingBLEConfigType_NET_STATE           = 34,
    ThingBLEConfigType_DATA_TRANS          = 35,
    ThingBLEConfigType_DP_SEND_256         = 36,
    
    ThingBLEConfigType_ZIGBEE_GATEWAY_INFO = 64,
    ThingBLEConfigType_ZIGBEE_COMMAND      = 65,
    
    ThingBLEConfigType_AUDIO_VOICE_CONTROL = 48,
    ThingBLEConfigType_AUDIO_VOICE_ACK     = 49,
    ThingBLEConfigType_AUDIO_VOICE_RESULT  = 50,
    ThingBLEConfigType_AUDIO_SET_ALARM_CLOCK = 51,
    ThingBLEConfigType_AUDIO_GET_TOKEN     = 52,
    ThingBLEConfigType_AUDIO_TOKEN_REPORT  = 53,
    ThingBLEConfigType_AUDIO_TOKEN_ACK     = 54,
    ThingBLEConfigType_AUDIO_COMMON_CMD    = 55,
    
    ThingBLEConfigType_EXTMODULE_QUERY     = 80,
    ThingBLEConfigType_EXTMODULE_ACTIVE    = 81,
    
    ThingBLEConfigType_EXPAND              = 100,
    ThingBLEConfigType_ALL_DP              = 91,
    
    ThingBLEConfigType_BT_DEV_INFO         = 96,
    ThingBLEConfigType_SEND_FILE_INFO      = 112,
    ThingBLEConfigType_SEND_FILE_OFFSET    = 113,
    ThingBLEConfigType_SEND_FILE_DATA      = 114,
    ThingBLEConfigType_SEND_FILE_END       = 115,
    
    ThingBLEConfigType_MCU_STATE           = 8001,
    ThingBLEConfigType_DPTIME              = 8003,
    ThingBLEConfigType_MUT_DP              = 8004,
    ThingBLEConfigType_MUT_DPTIME          = 8005,
    ThingBLEConfigType_DP_256              = 8006,
    ThingBLEConfigType_DPTIME_256          = 8007,
    ThingBLEConfigType_TIMESTAMP1          = 8011,
    ThingBLEConfigType_TIMESTAMP2          = 8012,
    ThingBLEConfigType_APPTIME             = 8013,
    ThingBLEConfigType_SUMMER_TIME         = 8014,
    ThingBLEConfigType_WEATHER_REQ         = 8015,
    ThingBLEConfigType_WEATHER_ACK         = 8016,
    ThingBLEConfigType_WEATHER_LOCATION_REQ = 8017,
    ThingBLEConfigType_WEATHER_LOCATION_ACK = 8018,
    
    ThingBLEConfigType_ComboWireless_DownTransport = 0x801E,//combo wireless
    ThingBLEConfigType_ComboWireless_UpTransport = 0x801F,//combo wireless
    
    ThingBLEConfigType_QRY_IOT_DATA            = 8019,
    ThingBLEConfigType_SEND_IOT_DATA            = 32794,
    
    ThingBLEConfigType_SEND_TRANSPARENT_DATA_REQ = 32795,
    ThingBLEConfigType_SEND_TRANSPARENT_DATA_ACK = 32796,
    ThingBLEConfigType_REPORT_LINK_STATUS  = 8029,
    
    ThingBLEConfigType_BIGDATA_SUMMARY     = 7,
    ThingBLEConfigType_BIGDATA_BLOCKSUMMARY = 8,
    ThingBLEConfigType_BIGDATA_ACK          = 9,
    ThingBLEConfigType_BIGDATA_DEL        = 10,
    ThingBLEConfigType_BIGDATA_SYNC        = 11,
    
    ThingBLEConfigType_MOUNTINGSINFO_QUERY   = 0x8020,
    ThingBLEConfigType_MOUNTINGSINFO_ACK     = 0x8021,
    ThingBLEConfigType_MOUNTINGSINFO_ACTIVE  = 0x8022,
    ThingBLEConfigType_MOUNTINGSINFO_DP_CONTROL = 0x0028,
    ThingBLEConfigType_MOUNTINGSINFO_DP_QUERY = 0x0029,
    ThingBLEConfigType_MOUNTINGSINFO_DP_REPORT = 0x8008,
    ThingBLEConfigType_MOUNTINGSINFO_DP_TIME_REPORT = 0x8009,
    
    ThingBLEConfigType_MOUNTINGSINFO_OTA_START = 0x0080,
    ThingBLEConfigType_MOUNTINGSINFO_OTA_INFO = 0x0081,
    ThingBLEConfigType_MOUNTINGSINFO_OTA_OFFSET = 0x0082,
    ThingBLEConfigType_MOUNTINGSINFO_OTA_DATA = 0x0083,
    ThingBLEConfigType_MOUNTINGSINFO_OTA_END = 0x0084,
    
    ThingBLEConfigType_REMOTECONTROL_CERT           = 0x8030,
    ThingBLEConfigType_REMOTECONTROL_GROUP_ADD      = 0x8031,
    ThingBLEConfigType_REMOTECONTROL_GROUP_DEL      = 0x8032,
    ThingBLEConfigType_REMOTECONTROL_GROUP_QUERY    = 0x8033,
    ThingBLEConfigType_AUDIO_VOICE_CHATGPT_CONTROL = 0x0090,
    ThingBLEConfigType_AUDIO_VOICE_CHATGPT_ACK     = 0x0091,
    ThingBLEConfigType_AUDIO_VOICE_CHATGPT_RESULT  = 0x0092,
    ThingBLEConfigType_AUDIO_VOICE_CHATGPT_PUBLISH  = 0x0093,
    ThingBLEConfigType_LOCAL_KEYEXCHANGE       = 32,
    
} ThingBLEConfigType;

typedef NS_ENUM(NSUInteger, ThingBLETransSubCmd) {
    ThingBLETransSubCmd_BT_NET_CFG = 0x0001,   // psk3.0 0x0021, 
    ThingBLETransSubCmd_PP_NET_CFG = 0x0002,   // psk3.0 0x001C, plug&play
};

@protocol ThingBLECryptologyProtcol <NSObject>


- (NSData *)encodeWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                      configType:(ThingBLEConfigType)configType
                            data:(NSData *)data;

- (NSData *)decodeWithConfigType:(ThingBLEConfigType)configType
                            data:(NSData *)data;

- (NSData *)decodeWithData:(NSData *)data;

- (NSData *)decodeWithPlusType:(frame_type_t)plusType data:(NSData *)data;

+ (ThingBLEConfigType)protocolType2ConfigCharType:(frame_type_t)proType;

+ (ThingBLEConfigType)protocolType2ConfigType:(frame_sec_type_t)proType;

+ (frame_type_t)configCharType2ProtocolType:(ThingBLEConfigType)configType;

+ (frame_sec_type_t)configType2ProtocolType:(ThingBLEConfigType)configType;

@property (nonatomic, copy) NSString *localKey;
@property (nonatomic, copy) NSString *secretKey;
@property (nonatomic, copy) NSString *sessionKey;
@property (nonatomic, copy) NSString *sessionKeyHex;
@property (nonatomic, copy) NSString *deviceSrand;

@property (nonatomic, strong) NSString *sign;

@property (nonatomic, strong, nullable) NSString *secretKey1; // MD5(authKey)
@property (nonatomic, strong, nullable) NSString *secretKey1IVString; // 「secretKey1」iv

@property (nonatomic, assign) BOOL isHistoryConnectProcess;

- (void)updateSesssionKeyWith:(id<ThingBLEDeviceInfoProtocol>_Nullable)devInfo;

@end

#endif /* ThingBLECryptologyProtcol_h */
