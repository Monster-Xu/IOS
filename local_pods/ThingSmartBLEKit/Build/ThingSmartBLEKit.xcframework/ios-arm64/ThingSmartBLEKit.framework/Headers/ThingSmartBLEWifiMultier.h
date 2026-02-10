//
//  ThingSmartBLEWifiMultier.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ThingSmartBLEWifiMultier;
@protocol ThingSmartBLEWifiMultierDelegate <NSObject>

- (void)bleWifiMuliter:(ThingSmartBLEWifiMultier *)muliter didStartActive:(ThingBLEAdvModel *)advModel;

- (void)bleWifiMuliter:(ThingSmartBLEWifiMultier *)muliter startFailDevice:(ThingBLEAdvModel *)advModel error:(NSError *)error;

- (void)bleWifiMuliter:(ThingSmartBLEWifiMultier *)muliter didReceiveBLEWifiConfigDevice:(nullable ThingSmartDeviceModel *)deviceModel error:(nullable NSError *)error;

@end


@interface ThingSmartBLEWifiConfiguration : NSObject <ThingSmartBLEPairConfiguration>

@end


@interface ThingSmartBLEWifiMultierTracker : NSObject
@property (nonatomic, strong) NSDate *add_time;
@property (nonatomic, strong) NSDate *pair_time;
@property (nonatomic, strong) NSDate *rcv_time;
@property (nonatomic, strong) NSDate *poll_time;
@property (nonatomic, strong) NSDate *cancel_time;
@property (nonatomic, strong) NSDate *fail_time;
@property (nonatomic, strong) NSDictionary *extendParams;
@end


typedef NS_ENUM(NSInteger, ThingSmartBLEMultiActiveType) {
    ThingSmartBLEMultiActiveTypeWiFi,
    ThingSmartBLEMultiActiveTypePreActive
};


@interface ThingSmartBLEMultiParams : NSObject

@property (nonatomic, assign) ThingSmartBLEMultiActiveType activeType;

@end


@interface ThingSmartBLEWifiMultier : NSObject

@property (nonatomic, weak) id<ThingSmartBLEWifiMultierDelegate> delegate;

@property (nonatomic, strong) ThingSmartBLEWifiConfiguration *config;

- (void)appendDevice:(ThingBLEAdvModel *)adv __deprecated_msg("This method is deprecated, Use appendDevice:params: instead");

- (void)appendDevice:(ThingBLEAdvModel *)adv params:(ThingSmartBLEMultiParams *)params;

- (void)removeDevice:(ThingBLEAdvModel *)adv;

- (void)startConfigWifi;

- (void)stopConfigWifi;

@end

NS_ASSUME_NONNULL_END
