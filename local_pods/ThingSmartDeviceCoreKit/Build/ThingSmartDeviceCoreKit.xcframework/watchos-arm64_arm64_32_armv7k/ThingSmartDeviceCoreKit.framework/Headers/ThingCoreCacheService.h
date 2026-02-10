//
//  ThingCoreCacheService.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>
#import "ThingSmartDeviceAdvancedAbility.h"

NS_ASSUME_NONNULL_BEGIN

/// The delegate of the ThingCoreCacheService class provides the callback of device or group status.
@protocol ThingCoreCacheServiceDelegate <NSObject>

- (void)deviceDidAdd:(ThingSmartDeviceModel *)deviceModel;
- (void)deviceListDidAdd:(NSArray<ThingSmartDeviceModel *> *)deviceList;
- (void)deviceDidRemove:(NSString *)devId;

- (void)groupDidAdd:(ThingSmartGroupModel *)groupModel;
- (void)groupDidRemove:(long long)groupId;

@end

/// @brief The devices and group core cache classes allow you to add, modify, and delete data models. You can also subscribe to MQTT messages.
@interface ThingCoreCacheService : NSObject

ThingSDK_SINGLETON;

@property (nonatomic, weak) id<ThingCoreCacheServiceDelegate> delegate;

/// The device cache.
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, ThingSmartDeviceModel *> *deviceData;

/// The group caching.
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, ThingSmartGroupModel *> *groupData;

/// The group product information cache.
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSDictionary *> *groupProductData;

/// The group device relationship cache.
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *groupDeviceRelation;

/// The mesh information.
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, ThingSmartBleMeshModel *> *meshData;

/// The mesh group information.
@property (nonatomic, strong, readonly) NSMutableDictionary *meshGroupAddData;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *,NSMutableSet *> *thirdMatterGateWayAndSubDict;

/// Sets the queue for processing the cached data.
///
/// @param queue The queue.
- (void)setCacheHandlerQueue:(dispatch_queue_t)queue;


/// Clears the cached data.
/// The asynchronous queue.
- (void)reset;

#pragma mark - device

/// Returns the device by device ID to synchronize device information.
/// The synchronous queue.
///
/// @param devId The device ID.
- (ThingSmartDeviceModel *)getDeviceInfoWithDevId:(NSString *)devId;

/// Returns the device by device uuid to synchronize device information.
/// The synchronous queue.
///
/// @param uuid The device uuid.
- (ThingSmartDeviceModel *)getDeviceInfoWithUUID:(NSString *)uuid;

/// Returns the device by device mac to synchronize device information.
/// The synchronous queue.
///
/// @param mac The device mac.
- (ThingSmartDeviceModel *)getDeviceInfoWithMac:(NSString *)mac;

/// Adds a device to the cache.
///
/// After you add the device to the cache, subscribe to the topic of the device's MQTT messages. Make sure that the local key and protocol version are both configured.
/// After the device is added, you can accept callbacks by implementing `deviceDidAdd:` of `ThingCoreCacheServiceDelegate`.
/// The tasks to add devices, subscribe to messages, and execute callbacks are run in the asynchronous thread.
/// The asynchronous queue.
///
/// @param deviceModel The model of the device to be added.
- (void)addDeviceModel:(ThingSmartDeviceModel *)deviceModel;


/// Adds a device to the cache.
///
/// After you add the device to the cache, subscribe to the topic of the device's MQTT messages. Make sure that the local key and protocol version are both configured.
/// During the process, you can set the completion block or implement the `deviceDidAdd:` of the proxy `ThingCoreCacheServiceDelegate` to handle the result of the event.
/// The completion block is called and followed by the delegate.
/// The tasks to add devices, subscribe to messages, block, and execute callbacks are run in the asynchronous thread.
/// The asynchronous queue.
///
/// @param deviceModel The device model to be added.
/// @param completion The callback after the completion of the join block.
- (void)addDeviceModel:(ThingSmartDeviceModel *)deviceModel completion:(nullable void (^)(ThingSmartDeviceModel *device))completion;


/// Adds multiple devices to the cache in an operation.
///
/// After you add the device to the cache, subscribe to the topic of each device's MQTT messages. Make sure that the local key and protocol version are both configured.
/// After the device is added, you can accept callbacks by implementing `deviceListDidAdd:` of `ThingCoreCacheServiceDelegate`.
/// The tasks to add devices, subscribe to messages, and execute callbacks are run in the asynchronous thread.
/// The asynchronous queue.
///
/// @param deviceModelList The group of devices to be added
- (void)addDeviceModelList:(NSArray<ThingSmartDeviceModel *> *)deviceModelList;


