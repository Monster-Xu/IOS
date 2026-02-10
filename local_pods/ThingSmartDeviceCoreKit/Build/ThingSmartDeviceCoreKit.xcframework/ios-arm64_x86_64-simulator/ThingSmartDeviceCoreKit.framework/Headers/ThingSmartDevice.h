//
//  ThingSmartDevice.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#ifndef ThingSmart_ThingSmartDevice
#define ThingSmart_ThingSmartDevice

#import <UIKit/UIKit.h>
#import <ThingSmartUtil/ThingSmartUtil.h>
#import "ThingSmartFirmwareUpgradeModel.h"
#import "ThingSmartFirmwareUpgradeStatusModel.h"
#import "ThingSmartDeviceModel.h"
#import "ThingSmartMQTTMessageModel.h"
#import "ThingSmartLanMessageModel.h"
#import "ThingSmartBackupWifiModel.h"
#import "ThingSmartDeviceOTAModel.h"

NS_ASSUME_NONNULL_BEGIN

/// The device online status.
typedef enum : NSUInteger {
    /// Connected to a LAN.
    ThingDeviceOnlineModeLocal,
    /// Connected to the Internet.
    ThingDeviceOnlineModeInternet,
    /// Goes offline.
    ThingDeviceOnlineModeOffline,
} ThingDeviceOnlineMode;

/// The DP sending channel.
typedef enum : NSUInteger {
    /// Over the LAN.
    ThingDevicePublishModeLocal,
    /// Over the Internet.
    ThingDevicePublishModeInternet,
    /// Automatically selects a channel to send DPs.
    ThingDevicePublishModeAuto,
} ThingDevicePublishMode;

typedef NS_ENUM(NSUInteger, ThingSmartThingMessageType) {
    /// Property thing message.
    ThingSmartThingMessageTypeProperty,
    /// Action thing message.
    ThingSmartThingMessageTypeAction,
    /// Event thing message.
    ThingSmartThingMessageTypeEvent,
};

/// Low power device awake response.
typedef NS_ENUM(NSUInteger, ThingSmartLowPowerAwakeRsp) {
    /// Device not support low power awake
    ThingSmartLowPowerAwakeRspUnsupport = 1,
    /// Device awake success
    ThingSmartLowPowerAwakeRspSuccess = 2,
    /// Device awake timeout
    ThingSmartLowPowerAwakeRspTimeout = 3,
};

@class ThingSmartDevice;

/// The delegate for the ThingSmartDevice class, used for getting all device status updates.
@protocol ThingSmartDeviceDelegate<NSObject>

@optional

/// Device information updates, such as the name and online status.
/// @param device The device instance.
- (void)deviceInfoUpdate:(ThingSmartDevice *)device;

/// Device online status updates
/// @param device The device instance.
- (void)deviceOnlineUpdate:(ThingSmartDevice *)device;

/// Indicates whether the device is removed.
/// @param device The device instance.
- (void)deviceRemoved:(ThingSmartDevice *)device;

/// The DP data updates.
/// @param device The device instance.
/// @param dps The command dictionary.
- (void)device:(ThingSmartDevice *)device dpsUpdate:(NSDictionary *)dps;

/// The DP data & DP time updates.
/// Note: If delegate implement this method, will not call the `-device:dpsUpdate:`.
/// @param device The device instance.
/// @param dps The command dictionary.
/// @param dpsTime The dps time dictionary, maybe nil or not contain some dpId's time.
- (void)device:(ThingSmartDevice *)device dpsUpdate:(NSDictionary *)dps dpsTime:(NSDictionary *)dpsTime;

/// The DP data updates.
/// @param device The device instance.
/// @param dpCodes The DP codes.
- (void)device:(ThingSmartDevice *)device dpCommandsUpdate:(NSDictionary *)dpCodes;

/// The group OTA task progress.
/// @param device The gateway instance.
/// @param groupId group OTA task id.
/// @param type The firmware type.
/// @param progress The update progress.
- (void)device:(ThingSmartDevice *)device groupOTAId:(long)groupId firmwareType:(NSInteger)type progress:(double)progress;

