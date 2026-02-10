//
//  ThingSmartProduct.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ThingSmartDeviceReplaceType) {
    ThingSmartDeviceReplaceTypeGatewaySubDevice,
};

@interface ThingSmartDeviceReplaceJobModel : NSObject
@property (nonatomic, assign) long jobId;
@property (nonatomic, strong) NSString *operatorUid;
@property (nonatomic, assign) long groupId;
@property (nonatomic, strong) NSString *gwId;
@property (nonatomic, strong) NSString *existFaultSubDevGwId;
@property (nonatomic, strong) NSString *faultSubDevId;
@property (nonatomic, strong) NSString *replaceSubDevId;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *currentStatus;
@property (nonatomic, strong) NSString *result;
@property (nonatomic, strong) NSString *failReason;


@end

@interface ThingSmartDeviceReplacementService : NSObject

- (instancetype)initWithDeviceType:(ThingSmartDeviceReplaceType)deviceType;

- (void)subDevReplaceWithOriginalId:(NSString *)deviceId
                      replacementId:(NSString *)replacementId
                            timeout:(NSTimeInterval)timeout
                     triggerSuccess:(nullable void (^)(void))success
                            complete:(nullable void (^)(void))complete
                            failure:(nullable void (^)(NSError *error))failure __deprecated_msg("Use handleDeviceWithOriginalId:replacementId:success:complete:failure: instead.");

/// Queries the capability of a gateway to replace its sub-devices.
/// - Parameters:
///   - gwId: The gateway ID.
///   - success: The callback to be executed when the query is successful. It returns void.
///   - failure: The callback to be executed when the query fails. It returns an NSError object containing error information.
- (void)queryGatewayReplacementCapability:(NSString *)gwId
                                   success:(ThingSuccessBOOL)success
                                   failure:(ThingFailureError)failure;

/// Fetches the list of replaceable sub-devices for a specific faulty sub-device or a new sub-device.
/// - Parameters:
///   - faultSubDevId: The ID of the faulty sub-device. Pass either `faultSubDevId` or `newSubDevId`, not both.
///   - newSubDevId: The ID of the new sub-device intended to replace an existing one. Pass either `newSubDevId` or `faultSubDevId`, not both.
///   - success: The callback to be executed when the query is successful. It returns an NSArray of sub-device IDs.
///   - failure: The callback to be executed when the query fails. It returns an NSError object containing error information.

- (void)fetchReplaceableSubDevices:(NSString *)faultSubDevId
                       newSubDevId:(NSString *)newSubDevId
                           success:(nullable void (^)(NSArray<NSString *> *subDeviceIds))success
                           failure:(nullable void (^)(NSError *error))failure;


/// Handles the operation for a device with original and replacement IDs, with an option to delete the original device.
/// - Parameters:
///   - deviceId: The original device ID of the sub-device.
///   - replacementId: The replacement device ID for the sub-device.
///   - timeout: timeout default 30 seconds
///   - shouldDeleteOriginal:
///   - success: The callback to be executed when the operation is successful. It returns void.
///   - complete: The callback to be executed when the operation is complete, regardless of success or failure. It returns bool.
///   - failure: The callback to be executed when the operation fails. It returns an NSError object containing error information.
- (void)handleDeviceWithOriginalId:(NSString *)deviceId
                     replacementId:(NSString *)replacementId
                           timeout:(NSTimeInterval)timeout
                    deleteOriginal:(BOOL)shouldDeleteOriginal
                           success:(ThingSuccessString)success
                          complete:(ThingSuccessBOOL)complete
                           failure:(ThingFailureError)failure;

/// Fetches the replacement outcome for a given job ID.
/// - Parameters:
///   - jobId: The job ID for which to query the replacement result.
///   - success: The callback to be executed when the query is successful. It returns an ThingSmartDeviceReplaceJobModel  Model,result representing the result (0 -> In Progress, -1 -> Failed, 1 -> Succeeded).
///   - failure: The callback to be executed when the query fails. It returns an NSError object containing error information.
- (void)fetchReplacementOutcome:(NSString *)jobId
                        success:(nullable void (^)(ThingSmartDeviceReplaceJobModel *result))success
                        failure:(nullable void (^)(NSError *error))failure;

/// Fetches the replacement outcome for a given job ID.
/// - Parameters:
///   - jobId: The job ID for which to query the replacement result.
///   - success: The callback to be executed when the query is successful. It returns an ThingSmartDeviceReplaceJobModel  Model,result representing the result (0 -> In Progress, -1 -> Failed, 1 -> Succeeded).
///   - failure: The callback to be executed when the query fails. It returns an NSError object containing error information.
///   - timeout: When result = 0, wait complete callback time.
///   - complete: when result = 0, receive complete callback.
- (void)fetchReplacementOutcome:(NSString *)jobId
                        success:(nullable void (^)(ThingSmartDeviceReplaceJobModel *result))success
                        failure:(nullable void (^)(NSError *error))failure
                        timeout:(NSTimeInterval)timeout
                       complete:(ThingSuccessBOOL)complete;


@end

NS_ASSUME_NONNULL_END
