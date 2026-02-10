//
//  ThingSmartBLECommRodManager.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ThingSmartBLECommRodManagerDelegate <NSObject>

- (void)deviceDidConnected:(ThingSmartBLELocalDevice *)localDevice;

- (void)deviceConnectedFailWithError:(NSError *)error;

- (void)deviceUploadSchema:(NSDictionary *)schema;

@end


@interface ThingSmartBLECommRodManager : NSObject

@property (nonatomic, weak) id<ThingSmartBLECommRodManagerDelegate> delegate;

- (void)connectDevice:(ThingBLEAdvModel *)adv machineKey:(NSString *)machineKey schema:(NSString *)schema;

@end

NS_ASSUME_NONNULL_END
