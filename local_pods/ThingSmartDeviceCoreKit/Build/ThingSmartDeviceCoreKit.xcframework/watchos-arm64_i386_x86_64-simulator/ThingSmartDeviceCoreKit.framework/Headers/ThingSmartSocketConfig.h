//
//  ThingSmartSocketConfig.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//


#if TARGET_OS_IOS
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartSocketConfig : NSObject

- (void)registWithUniversal:(BOOL)universal uid:(NSString *)uid configKey:(nullable NSData *)configKey broadcastKey:(nullable NSData *)broadcastKey sendKey:(nullable NSData *)sendKey;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
#endif
