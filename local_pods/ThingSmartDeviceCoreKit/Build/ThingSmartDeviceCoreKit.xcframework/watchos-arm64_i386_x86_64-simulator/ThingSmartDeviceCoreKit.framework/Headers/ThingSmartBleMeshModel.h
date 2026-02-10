//
//  ThingSmartBleMeshModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#ifndef ThingSmart_ThingSmartBleMeshModel
#define ThingSmart_ThingSmartBleMeshModel

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ThingSmartMeshType) {
    ThingSmartMeshTypeUnknow = 0,
    ThingSmartMeshTypeBLEMesh,
    ThingSmartMeshTypeSigMesh,
    ThingSmartMeshTypeBeaconMesh,
    ThingSmartMeshTypeBLEMeshV2,
};

@interface ThingSmartBleMeshModel : NSObject

// The generic mesh information.
@property (nonatomic, strong) NSString     *name;

// The mesh ID.
@property (nonatomic, strong) NSString     *meshId;

// The local key.
@property (nonatomic, strong) NSString     *localKey;

//The protocol version.
@property (nonatomic, strong) NSString     *pv;

@property (nonatomic, strong) NSString     *code;

@property (nonatomic, strong) NSString     *password;

@property (nonatomic, assign) BOOL         share;

@property (nonatomic, assign) long long    homeId;

// --------- The Bluetooth mesh information
@property (nonatomic, strong) NSString *netKey;

@property (nonatomic, strong) NSString *appKey;

@property (nonatomic, strong) NSString *meshKey;

@property (nonatomic, strong) NSString *networkKey;

//sigmesh ivIndex
@property (nonatomic, assign) NSInteger ivIndex;

@property (nonatomic, assign) ThingSmartMeshType meshType;

@end

#endif
