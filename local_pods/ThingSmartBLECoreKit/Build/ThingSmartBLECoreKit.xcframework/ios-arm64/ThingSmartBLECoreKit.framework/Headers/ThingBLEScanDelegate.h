//
//  ThingBLEScanDelegate.h
//  Pods
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)
//

#ifndef ThingBLEScanDelegate_h
#define ThingBLEScanDelegate_h

#import "ThingBLEDeviceInfoProtocol.h"

@protocol ThingBLEScanDelegate <NSObject>

@optional
/// @param deviceInfos deviceInfos
- (void)didScanDevices:(NSArray<id <ThingBLEDeviceInfoProtocol>> *)deviceInfos;

- (void)bleOnCentralDidUpdateState:(BOOL)isPoweredOn;

- (void)syncDevice2Cloud:(id<ThingBLEDeviceInfoProtocol>)dev;

- (void)scanHasStopped;

@end


#endif /* ThingBLEScanDelegate_h */