/// The group OTA task status.
/// @param device The gateway device instance.
/// @param upgradeStatusModel The model of the update status.
- (void)device:(ThingSmartDevice *)device
    groupOTAStatusModel:(ThingSmartFirmwareUpgradeStatusModel *)upgradeStatusModel;

/// The callback of Wi-Fi signal strength.
/// @param device The device instance.
/// @param signal The signal strength.
- (void)device:(ThingSmartDevice *)device signal:(NSString *)signal;

/// Receives MQTT custom messages.
/// @param device The device instance.
/// @param message The custom message.
- (void)device:(ThingSmartDevice *)device didReceiveCustomMessage:(ThingSmartMQTTMessageModel *)message;

/// Receives LAN custom messages.
- (void)device:(ThingSmartDevice *)device didReceiveLanMessage:(ThingSmartLanMessageModel *)message;

/// The delegate of warning information updates.
/// @param device The device instance.
/// @param warningInfo The warning information.
- (void)device:(ThingSmartDevice *)device warningInfoUpdate:(NSDictionary *)warningInfo;

/// The delegate of changes in device normal firmware/pid version update's status/progress
/// Notice: sometimes the progress may <0, when it occured please ignore the progress.
/// @param device The device instance.
/// @param statusModel status/progress model.
- (void)device:(ThingSmartDevice *)device otaUpdateStatusChanged:(ThingSmartFirmwareUpgradeStatusModel *)statusModel;

/// The thing message data update.
/// Example:
///     type == property:
///         payload = {
///           "code_name1": {
///             "value": "code_value1",
///             "time": 1234567890
///           },
///           "code_name2": {
///             "value": 50,
///             "time": 1234567890
///           }
///         }
///     type == action:
///         payload = {
///            "actionCode": "testAction",
///            "outputParams": {
///              "outputParam1":"outputValue1",
///              "outputParam2":50
///            }
///         }
///     type == event:
///         payload = {
///            "eventCode": "testEvent",
///            "outputParams": {
///              "outputParam1":["outputValue1", "outputValue2"],
///              "outputParam2":false
///            }
///         }
/// @param device The device instance.
/// @param thingMessageType The message type.
/// @param payload The message payload.
- (void)device:(ThingSmartDevice *)device didReceiveThingMessageWithType:(ThingSmartThingMessageType)thingMessageType payload:(NSDictionary *)payload;

#pragma mark - deprecated

/// The firmware update progress.
/// @param device The device instance.
/// @param type The device type.
/// @param progress The update progress.
- (void)device:(ThingSmartDevice *)device firmwareUpgradeProgress:(NSInteger)type progress:(double)progress __deprecated_msg("This method is deprecated, Use device:otaUpdateStatusChanged: instead");

/// The delegate of changes in device firmware update status.
/// @param device The device instance.
/// @param upgradeStatusModel The model of the device update status.
- (void)device:(ThingSmartDevice *)device firmwareUpgradeStatusModel:(ThingSmartFirmwareUpgradeStatusModel *)upgradeStatusModel __deprecated_msg("This method is deprecated, Use device:otaUpdateStatusChanged: instead");

/// The delegate of changes in device firmware update status.
/// @param device The device instance.
/// @param type The device type.
/// @param upgradeStatus The device update status.
/// @deprecated This method is deprecated. Use ThingSmartDeviceDelegate::device:firmwareUpgradeStatusModel: instead.
- (void)device:(ThingSmartDevice *)device type:(NSInteger)type upgradeStatus:(ThingSmartDeviceUpgradeStatus)upgradeStatus __deprecated_msg("This method is deprecated, Use device:firmwareUpgradeStatusModel: instead");

