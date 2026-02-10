//
//  ThingBleEventConnectHelper.h
//  ThingSmartBLECoreKit
//
//  Created by aotuo on 2024/6/19.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ThingBleEventErrorCode) {
    ThingBleEventErrorCodeBlePowerOff = 1,
    ThingBleEventErrorCodeNoFoundBroadcast = 2,
    ThingBleEventErrorCodeFoundButFail = 3,
};

typedef NS_ENUM(NSUInteger, ThingBleEventConnectStage) {
    ThingBleEventConnectStageTigger       = 0,
    ThingBleEventConnectStageFound        = 100,
    ThingBleEventConnectStageConnectStart = 200,
    ThingBleEventConnectStageConnectEnd   = 299,
    ThingBleEventConnectStageOnlineStart  = 300,
    ThingBleEventConnectStageOnlineEnd    = 399
};

NS_ASSUME_NONNULL_BEGIN

@interface ThingBleEventConnectHelper : NSObject

ThingSDK_SINGLETON

- (void)recordBleConnectEvent:(NSString *)uuid devId:(NSString *)devId src:(NSInteger)src actId:(NSString *)actId extra:(NSDictionary *)extra;

- (void)updateFoundWithUUID:(NSString *)uuid peripheral_uuid:(NSString *)peripheral_uuid;

- (void)updateStage:(ThingBleEventConnectStage)stage devId:(nullable NSString *)devId uuid:(NSString *)uuid;

- (void)updateFailure:(NSError *)error stage:(ThingBleEventConnectStage)stage devId:(nullable NSString *)devId uuid:(NSString *)uuid;

@end

NS_ASSUME_NONNULL_END
