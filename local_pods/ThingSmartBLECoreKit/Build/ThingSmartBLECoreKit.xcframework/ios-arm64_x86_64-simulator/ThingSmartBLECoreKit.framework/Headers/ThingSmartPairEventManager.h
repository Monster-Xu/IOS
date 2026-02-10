//
//  ThingSmartPairEventManager.h
//  ThingSmartBLECoreKit
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ThingSmartPairEvent) {
    ThingSmartPairEventInit = 0,
    ThingSmartPairEventStart,
    ThingSmartPairEventCancel,
    ThingSmartPairEventSuccess,
    ThingSmartPairEventFail
};

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartPairEventManager : NSObject

+ (instancetype)shared;

- (void)event:(ThingSmartPairEvent)event uuid:(NSString *)uuid dict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