/// Success of device firmware updates.
/// @param device The device instance.
/// @param type The device type.
/// @deprecated This method is deprecated. Use ThingSmartDeviceDelegate::device:upgradeStatus: instead.
- (void)deviceFirmwareUpgradeSuccess:(ThingSmartDevice *)device type:(NSInteger)type __deprecated_msg("This method is deprecated, Use device:upgradeStatus: instead");

/// Failure of device firmware updates.
/// @param device The device instance.
/// @param type The device type.
/// @deprecated This method is deprecated. Use ThingSmartDeviceDelegate::device:upgradeStatus: instead.
- (void)deviceFirmwareUpgradeFailure:(ThingSmartDevice *)device type:(NSInteger)type __deprecated_msg("This method is deprecated, Use device:upgradeStatus: instead");

/// Device firmware updating.
/// @param device The device instance.
/// @param type The device type.
/// @deprecated This method is deprecated. Use ThingSmartDeviceDelegate::device:upgradeStatus: instead.
- (void)deviceFirmwareUpgrading:(ThingSmartDevice *)device type:(NSInteger)type __deprecated_msg("This method is deprecated, Use device:upgradeStatus: instead");

@end

/// @brief The basic operation class of ThingSmartDevice contains the model of basic information, including the device, DPs to send, update device information, and other common API operations.
///  
/// All types of devices can be controlled after you initialize an instance of this class if the function is supported.
///  
@interface ThingSmartDevice : NSObject
/// Returns the device id.
@property (nonatomic, strong, readonly) NSString *devId;
/// Returns the model of basic device information.
@property (nonatomic, strong, readonly) ThingSmartDeviceModel *deviceModel;

@property (nonatomic, weak, nullable) id<ThingSmartDeviceDelegate> delegate;

/// Returns the ThingSmartDevice instance. If the current user does not have this device, a value of nil is returned.
/// @param devId The device ID.
+ (nullable instancetype)deviceWithDeviceId:(NSString *)devId;

/// Returns the ThingSmartDevice instance. If the current user does not have this device, a value of nil is returned.
/// @param devId The device ID.
- (nullable instancetype)initWithDeviceId:(NSString *)devId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// Returns the device online status.
- (ThingDeviceOnlineMode)onlineMode;

/// Sends DPs.
/// @param dps The DP dictionary.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)publishDps:(NSDictionary *)dps
           success:(nullable ThingSuccessHandler)success
           failure:(nullable ThingFailureError)failure;

/// Sends DPs.
/// @param dps The DP dictionary.
/// @param mode Publish mode(Lan/Internet/Auto).
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)publishDps:(NSDictionary *)dps
              mode:(ThingDevicePublishMode)mode
           success:(nullable ThingSuccessHandler)success
           failure:(nullable ThingFailureError)failure;

/// Sends DPs.
/// @param dps The dp dictionary.
/// @param communicationTypes Use communication order to publish dps. (Array element's value  reference enum ThingCommunicationType)
/// @param success Called when the task finishes successfully.
/// @param failure Called when the task is interrupted by an error.
- (void)publishDps:(NSDictionary *)dps
communicationTypes:(NSArray *)communicationTypes
           success:(nullable ThingSuccessHandler)success
           failure:(nullable ThingFailureError)failure;

/// Edits the device name.
/// @param name The device name.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)updateName:(NSString *)name
           success:(nullable ThingSuccessHandler)success
           failure:(nullable ThingFailureError)failure;

/// Edits the device icon.
/// @param icon The device icon.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)updateIcon:(UIImage *)icon
           success:(nullable ThingSuccessHandler)success
           failure:(nullable ThingFailureError)failure;

/// Edits the device icon.
/// @param cloudKey The cloud key.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
/// @deprecated This method is deprecated. Use ThingSmartDevice::updateIconWithURL:success:failure instead.
- (void)updateIconWithCloudKey:(NSString *)cloudKey
                       success:(nullable ThingSuccessHandler)success
                       failure:(nullable ThingFailureError)failure __deprecated_msg("This method is deprecated, Use -[ThingSmartDevice -  updateIconWithURL:success:failure] instead");

