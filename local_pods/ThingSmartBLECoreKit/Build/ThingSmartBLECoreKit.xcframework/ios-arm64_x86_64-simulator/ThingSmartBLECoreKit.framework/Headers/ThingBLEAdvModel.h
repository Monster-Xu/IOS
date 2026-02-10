//
// ThingBLEAdvModel.h
// ThingSmartBLEKit
//
// Copyright (c) 2014-2021 Thing Inc. (https://developer.thing.com)

/// The different types of Bluetooth LE devices.
typedef enum : NSUInteger {
    /// The unknown type of Bluetooth LE device.
    ThingSmartBLETypeUnknow = 1,
    /// The type of Bluetooth LE device that supports an earlier protocol. The device does not support a security protocol.
    ThingSmartBLETypeBLE,
    /// The type of Bluetooth LE device that supports an earlier protocol of a lower security level.
    ThingSmartBLETypeBLEPlus,
    /// The type of Bluetooth LE device that supports an earlier protocol. The device does not support a security protocol.
    ThingSmartBLETypeBLEWifi,
    /// The type of Bluetooth LE device that supports a later protocol of a higher security level.
    ThingSmartBLETypeBLESecurity,
    /// The type of Bluetooth LE dual-mode device that supports a later protocol of a higher security level.
    ThingSmartBLETypeBLEWifiSecurity,
    /// The type of Bluetooth LE dual-mode device that supports a later protocol of a higher security level and that supports the plug and play (PnP) function.
    ThingSmartBLETypeBLEWifiPlugPlay,
    /// The type of Bluetooth LE and Zigbee dual-mode device that supports a later protocol of a higher security level.
    ThingSmartBLETypeBLEZigbee,
    /// The type of Bluetooth LE and LTE Category 1 dual-mode device that supports a later protocol of a higher security level.
    ThingSmartBLETypeBLELTESecurity,
    /// The beacon security.
    ThingSmartBLETypeBLEBeacon,
    /// Same as the ThingSmartBLETypeBLEWifiPlugPlay, but BLE is prior while configing.
    ThingSmartBLETypeBLEWifiPriorBLE,
} ThingSmartBLEType;

/// The communication capability of Bluetooth LE devices.
typedef NS_OPTIONS(NSUInteger, ThingSmartBLECommunicationCapability) {
    ThingSmartBLECommunicationCapabilityNone = 0,
    /// Register and bind devices through BLE
    ThingSmartBLECommunicationCapabilityBLE = 1 << 0,
    /// Support MESH
    ThingSmartBLECommunicationCapabilityMESH = 1 << 1,
    /// Capable of WiFi 2.4G communication and only supports dual-mode devices
    ThingSmartBLECommunicationCapabilityDualModeWifi2_4G = 1 << 2,
    /// Capable of WiFi 5G communication and only supports dual-mode devices
    ThingSmartBLECommunicationCapabilityDualModeWifi5G = 1 << 3,
    /// Capable of Zigbee communication
    ThingSmartBLECommunicationCapabilityZigbee = 1 << 4,
    /// Having NB communication capability
    ThingSmartBLECommunicationCapabilityNB = 1 << 5,
    /// Having Cellular communication capability
    ThingSmartBLECommunicationCapabilityCellular = 1 << 6,
    /// Capable of WiFi 2.4G communication, only suitable for BLE+X device form
    ThingSmartBLECommunicationCapabilityBLEXWifi2_4G = 1 << 7,
    /// Capable of WiFi 5G communication, only suitable for BLE+X device form
    ThingSmartBLECommunicationCapabilityBLEXWifi5G = 1 << 8,
    /// Capable of wired communication (Ethernet)
    ThingSmartBLECommunicationCapabilityWiredConnected = 1 << 9,
};

/// @brief ThingBLEAdvModel provides a model to get the Bluetooth LE device broadcast information.
///
/// All the device information is obtained from the Bluetooth device broadcast packet data.

/// The different types of Bluetooth LE devices. See the following parameter descriptions.
@interface ThingBLEAdvModel : NSObject

/// The Bluetooth peripheral to be scanned.
@property (nonatomic, strong) ThingBLEPeripheral *peripheral;
/// The UUID of the Bluetooth LE device.
@property (nonatomic, strong) NSString           *uuid;
/// The product ID of the Bluetooth LE device.
@property (nonatomic, strong) NSString           *productId;
/// The MAC address of the Bluetooth LE device.
@property (nonatomic, strong) NSString           *mac;
/// The activation state of the Bluetooth LE device.
@property (nonatomic, assign) BOOL               isActive;
/// The type of Bluetooth LE device.
@property (nonatomic, assign) ThingSmartBLEType     bleType;
/// Indicates whether the Bluetooth LE device supports connections through the router on a 5 GHz band.
/// @note `ThingSmartBLETypeBLEWifi` or `ThingSmartBLETypeBLEWifiSecurity` is only available for `bleType`.
@property (nonatomic, assign) BOOL               isSupport5G;
/// Indicates whether the Bluetooth LE device supports the product key.
@property (nonatomic, assign) BOOL               isProuductKey;
/// The protocol version of the Bluetooth LE device.
@property (nonatomic, assign) int                bleProtocolV;
/// Whether the device is activated by scanning, such as scanning a QR code.Defaults to NO.
@property (nonatomic, assign) BOOL               isQRCodeDevice;
/// Whether the device is support config by multi user.
@property (nonatomic, assign) BOOL               isSupportMultiUserShare;
/// Whether the device is support  roam
@property (nonatomic, assign) BOOL              isRoaming;
/// Whether the device is support  wifi list query
@property (nonatomic, assign) BOOL              isSupportQueryWifiList;
/// Whether the device is support  Beacon WiFi
@property (nonatomic, assign) BOOL              isBeaconWiFi;
/// Whether the device is support  Pegasus
@property (nonatomic, assign) BOOL              isSupportPegasus;

/// extra Params for activator point
@property (nonatomic, strong) NSDictionary *extraParams;

@property (strong) ThingBLEBeaconWiFiAdvFrame   *bcframe;

/// The communication capability of Bluetooth LE devices.
@property (nonatomic, assign) ThingSmartBLECommunicationCapability bleCommunicationCapability;

@property (nonatomic, assign) BOOL isExecutedV2Secret;  //Executed secret
@property (nonatomic, assign) BOOL isSupportV2Secret;  //support secret


@end
