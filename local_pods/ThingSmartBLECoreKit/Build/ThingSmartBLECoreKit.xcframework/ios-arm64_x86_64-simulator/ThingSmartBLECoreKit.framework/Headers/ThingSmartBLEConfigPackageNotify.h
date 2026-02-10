//
//  ThingSmartBLEConfigPackageNotify.h
//  Pods
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)
//

#ifndef ThingSmartBLEConfigPackageNotify_h
#define ThingSmartBLEConfigPackageNotify_h

#import "ThingSmartBLEConfigNotifyItem.h"

@protocol ThingSmartBLEConfigPackageNotify <NSObject>

- (void)classicConfigPackageWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                                notifyItem:(ThingSmartBLEConfigNotifyItem *)notifyItem;

- (void)plusConfigPackageWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                             notifyItem:(ThingSmartBLEConfigNotifyItem *)notifyItem;

- (void)secretConfigPackageWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                               notifyItem:(ThingSmartBLEConfigNotifyItem *)notifyItem;

@end

#endif /* ThingSmartBLEConfigPackageNotify_h */