/// Edits the device icon.
/// @param url The icon url.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)updateIconWithURL:(NSString *)url
                  success:(nullable ThingSuccessHandler)success
                  failure:(nullable ThingFailureError)failure;

/// Synchronizes device information.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)syncWithCloud:(nullable ThingSuccessHandler)success
              failure:(nullable ThingFailureError)failure;


/// Synchronizes device information.
/// @param devId The device ID.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
+ (void)syncDeviceInfoWithDevId:(NSString *)devId
                        success:(nullable void (^)(ThingSmartDeviceModel *device))success
                        failure:(nullable ThingFailureError)failure;

/// Synchronizes sub-device information.
/// @param gatewayId The gateway ID.
/// @param devId The device ID.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
+ (void)syncSubDeviceInfoWithGatewayId:(NSString *)gatewayId
                                 devId:(NSString *)devId
                               success:(nullable ThingSuccessHandler)success
                               failure:(nullable ThingFailureError)failure;

/// Synchronizes the localKey of the device.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
+ (void)syncSubDeviceLocalKeyWithGatewayId:(NSString *)gatewayId nodeIds:(NSArray<NSString *> *)nodeId success:(nullable ThingSuccessList)success failure:(nullable ThingFailureError)failure;

/// Synchronizes product info for productKey or uuid
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
+ (void)syncProductInfoWithProductID:(NSString *)productId uuid:(NSString *)uuid mac:(NSString *)mac success:(ThingSuccessID)success failure:(ThingFailureError)failure;

/// Synchronizes product ext info for pids.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
+ (void)syncProductExtInfoWithPid:(NSArray <NSString *> *)pids success:(ThingSuccessID)success failure:(ThingFailureError)failure;

/// Removes the device and unbinds the device from the current user.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)remove:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

/// Only the device is deleted from the cloud. The device is not reset
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)removeFromCloud:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

/// Restores factory settings.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)resetFactory:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

/// Delete device and clear data from cloud. The device is not reset
/// @param success  Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)resetFactoryFromCloud:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

/// Returns a sub-device list of the current gateway.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)getSubDeviceListFromCloudWithSuccess:(nullable void (^)(NSArray <ThingSmartDeviceModel *> *subDeviceList))success failure:(nullable ThingFailureError)failure;

/// Synchronizes the longitude and latitude of the mobile phone to the device.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)syncLocationToDeviceWithSucecess:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

#pragma mark - firmware upgrade

/// Returns firmware update information.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)getFirmwareUpgradeInfo:(nullable void (^)(NSArray <ThingSmartFirmwareUpgradeModel *> *upgradeModelList))success
                       failure:(nullable ThingFailureError)failure __deprecated_msg("This method is deprecated, Use -[ThingSmartDevice checkFirmwareUpgrade:failure:] instead");

/// Updates the firmware and receives a success or failure callback from ThingSmartDeviceDelegate.
/// @param type The device type of "ThingSmartFirmwareUpgradeModel".
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)upgradeFirmware:(NSInteger)type success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure __deprecated_msg("This method is deprecated, Use -[ThingSmartDevice startFirmwareUpgrade:] instead");

/// Cancels the firmware updates. Only the update tasks that have not been published can be canceled.
/// @param type The device type of `ThingSmartFirmwareUpgradeModel`.
/// @param success  Called when the task is finished.
/// @param failure  Called when the task is interrupted by an error.
- (void)cancelUpgradeFirmware:(NSInteger)type success:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure __deprecated_msg("This method is deprecated, Use -[ThingSmartDevice cancelFirmwareUpgrade:failure:] instead");

/// Cancels the firmware update request.
- (void)cancelFirmwareRequest __deprecated_msg("This method is deprecated");

/// Reports the device firmware version.
/// @param version The device version.
/// @param type The device type.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)updateDeviceVersion:(NSString *)version
                       type:(NSInteger)type
                    success:(nullable ThingSuccessHandler)success
                    failure:(nullable ThingFailureError)failure;

