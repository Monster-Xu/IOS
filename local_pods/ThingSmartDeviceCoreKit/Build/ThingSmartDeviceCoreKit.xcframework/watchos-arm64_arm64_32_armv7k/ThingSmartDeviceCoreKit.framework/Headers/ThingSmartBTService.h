//
//  ThingSmartBTService.h
//  ThingSmartDeviceCoreKit
//
//  Created by milong on 2025/4/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartBTActiveWithoutUUIDParam : NSObject

@property (nonatomic, strong) NSString *productKey;

@property (nonatomic, strong) NSString *btName;

@property (nonatomic, assign) long long homeId;

@property (nonatomic, strong) NSString *mac;

@end



@interface ThingSmartBTModel : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mac;

- (instancetype)initWithType:(NSString *)type name:(NSString *)name mac:(NSString *)mac;

@end

@interface ThingSmartBTService : NSObject

+ (instancetype)shareInstance;

- (NSArray<ThingSmartBTModel *> *)getConnectedBluetoothDevices;

- (BOOL)hasBluetoothDeviceConnectedWithDevId:(NSString *)deviceId;

- (BOOL)didBluetoothDeviceBonded:(NSString *)deviceId;

- (void)updateBTName:(NSString *)name devId:(NSString *)devId success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

- (void)activeBTDeviceWithoutUUIDParams:(ThingSmartBTActiveWithoutUUIDParam *)activeParams success:(void (^)(ThingSmartDeviceModel * _Nonnull))success failure:(ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END
