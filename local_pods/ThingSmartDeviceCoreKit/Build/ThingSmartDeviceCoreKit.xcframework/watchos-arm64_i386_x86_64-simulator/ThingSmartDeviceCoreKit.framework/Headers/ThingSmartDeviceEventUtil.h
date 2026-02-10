//
//  ThingSmartDeviceEventUtil.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The device category defined by inside rule. Just for event statistics.
typedef NS_ENUM(NSUInteger, ThingDeviceOSCategory) {
    ThingDeviceOSCategoryDefault       = 9999,
    
    ThingDeviceOSCategoryWifiPv2_0     = 1,
    ThingDeviceOSCategoryWifiPv2_1     = 2,
    ThingDeviceOSCategoryWifiPv2_2     = 3,
    ThingDeviceOSCategoryWifiPv2_3     = 4,
    ThingDeviceOSCategoryWifiPvUnknown = 5,
    
    ThingDeviceOSCategoryGPRS = 200,
    
    ThingDeviceOSCategoryNB   = 300,
    
    ThingDeviceOSCategoryBle       = 1000,
    ThingDeviceOSCategoryBleSub    = 1001,
    ThingDeviceOSCategoryBleWifi   = 1002,
    ThingDeviceOSCategoryBleCat1   = 1003,
    ThingDeviceOSCategoryBlePlugPlayFull  = 1004,
    ThingDeviceOSCategoryBlePlugPlayHalf  = 1005,
    ThingDeviceOSCategoryBleMultiuser     = 1006,
    ThingDeviceOSCategoryBleWifiMultiuser = 1007,
    
    ThingDeviceOSCategoryBleMesh    = 1100,
    ThingDeviceOSCategoryBleMeshSub = 1101,
    
    ThingDeviceOSCategoryZigBeeSub  = 1200,

    ThingDeviceOSCategoryInfraredWifi   = 1300,
    ThingDeviceOSCategoryInfraredZigBee = 1301,
    
    ThingDeviceOSCategory433        = 1400,
    ThingDeviceOSCategory433Gateway = 1401,
    
    ThingDeviceOSCategorySigMesh           = 1500,
    ThingDeviceOSCategorySigMeshSub        = 1501,
    ThingDeviceOSCategorySigMeshSingleFire = 1502,
    
    ThingDeviceOSCategoryCat1 = 2000,
    
    ThingDeviceOSCategoryBeacon    = 2100,
    ThingDeviceOSCategoryBeaconSub = 2101,
    
    ThingDeviceOSCategoryMatterGateway = 2500,
    ThingDeviceOSCategoryMatterThreadSub = 2501,
    ThingDeviceOSCategoryMatterDualMode = 2502,
    ThingDeviceOSCategoryMatterOrigin = 2503,
    
    ThingDeviceOSCategoryGatewayWifi  = 9000,
    ThingDeviceOSCategoryGatewayCable = 9001,
    ThingDeviceOSCategoryGatewaySigMeshElection = 9002,
    
    ThingDeviceOSCategoryGroupWifi    = 9100,
    ThingDeviceOSCategoryGroupBleMesh = 9101,
    ThingDeviceOSCategoryGroupZigBee  = 9102,
    ThingDeviceOSCategoryGroupSigMesh = 9103,
    ThingDeviceOSCategoryGroupBeacon  = 9104
};

typedef NS_ENUM(NSUInteger, ThingEventPipelineType) {
    /// LAN
    ThingEventPipelineTypeLAN      = 1,
    
    /// MQTT
    ThingEventPipelineTypeMQTT     = 2,
    
    /// HTTP
    ThingEventPipelineTypeHTTP     = 3,
    
    /// Single Point Bluetooth
    ThingEventPipelineTypeBLE      = 4,
    
    /// Sig Mesh
    ThingEventPipelineTypeSIGMesh  = 5,
    
    /// Thing Private Mesh
    ThingEventPipelineTypeBLEMesh  = 6,
    
    /// others
    ThingEventPipelineTypeOther    = 9,
};

