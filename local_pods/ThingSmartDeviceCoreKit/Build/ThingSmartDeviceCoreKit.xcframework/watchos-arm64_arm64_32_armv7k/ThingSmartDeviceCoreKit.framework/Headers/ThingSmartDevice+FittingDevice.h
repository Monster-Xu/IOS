//
//  ThingSmartDevice+FittingDevice.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <ThingSmartDeviceCoreKit/ThingSmartDeviceCoreKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger,ThingSmartRemoteControlHandleType){
    ThingSmartRemoteControlHandleTypeDeviceAuth = 0,
    ThingSmartRemoteControlHandleTypeDeviceCheck,
    hingSmartRemoteControlHandleTypeDeviceDelete,
    ThingSmartRemoteControlHandleTypeGroupAdd,
    ThingSmartRemoteControlHandleTypeGroupDelete,
    ThingSmartRemoteControlHandleTypeGroupQuery,
};

@interface ThingSmartRemoteControlModel : NSObject

//remote control auto type.
// authorization to use.Group is not
@property (nonatomic, assign) NSInteger type;
/// Fitting's secret key
@property (nonatomic, strong) NSString *authDeviceS1;

/// Fitting's mac
@property (nonatomic, strong) NSString *mac;

/// Fitting's group ID
@property (nonatomic, assign) NSInteger groupId;

/// Fitting's devId
@property (nonatomic, strong) NSString *devId;

@property (nonatomic, assign) BOOL isSuccess;


@end


@interface ThingSmartRemoteControlAuthParams : NSObject

@property (nonatomic, assign) ThingSmartRemoteControlHandleType remoteControlHandleType;

@property (nonatomic, strong) NSArray<ThingSmartRemoteControlModel *> * remoteControlList;

/// The device ID of the message source
@property (nonatomic, strong) NSString *deviceId;

@end


@interface ThingSmartDevice (FittingDevice)


- (void)handleRemoteControlGroup:(ThingSmartRemoteControlAuthParams *)remoteControlModel
                         success:(ThingSuccessHandler)success
                         failure:(ThingFailureError)failure;


@end

NS_ASSUME_NONNULL_END
