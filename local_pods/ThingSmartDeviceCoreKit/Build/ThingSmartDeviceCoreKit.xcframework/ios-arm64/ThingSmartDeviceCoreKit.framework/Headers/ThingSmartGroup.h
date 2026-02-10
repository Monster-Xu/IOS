//
//  ThingSmartGroup.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#ifndef ThingSmart_ThingSmartGroup
#define ThingSmart_ThingSmartGroup

#import <Foundation/Foundation.h>
#import "ThingSmartGroupModel.h"
#import "ThingSmartGroupDevListModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface ThingSmartGroupAddParams : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *productId;
@property (nonatomic, strong) NSString *productVer;
@property (nonatomic, assign) long long homeId;
@property (nonatomic, strong) NSArray<NSString *>  *devIdList;
@property (nonatomic, assign) ThingSmartGroupType groupType;
@property (nonatomic, strong) ThingSmartDeviceModel *deviceModel;
@end


@class ThingSmartGroup;

/// The delegate of the ThingSmartGroup class provides the callback of group status updates.
@protocol ThingSmartGroupDelegate<NSObject>

@optional

/// The update of group DPs data.
/// @param group The instance of ThingSmartGroup.
/// @param dps The DPs.
- (void)group:(ThingSmartGroup *)group dpsUpdate:(NSDictionary *)dps;

/// The group information update.
/// @param group The instance of ThingSmartGroup.
- (void)groupInfoUpdate:(ThingSmartGroup *)group;

/// Removes the group.
/// @param groupId The group ID.
- (void)groupRemove:(NSString *)groupId;

/// The update of group DP data.
/// @param group The instance of ThingSmartGroup.
/// @param dpCodes The DP codes.
- (void)group:(ThingSmartGroup *)group dpCodesUpdate:(NSDictionary *)dpCodes;

/// The group response of Zigbee devices that join the gateway. `1`: exceeds the scenario limit. `2`: sub-device timeout. `3`: specified value out of range. `4`: file writing error. `5`: other errors.
/// @param group The instance of ThingSmartGroup.
/// @param responseCode The response code.
- (void)group:(ThingSmartGroup *)group addResponseCode:(NSArray <NSNumber *>*)responseCode;

/// The group response of Zigbee devices that are removed from the gateway. `1`: exceeds the scenario limit. `2`: sub-device timeout. `3`: specified value out of range. `4`: file writing error. `5`: other errors.
/// @param group The instance of ThingSmartGroup.
/// @param responseCode The response code.
- (void)group:(ThingSmartGroup *)group removeResponseCode:(NSArray <NSNumber *>*)responseCode;

@end

/// @brief The group of smart devices allows you to create groups, send group commands, and update basic group information.
///
/// You can add multiple devices with the same functions to a group and simultaneously control the devices.
///
@interface ThingSmartGroup : NSObject

/// Returns the basic group information model.
@property (nonatomic, strong, readonly) ThingSmartGroupModel *groupModel;

@property (nonatomic, weak, nullable) id<ThingSmartGroupDelegate> delegate;

/// Returns the ThingSmartGroup instance.
/// @param groupId The group ID.
+ (nullable instancetype)groupWithGroupId:(NSString *)groupId;

/// Returns the ThingSmartGroup instance.
/// @param groupId The group ID.
- (nullable instancetype)initWithGroupId:(NSString *)groupId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// Creates groups of Wi-Fi devices.
/// @param groupAddParams The group params
/// @param success  Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
+ (void)createGroupWithParams:(ThingSmartGroupAddParams *)groupAddParams
                      success:(nullable void (^)(ThingSmartGroup *group))success
                      failure:(nullable ThingFailureError)failure;

+ (void)createGroupWithParams:(ThingSmartGroupAddParams *)groupAddParams
                      process:(void(^)(NSDictionary<NSString *,NSNumber *> *))process
                      success:(nullable void (^)(ThingSmartGroup *group))success
                      failure:(nullable ThingFailureError)failure;

/// Returns the device list that belongs to the specified group based on productId.
/// @param productId The product ID.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)getDevList:(NSString *)productId
           success:(nullable void(^)(NSArray <ThingSmartGroupDevListModel *> *list))success
           failure:(nullable ThingFailureError)failure;

/// Sends group control commands.
/// @param dps The DPs.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)publishDps:(NSDictionary *)dps success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

+ (void)getBLEMeshDevListWithDeviceModel:(ThingSmartDeviceModel *)deviceModel
                                 success:(nullable void(^)(NSArray <ThingSmartGroupDevListModel *> *list))success
                                 failure:(nullable ThingFailureError)failure;

/// Sends control commands to the group.
///
/// @param dpCodes The DP codes.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)publishDpCodes:(NSDictionary *)dpCodes success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

/// Renames the group name.
/// @param name The group name.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)updateGroupName:(NSString *)name success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

/// Edits the group icon.
/// @param icon The group icon.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)updateIcon:(UIImage *)icon
           success:(nullable ThingSuccessHandler)success
           failure:(nullable ThingFailureError)failure;

/// Edits the group icon.
/// @param cloudKey The cloud key.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)updateIconWithCloudKey:(NSString *)cloudKey
                       success:(nullable ThingSuccessHandler)success
                       failure:(nullable ThingFailureError)failure;

/// Modifies the device list of the group.
/// @param devList The device list.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)updateGroupRelations:(NSArray <NSString *>*)devList
                     success:(nullable ThingSuccessHandler)success
                     failure:(nullable ThingFailureError)failure;


- (void)updateBLEMeshGroupRelations:(NSArray <NSString *>*)devList
                            process:(void(^)(NSDictionary<NSString *,NSNumber *> *))process
                            success:(nullable ThingSuccessHandler)success
                            failure:(nullable ThingFailureError)failure;

/// Removes the group.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)dismissGroup:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;


#pragma mark - zigbee

#if TARGET_OS_IOS

/// Adds sub-devices to groups that locally interact with gateways.
/// @param nodeList A list of sub-device node IDs.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)addSubDeviceWithSubDeviceNodeList:(NSArray <NSString *>*)nodeList
                                  success:(nullable ThingSuccessHandler)success
                                  failure:(nullable ThingFailureError)failure;

/// Removes sub-devices from groups that locally interact with gateways.
/// @param nodeList  A list of sub-device node IDs.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)removeSubDeviceWithSubDeviceNodeList:(NSArray <NSString *>*)nodeList
                                     success:(nullable ThingSuccessHandler)success
                                     failure:(nullable ThingFailureError)failure;

#endif

+ (void)syncGroupInfoWithGroupId:(NSString *)groupId
                         success:(nullable void (^)(ThingSmartGroupModel *group))success
                         failure:(nullable ThingFailureError)failure;

/// Cancels the request.
- (void)cancelRequest;


@end

NS_ASSUME_NONNULL_END

#endif
