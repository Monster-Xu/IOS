//
//  ThingSmartDeviceServiceManager.h
//  ThingSmartDeviceCoreKit
//
//  Created by thing on 2024/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartSyncServiceModel : NSObject
@property (nonatomic, strong) NSString *devId;
@property (nonatomic, strong) NSString *serviceName;
@property (nonatomic, strong) NSArray<NSString *> *serverDeviceIds;
@end

@interface ThingSmartSupportServiceModel : NSObject
@property (nonatomic, strong) NSArray<NSString *> *client;
@property (nonatomic, strong) NSArray<NSString *> *server;
@end

@protocol ThingSmartDeviceServiceManagerDelegate <NSObject>

- (void)didReceiveSyncResponse:(NSDictionary *)data forDeviceId:(NSString *)deviceId;
- (void)didDiscoverService:(NSDictionary *)serviceInfo forDeviceId:(NSString *)deviceId;
- (void)didConfirmService:(NSDictionary *)serviceInfo permit:(BOOL)permit forDeviceId:(NSString *)deviceId;
- (void)didCancelService:(NSDictionary *)serviceCancel forDeviceId:(NSString *)deviceId;

@end

@interface ThingSmartDeviceServiceManager : NSObject
+ (instancetype)sharedManager;
- (void)registerDelegate:(id<ThingSmartDeviceServiceManagerDelegate>)delegate;
- (void)removeDelegate:(id<ThingSmartDeviceServiceManagerDelegate>)delegate;

- (ThingSmartSupportServiceModel *)supportServicesWithDeviceId:(NSString *)deviceId;
- (void)deviceSyncWithSyncServiceModel:(ThingSmartSyncServiceModel *)syncModel success:(nullable void (^)(void))success failure:(nullable void (^)(NSError *error))failure;

- (NSArray<NSString *> *)getServerDevices:(NSString *)service;
- (NSArray<NSString *> *)getClientDevices:(NSString *)service;

- (void)serviceDiscoveryWithDeviceId:(NSString *)deviceId service:(NSString *)service success:(nullable void (^)(void))success failure:(nullable void (^)(NSError *error))failure;
- (void)serviceConfirmWithServiceInfo:(NSDictionary *)serviceInfo permit:(BOOL)permit success:(nullable void (^)(void))success failure:(nullable void (^)(NSError *error))failure;
- (void)serviceCancelWithServiceCancel:(NSDictionary *)serviceCancel success:(nullable void (^)(void))success failure:(nullable void (^)(NSError *error))failure;


@end

NS_ASSUME_NONNULL_END
