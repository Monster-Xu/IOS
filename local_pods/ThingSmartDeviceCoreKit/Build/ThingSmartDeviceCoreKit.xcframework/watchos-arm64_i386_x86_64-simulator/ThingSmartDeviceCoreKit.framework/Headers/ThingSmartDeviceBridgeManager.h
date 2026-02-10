//
//  ThingSmartDeviceBridgeManager.h
//  ThingSmartDeviceCoreKit
//
//  Created by thing on 2025/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartRelayQueryModel : NSObject
@property (nonatomic, assign) NSInteger enable;
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *passwd;
@property (nonatomic, assign) NSInteger hide;
@property (nonatomic, assign) NSInteger follow;
@end

@interface ThingSmartRelayConfigurationModel : NSObject
@property (nonatomic, assign) NSInteger enable;
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *passwd;
@property (nonatomic, assign) NSInteger hide;
@property (nonatomic, assign) NSInteger follow;
@property (nonatomic, assign) NSInteger resCode;
@end

@interface ThingSmartRelayStatusArrayModel : NSObject
@property (nonatomic, assign) NSInteger resCode;
@property (nonatomic, strong) NSArray *staList;
@end

@interface ThingSmartRelayStatusModel : NSObject
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *rssi;
@end


@protocol ThingSmartDeviceBridgeManagerDelegate <NSObject>
- (void)didQueryWifiBridge:(ThingSmartRelayQueryModel *)bridgeWifiInfo forDeviceId:(NSString *)deviceId;
- (void)didSetWifiBridge:(ThingSmartRelayConfigurationModel *)bridgeWifiSet forDeviceId:(NSString *)deviceId;
- (void)didStatusWifiBridge:(nullable ThingSmartRelayStatusArrayModel *)bridgeStatusModel forDeviceId:(NSString *)deviceId;
@end


@interface ThingSmartDeviceBridgeManager : NSObject

+ (instancetype)sharedManager;
- (void)registerDelegate:(id<ThingSmartDeviceBridgeManagerDelegate>)delegate;
- (void)removeDelegate:(id<ThingSmartDeviceBridgeManagerDelegate>)delegate;

- (void)bridgeServiceQuery:(NSString *)deviceId success:(nullable void (^)(void))success failure:(nullable void (^)(NSError *error))failure;
- (void)bridgeServiceConfiguration:(ThingSmartRelayConfigurationModel *)configurationModel devId:(NSString *)deviceId success:(nullable void (^)(void))success failure:(nullable void (^)(NSError *error))failure;
- (void)bridgeServiceStatus:(NSString *)deviceId success:(nullable void (^)(void))success failure:(nullable void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
