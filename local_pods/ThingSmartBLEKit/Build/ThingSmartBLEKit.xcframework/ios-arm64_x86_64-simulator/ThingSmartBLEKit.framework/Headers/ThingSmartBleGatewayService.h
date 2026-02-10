//
//  ThingSmartBleGatewayService.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <Foundation/Foundation.h>
#import <ThingSmartUtil/ThingSmartUtil.h>
#import <ThingSmartDeviceCoreKit/ThingSmartDeviceCoreKit.h>


NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    ThingBleGatewayServiceErrorUnknown = 900,
    ThingBleGatewayServiceErrorWrongParam = 901,
    ThingBleGatewayServiceErrorNotInWhiteList = 902,
    ThingBleGatewayServiceErrorTimeOut = 903,
    ThingBleGatewayServiceAddIsRunning = 904,
} ThingBleGatewayServiceError;

@protocol ThingBleGatewayServiceAddDeviceDelegate <NSObject>

/// Add a device successfully
/// @param deviceId  device id
- (void)onReceiveAddDeviceSuccess:(NSString *)deviceId;


/// Add a device Failed
/// @param error error
/// @param deviceId  device Id
- (void)onReceiveAddDeviceFailure:(NSString *)deviceId error:(NSError *)error;

/// Error adding device
/// @param error error
- (void)onError:(NSError *)error;

/// Add complete
- (void)onReceiveAddDeviceFinish;

@end

@interface ThingSmartBleGatewayService : NSObject

ThingSDK_SINGLETON

/// add device delegate
/// @param delegate delegate
- (void)addDelegate:(id<ThingBleGatewayServiceAddDeviceDelegate>)delegate;

///  remove delegate
/// @param delegate  delegate
- (void)removeDelegate:(id<ThingBleGatewayServiceAddDeviceDelegate>)delegate;

/// add device to gateway
/// @param gatewayId  gateway id
/// @param devIdList device id list
- (void)addDevices:(NSArray<NSString *> *)devIdList toGateway:(NSString *)gatewayId;

/// remove device from gateway
/// @param deviceId de
/// @param gatewayId gateway Id
/// @param successBlock success block
/// @param failureBlock failure block
- (void)removeDevice:(NSString *)deviceId
        fromGateway:(NSString *)gatewayId
            success:(ThingSuccessHandler)successBlock
            failure:(ThingFailureError)failureBlock;

/// get device list
/// @param gatewayId gateway id
/// @param successBlock success block
/// @param failureBlock failure block
- (void)deviceListFromGateway:(NSString *)gatewayId success:(nullable void (^)(NSArray <ThingSmartDeviceModel *> *subDeviceList))successBlock failure:(nullable ThingFailureError)failureBlock;

/// connect device id list
/// @param devIdList device list
/// @param gwId  gateway id
- (void)connectDevIdList:(NSArray<NSString *> *)devIdList WithGateWayId:(NSString *)gwId;

/// disconnect device id list
/// @param devIdList device id list
/// @param gwId gateway id
- (void)disconnectDevIdList:(NSArray<NSString *> *)devIdList WithGateWayId:(NSString *)gwId;

/// check heart beat
/// @param gatewayIdList gateway id list
- (void)checkAndSendHeardBeatWithGatewayIdList:(NSArray<NSString *> *)gatewayIdList;

/// stop heart beat
- (void)stopHeartBeat;




@end

NS_ASSUME_NONNULL_END
