//
//  ThingBLEStatusService.h
//  ThingSmartBLEKit
//
//

#import <Foundation/Foundation.h>
#import "ThingBLEDeviceInfoProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@class ThingBLEWriteNotifyService;
@interface ThingBLEStatusService : NSObject

@property (nonatomic, weak) id<ThingBLEFindMacDelegate> findMacDelegate;

ThingSDK_SINGLETON

- (id<ThingBLEDeviceInfoProtocol>)addDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo;

- (void)updateDeviceInfo:(NSString *)uuid state:(ThingSmartBLEDeviceState)state;

/// - Parameter devId: devId
- (nullable id<ThingBLEDeviceInfoProtocol>)findDeviceInfoWithDevId:(NSString *)devId;

- (nullable id<ThingBLEDeviceInfoProtocol>)findDeviceInfoWithUUID:(NSString *)uuid;

- (nullable id<ThingBLEDeviceInfoProtocol>)findDeviceInfoWithUUID:(NSString *)uuid andMac:(nullable NSString *)mac;

/// Create ThingBLEDeviceInfoProtocol Model
/// @param uuid uuid
/// @param mac mac id
- (id<ThingBLEDeviceInfoProtocol>)createDeviceInfoWithUUID:(NSString *)uuid andMac:(nullable NSString *)mac;

- (NSDictionary<NSString *, id<ThingBLEDeviceInfoProtocol>> *)findAllDeviceInfo;

- (void)offlineDevcieInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo;

- (void)removeDevcieInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo;

#pragma mark - reconnectList

- (void)addReconnectDevice:(ThingBLEPeripheral *)peripheral forKey:(NSString *)key;

- (ThingBLEPeripheral *)getReconnectDeviceWithKey:(NSString *)key;

- (void)removeReconnectDeviceWithKey:(NSString *)key;

- (void)removeAllReconnectDevice;

#pragma mark - otaStatusList

- (void)addOtaStatusDevice:(id)anObject forKey:(NSString *)key;

- (id)getOtaStatusDeviceWithKey:(NSString *)key;

- (void)removeOtaStatusDeviceWithKey:(NSString *)key;

- (void)removeAllOtaStatusDevice;


#pragma mark - deviceCategoryInfoList

- (void)addDeviceCategoryInfo:(id)categoryInfo forKey:(NSString *)key;

- (id)getDeviceCategoryInfoWithKey:(NSString *)key;

- (void)removeDeviceCategoryInfoWithKey:(NSString *)key;

- (void)removeAllDeviceCategoryInfo;

#pragma mark - pskSecurityConfigInfoList
- (void)addPskSecurityConfigInfo:(id)securityConfigInfo forKey:(NSString *)key;

- (id)getPskSecurityConfigInfoWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
