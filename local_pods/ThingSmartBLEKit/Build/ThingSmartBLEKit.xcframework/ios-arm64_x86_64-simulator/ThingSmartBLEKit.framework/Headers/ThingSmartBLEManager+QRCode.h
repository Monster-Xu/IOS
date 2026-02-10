//
//  ThingSmartBLEManager+QRCode.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <ThingSmartBLEKit/ThingSmartBLEKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ ThingSmartBLEDevcieCheckHandler)(ThingSmartBLEDeviceCheckModel *checkModel);

@interface ThingSmartBLEManager (QRCode)

- (void)startListeningWithUUID:(NSString *)UUID;

- (void)startListeningWithUUID:(NSString *)UUID
                       success:(nullable void(^)(id<ThingBLEDeviceInfoProtocol> devInfo))success
                       failure:(nullable ThingFailureHandler)failure;

- (void)fetchResetKeyWithUUID:(NSString *)UUID
                     shortUrl:(NSString *)shortUrl
                      success:(nullable ThingSmartBLEDevcieCheckHandler)success
                      failure:(nullable ThingFailureError)failure;

- (void)scanQRCodeToResetDeviceWithUUID:(NSString *)UUID
                       encryptedAuthKey:(NSString *)encryptedAuthKey
                                 random:(NSString *)random
                                success:(nullable ThingSuccessHandler)success
                                failure:(nullable ThingFailureError)failure;
@end

NS_ASSUME_NONNULL_END
