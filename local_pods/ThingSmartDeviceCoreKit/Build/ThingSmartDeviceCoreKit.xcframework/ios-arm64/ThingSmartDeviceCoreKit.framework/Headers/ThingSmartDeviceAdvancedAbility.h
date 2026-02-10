//
//  ThingSmartDeviceAdvancedAbility.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartDeviceAdvancedAbility : NSObject

@property (nonatomic, strong) NSString *devId;

@property (nonatomic, assign) BOOL value;

@property (nonatomic, strong) NSString *code;

@property (nonatomic, assign) long long    homeId;

@end

NS_ASSUME_NONNULL_END
