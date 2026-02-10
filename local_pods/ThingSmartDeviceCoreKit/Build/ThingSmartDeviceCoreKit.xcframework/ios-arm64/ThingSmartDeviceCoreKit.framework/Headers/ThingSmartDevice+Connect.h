//
//  ThingSmartDevice+Connect.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import "ThingSmartDevice.h"

typedef NS_ENUM(NSInteger, ThingDeviceConnectSourceType){
    ThingDeviceConnectSourceTypeNormal = 0,
    ThingDeviceConnectSourceTypePanelIn = 1,
};

typedef NS_ENUM(NSInteger, ThingDeviceConnectType){
    ThingDeviceConnectTypeNormal = 0,
    ThingDeviceConnectTypeBLEOnly = 1,
    ThingDeviceConnectTypeGatewayOnly = 2,
};


@interface ThingDeviceConnectParams : NSObject

/// Connection timeout milliseconds. Default: 15000 , 15s
@property (nonatomic, assign) long connectTimeoutMills;

/// The default  value is ThingDeviceConnectSourceTypeNormal
@property (nonatomic, assign) ThingDeviceConnectSourceType sourceType;

/// The default  value is ThingDeviceConnectTypeNormal
@property (nonatomic, assign) ThingDeviceConnectType connectType;

@end


@interface ThingDeviceDisconnectParams : NSObject

/// The default  value is ThingDeviceConnectTypeNormal
@property (nonatomic, assign) ThingDeviceConnectType connectType;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartDevice (Connect)

/// connect device with params
/// @param success success
/// @param failure failure
- (void)connectDeviceWithParams:(ThingDeviceConnectParams *)connectParams
                        success:(ThingSuccessHandler)success
                        failure:(ThingFailureError)failure;

/// Disconnect the device. Note If the sigmesh device is used, the sigmesh network is disconnected
/// @param disconnectParams disconnectParams
- (void)disconnect:(ThingDeviceDisconnectParams *)disconnectParams;

@end

NS_ASSUME_NONNULL_END
