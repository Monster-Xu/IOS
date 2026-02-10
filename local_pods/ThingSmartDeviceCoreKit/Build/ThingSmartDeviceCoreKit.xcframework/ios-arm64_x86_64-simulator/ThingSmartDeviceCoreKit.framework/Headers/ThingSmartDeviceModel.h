//
//  ThingSmartDeviceModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#ifndef ThingSmart_ThingSmartDeviceModel
#define ThingSmart_ThingSmartDeviceModel

#import "ThingSmartSchemaModel.h"
#import "ThingSmartDeviceModuleModel.h"
#import "ThingSmartStandSchemaModel.h"
#import "ThingSmartCommunication.h"
#import "ThingSmartThingModel.h"
#import "ThingSmartUIComponent.h"
#import "ThingSmartUIPanelModel.h"
#import "ThingSmartBleMeshV2Data.h"

/// The device types.
typedef enum : NSUInteger {
    
    /// Wi-Fi
    ThingSmartDeviceModelTypeWifiDev,
    
    /// Single Point Bluetooth Device
    ThingSmartDeviceModelTypeBle,
    
    /// GPRS
    ThingSmartDeviceModelTypeGprs,
    
    /// NB-IoT
    ThingSmartDeviceModelTypeNBIoT,
    
    /// Zigbee Gateway
    ThingSmartDeviceModelTypeZigbeeGateway,
        
    /// Zigbee subDevice
    ThingSmartDeviceModelTypeZigbeeSubDev,

    /// Mesh
    ThingSmartDeviceModelTypeMeshBleSubDev,
    
    /// Infrared gateway
    ThingSmartDeviceModelTypeInfraredGateway,
    
    /// Infrared subDevice
    ThingSmartDeviceModelTypeInfraredSubDev,
    
    /// Wi-Fi Gateway
    ThingSmartDeviceModelTypeWifiGateway,
    
    /// Wi-Fi subDevice
    ThingSmartDeviceModelTypeWifiSubDev,
    
    /// SIG Mesh Gateway
    ThingSmartDeviceModelTypeSIGMeshGateway,
    
    /// SIG Mesh subDevice
    ThingSmartDeviceModelTypeSIGMeshSubDev,

    /// Ble Beacon
    ThingSmartDeviceModelTypeBeacon,
    
    /// Cat.1
    ThingSmartDeviceModelTypeCat1,
    
    /// Thread gateway device
    ThingSmartDeviceModelTypeThreadGateway,
    
    /// Thread sub device
    ThingSmartDeviceModelTypeThreadSubDev,
    
    /// Fitting device
    ThingSmartDeviceModelTypeFitting,

} ThingSmartDeviceModelType;


typedef enum : NSUInteger {
    ThingSmartDeviceModeCapabilitylTypeWifi = 1 << 0,
    ThingSmartDeviceModeCapabilitylTypeCable = 1 << 1,
    ThingSmartDeviceModeCapabilitylTypeGPRS = 1 << 2,
    ThingSmartDeviceModeCapabilitylTypeNBIoT = 1 << 3,
    ThingSmartDeviceModeCapabilitylTypeBluetooth = 1 << 10,
    ThingSmartDeviceModeCapabilitylTypeBLEMesh = 1 << 11,
    ThingSmartDeviceModeCapabilitylTypeZigBee = 1 << 12,
    ThingSmartDeviceModeCapabilitylTypeInfrared = 1 << 13,
    ThingSmartDeviceModeCapabilitylTypeSubpieces433 = 1 << 14,
    ThingSmartDeviceModeCapabilitylTypeSigMesh = 1 << 15,
    ThingSmartDeviceModeCapabilitylTypeMCU = 1 << 16,
    ThingSmartDeviceModeCapabilitylTypeSMesh = 1 << 17,
    ThingSmartDeviceModeCapabilitylTypeCat1 = 1 << 20,
    ThingSmartDeviceModeCapabilitylTypeBeacon = 1 << 21,
    ThingSmartDeviceModeCapabilitylTypeThread = 1 << 25,
    ThingSmartDeviceModeCapabilitylTypePLC = 1 << 27,
    ThingSmartDeviceModeCapabilitylTypeWiSun = 1 << 28,
} ThingSmartDeviceModeCapabilitylType;


