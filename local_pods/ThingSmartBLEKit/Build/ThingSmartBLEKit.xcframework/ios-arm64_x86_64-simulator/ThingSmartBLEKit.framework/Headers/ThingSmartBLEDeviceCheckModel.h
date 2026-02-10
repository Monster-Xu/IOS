//
//  ThingSmartBLEDeviceCheckModel.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartBLEDeviceCheckModel : NSObject

@property (nonatomic, assign) NSInteger businessCode;

@property (nonatomic, copy) NSString *encryptedAuthKey;

@property (nonatomic, copy) NSString *random;

@end

NS_ASSUME_NONNULL_END
