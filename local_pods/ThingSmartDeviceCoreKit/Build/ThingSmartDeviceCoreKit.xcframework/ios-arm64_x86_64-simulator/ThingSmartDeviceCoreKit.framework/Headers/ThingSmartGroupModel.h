//
//  ThingSmartGroupModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#ifndef ThingSmart_ThingSmartGroupModel
#define ThingSmart_ThingSmartGroupModel

/// The group type.
typedef enum : NSUInteger {
    ThingSmartGroupTypeWifi = 0,
    ThingSmartGroupTypeMesh,
    ThingSmartGroupTypeZigbee,
    ThingSmartGroupTypeSIGMesh,
    ThingSmartGroupTypeBeacon,
    ThingSmartGroupTypeMatter,
    ThingSmartGroupTypeThread,
    ThingSmartGroupTypeBeacon2,
    ThingSmartGroupTypeBLEMesh = 9,
} ThingSmartGroupType;

#import <Foundation/Foundation.h>
#import "ThingSmartDevice.h"

/// The group information.
@interface ThingSmartGroupModel : NSObject

@property (nonatomic, strong) NSString  *category;

/// The group ID.
@property (nonatomic, strong) NSString  *groupId;

/// The product ID.
@property (nonatomic, strong) NSString  *productId;

@property (nonatomic, strong) NSString *productVer;

/// The time when the group was created.
@property (nonatomic, assign) long long    time;

/// The name of the group.
@property (nonatomic, strong) NSString  *name;

/// The URL of the icon.
@property (nonatomic, strong) NSString  *iconUrl;

/// The type of group.
@property (nonatomic, assign) ThingSmartGroupType  type;

@property (nonatomic, assign) BOOL      isShare;

/// The DPs.
@property (nonatomic, strong) NSDictionary *dps;

/// The DP codes.
@property (nonatomic, strong) NSDictionary *dpCodes;

/// The local key.
@property (nonatomic, strong) NSString     *localKey;

/// The protocol version.
@property (nonatomic, assign) double        pv;

/// The number of devices,
@property (nonatomic, assign) NSInteger    deviceNum;

/// The product information.
@property (nonatomic, strong) NSDictionary *productInfo;

/// The home ID.
@property (nonatomic, assign) long long    homeId;

/// The room ID.
@property (nonatomic, assign) long long    roomId;

/// The custom DP name.
@property (nonatomic, copy)   NSDictionary *dpName;

/// The order.
@property (nonatomic, assign) NSInteger displayOrder;

/// The order of all home groups.
@property (nonatomic, assign) NSInteger homeDisplayOrder;

/// The device list.
@property (nonatomic, strong) NSArray<ThingSmartDeviceModel *> *deviceList;

/// The local short address of groups.
@property (nonatomic, strong) NSString     *localId;

/// The subclass.
@property (nonatomic, strong) NSString     *pcc;

/// The mesh ID or gateway ID.
@property (nonatomic, strong) NSString     *meshId;

/// The schema array.
@property (nonatomic, strong) NSArray      *schemaArray;

/// Indicates whether the standard DP ID is used.
@property (nonatomic, assign) BOOL         standard;

/// The standard schema.
@property (nonatomic, strong, readonly) ThingSmartStandSchemaModel *standSchemaModel;

// Add the beacon beaconKey.
@property (nonatomic, strong) NSString *groupKey;

//meta dictionary
@property (nonatomic, strong, readonly) NSDictionary *groupMetaDictionary;


@end

#endif