/// Returns the switch value for the automatic device OTA updates.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)getAutoUpgradeSwitchInfoWithSuccess:(nullable ThingSuccessID)success
                                    failure:(nullable ThingFailureError)failure;

/// Saves the switch value for automatic device over-the-air (OTA) updates.
/// @param switchValue The value of the auto switch. 0 means off, and 1 means on.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)saveUpgradeInfoWithSwitchValue:(NSInteger)switchValue
                               success:(nullable ThingSuccessHandler)success
                               failure:(nullable ThingFailureError)failure;


/// Manages the device custom data, such as recording and storing of custom data information.
/// @param success  Called when the task is finished. The device property is returned.
/// @param failure Called when the task is interrupted by an error.
- (void)getDevPropertyWithSuccess:(ThingSuccessDict)success
                          failure:(nullable ThingFailureError)failure;


/// Sets the device custom data to record and store custom data information.
/// @param code The custom data key.
/// @param value The custom data value.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)setDevPropertyWithCode:(NSString *)code
                         value:(id)value
                       success:(ThingSuccessBOOL)success
                       failure:(nullable ThingFailureError)failure;

- (void)queryWifiSignalStrengthWithSuccess:(nullable ThingSuccessInt)success failure:(nullable ThingFailureError)failure;

#if TARGET_OS_IOS

/// Returns the Wi-Fi signal strength. Receives the signal strength from `-[ThingSmartDeviceDelegate device:signal:]`.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)getWifiSignalStrengthWithSuccess:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

/// Publishes messages over the LAN.
/// @param body The message body.
/// @param type The message type.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)publishMessageInLanWithBody:(NSDictionary *)body
                               type:(NSInteger)type
                            success:(nullable ThingSuccessDict)success
                            failure:(nullable ThingFailureError)failure;

/// Queries the DPs. Some DPs do not report the initial data when settings are changed.
/// @param dpsArray The array of DP IDs. If the value is set to nil or an empty array, all DPs are queried.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)getInitiativeQueryDpsInfoWithDpsArray:(nullable NSArray *)dpsArray
                                      success:(nullable ThingSuccessHandler)success
                                      failure:(nullable ThingFailureError)failure;

/// Awakes the low-energy device.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)awakeDeviceWithSuccess:(nullable ThingSuccessHandler)success failure:(nullable ThingFailureError)failure;

#pragma mark - publish custom message

/// Subscribes to the topic.
/// @param topic the topic
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)subscribeToTopic:(NSString *)topic success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

/// unSubscribes to the topic.
/// @param topic the topic
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)unsubscribeToTopic:(NSString *)topic success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

/// Adds the custom message delegate. Receives the custom message from `- (void)device:(ThingSmartDevice *)device didReceiveCustomMessage:(ThingSmartMQTTMessageModel *)message`.
/// @param delegate The delegate of ThingSmartDevice.
/// @param protocol The protocol.
- (void)addDelegate:(id<ThingSmartDeviceDelegate>)delegate forProtocol:(NSInteger)protocol;

/// Removes the custom message delegate.
/// @param delegate The delegate of ThingSmartDevice.
/// @param protocol The protocol.
- (void)removeDelegate:(id<ThingSmartDeviceDelegate>)delegate forProtocol:(NSInteger)protocol;

/// Sends custom messages.
/// @param data The data.
/// @param protocol The protocol.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)publishCustomMessageWithData:(NSDictionary *)data
                            protocol:(NSInteger)protocol
                             success:(nullable ThingSuccessHandler)success
                             failure:(nullable ThingFailureError)failure;

#endif

/// Sends DPs.
/// @param commands The dictionary of DP values.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)publishDpWithCommands:(NSDictionary *)commands
                      success:(nullable ThingSuccessHandler)success
                      failure:(nullable ThingFailureError)failure;

#pragma mark - ThingLink
/// Get thing model from cloud and update cache.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)getThingModelWithSuccess:(nullable void(^)(ThingSmartThingModel * _Nullable thingModel))success
                         failure:(nullable ThingFailureError)failure;

