//
//  ThingSmartDeviceModuleModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#ifndef ThingSmart_BleMeshSubDeviceModuleModel
#define ThingSmart_BleMeshSubDeviceModuleModel

#import <Foundation/Foundation.h>
#import "ThingSmartDeviceModelUtils.h"

/// The microcontroller unit (MCU) device.
@interface ThingSmartDeviceMcuModel : NSObject

@property (nonatomic, assign) BOOL     isOnline;
@property (nonatomic, strong) NSString *verSw;

@property (nonatomic, strong) NSString     *bv;
@property (nonatomic, strong) NSString     *pv;
@property (nonatomic, strong) NSString     *type;
@property (nonatomic, assign) ThingSmartDeviceUpgradeStatus upgradeStatus;

@end

/// The Zigbee device.
@interface ThingSmartDeviceZigbeeModel : NSObject

@property (nonatomic, assign) BOOL     isOnline;
@property (nonatomic, strong) NSString *verSw;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) ThingSmartDeviceUpgradeStatus upgradeStatus;

@end

/// The Bluetooth device.
@interface ThingSmartDeviceBluetoothModel : NSObject

@property (nonatomic, assign) BOOL          isOnline;
@property (nonatomic, strong) NSString      *verSw;
@property (nonatomic, strong) NSString      *pv;
@property (nonatomic, strong) NSString      *type;
@property (nonatomic, assign) ThingSmartDeviceUpgradeStatus upgradeStatus;

@end

/// The Wi-Fi device.
@interface ThingSmartDeviceWifiModel : NSObject

@property (nonatomic, assign) BOOL         isOnline;
@property (nonatomic, strong) NSString     *bv;
@property (nonatomic, strong) NSString     *pv;
@property (nonatomic, strong) NSString     *verSw;
@property (nonatomic, strong) NSString     *cadv;
@property (nonatomic, strong) NSString     *cdv;
@property (nonatomic, strong) NSString     *type;
@property (nonatomic, assign) ThingSmartDeviceUpgradeStatus upgradeStatus;

@end

/// The infrared device.
@interface ThingSmartDeviceInfraredModel : NSObject

@property (nonatomic, assign) BOOL         isOnline;
@property (nonatomic, strong) NSString     *verSw;
@property (nonatomic, strong) NSString     *cadv;
@property (nonatomic, strong) NSString     *cdv;
@property (nonatomic, strong) NSString     *type;
@property (nonatomic, assign) ThingSmartDeviceUpgradeStatus upgradeStatus;

@end

/// The GPRS device.
@interface ThingSmartDeviceGprsModel : NSObject

@property (nonatomic, assign) BOOL         isOnline;
@property (nonatomic, strong) NSString     *bv;
@property (nonatomic, strong) NSString     *pv;
@property (nonatomic, strong) NSString     *verSw;
@property (nonatomic, strong) NSString     *type;
@property (nonatomic, assign) ThingSmartDeviceUpgradeStatus upgradeStatus;

@end

/// The subpieces.
@interface ThingSmartDeviceSubpiecesModel : NSObject

@property (nonatomic, assign) BOOL         isOnline;
@property (nonatomic, strong) NSString     *verSw;
@property (nonatomic, strong) NSString     *type;
@property (nonatomic, assign) ThingSmartDeviceUpgradeStatus upgradeStatus;

@end

@interface ThingSmartDeviceSMeshModel : NSObject

@property (nonatomic, assign) BOOL     isOnline;
@property (nonatomic, strong) NSString *verSw;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) ThingSmartDeviceUpgradeStatus upgradeStatus;

@end

/// The NB-IoT device.
@interface ThingSmartDeviceNBIoTModel : NSObject

@property (nonatomic, assign) BOOL         isOnline;
@property (nonatomic, strong) NSString     *bv;
@property (nonatomic, strong) NSString     *pv;
@property (nonatomic, strong) NSString     *verSw;
@property (nonatomic, strong) NSString     *type;
@property (nonatomic, assign) NSInteger    upgradeStatus;

@end

/// The device module.
@interface ThingSmartDeviceModuleModel : NSObject

@property (nonatomic, strong) ThingSmartDeviceWifiModel           *wifi;
@property (nonatomic, strong) ThingSmartDeviceNBIoTModel          *nbIot;
@property (nonatomic, strong) ThingSmartDeviceBluetoothModel      *bluetooth;
@property (nonatomic, strong) ThingSmartDeviceMcuModel            *mcu;
@property (nonatomic, strong) ThingSmartDeviceGprsModel           *gprs;
@property (nonatomic, strong) ThingSmartDeviceZigbeeModel         *zigbee;
@property (nonatomic, strong) ThingSmartDeviceInfraredModel       *infrared;
@property (nonatomic, strong) ThingSmartDeviceSubpiecesModel      *subpieces;
@property (nonatomic, strong) ThingSmartDeviceSMeshModel          *smesh;

@end

#endif
