//
//  ThingBLECMDToken.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)
//

#import <Foundation/Foundation.h>
#import "ThingBLECryptologyProtcol.h"
#import "ThingBLEGCDTimer.h"
NS_ASSUME_NONNULL_BEGIN

@interface ThingBLECMDToken : NSObject

@property (nonatomic, assign) ThingBLEConfigType               cmdType;

@property (nonatomic, copy, nullable) ThingFailureError        failure;
@property (nonatomic, copy, nullable) ThingSuccessData         success;
@property (nonatomic, strong) NSData                        *data;
@property (nonatomic, strong) id<ThingBLEDeviceInfoProtocol>   deviceInfo;

@property (nonatomic, strong, nullable) ThingBLEGCDTimer *timer;

@end

NS_ASSUME_NONNULL_END
