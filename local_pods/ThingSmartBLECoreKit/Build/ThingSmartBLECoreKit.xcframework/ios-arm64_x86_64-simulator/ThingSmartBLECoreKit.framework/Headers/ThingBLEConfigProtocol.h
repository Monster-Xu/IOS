//
//  ThingBLEConfigProtocol.h
//

#ifndef ThingBLEConfigProtocol_h
#define ThingBLEConfigProtocol_h

#import "ThingBLECryptologyProtcol.h"
#import "ThingBLEWriteNotifyProtocol.h"
#import "ThingSmartBLEActiveDelegate.h"
#import "ThingSmartBLEConfigPackageNotify.h"
#import "ThingSmartBLEManager.h"

@protocol ThingBLEDeviceInfoProtocol;
@protocol ThingBLECryptologyProtcol;
@protocol ThingBLEWriteNotifyProtocol;
@protocol ThingBLEConfigProtocol;

typedef enum : NSUInteger {
    ThingBLESubPackageStatus_AllSuccess = 0,
    ThingBLESubPackageStatus_CurrentSuccess,
    ThingBLESubPackageStatus_CurrentFailure,
    ThingBLESubPackageStatus_Failure,
} ThingBLESubPackageStatus;


@protocol ThingBLEConfigProtocol <NSObject>

@property (nonatomic, weak, nullable) id<ThingBLEDeviceInfoProtocol>  deviceInfo;
@property (nonatomic, strong, nullable) id<ThingBLECryptologyProtcol> cryptologyManager;
@property (nonatomic, strong, nullable) id<ThingBLEWriteNotifyProtocol> writeNotifyManager;

@property (nonatomic, weak, nullable) id<ThingSmartBLEActiveDelegate> handlerDelegate;

@property (nonatomic, weak, nullable) id<ThingSmartBLEConfigPackageNotify> packageNotify;

- (void)cancelActiveTimer;

- (void)publishCommandWithDeviceInfo:(nullable  id<ThingBLEDeviceInfoProtocol>)deviceInfo
                                type:(ThingBLEConfigType)type
                                data:(nullable NSData *)data
                             success:(__nullable ThingSuccessData)success
                             failure:(__nullable ThingFailureError)failure;



- (void)publishCommandWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                                type:(ThingBLEConfigType)type
                                data:(nullable NSData *)data
                             timeout:(NSTimeInterval)timeout
                             success:(__nullable ThingSuccessData)success
                             failure:(__nullable ThingFailureError)failure;

- (void)publishCommandWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                                type:(ThingBLEConfigType)type
                                data:(NSData *)data
                             timeout:(NSTimeInterval)timeout
                             needAck:(BOOL)needAck
                             success:(ThingSuccessData)success
                             failure:(ThingFailureError)failure;

- (NSData *)buildDpDataWithDps:(nullable NSDictionary *)dps deviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo;


- (void)publishDpsWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                             dps:(nullable NSDictionary *)dps
                        success:(__nullable ThingSuccessHandler)success
                        failure:(__nullable ThingFailureError)failure;

- (void)publishDpsWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>_Nullable)deviceInfo
                     childNodeId:(nullable NSString *)childNodeId
                             dps:(nullable NSDictionary *)dps
                         success:(__nullable ThingSuccessHandler )success
                         failure:(__nullable ThingFailureError)failure DEPRECATED_MSG_ATTRIBUTE("use `publishDpsWithDeviceInfo:childNodeId:secType:dps:success:failure` instead");

- (void)publishDpsWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>_Nullable)deviceInfo
                     childNodeId:(nullable NSString *)childNodeId
                        secType:(NSInteger)secType
                             dps:(nullable NSDictionary *)dps
                         success:(__nullable ThingSuccessHandler)success
                         failure:(__nullable ThingFailureError)failure;

- (void)publishDataUseTransportPipeWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>_Nullable)deviceInfo
                                           subCmd:(nullable NSData *)subCmdData
                                      payloadDict:(nullable NSDictionary *)payloadData
                                          success:(__nullable ThingSuccessHandler)success
                                          failure:(__nullable ThingFailureError)failure;