/// Get thing model from cloud and update cache.
/// @param pid productId
/// @param productVersion product version
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
+ (void)getThingModelWithProductId:(NSString *)pid
                    productVersion:(NSString *)productVersion
                           success:(nullable void (^)(ThingSmartThingModel * _Nullable thingModel))success
                           failure:(nullable ThingFailureError)failure;

/// Publish the thing message
/// Example:
///     type == property:
///         payload = {
///           "color":"green",
///           "brightness": 50
///         }
///     type == action:
///         payload = {
///            "actionCode": "testAction",
///            "inputParams": {
///              "inputParam1":"value1",
///              "inputParam2":"value2"
///            }
///         }
/// @param thingMessageType thing message type
/// @param payload message payload
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)publishThingMessageWithType:(ThingSmartThingMessageType)thingMessageType
                            payload:(NSDictionary *)payload
                            success:(ThingSuccessHandler)success
                            failure:(ThingFailureError)failure;


/// Query the device operate log
///
/// @param dpIds the dp id array, such as @[@"1", @"2"]
/// @param offset offset
/// @param limit limit
/// @param startTime startTime
/// @param endTime endTime
/// @param isASC  YES=ASC  NO=DESC
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)queryDeviceOperateLogWithDpIds:(NSArray *)dpIds
                                offset:(NSInteger)offset
                                 limit:(NSInteger)limit
                             startTime:(NSDate *)startTime
                               endTime:(NSDate *)endTime
                                 isASC:(BOOL)isASC
                               success:(ThingSuccessID)success
                               failure:(ThingFailureError)failure;


/// Publish dps cached in the cloud, and then the device itself requests to pull OR receives push from cloud.
///
/// **Note: Only suitable for low-power device.**
/// When the device is dormant, sending dps through this API will be cached in the cloud for a period of time.
/// When the device wakes up within the validity period, the device can get the cached `dps`.
///
/// @param dps The DP dictionary.
/// @param validity The cached dps validity period. (Unit: second, Range: 1 ~ 172800).
/// @param dpCacheType The dps cache type. ( `0`: device itself requests to pull, `1`: device receives push from cloud).
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)sendCacheDps:(NSDictionary *)dps
            validity:(NSUInteger)validity
         dpCacheType:(NSUInteger)dpCacheType
             success:(ThingSuccessID)success
             failure:(ThingFailureError)failure;

/// Suitable infrared control device publish dps. (only for scene lan action.)
/// When publish success, will update dps to cloud and local manually.
///
/// **Note: Only suitable for infrared device to excute scene lan action. **
///
/// @param subDevId The sub device id.
/// @param actionDps The action dps.
/// @param reportDps The report dps.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)infraredPublishDps:(NSString *)subDevId
                 actionDps:(NSDictionary *)actionDps
                 reportDps:(NSDictionary *)reportDps
                   success:(nullable ThingSuccessHandler)success
                   failure:(nullable ThingFailureError)failure;


/// Publishes transport data.
/// @param subCmdData sub cmd data.
/// @param payloadData payload data.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)publishDpsUseTransportSubCmd:(nullable NSData *)subCmdData
                         payloadDict:(nullable NSDictionary *)payloadData
                             success:(ThingSuccessHandler)success
                             failure:(ThingFailureError)failure;

/// Low power device awake.
///
/// ** Note: Suitable for the device which `- supportLowPowerWakeUp` return YES. **
///
/// @param timeout The timeout. ( If timeout <= 0, then we use default 10s. )
/// @param handler Called when the task is finished.
- (void)lowPowerDeviceAwakeWithTimeout:(NSInteger)timeout handler:(nullable void(^)(ThingSmartLowPowerAwakeRsp awakeRsp))handler;

- (void)sendMQTTDataByHttp:(NSUInteger)protocol
                   message:(NSString *)message
                   success:(ThingSuccessHandler)success
                   failure:(ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END

#endif