typedef enum : NSUInteger {
    ThingSmartDeviceModeProtocolAttributeTypeSigmesh = 1 << 0,
    ThingSmartDeviceModeProtocolAttributeTypeZigbee = 1 << 1,
    ThingSmartDeviceModeProtocolAttributeTypeSubpieces = 1 << 2,
    ThingSmartDeviceModeProtocolAttributeTypebeacon1 = 1 << 3,
    ThingSmartDeviceModeProtocolAttributeTypeThread = 1 << 4,
    ThingSmartDeviceModeProtocolAttributeTypeThingmesh = 1 << 5,
    ThingSmartDeviceModeProtocolAttributeTypeBle = 1 << 6,
    ThingSmartDeviceModeProtocolAttributeTypeBeacon2 = 1 << 7,
    ThingSmartDeviceModeProtocolAttributeTypeBleRoam = 1 << 8,
    ThingSmartDeviceModeProtocolAttributeTypeMatter = 1 << 9,
    ThingSmartDeviceModeProtocolAttributeTypePLC = 1 << 10,
    ThingSmartDeviceModeProtocolAttributeTypeWiSun = 1 << 11,

} ThingSmartDeviceModeProtocolAttributeType;

typedef NS_OPTIONS(NSUInteger, ThingSmartDeviceOnlineType) {
    /// Offline
    ThingSmartDeviceOnlineTypeOffline = 0,
    /// Wi-Fi online
    ThingSmartDeviceOnlineTypeWifi = 1 << 0,
    /// Local online
    ThingSmartDeviceOnlineTypeLan = 1 << 1,
    /// Bluetooth LE online
    ThingSmartDeviceOnlineTypeBLE = 1 << 2,
    /// Bluetooth LE mesh online
    ThingSmartDeviceOnlineTypeMeshBLE = 1 << 3,
    /// beacon online
    ThingSmartDeviceOnlineTypeBeacon = 1 << 4,
    /// dayu online
    ThingSmartDeviceOnlineTypeDaYu = 1 << 5,
    /// bt is connect
    ThingSmartDeviceOnlineTypeSysBT = 1 << 6
    
};

/// The information about the device.
@interface ThingSmartDeviceModel : NSObject

/// The ID of the device.
@property (nonatomic, strong) NSString     *devId;

/// The name of the device.
@property (nonatomic, strong) NSString     *name;

/// The URL of the device icon.
@property (nonatomic, strong) NSString     *iconUrl;

/// The capability of the device.
@property (nonatomic, assign) NSInteger    ability;

/// Specifies whether the device is online.
@property (nonatomic, assign) BOOL         isOnline;

/// Specifies whether the device is connected to the cloud.
@property (nonatomic, assign) BOOL         isCloudOnline;

/// Specifies whether the device is connected to the yu net.
@property (nonatomic, assign) BOOL         isYuOnline;

/// The online type of the device, it can be online on multiple types.
/// Recommended to use `(onlineType & ThingSmartDeviceOnlineTypeXXX) == YES` to judge.
@property (nonatomic, assign) ThingSmartDeviceOnlineType onlineType;

/// The communication information, the information about the gateway sub-devices and mesh-like device communication nodes, the communication priority, and the device connectivity.
@property (nonatomic, strong) ThingSmartCommunication *communication;

/// Specifies whether the device is shared.
@property (nonatomic, assign) BOOL         isShare;

@property (nonatomic, strong) NSString     *verSw;

/// The DP of the device.
@property (nonatomic, strong) NSDictionary *dps;

/// The DP execution time of the device.
@property (nonatomic, strong) NSDictionary *dpsTime;

/// The product ID.
@property (nonatomic, strong) NSString     *productId;

/// The product version.
@property (nonatomic, strong) NSString     *productVer;

/// Specifies whether to support groups.
@property (nonatomic, assign) BOOL         supportGroup;

/// Specifies whether to support standard groups.
@property (nonatomic, assign) BOOL         supportSGroup;

/// The type of gateway.
@property (nonatomic, strong) NSString     *gwType;

/// The protocol version of the gateway.
@property (nonatomic, assign) double       pv;

#if TARGET_OS_IOS

/// The LAN online status.
@property (nonatomic, assign) BOOL         isLocalOnline;

/// The LAN gateway protocol version.
@property (nonatomic, assign) double       lpv;

#endif

/// The hardware baseline version.
@property (nonatomic, assign) double       bv;

/// The latitude of the device.
@property (nonatomic, strong) NSString     *latitude;

/// The longitude of the device.
@property (nonatomic, strong) NSString     *longitude;

/// The DP name.
@property (nonatomic, strong) NSDictionary *dpName;

/// The schema of the device.
@property (nonatomic, strong) NSString     *schema;
@property (nonatomic, strong) NSDictionary *schemaDict;
@property (nonatomic, strong) NSString     *schemaExt;
@property (nonatomic, strong) NSArray<ThingSmartSchemaModel *> *schemaArray;

@property (nonatomic, strong) NSString     *runtimeEnv;

/// The attribute.
@property (nonatomic, assign) NSUInteger   attribute;