typedef NS_ENUM(NSUInteger, ThingEventDpOptCode) {
    ThingEventDpOptCodeNoNextPipeline      = 997,
    
    ThingEventDpOptCodePublishUnknownFail  = 998,
    ThingEventDpOptCodeReportUnknownFail   = 999,
    
    ThingEventDpOptCodeOffline             = 100,
    ThingEventDpOptCodePublishApiFail      = 101,
    ThingEventDpOptCodePublishVerifyFail   = 102,
    ThingEventDpOptCodePublishNoPipeline   = 103,
    ThingEventDpOptCodeUpgrading           = 104,
    ThingEventDpOptCodeBleMTPFail          = 105,
    ThingEventDpOptCodePhoneBleOff         = 106,
    ThingEventDpOptCodeLocalKeyFail        = 107,
    ThingEventDpOptCodeEncodeFail          = 108,
    ThingEventDpOptCodePublishLanUnstable  = 109,
    ThingEventDpOptCodeDevOnlineButPipelineOff = 110,
    ThingEventDpOptCodePipelineSupportOther = 111,
    
    ThingEventDpOptCodeReportVerifyFail    = 200,
    ThingEventDpOptCodeReportTimeout       = 201,
    ThingEventDpOptCodeReportValueNotSame  = 202,
    ThingEventDpOptCodeReportReplayBlock   = 203,
    ThingEventDpOptCodeReportDualModeBlock = 204,
    ThingEventDpOptCodeReportMqttNotSub    = 205,
    ThingEventDpOptCodeReportSameDpsFrequently = 206,
    ThingEventDpOptCodeReportLanUnstable       = 207,
    ThingEventDpOptCodeReportDeviceNoResponse  = 208,
    ThingEventDpOptCodeReportDeviceResponseButTimeout  = 209,
    ThingEventDpOptCodeReportDeviceResponseButSameDps  = 210,
    ThingEventDpOptCodeReportTimeoutBeOffline = 211
};

typedef NS_ENUM(NSUInteger, ThingEventPubishDpSrc) {
    ThingEventPubishDpSrcUndefine  = 0,
    ThingEventPubishDpSrcHomeQuick = 1,
    ThingEventPubishDpSrcPanelRN   = 2,
    ThingEventPubishDpSrcUniTTT    = 3,
    ThingEventPubishDpSrcCamera    = 4,
};

FOUNDATION_EXPORT NSErrorUserInfoKey const ThingErrorDpEventPipelineKey;
FOUNDATION_EXPORT NSErrorUserInfoKey const ThingErrorDpEventOptCodeKey;

@interface ThingSmartDeviceEventHelper : NSObject
+ (ThingDeviceOSCategory)osCategoryByGroup:(ThingSmartGroupModel *)group;
+ (ThingDeviceOSCategory)osCategoryByDevice:(ThingSmartDeviceModel *)device;
@end

@interface ThingSmartDeviceEventUtil : NSObject

/// The message sending request is successful.
///
/// @param pipelineType The message sending pipeline.
+ (void)successEventWithPipelineType:(ThingEventPipelineType)pipelineType;

/// The message sending request failed.
///
/// @param pipelineType The message sending pipeline.
/// @param pv The device protocol version that is used when the message is sent.
/// @param error An error occurs while processing the request.
/// @param extendInfo Detailed error information, in which you can easily check the status of the error and the app condition.
+ (void)failedEventWithPipelineType:(ThingEventPipelineType)pipelineType
                                 pv:(double)pv
                              error:(NSError *)error
                         extendInfo:(NSDictionary *)extendInfo;

/// The message for public demend
///
/// @param attribute The attribute dictionary.
+ (void)thingsdkControlEventWithAttribute:(NSDictionary *)attribute;

/// The message for lan control. report mqtt status
///
/// @param attribute The attribute dictionary.
+ (void)thingsdkLanControlEventWithAttribute:(NSDictionary *)attribute;

/// The message for lan connect. report mqtt status & cloudOnline
///
/// @param attribute The attribute dictionary.
+ (void)thingsdkLanConnectedEventWithAttribute:(NSDictionary *)attribute;

+ (void)thingsdkThingModelControlWithAttribute:(NSDictionary *)attribute;

/// Record the publish dps event.
+ (void)thingsdkRecordEventForPubishDps:(NSDictionary *)dps devId:(NSString *)devId src:(ThingEventPubishDpSrc)src;

/// The message for device publish dp.
/// error code reference to `ThingEventDpOptCode`
+ (void)thingsdkDpBuriedPublishDevice:(ThingSmartDeviceModel *)device
                                  dps:(NSDictionary *)dps
                             pipeline:(NSInteger)pipeline
                                error:(NSError *)error
                               orders:(NSArray *)orders;

/// The message for group publish dp.
/// error code reference to `ThingEventDpOptCode`
/// Deprecated
+ (void)thingsdkDpBuriedPublishGroup:(ThingSmartGroupModel *)group
                              dps:(NSDictionary *)dps
                         pipeline:(NSInteger)pipeline
                            error:(nullable NSError *)error
                            start:(NSDate *)start
                              end:(NSDate *)end;

/// The message for dp update fail.
/// error code reference to `ThingEventDpOptCode`
+ (void)thingsdkDpBuriedReportFailWithDevId:(nullable NSString *)devId
                               orGroupId:(nullable NSString *)groupId
                                     dps:(NSDictionary *)dps
                                   error:(NSError *)error;

/// Report dp message.
+ (void)reportDps:(NSDictionary *)dps deviceModel:(ThingSmartDeviceModel *)deviceModel communicationType:(ThingCommunicationType)source isPublish:(BOOL)isPushlish extend:(nullable NSDictionary *)extend;

/// Record the local connect device event.
+ (void)thingsdkRecordLocalConnectWithDevId:(NSString *)devId;

@end

NS_ASSUME_NONNULL_END
