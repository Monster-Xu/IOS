//
//  ThingSmartDeviceCoreKit.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#ifndef ThingSmartDeviceCoreKit_h
#define ThingSmartDeviceCoreKit_h


#define THING_DEVICECORE_VERSION @"5.21.7-feature-6704GWIFI.1"

/// @brief Header files for ThingSmartDeviceCoreKit.

/// The highest currently supported extranet communication protocol for clients.
#define THING_CURRENT_GW_PROTOCOL_VERSION 2.3

/// Highest currently supported LAN communication protocol for clients.
#define THING_CURRENT_LAN_PROTOCOL_VERSION 3.5

#import <ThingSmartNetworkKit/ThingSmartNetworkKit.h>

#if TARGET_OS_IOS
    #import <ThingSmartMQTTChannelKit/ThingSmartMQTTChannelKit.h>
    #import <ThingSmartSocketChannelKit/ThingSmartSocketChannelKit.h>

    #import "ThingSmartDevice+WiFiBackup.h"

#elif TARGET_OS_WATCH
    #define ThingSmartMQTTChannelDelegate NSObject
    #define ThingSmartSocketChannelDelegate NSObject
#endif

#import "ThingSmartDevice.h"
#import "ThingSmartGroup.h"
#import "ThingSmartBleMeshModel.h"
#import "ThingSmartSingleTransfer.h"
#import "ThingSmartDeviceAdvancedAbility.h"
#import "ThingCoreCacheService.h"

#import "ThingSmartDevice+OfflineReminder.h"
#import "ThingSmartDeviceCoreKitErrors.h"
#import "ThingSmartDevice+OfflineReminder.h"
#import "ThingSmartCommunication.h"
#import "ThingSmartDeviceEventUtil.h"

#import "ThingSmartCommunication.h"
#import "ThingSmartDevice+LocalKey.h"

#import "ThingSmartDevice+OTA.h"
#import "ThingSmartDevice+Connect.h"
#import "ThingSmartDeviceModelUtils.h"

#import "ThingSmartMQTTConfig.h"
#import "ThingSmartSocketConfig.h"

#import "ThingSmartLANAndMQTTVersionSupport.h"

#import "ThingSmartCoreCache.h"
#import "ThingSmartUIPanelModel.h"
#import "ThingSmartDevice+FittingDevice.h"

#import "ThingSmartDpParser.h"
#import "ThingSmartDeviceReplacementService.h"
#import "ThingSmartNFCHandler.h"

#import "ThingSmartBTService.h"

#endif /* ThingSmartDeviceCoreKit_h */