/// Adds multiple devices to the cache in an operation.
///
/// After you add the device to the cache, subscribe to the topic of each device's MQTT messages. Make sure that the local key and protocol version are both configured.
/// During the process, you can set the completion block or implement the `deviceListDidAdd:` of the proxy `ThingCoreCacheServiceDelegate` to handle the result of the event.
/// The completion block is called and followed by the delegate.
/// The tasks to add devices, subscribe to messages, and execute callbacks are run in the asynchronous thread.
/// The asynchronous queue.
///
/// @param deviceModelList The group of devices to be added.
/// @param completion The callback after the completion of the join block.
- (void)addDeviceModelList:(NSArray<ThingSmartDeviceModel *> *)deviceModelList completion:(nullable void (^)(NSArray<ThingSmartDeviceModel *> *deviceList))completion;


/// Deletes the cached data of the device by device ID.
///
/// If the data is already deleted, the deletion task is not run to avoid duplicate operations.
/// After the deletion, the subscription to the MQTT topic of the device is canceled.
/// During the deletion process, you can handle the result of the event by implementing `deviceDidRemove:` of `ThingCoreCacheServiceDelegate`.
/// The tasks to delete devices, unsubscribe from messages, and execute callbacks are run in the asynchronous thread.
/// The asynchronous queue.
///
/// @param devId The ID of the device to be removed.
- (void)removeDeviceWithDevId:(NSString *)devId;


/// Delete the cached data of the device by device ID.
///
/// If the data is already deleted, the deletion task is not run to avoid duplicate operations.
/// After deletion, the subscription to the MQTT topic of the device is canceled.
/// During the deletion process, you can set the completion block or implement `deviceDidRemove:` as a proxy for `ThingCoreCacheServiceDelegate` to handle the result of the event.
/// The completion block is called and followed by the delegate.
/// The tasks to add devices, subscribe to messages, block, and execute callbacks are run in the asynchronous thread.
/// The asynchronous queue.
///
/// @param devId The device ID to be deleted.
/// @param completion The callback block after the completion of the deletion.
- (void)removeDeviceWithDevId:(NSString *)devId completion:(nullable void (^)(NSString *devId))completion;


/// Returns all devices in the cache.
/// The synchronous queue.
- (NSArray <ThingSmartDeviceModel *> *)getAllDeviceList;

#pragma mark - device ota

/// Updates the over-the-air (OTA) information.
/// @param otaList A list of device OTA information.
- (void)updateDeviceOtaInfoWithList:(NSArray<ThingSmartDeviceOTAModel *> *)otaList;

/// Updates the over-the-air (OTA) information.
/// @param otaList A list of device OTA information.
/// @param completion The callback block after the completion of the update.
- (void)updateDeviceOtaInfoWithList:(NSArray<ThingSmartDeviceOTAModel *> *)otaList
                         completion:(nullable void (^)(NSArray<ThingSmartDeviceOTAModel *> *))completion;

/// Returns a device OTA information.
/// @param devId The device ID.
- (ThingSmartDeviceOTAModel *)getDeviceOtaInfoWithDevId:(NSString *)devId;

/// update the over-the-air (OTA) information.
/// @param otaModel device OTA information.
- (void)updateDeviceOtaMode:(ThingSmartDeviceOTAModel *)otaModel;

/// update the over-the-air (OTA) information.
/// @param otaModel device OTA information.
/// @param completion The callback block after the completion of the update.
- (void)updateDeviceOtaModel:(ThingSmartDeviceOTAModel *)otaModel
                  completion:(nullable void (^)(ThingSmartDeviceOTAModel *))completion;


/// Verify that the SN of the current device is valid. If yes is returned, the cache is updated
/// @param message mqtt message
- (BOOL)validateCachRoamDeviceSN:(NSDictionary *)message;


#pragma mark - group


/// Returns the group cache information by group ID.
/// The synchronous queue.
///
/// @param groupId The group ID.
- (ThingSmartGroupModel *)getGroupInfoWithGroupId:(long long)groupId;


/// Adds a group to the cache.
///
/// After you add the group to the cache, subscribe to the topic of the group's MQTT messages. Make sure that the local key and protocol version are both configured.
/// After the group is added, you can accept callbacks by implementing `groupDidAdd:` of `ThingCoreCacheServiceDelegate`.
/// The tasks to add groups, subscribe to messages, and execute callbacks are run in the asynchronous threads.
/// The asynchronous queue.
///
/// @param groupModel The group model to be added.
- (void)addGroupModel:(ThingSmartGroupModel *)groupModel;


