//
//  ThingSmartLANAndMQTTVersionSupport.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>
#import "ThingSmartDeviceModel.h"
#import "ThingSmartGroupModel.h"



/// Returns YES if the device supports the current LAN and MQTT protocol version
/// @param devIdOrGroupId devId Or groupId
/// @param isGroup If YES, the input id is groupId, otherwise it is devId
FOUNDATION_EXTERN BOOL IsDeviceOrGroupLanAndMQTTVersionSupport(NSString *devIdOrGroupId, BOOL isGroup);


@interface ThingSmartDeviceModel (VersionSupport)
/// Returns YES if the device supports the current LAN and MQTT protocol version
- (BOOL)isLANAndMQTTVersionSupport;
@end



@interface ThingSmartGroupModel (VersionSupport)
/// Returns YES if the device supports the current LAN and MQTT protocol version
- (BOOL)isLANAndMQTTVersionSupport;
@end
