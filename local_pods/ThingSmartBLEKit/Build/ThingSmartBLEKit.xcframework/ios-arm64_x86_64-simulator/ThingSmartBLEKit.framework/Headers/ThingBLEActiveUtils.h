//
//  ThingBLEActiveUtils.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

NS_ASSUME_NONNULL_BEGIN

@interface ThingBLEActiveUtils : NSObject

+ (void)fetchEncryptionKeyFromServe:(ThingBLEAdvModel *)advModel
                             homeId:(long long)homeId
                            success:(ThingSuccessID)success
                            failure:(ThingFailureError)failure;

+ (void)fetchDeleteEncryptionKeyFromServe:(ThingBLEAdvModel *)advModel homeId:(long long)homeId success:(ThingSuccessID)success failure:(ThingFailureError)failure;

+ (void)fetchBLEMeshNodeIdWithMeshId:(NSString *)meshId type:(NSString *)type success:(ThingSuccessID)success failure:(ThingFailureError)failure;

+ (void)fetchResetKeyWithShortUrl:(NSString *)shortUrl advModel:(ThingBLEAdvModel *)advModel success:(ThingSuccessID)success failure:(ThingFailureError)failure;

+ (void)activeDMDevice:(NSDictionary *)postData success:(ThingSuccessID)success failure:(ThingFailureError)failure;

+ (void)getEnvWithSuccess:(ThingSuccessID)success failure:(ThingFailureError)failure;

+ (void)getPSKInfoWithSL:(NSNumber *)SL success:(ThingSuccessDict)success failure:(ThingFailureError)failure;

+ (void)getAuthPropertyByUUID:(NSArray<NSString *> *)uuids code:(NSString *)code success:(ThingSuccessID)success failure:(ThingFailureError)failure;

+ (void)getAuthPropertyByUUID:(NSString *)uuid codes:(NSArray<NSString *> *)codes success:(ThingSuccessID)success failure:(ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END
