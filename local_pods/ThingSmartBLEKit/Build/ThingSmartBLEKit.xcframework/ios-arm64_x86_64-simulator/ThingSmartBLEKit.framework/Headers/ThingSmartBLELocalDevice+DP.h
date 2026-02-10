//
//  ThingSmartBLELocalDevice+DP.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//



NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartBLELocalDevice (DP)

- (void)publishDps:(NSDictionary *)dps success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END
