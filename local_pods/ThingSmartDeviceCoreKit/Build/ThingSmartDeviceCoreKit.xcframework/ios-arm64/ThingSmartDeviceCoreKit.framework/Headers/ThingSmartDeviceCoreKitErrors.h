//
//  ThingSmartDeviceCoreKitErrors.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#ifndef ThingSmartDeviceCoreKitErrors_h
#define ThingSmartDeviceCoreKitErrors_h

/*
 *  ThingDeviceCoreKitError
 *
 *  Discussion:
 *    Error returned as code to NSError from ThingSmartDeviceKit.
 */
extern NSString *const kThingDeviceCoreKitErrorDomain;

/// The definitions of device core kit errors.
typedef NS_ENUM(NSInteger, ThingDeviceCoreKitError) {
    /// The device does not support a certain capability that is reported on the device dimensions.
    kThingDeviceCoreKitErrorDeviceNotSupport                      = 3000,
    /// The LAN downstream data failure.
    kThingDeviceCoreKitErrorSocketSendDataFailed                  = 3001,
    /// The DP data is empty.
    kThingDeviceCoreKitErrorEmptyDpsData                          = 3002,
    /// The group devices are empty.
    kThingDeviceCoreKitErrorGroupDeviceListEmpty                  = 3003,
    /// The group ID length error.
    kThingDeviceCoreKitErrorGroupIdLengthError                    = 3004,
    /// Illegal DPs. See the product DP definition.
    kThingDeviceCoreKitErrorIllegalDpData                         = 3005,
    /// The device ID length error.
    kThingDeviceCoreKitErrorDeviceIdLengthError                   = 3006,
    /// The local key is not found.
    kThingDeviceCoreKitErrorDeviceLocalKeyNotFound                = 3007,
    /// The product ID length error.
    kThingDeviceCoreKitErrorDeviceProductIDLengthError            = 3008,
    /// Illegal communication type, see the enum ThingCommunicationType.
    kThingDeviceCoreKitErrorIllegalCommunicationType              = 3009,
    ///Method does not support invocation
    kThingDeviceCoreKitErrorMethodNotSupport                      = 3010,
    /// fetch product ext info failed
    kThingDeviceCoreKitErrorProductExtInfoErrror                  = 4000,
};

#endif /* ThingSmartDeviceCoreKitErrors_h */
