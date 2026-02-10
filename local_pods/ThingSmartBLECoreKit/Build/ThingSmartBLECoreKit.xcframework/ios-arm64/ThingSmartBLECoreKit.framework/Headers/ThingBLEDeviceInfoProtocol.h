//
//  ThingBLEDeviceInfoProtocol.h
//  Pods
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)
//  

#ifndef ThingBLEDeviceInfoProtocol_h
#define ThingBLEDeviceInfoProtocol_h

#import "ThingBLEActiveProtocol.h"
#import "ThingBLEConfigProtocol.h"

#import <ThingBluetooth/ThingBluetooth.h>

typedef void (^ThingBLEBigDataProgressBlock)(float progress);

typedef enum : NSUInteger {
    ThingBLEEncryptTypeNormal = 1,
    ThingBLEEncryptTypeAdvanced,  
} ThingBLEEncryptType;

typedef enum : NSUInteger {
    ThingSmartBLEDeviceStateUnactive = 1,
    ThingSmartBLEDeviceStateUnstable,    
    ThingSmartBLEDeviceStateActived,     
    ThingSmartBLEDeviceStateReconnect,   
    ThingSmartBLEDeviceStateOTA,         
    ThingSmartBLEDeviceStateOffline,     
} ThingSmartBLEDeviceState;

typedef enum : NSUInteger {
    ThingSmartBLEBusinessTypeDefault = 0,
    ThingSmartBLEBusinessTypeMulitUser,  
} ThingSmartBLEBusinessType;

typedef enum : NSUInteger {
    ThingBLEAdvIDTypeUUID      = 0,
    ThingBLEAdvIDTypeMac       = 1,
} ThingBLEAdvIDType;

@protocol ThingBLEConfigProtocol;
@protocol ThingBLEDeviceInfoProtocol <NSObject>

@property (nonatomic, strong) ThingBLEAgent *agent;

@property (nonatomic, assign) ThingSmartBLEDeviceState state;

@property (nonatomic, strong) NSString            *uuid;
@property (nonatomic, strong) NSString            *mac;
@property (nonatomic, strong) NSString            *devId;
@property (nonatomic, strong) NSString            *pid;
@property (nonatomic, strong) NSString            *pairUuid;

@property (atomic, strong) ThingBLEPeripheral     *peripheral;
@property (nonatomic, strong) ThingBLEAdvModel       *advModel;
@property (nonatomic, assign) ThingBLEAdvIDType      IDType;

@property (nonatomic, assign) int32_t             sn;
@property (nonatomic, assign) int32_t             ack;

@property (nonatomic, strong) NSDictionary        *schemaDict;

@property (nonatomic, strong) ThingBLECharacteristic *notifyCharacteristic;
@property (nonatomic, strong) ThingBLECharacteristic *writeCharacteristic;
@property (nonatomic, strong) ThingBLECharacteristic *otaCharacteristic;

@property (nonatomic, assign) BOOL                bondState;   
@property (nonatomic, assign) BOOL                isSIGMesh;

@property (nonatomic, assign) NSTimeInterval      activeTime;

// bleSecret
@property (nonatomic, assign) ThingBLEEncryptType      encryptType;
@property (nonatomic, assign) ThingSmartBLEBusinessType businessType;

@property (nonatomic, strong) NSMutableDictionary *bizExt;

@property (nonatomic, assign) BOOL        certCheck;            ///< Whether cloud-based mutual certificate verification is required (protocol version above 4.0)
@property (nonatomic, assign) BOOL        advanceEncrypt;       ///< Whether advanced encryption (mutual authentication) is supported (protocol version above 4.0)
@property (nonatomic, assign) BOOL        isSupportBeaconkey;   ///< Whether beaconKey needs to be obtained

//==== Plug&Play dual-mode fields ======= //
@property (nonatomic, assign) BOOL        isBLEChannelFirst; ///< Is the Bluetooth channel the highest priority
@property (nonatomic, assign) BOOL        isSupportPlugPlay; ///< Does the device support Plug&Play
@property (nonatomic, strong) NSString    *bleMac;    ///<  ble device  mac
@property (nonatomic, strong) NSString    *zigbeeMac; ///<  zigbee device mac
@property (nonatomic, assign) NSInteger networkStatus;// Network status reported by dual-mode device

// Security protocol version
@property (nonatomic, assign) int                 bleProtocolV;

@property (nonatomic, assign) NSUInteger          maxMtuLen;

