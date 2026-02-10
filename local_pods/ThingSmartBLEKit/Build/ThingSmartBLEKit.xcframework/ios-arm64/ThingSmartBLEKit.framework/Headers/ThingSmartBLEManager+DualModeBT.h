//
//  ThingSmartBLEManager+DualModeBT.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <ThingSmartBLECoreKit/ThingSmartBLEManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartBLEManager (DualModeBT)
/// Get BT information, such as  name ，macaddress，connect status.
/// @param deviceId The device id
/// @param success                        Called when the task is finished. btModel is returned.
/// @param failure                        Called when the task is interrupted by an error.
- (void)queryBLEDualModeBTInfoWithDeviceId:(NSString *)deviceId
                                   success:(void(^)(ThingBLEDualModeBTModel *btModel))success
                                   failure:(ThingFailureError)failure;
@end

NS_ASSUME_NONNULL_END