@property (nonatomic, strong) NSString     *localKey;

@property (nonatomic, strong) NSString     *secKey;

@property (nonatomic, strong) NSString     *uuid;

/// The media access control address.
@property (nonatomic, strong) NSString     *mac;

/// The network communication capability. Valid values: `0`: Wi-Fi. `1`: wired. `2`: GPRS. `3`: NB-IoT. `10`: Bluetooth. `11`: Bluetooth mesh. `12`: Zigbee.
@property (nonatomic, assign) NSUInteger   capability;

@property (nonatomic, strong) NSString     *timezoneId;

@property (nonatomic, assign) long long    homeId;
@property (nonatomic, assign) long long    roomId;
@property (nonatomic, assign) long long    sharedTime;

/// The order.
@property (nonatomic, assign) NSInteger    displayOrder;
@property (nonatomic, assign) NSInteger    homeDisplayOrder;

@property (nonatomic, strong) NSString     *ip;

/// The skills.
@property (nonatomic, strong) NSDictionary *skills;

@property (nonatomic, strong) NSString     *cloudId;

@property (nonatomic, strong) NSString     *cadv;

#pragma mark - panel

@property (nonatomic, assign) BOOL         rnFind;
@property (nonatomic, assign) long long    i18nTime;
@property (nonatomic, strong) NSString     *ui;
@property (nonatomic, strong) NSString     *uiId;
@property (nonatomic, strong) NSString     *uiVersion;
@property (nonatomic, strong) NSString     *uiPhase;
@property (nonatomic, strong) NSString     *uiType;
@property (nonatomic, strong) NSString     *uiName;
@property (nonatomic, strong) NSString     *uiBizClientId;
@property (nonatomic, strong) NSDictionary *uiConfig;
@property (nonatomic, strong) NSDictionary *panelConfig;
@property (nonatomic, strong) NSString     *category;
@property (nonatomic, strong) NSString     *categoryCode;
@property (nonatomic, strong) NSArray      *quickOpDps;
@property (nonatomic, strong) NSArray      *displayDps;
@property (nonatomic, strong) NSArray      *faultDps;
@property (nonatomic, strong) NSDictionary *displayMsgs;
@property (nonatomic, strong) NSString     *switchDp __deprecated_msg("Use switchDps instead");
@property (nonatomic, strong) NSArray<NSNumber *> *switchDps;

@property (nonatomic, strong) NSString     *content;
@property (nonatomic, strong) NSString     *fileSize;
@property (nonatomic, strong) NSString     *fileMd5;
@property (nonatomic, assign) NSInteger    rnBizPack;
@property (nonatomic, strong) NSArray<ThingSmartUIComponent *> *uiComponentList;

/// creates a dictionary containing entries constructed from `self.switchDps` and `self.dps`
- (NSDictionary<NSString *, NSNumber *> *)switchDpsMap;
/// return `or` operation on all values from `self.switchDpsMap`
- (BOOL)switchDpsValue;

/// creates a dictionary containing entries constructed from `self.switchDps` and `dps`
/// @param dps the dps which contains the dp value
- (NSDictionary<NSString *, NSNumber *> *)switchDpsMapFromDps:(NSDictionary<NSString *, id> *)dps;

/// return `or` operation on all values from  `self.switchDps` and `dps`
/// @param dps the dps which contains the dp value
- (BOOL)switchDpsValueFromDps:(NSDictionary<NSString *, id> *)dps;

@property (nonatomic, assign) BOOL         isNewFirmware;
@property (nonatomic, assign) NSTimeInterval activeTime;
@property (nonatomic, assign) long         errorCode;

@property (nonatomic, assign) ThingSmartDeviceModelType deviceType;
@property (nonatomic, assign) BOOL         upgrading  __deprecated_msg("Use ThingSmartDeviceOTAModel.otaUpgradeStatus instead");

@property (nonatomic, strong) NSDictionary *originJson;

@property (nonatomic, strong) ThingSmartDeviceModuleModel *moduleMap;

@property (nonatomic, assign) NSUInteger    bizAttribute;

@property (nonatomic, strong) NSDictionary *meta;

@property (nonatomic, strong) ThingSmartBleMeshV2Data *bleMeshV2Data;

- (BOOL)attributeIsSupport:(NSUInteger)i;
- (BOOL)capabilityIsSupport:(NSUInteger)i;
- (BOOL)devAttributeIsSupport:(NSUInteger)i;
- (BOOL)baseAttributeIsSupport:(NSUInteger)i;
- (BOOL)protocolAttributeIsSupport:(NSUInteger)i;

///  Update the value of a part properties of DeviceModel
///  This method will change the value of the originJson
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