//// Adds a group to the cache.
///
/// After you add the group to the cache, subscribe to the topic of the group's MQTT messages. Make sure that the local key and protocol version are both configured.
/// During the process, you can set the completion block or implement the proxy `groupDidAdd:` of `ThingCoreCacheServiceDelegate` to handle the result of the event.
/// The completion block is called and followed by the delegate.
/// The tasks to add devices, subscribe to messages, and execute callbacks are run in the asynchronous thread.
/// The asynchronous queue.
///
/// @param groupModel The group model to be joined.
/// @param completion Callback after the completion of the join block.
- (void)addGroupModel:(ThingSmartGroupModel *)groupModel completion:(nullable void (^)(ThingSmartGroupModel *group))completion;


//// Deletes the cached data of a group by group ID.
///
/// If the group is already deleted, the deletion task is not run to avoid duplicate operations.
/// After deletion, the subscription to the MQTT topic of the device is canceled.
/// During the deletion process, you can handle the result of the event by implementing `groupDidRemove:` of `ThingCoreCacheServiceDelegate`.
/// The tasks to delete groups, unsubscribe from messages, and execute callbacks are run in the asynchronous thread.
/// The asynchronous queue.
///
/// @param groupId The device ID to be removed.
- (void)removeGroupWithGroupId:(long long)groupId;

/// Returns all groups in the cache.
/// The synchronous queue.
- (NSArray <ThingSmartGroupModel *> *)getAllGroupList;


#pragma mark - group product

/// Returns the group product information by product ID.
/// The synchronous queue.
///
/// @param productId The product ID.
- (NSDictionary *)getGroupProductWithProductId:(NSString *)productId DEPRECATED_MSG_ATTRIBUTE("Please use `getGroupProductWithProductId:productVer:` instead");


/// Returns the group product information by product ID and productVer .
/// @param productId The product ID.
/// @param productVer The product Version.
- (NSDictionary *)getGroupProductWithProductId:(NSString *)productId productVer:(NSString *)productVer;

/// Returns a list of devices in a group.
/// The synchronous queue.
///
/// @param groupId The group ID.
- (NSArray <ThingSmartDeviceModel *> *)getDeviceListWithGroupId:(long long)groupId;


/// Updates information about multiple products in an operation.
/// The asynchronous queue.
///
/// @param groupProductList A list of product information in the JSON format.
- (void)updateGroupProductList:(NSArray <NSDictionary *> *)groupProductList;


#pragma mark - [group - device] relation

/// The batch update group allows you to update device information relationships.
/// The asynchronous queue.
///
/// @param deviceList The device list.
/// @param groupId The group ID.
- (void)updateDeviceGroupRelationWithDeviceList:(NSArray *)deviceList groupId:(long long)groupId;


/// The batch update group allows you to update device information relationships.
/// The asynchronous queue.
///
/// @param deviceList The device list.
/// @param groupId The group ID.
/// @param shouldNotify Specifies whether to send notifications. If the value is set to `yes`, `kNotificationGroupUpdate` is sent.
- (void)updateDeviceGroupRelationWithDeviceList:(NSArray *)deviceList groupId:(long long)groupId shouldNotify:(BOOL)shouldNotify;

- (NSArray <ThingSmartDeviceModel *> *)getDeviceListWithHomeId:(long long)homeId;

#pragma mark - mesh

/// Returns the mesh information.
/// The synchronous queue.
///
/// @param meshId The mesh ID.
- (ThingSmartBleMeshModel *)getMeshModelWithMeshId:(NSString *)meshId;

/// Updates mesh information.
/// The synchronous queue.
///
/// @param meshModel The mesh information.
- (void)updateMeshModel:(ThingSmartBleMeshModel *)meshModel;

- (NSArray<ThingSmartBleMeshModel *> *)getAllMeshList;
- (NSInteger)getMeshGroupAddressFromLocalWithMeshId:(NSString *)meshId;
- (NSInteger)getMeshGroupCountFromLocalWithMeshId:(NSString *)meshId;
- (void)removeMeshGroupWithAddress:(NSInteger)address meshId:(NSString *)meshId;

#pragma mark - ThingLink
- (void)addThingModel:(ThingSmartThingModel *)model
           completion:(nullable void (^)(ThingSmartThingModel *thingModel))completion;

- (nullable ThingSmartThingModel *)getThingModelWithProductId:(NSString *)productId
                                              productVersion:(NSString *)productVersion;

#pragma mark - HighPower
- (void)addAdvancedAbilityModel:(ThingSmartDeviceAdvancedAbility *)model
                     completion:(nullable void (^)(ThingSmartDeviceAdvancedAbility *thingModel))completion;

- (BOOL)hasAdvancedAbilityWithDevId:(NSString *)devId code:(NSString *)code;

- (NSArray<ThingSmartDeviceAdvancedAbility *> *)getAbilityList;


- (void)processMatterThirdSubDevicesFromList:(NSArray<ThingSmartDeviceModel *> *)deviceModelList;
- (void)removeMatterThirdSubDeviceById:(NSString *)devId;

@end

NS_ASSUME_NONNULL_END
