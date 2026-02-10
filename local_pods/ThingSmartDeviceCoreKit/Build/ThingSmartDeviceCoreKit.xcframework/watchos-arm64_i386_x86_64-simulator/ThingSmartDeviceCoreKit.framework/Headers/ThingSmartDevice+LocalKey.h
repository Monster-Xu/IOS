//
//  ThingSmartDevice+LocalKey.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import "ThingSmartDevice.h"

NS_ASSUME_NONNULL_BEGIN

#define LocalKeySupportKey @"supportLocalKeyChange"

@interface ThingSmartDevice (LocalKey)

/// Update device local key.
- (void)updateLocalKeySuccess:(nullable ThingSuccessHandler)success
                      failure:(nullable ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END
