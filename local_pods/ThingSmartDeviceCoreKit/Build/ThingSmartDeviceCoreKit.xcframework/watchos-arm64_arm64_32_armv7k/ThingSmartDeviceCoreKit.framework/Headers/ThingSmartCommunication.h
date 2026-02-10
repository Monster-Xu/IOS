//
//  ThingSmartCommunication.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The communication type.
typedef NS_ENUM(NSUInteger, ThingCommunicationType) {
    ThingCommunicationTypeLAN      = 0, // LAN
    ThingCommunicationTypeMQTT     = 1, // MQTT
    ThingCommunicationTypeHTTP     = 2, // Http
    ThingCommunicationTypeBLE      = 3, // Single Point Bluetooth
    ThingCommunicationTypeSIGMesh  = 4, // Sig Mesh
    ThingCommunicationTypeBLEMesh  = 5, // Thing Private Mesh
    ThingCommunicationTypeBLEBeacon  = 6, // Beacon
    ThingCommunicationTypeMatter    = 8,  // Matter
    ThingCommunicationTypeYuNetMqtt = 12,  // YuNet MQTT
    ThingCommunicationTypeCloudMode = 100, // Cloud Mode
};

/// The communication mode.
@interface ThingSmartCommunicationMode : NSObject

/// The communication protocol version.
@property (nonatomic, assign) double pv;

/// The communication protocol type.
@property (nonatomic, assign) ThingCommunicationType type;


@end

/// The device communication.
@interface ThingSmartCommunication : NSObject

/// The communication sequence.
@property (nonatomic, strong) NSArray<ThingSmartCommunicationMode *> *communicationModes;

/// The communication nodes.
@property (nonatomic, strong) NSString *communicationNode;

/// The connection status
/// CONNECT_BREAK(0)
/// CONNECTED(1)
/// NEARBY(2)
@property (nonatomic, assign) NSInteger connectStatus;

/// the local communication node
@property (nonatomic, strong) NSString *localCommunicationNode;
/// the local node node
@property (nonatomic, strong) NSString *localNodeId;
/// BLE Accessories / master-slave equipment
/// 1.BLE Accessories
/// 2.BLE master-slave equipment
@property (nonatomic, assign) NSInteger localDataModel;

///The data model.   1-DP Model, 2-Thing Model
@property (nonatomic, assign) NSInteger dataModel;

///The mqtt topic attribute. 0-Default 1-Thing-Link
@property (nonatomic, assign) long mqttTopicAttr;

@end

NS_ASSUME_NONNULL_END
