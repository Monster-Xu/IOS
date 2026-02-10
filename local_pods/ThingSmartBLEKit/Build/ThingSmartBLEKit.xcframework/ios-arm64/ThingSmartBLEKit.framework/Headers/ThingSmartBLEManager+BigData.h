//
//  ThingSmartBLEManager+BigData.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <ThingSmartBLECoreKit/ThingSmartBLEManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartBLEManager (BigData)

/// Sending parameters data to the BLE device, whilc make device report data through big data channels.
///
/// @param devId        The device Id for the device.
/// @param paramsDict   A dictionary of parameter, defined by the protocol party.
/// @param success      When  successfully, this block will be called success.
/// @param failure      This block will be called if some error occurred.
- (void)postBleBigDataChannel:(NSString *)devId params:(NSDictionary *)paramsDict success:(ThingSuccessHandler)success failure:(ThingFailureError)failure __deprecated_msg("This method is deprecated, Use postBleBigDataChannel: params:  progress: success: failure: instead");


/// Sending parameters data to the BLE device, whilc make device report data through big data channels.
///
/// @param devId        The device Id for the device.
/// @param paramsDict   A dictionary of parameter, defined by the protocol party.
/// @param progress     This  progress   block will be called if  report data revicein,progress   value is 0-100.
/// @param success      When  successfully, this block will be called success.
/// @param failure      This block will be called if some error occurred.
- (void)postBleBigDataChannel:(NSString *)devId params:(NSDictionary *)paramsDict  progress:(nullable ThingBLEBigDataProgressBlock)progress success:(ThingSuccessDict)success failure:(ThingFailureError)failure;


/// Sending parameters data to the BLE device, whilc make device report data through big data channels.
///
/// @param devId        The device Id for the device.
/// @param paramsDict   A dictionary of parameter, defined by the protocol party.
/// @param receivedDpsProgress     This  progress   block will be called if  report data revicein,progress   value is 0-100.
/// @param receivedDps      receivedDps will be called when the dps have been sent from device completed..
/// @param uploadClouldProgress     progress of upload cloud,progress   value is 0-100.
/// @param success      When successfully, this block will be called success.
/// @param failure      This block will be called if some error occurred.
- (void)postBleBigDataChannel:(NSString *)devId params:(NSDictionary *)paramsDict  receivedDpsProgress:(nullable ThingBLEBigDataProgressBlock)receivedDpsProgress
    receivedDps:(nullable void(^)(NSArray<NSDictionary *>* dpsArray))receivedDps
    uploadClouldProgress:(nullable ThingBLEBigDataProgressBlock)uploadClouldProgress
    success:(ThingSuccessDict)success failure:(ThingFailureError)failure;

/// Send delete command to the BLE device, which delete data in device and will delete cache data.
/// @Param devId The device Id for the device.
/// @param success      When successfully, this block will be called success.
/// @param failure      This block will be called if some error occurred.
- (void)deleteBleBigDataChannel:(NSString *)devId success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END