- (void)publishDpsStateQueryWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                                     dpIds:(nullable NSArray *)dpIds
                                   success:(ThingSuccessBOOL)success
                                   failure:(ThingFailureError)failure;


- (void)publishDpsUseTransportPipeWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                                             dps:(NSDictionary *)dps
                                         success:(ThingSuccessHandler)success
                                         failure:(ThingFailureError)failure;

- (nullable NSDictionary *)dpsWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>_Nullable)deviceInfo
                                     dpsData:(nullable NSData *)dpsData
                             isFittingDevice:(BOOL)isFittingDevice;


//- (void)receiveCommandWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
//                                type:(ThingBLEConfigType)type
//                                data:(NSData *)data
//                             success:(ThingSuccessData)success
//                             failure:(ThingFailureError)failure;

- (void)connectWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                     localKey:(nullable NSString *)localKey
                      success:(__nullable ThingSuccessHandler)success
                      failure:(__nullable ThingFailureError)failure __deprecated_msg("Use connectWithDeviceInfo:localKey:secKey:sign:success:failure:] instead.");


- (void)connectWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                     localKey:(nullable NSString *)localKey
                       secKey:(nullable NSString *)secKey
                         sign:(nullable NSString *)sign
                      success:(__nullable ThingSuccessHandler)success
                      failure:(__nullable ThingFailureError)failure;




- (void)disconnectWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                         success:(__nullable ThingSuccessHandler)success
                         failure:(__nullable ThingFailureError)failure;



- (void)removeWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                     success:(__nullable ThingSuccessHandler)success
                     failure:(__nullable ThingFailureError)failure;


- (void)resetWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                    success:(__nullable ThingSuccessHandler)success
                    failure:(__nullable ThingFailureError)failure;


- (void)sendOTAPackWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                          otaData:(nullable NSData *)otaData
                          otaType:(ThingSmartBLEOTAType)otaType
                       otaVersion:(nullable NSString *)otaVersion
                          success:(__nullable ThingSuccessHandler)success
                          failure:(__nullable ThingFailureError)failure;

- (void)sendOTAPackWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                       childNodeId:(NSString *)childNodeId
                         childPid:(NSString *)childPid
                       childDevid:(NSString *)devId
                          otaData:(NSData *)otaData
                          otaType:(ThingSmartBLEOTAType)otaType
                       otaVersion:(NSString *)otaVersion
                          success:(ThingSuccessHandler)success
                          failure:(ThingFailureError)failure;

- (void)sendOTAPackWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                              pid:(nullable NSString *)pid
                          otaData:(nullable NSData *)otaData
                          otaType:(ThingSmartBLEOTAType)otaType
                       otaVersion:(nullable NSString *)otaVersion
                          success:(__nullable ThingSuccessHandler)success
                          failure:(__nullable ThingFailureError)failure;



- (void)resetDeviceWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                           random:(nullable NSString *)random
                         resetKey:(nullable NSString *)resetKey
                          success:(__nullable ThingSuccessHandler)success
                          failure:(__nullable ThingFailureError)failure;



- (void)forceDeleteWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                          success:(__nullable ThingSuccessHandler)success
                          failure:(__nullable ThingFailureError)failure;



- (void)publishIoTTransparentDataWithDeviceInfo:(nullable  id<ThingBLEDeviceInfoProtocol>)dev
                                     type:(ThingBLEConfigType)type
                                     data:(nullable  NSData *)data
                                  success:(__nullable ThingSuccessHandler)success
                                  failure:(__nullable ThingFailureError)failure;

- (void)publishTransparentDataWithDeviceInfo:(nullable  id<ThingBLEDeviceInfoProtocol>)dev
                                     data:(nullable  NSData *)data
                                  success:(__nullable ThingSuccessHandler)success
                                  failure:(__nullable ThingFailureError)failure;