#pragma mark - subdevice
/// The node ID.
@property (nonatomic, strong) NSString     *nodeId;
@property (nonatomic, strong) NSString     *parentId;
@property (nonatomic, strong) NSString *meshId;

/// The information about Bluetooth mesh.
@property (nonatomic, strong) NSString     *vendorInfo;
@property (nonatomic, assign) BOOL         isMeshBleOnline;
@property (nonatomic, strong) NSString     *pcc;

- (BOOL)isLoginMesh;
#pragma mark - discovery device
/// Mark:  0: 1<<0 auto. 3: 1<<3 route.
@property (nonatomic, assign) NSUInteger devAttribute;

/// The Bluetooth mesh device key.
@property (nonatomic, strong) NSString     *devKey;

/// Specifies whether to standardize the schema.
@property (nonatomic, assign) BOOL standard;
@property (nonatomic, strong) ThingSmartStandSchemaModel *standSchemaModel;

/// The DP codes.
@property (nonatomic, strong, readonly) NSDictionary *dpCodes;

/// The last DP update time.
@property (nonatomic, assign) NSTimeInterval dpMaxTime;

/// Specifies whether the device is a virtual device.
@property (nonatomic, assign) BOOL isVirtualDevice;

// Use `baseAttributeIsSupport: index` to check the feature.
//
// Index rules:
// 9: Thing Bluetooth mesh device.
// 10: supports network checks.
@property (nonatomic, assign) NSUInteger baseAttribute;

// Use `protocolAttributeIsSupport: index` to check the feature.
//
// Index rules:
// 0: supports the Bluetooth mesh feature.
// 1: supports the Zigbee feature.
// 2: supports the subpieces feature.
@property (nonatomic, assign) NSInteger protocolAttribute;

/// Specifies whether automatic updates are supported. Currently, NB-IoT and Bluetooth mesh devices do not support automatic updates.
@property (nonatomic, assign) BOOL supportAuto;

/// Supports the following over-the-air (OTA) update methods that are listed in descending priority from left to right:
/// `0`: Wi-Fi. `1`: Bluetooth LE. `2`: Bluetooth mesh. `3`: NB-IoT.
@property (nonatomic, strong) NSArray *otaUpgradeModes;

/// The Bluetooth connection configuration.
@property (nonatomic, strong) NSDictionary *configMetas;

/// The MatterNodeId.(Attention:when home changed,nodeId changed)
@property (nonatomic, assign) long long matterNodeId;

/// The device access type: 0-Thing, 1-Matter, 2-ThingLink
@property (nonatomic, assign) NSInteger accessType;

/// The device's thing model. ( for the device which accessType == 2)
/// Notice: If it return nil, you can get it from ` - getThingModelWithSuccess:failure:` or `+ getThingModelWithProductId:productVersion:success:failure:`.
@property (nonatomic, strong, nullable) ThingSmartThingModel *thingModel;

@property (nonatomic, assign, readonly) BOOL isOriginMatter;

/// Can be controlled with matter protocol.  Default is YES.
@property (nonatomic, assign) BOOL matterControlEnable;

/// The device experience.
@property (nonatomic, assign) BOOL virtualExperience;

/// mesh categroyExt
@property (nonatomic, strong) NSData *meshCategoryExt;

@property (nonatomic, assign) BOOL isProxyOpen;

@property (nonatomic, assign) BOOL isRelayOpen;

@property (nonatomic, assign) BOOL supportBLEGroup;

@property (nonatomic, assign) BOOL supportLongRange;
 
/// The device support thing model.
- (BOOL)isSupportThingModelDevice;

/// The device support matter protocol.
- (BOOL)isSupportMatter;

/// The device is thing.BLE & WIFI matter device
- (BOOL)isThingWIFIMatterDevice;


- (BOOL)isSupportProxyAndRelay;

// gateway support support dps
- (BOOL)isSupportedBLEStructDps;

//subdevice communication use gateway ble
- (BOOL)isCommunicationUseGatewayBle;

- (BOOL)isSupportCommunicationBleGateway;

- (ThingSmartUIPanelModel *)uiPanelModel;

- (void)subscribeWithSuccess:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

/// The device support new wake up flow.
- (BOOL)supportLowPowerWakeUp;

- (BOOL)hasCapabilityWithCapabilityType:(ThingSmartDeviceModeCapabilitylType)type;

- (BOOL)hasProtocolAttributeWithAttributeType:(ThingSmartDeviceModeProtocolAttributeType)type;

/// The device is matter third subDevice
- (BOOL)isMatterThirdSubDevice;

/// The device is matter third gateway device
- (BOOL)isMatterThirdGatewayDevice;


@end

#endif
