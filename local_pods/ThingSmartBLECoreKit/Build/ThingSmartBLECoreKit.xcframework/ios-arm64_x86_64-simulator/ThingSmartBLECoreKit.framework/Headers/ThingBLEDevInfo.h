//
//  ThingBLEDevInfo.h
//  ThingSmartKit
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.thing.com)
//

@interface ThingBLEDevInfo : NSObject

/**
 *  Device information model for the old protocol
 */
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *sv;
@property (nonatomic, strong) NSString *pv;
@property (nonatomic, strong) NSString *authKey;
@property (nonatomic, strong) NSString *randomHex;
@property (nonatomic, strong) NSString *random;

@end

/** 
 *  Device information model for the security protocol
 */
@interface ThingBLESecurityDevInfo : NSObject

@property (nonatomic, strong) NSString    *uuid;
@property (nonatomic, strong) NSString    *dv;  // Hardware version number 1: take the high 2 bits of hardware version number 2, e.g., v1.1
@property (nonatomic, strong) NSString    *dv2; // Hardware version number 2: e.g., 0x010000 represents v1.1.0
@property (nonatomic, strong) NSString    *sv;  // Firmware version number 1: take the high 2 bits of firmware version number 2, e.g., V1.2
@property (nonatomic, strong) NSString    *sv2; // Firmware version number 2: e.g., 0x010200 represents v1.2.0
@property (nonatomic, assign) BOOL        use_sv2; // Whether to use sv2 for firmware version? true = sv2 false = sv
@property (nonatomic, assign) BOOL        use_dv2; // Whether to use dv2 for hardware version? true = dv2 false = dv
@property (nonatomic, strong) NSString    *pv;  // Protocol version
@property (nonatomic, strong) NSString    *flag;
@property (nonatomic, strong) NSString    *bleType;
@property (nonatomic, assign) BOOL        bond;
@property (nonatomic, strong) NSString    *srand;
@property (nonatomic, strong) NSString    *authKey; // Actually corresponds to the secretKey obtained from the cloud for authKey
@property (nonatomic, strong) NSString    *ability; // Communication capability
@property (nonatomic, strong) NSString    *devId; // Device virtual ID
@property (nonatomic, strong) NSString    *mcuDv; // MCU hardware version number
@property (nonatomic, strong) NSString    *mcuSv; // MCU firmware version number
@property (nonatomic, strong) NSString    *bleMac; // BLE MAC
@property (nonatomic, strong) NSString    *zigbeeMac; // Zigbee sub-device MAC
@property (nonatomic, strong) NSMutableArray *channel_modules; // Supported channel modules of the device
@property (nonatomic, assign) BOOL        isSupportRegisterKey; // Whether registerKey is supported
@property (nonatomic, assign) BOOL        isSupportPlugPlay; // Whether Plug&Play is supported
@property (nonatomic, assign) BOOL        certCheck; // Whether cloud-based mutual certificate verification is required (protocol version above 4.0)
@property (nonatomic, assign) BOOL        advanceEncrypt; // Whether advanced encryption (mutual authentication) is supported (protocol version above 4.0)
@property (nonatomic, assign) BOOL        isSupportBeaconkey; // Whether beaconKey needs to be obtained
@property (nonatomic, strong) NSString    *bleCapability; // Bluetooth capability
@property (nonatomic, assign) NSInteger   packetMaxSize; // Maximum length of application layer packet fragmentation
@property (nonatomic, assign) BOOL        isLinkEncrypt; // Whether the current Bluetooth connection has LINK layer encryption
@property (nonatomic, assign) BOOL        isForceLinkDevice; // Whether to enforce LINK layer encryption
@property (nonatomic, assign) BOOL        isSecurityLevelDevice; // Whether security level configuration is required

@property (nonatomic, assign) BOOL isSupportLan;    //是否支持WIFI局域网通信能力

@property (nonatomic, assign) BOOL        isSupportQueryWifiList; // Whether to support querying Wi-Fi list
@property (nonatomic, assign) BOOL        isSupportReportConfigState; // Whether to support actively reporting network configuration state code

@property (nonatomic, assign) BOOL        isSupportUploadDeviceLog; // Whether to support log collection and transmission

@property (nonatomic, assign) BOOL        isSupportQueryExtraNetCapbility;  // Whether to support  querying ExtraNet
@property (nonatomic, assign) BOOL        isQueryExtraNetCapbility;


@property (nonatomic, assign) BOOL        isSupportFitting; // Whether Bluetooth accessories are supported
@property (nonatomic, strong) NSNumber    *slValue; // Security level
@property (nonatomic, assign) BOOL        isExecutedV2Secret; // Whether the device broadcast packet has executed V2 command
@property (nonatomic, assign) BOOL        isSupportV2Secret; // Whether the device broadcast packet supports V2 command
@property (nonatomic, assign) BOOL        isSupportMasterSlaveDevice; // Whether master-slave device is supported

// Whether single-zone upgrade is supported
@property (nonatomic, assign) BOOL        bootOTASupport;
// Whether a single-zone upgrade is in progress
@property (nonatomic, assign) BOOL        bootOTABeing;

@property (nonatomic, assign) BOOL        isSupportLongRange;

@property (nonatomic, assign) BOOL        isSupportBLEMeshCtrl;

@property (nonatomic, copy) NSString      *nodeId;

@end

@interface ThingBLEPlugPlayDevInfo : NSObject

/**
 *  Device information model for devices that support PlugPlay
 */
@property (nonatomic, strong) NSString      *version;               /// Instruction version number
@property (nonatomic, strong) NSString      *protocolVer;           /// Wi-Fi protocol version
@property (nonatomic, assign) NSUInteger    devAttribute;           /// Device capability
@property (nonatomic, strong) NSString      *baselineVer;           /// Baseline version
@property (nonatomic, strong) NSString      *softVer;               /// Firmware version number
@property (nonatomic, strong) NSString      *cadVer;                /// CAD version
@property (nonatomic, strong) NSString      *cdVer;
@property (nonatomic, strong) NSString      *modules_softVer;       /// MCU software version
@property (nonatomic, assign) NSUInteger    modules_otaChannel;     /// MCU upgrade channel
@property (nonatomic, assign) BOOL          modules_online;         /// Online status, 1 byte, 0 – false, 1 – true
@property (nonatomic, assign) BOOL          options_isFK;           /// Whether OEM, 1 byte, 0 – false, 1 – true
@property (nonatomic, assign) NSUInteger    options_otaChannel;     /// Wi-Fi firmware upgrade channel
@property (nonatomic, strong) NSString      *options_udf;           /// Wi-Fi firmware upgrade channel
@property (nonatomic, assign) BOOL          isSupportSchema;        /// bit0 Whether schema is needed, 0 – not needed, 1 – needed
@property (nonatomic, assign) int           packetMaxSize;          /// Maximum length for fragmentation when sending device activation information
@property (nonatomic, strong) NSString      *productkey;            /// Product ID
@property (nonatomic, strong) NSString      *productkeyStr;         /// Firmware key
@property (nonatomic, strong) NSString      *devId;                 /// Device ID
@property (nonatomic, strong) NSString      *hid;                   /// MAC address
@property (nonatomic, strong) NSString      *uuid;                  /// Device UUID
@property (nonatomic, strong, nullable) NSString *communicatePriority;   /// Priority

@end
