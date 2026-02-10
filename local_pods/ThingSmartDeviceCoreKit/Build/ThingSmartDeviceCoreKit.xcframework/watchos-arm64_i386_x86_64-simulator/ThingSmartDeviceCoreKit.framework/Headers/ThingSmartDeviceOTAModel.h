//
//  ThingSmartDeviceOTAModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The device update status.
typedef enum : NSUInteger {
    /// Not updating.
    ThingSmartDeviceOTAModelUpgradeStatusNone = 0,
    /// Updating.
    ThingSmartDeviceOTAModelUpgradeStatusUpgrading = 2
} ThingSmartDeviceOTAModelUpgradeStatus;

typedef NS_ENUM(NSInteger, ThingSmartDeviceCapability){
    ThingSmartDeviceCapabilityOTAControlDP = 0, //!< bit0
    ThingSmartDeviceCapabilityUseLEOnline,      //!< bit1
    ThingSmartDeviceCapabilityBeacon,           //!< bit2
    ThingSmartDeviceCapabilityLinkEncrypt,      //!< bit3
    ThingSmartDeviceCapabilityExtend,           //!< bit4
    ThingSmartDeviceCapabilityTimer,            //!< bit5
    ThingSmartDeviceCapabilityLinkBT = 6,       //!< bit6
    ThingSmartDeviceCapabilityForceLink,        //!< bit7
    ThingSmartDeviceCapabilitySupportPSK,       //!< bit8
    ThingSmartDeviceCapabilitySupportFitting,   //!< bit9
    ThingSmartDeviceCapabilityDiffOTA,          //!< bit10
    ThingSmartDeviceCapabilityConnectivityGateway, //!< bit11
    ThingSmartDeviceCapabilityConnectivityIphone,  //!< bit12
    ThingSmartDeviceCapabilityGatewayConnect,   //!< bit13
    ThingSmartDeviceCapabilityOnlineType,       //!< bit14
    ThingSmartDeviceCapabilityDpSendByTransparentCmd = 19, //!< bit19, 0: 0x0002 / 0x0027, 1: 0x801B_0x000c
    ThingSmartDeviceCapabilityLongRange,        //!< bit20
    ThingSmartDeviceCapabilityBLEMeshCtrl,      //!< bit21
};

typedef enum : NSUInteger {
    ThingSmartDeviceConnectivityTypeIphone = 0,
    ThingSmartDeviceConnectivityTypeGateWay = 1,
    ThingSmartDeviceConnectivityTypeIphoneAndGateWay = 2,
} ThingSmartDeviceConnectivityType;


@interface ThingSmartDeviceOTAModel : NSObject

/// The device ID.
@property (nonatomic, strong) NSString     *devId;

@property (nonatomic, strong) NSString     *ssidHash;

/// The status of device updates.
@property (nonatomic) ThingSmartDeviceOTAModelUpgradeStatus otaUpgradeStatus;
 
// Adds a beacon category for the Bluetooth LE beacon device.
@property (nonatomic, strong) NSString     *beaconCategory;

@property (nonatomic, strong) NSString *beaconKey;

@property (nonatomic, strong) NSString *bluetoothCapability;

@property (nonatomic, strong) NSString *bleMeshV2Data;

//Bluetooth gateway sub-device ota capability
@property (nonatomic, strong) NSNumber *gwBTSubDevOtaCap;

@property (nonatomic, assign) BOOL zigbeeInstallCode;

@property (nonatomic, assign) NSTimeInterval cloudConnectLastUpdateTime;
@property (nonatomic, assign) NSTimeInterval localConnectLastUpdateTime;

@property (nonatomic, assign) NSInteger yuNetState;

- (BOOL)deviceCapabilitySupport:(ThingSmartDeviceCapability)capability;

- (BOOL)bluetoothCapabilityOfIndex:(NSInteger)index DEPRECATED_MSG_ATTRIBUTE("Please use deviceCapabilitySupport: instead");


/// if the current gateway supports sub-device upgrade, return YES.
/// - Parameter type: Only support `ThingSmartDeviceModelTypeBle` and `ThingSmartDeviceModelTypeSIGMeshSubDev`
- (BOOL)isGatewaySubDevOTASupported:(ThingSmartDeviceModelType)type;

- (ThingSmartDeviceConnectivityType)blueConnectivitySupport;
@end

NS_ASSUME_NONNULL_END
