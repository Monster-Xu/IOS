//
//  ThingBLEBizTools.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Inc. (https://developer.tuya.com)
//

#import <Foundation/Foundation.h>
#import <ThingSmartBLECoreKit/ThingBLEDeviceInfoProtocol.h>
#import <ThingSmartBLECoreKit/ThingBLEGeneralHelper.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingBLEBizTools : NSObject

+ (NSData *)bigDataSummary:(unsigned int)type;

+ (NSData *)bigDataBlockSummaryType:(unsigned int)type index:(NSInteger)index;

+ (NSData *)bigDataDel:(unsigned int)type ;

+ (ThingSmartDeviceModel *)getDeviceModelWithUUID:(NSString *)uuid;


+ (BOOL)deviceIsActive:(NSString *)uuid;


+ (BOOL)isDualModeDevice:(NSString *)uuid;

+ (BOOL)isDualModeDeviceWithDevId:(NSString *)devId;


+ (BOOL)dualModeDeviceSupportBLEControl:(id <ThingBLEDeviceInfoProtocol>)deviceInfo;

#pragma mark - 

- (void)unbindDeviceHandle:(ThingBLEAdvModel *)item success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

- (void)clearUnbindDeviceCach;

- (void)removeUnbindDeviceFlag:(NSString *)unbindDeviceId;

+ (void)updateBLEDeviceOnline:(ThingSmartDeviceModel *)device;

+ (ThingBLESupportConnect)getConfigConnectType:(id<ThingBLEDeviceInfoProtocol>)dev;

//get connect type from deviceId
+ (ThingBLESupportConnect)getConfigConnectTypeWithUUID:(NSString *)uuid;

@end

NS_ASSUME_NONNULL_END