- (void)handleDpData:(nullable NSData *)data
             ackData:(nullable NSData *)ackData
                type:(int)type
             dpsTime:(nullable NSString *)dpsTime
          reportMode:(NSUInteger)mode;

- (void)handleDPTimeRequest:(nullable NSString *)dataHexString
                    ackData:(nullable NSData *)ackData
            withCommandType:(int)type
                 reportMode:(NSUInteger)mode;


- (void)handleIoTTransparentData:(nullable NSData *)data
                    businessData:(nullable NSData *)businessData;


- (void)handleTransparentData:(nullable NSData *)data;



- (void)handleDeviceLinkEncryptState:(Boolean)isLinkEncrypt;

- (void)discoverServiceWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>_Nullable)deviceInfo
                     localKey:(nullable NSString *)localKey
                      success:(__nullable ThingSuccessHandler)success
                      failure:(__nullable ThingFailureError)failure;


- (void)publishFileWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                           fileId:(NSInteger)fileId
                   fileIdentifier:(nullable NSString *)fileIdentifier
                      fileVersion:(NSInteger)fileVersion
                         fileData:(nullable NSData *)fileData
                    progressBlock:(nullable void(^)(float progress))progressBlock
                          success:(nullable ThingSuccessHandler)success
                          failure:(nullable ThingFailureError)failure;


- (void)publishFileWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                           fileId:(NSInteger)fileId
                   fileIdentifier:(nullable NSString *)fileIdentifier
                      fileVersion:(NSInteger)fileVersion
                         fileData:(nullable NSData *)fileData
                         fileType:(unsigned int)fileType
                    progressBlock:(nullable void(^)(float progress))progressBlock
                          success:(nullable ThingSuccessHandler)success
                          failure:(nullable ThingFailureError)failure;


- (void)stopFileTransfer:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo;

- (void)stopFileTransfer:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo;

- (void)publishAudioTransparentData:(nullable NSData *)data
                            needACk:(BOOL)isNeedAck
                           typeData:(nullable NSData *)typeData
                         deviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
                            success:(nullable ThingSuccessHandler)success
                            failure:(nullable ThingFailureError)failure;
//reset all parameters
- (void)resetAllparameters;


- (void)publishWifiTransportDataWithDeviceInfo:(nullable id<ThingBLEDeviceInfoProtocol>)dev
                                          data:(nullable NSData *)data
                                       success:(nullable ThingSuccessHandler)success
                                       failure:(nullable ThingFailureError)failure;
//- (void)handleComboWifiTransportData:(NSData *)businessData;


/// handle fitting device with time
/// @param data business data not contain time
/// @param fitttingDevId fitting devid
/// @param ackData ack data
/// @param type type
/// @param dpsTime dpsTime
/// @param mode model
- (void)handleDpData:(nullable NSData *)data
        fittingDevId:(nullable NSString *)fitttingDevId
             ackData:(nullable NSData *)ackData
                type:(int)type
             dpsTime:(nullable NSString *)dpsTime
          reportMode:(NSUInteger)mode;


/// handle fitting device  time and data contain time
/// @param data data contain time
/// @param fitttingDevId fitting devid
/// @param ackData ack data
/// @param type type
/// @param dpsTime dpsTime
/// @param mode model
- (void)handleDpWithTimeData:(nullable NSData *)data
                fittingDevId:(nullable NSString *)fitttingDevId
                     ackData:(nullable NSData *)ackData
                        type:(int)type
                     dpsTime:(nullable NSString *)dpsTime
                  reportMode:(NSUInteger)mode;

- (void)queryFittingInfo:(nullable id<ThingBLEDeviceInfoProtocol>)deviceInfo
             activeQuery:(BOOL)isActive
                 success:(nullable ThingSuccessData)success
                 failure:(nullable ThingFailureError)failure;

- (void)publishSplitCommandWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)dev
                                     type:(ThingBLEConfigType)type
                                     head:(NSData *)head
                                     data:(NSData *)data
                                  success:(ThingSuccessHandler)success
                                  failure:(ThingFailureError)failure;

@end

#endif /* ThingBLEConfigProtocol_h */