@property (nonatomic, strong) NSString            *pv;

@property (nonatomic, strong) NSString            *dv;  ///< Hardware version number 1: Take the high 2 bits of hardware version number 2, e.g., v1.1
@property (nonatomic, strong) NSString            *dv2; ///< Hardware version number 2: e.g., 0x010000 represents v1.1.0
@property (nonatomic, strong) NSString            *sv;  ///< Firmware version number 1: Take the high 2 bits of firmware version number 2, e.g., V1.2
@property (nonatomic, strong) NSString            *sv2; ///< Firmware version number 2: e.g., 0x010200 represents v1.2.0
@property (nonatomic, assign) BOOL                use_sv2;///< Whether to use sv2 for firmware version? true = sv2 false = sv
@property (nonatomic, assign) BOOL                use_dv2;///< Whether to use dv2 for hardware version? true = dv2 false = dv
@property (nonatomic, strong) NSString            *mcuDv; ///< MCU hardware version number
@property (nonatomic, strong) NSString            *mcuSv; ///< MCU firmware version number
@property (nonatomic, strong) NSString            *authKey; ///< MCU firmware version number


@property (nonatomic, strong) NSMutableArray      *channel_modules; // Supported channel modules of the device
@property (nonatomic, strong) NSString            *bleCapability;/// Bluetooth capability
@property (nonatomic, assign) NSUInteger          packetMaxSize; /// Maximum length of application layer packet fragmentation
@property (nonatomic, assign) BOOL                isLinkEncrypt; /// Whether the current Bluetooth connection has LINK layer encryption
@property (nonatomic, assign) BOOL                isForceLinkDevice; /// Whether to enforce LINK layer encryption
@property (nonatomic, assign) BOOL                isSecurityLevelDevice; /// Whether security level configuration is required
@property (nonatomic, strong) NSNumber            *slValue;  /// Security level
@property (nonatomic, assign) BOOL                isSupportFitting;  /// Whether Bluetooth accessories are supported
@property (nonatomic, strong) NSDictionary        *fittingSchemaDict; // Schema array for accessories

@property (nonatomic, assign) BOOL                isSupportQueryWifiList; /// Whether to support querying WiFi list
@property (nonatomic, assign) BOOL                isSupportReportConfigState; /// Whether to support actively reporting network configuration state code

@property (nonatomic, assign) BOOL                isSupportUploadDeviceLog; /// Whether to support log collection and transmission
///////// Whether the device supports roaming
@property (nonatomic, assign) BOOL              isRoaming; // Whether roaming protocol is supported

@property (nonatomic, assign) BOOL        isSupportQueryExtraNetCapbility;  // Whether to support  querying ExtraNet

@property (nonatomic, assign) BOOL        isQueryExtraNetCapbility;


@property (nonatomic, assign) BOOL isExecutedV2Secret;  // Whether the device broadcast packet has executed V2 command
@property (nonatomic, assign) BOOL isSupportV2Secret;  // Whether the device broadcast packet supports V2 command

@property (nonatomic, assign) BOOL        isSupportMasterSlaveDevice; // Whether master-slave integration scheme is supported

@property (nonatomic, assign) BOOL isCloudSynch;

// Used to mark whether the connection was made from the system Bluetooth
@property (nonatomic, assign) BOOL isFromeSysBle;

@property (nonatomic, assign) BOOL isSupportLan;    //是否支持WIFI局域网通信能力
// Whether single-zone upgrade is supported
@property (nonatomic, assign) BOOL bootOTASupport;
// Whether a single-zone upgrade is in progress
@property (nonatomic, assign) BOOL bootOTABeing;

@property (nonatomic, assign) BOOL isSupportLongRange;
//voice sn
@property (nonatomic, assign) int voiceSn;

@property (nonatomic, assign) BOOL isSupportBLEMeshCtrl;

@property (nonatomic, strong) NSString *nodeId;

- (void)handlePeripheral:(ThingBLEPeripheral *)peripheral;

- (void)updateActiveEvent;

- (void)configSchemaDict:(NSString *)json;

- (void)configFittingSchemaDict:(NSString *)json;

@property (nonatomic, strong) id<ThingBLEActiveProtocol> activeManager;

@property (nonatomic, strong) id<ThingBLEActiveProtocol, ThingLocalBLEActiveProtocol> localActiveMgr;

@property (nonatomic, strong) id<ThingBLEConfigProtocol> configManager;

@end


#endif /* ThingBLEDeviceInfoProtocol_h */
