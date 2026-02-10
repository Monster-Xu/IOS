//
//  ThingBLEBeaconAdvFrame.h
//  ThingSmartBLECoreKit
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingBLEBeaconAdvFrame : NSObject

+ (BOOL)validateBeaconWiFiFormatData:(NSDictionary *)data;

+ (instancetype)frameWithServices:(NSArray *)services;

@end

NS_ASSUME_NONNULL_END
