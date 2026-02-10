//
//  ThingBLEDataManager.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)
//

#import <Foundation/Foundation.h>
#import "ThingBLEDeviceInfoProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThingBLEDataManager : NSObject

ThingSDK_SINGLETON

- (void)handleNotifyData:(NSData *)data deviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo type:(ThingBLEConfigType)type completion:(void(^)(NSData *resultData))completion;


- (void)handleNotifyData:(NSData *)data deviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo type:(ThingBLEConfigType)type ackHeadData:(nullable NSData *)ackHeadData completion:(void(^)(NSData *resultData))completion;

@end

NS_ASSUME_NONNULL_END
