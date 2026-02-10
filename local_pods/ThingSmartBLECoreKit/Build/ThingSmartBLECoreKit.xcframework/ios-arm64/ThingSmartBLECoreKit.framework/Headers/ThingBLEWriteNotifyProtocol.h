//
//  ThingBLEWriteNotifyProtocol.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)
//

#ifndef ThingBLEWriteNotifyProtocol_h
#define ThingBLEWriteNotifyProtocol_h

#import "ThingBLECryptologyProtcol.h"
#import "ThingSmartBLEMutliTsfDefine.h"

@class ThingBLEWriteNotify;
@protocol ThingBLEWriteNotifyDelegate <NSObject>

@optional

- (void)didPackagedNotifyData:(NSData *)data;

- (void)didPackagedNotifyType:(frame_type_t)type data:(NSData *)data;

@end

@protocol ThingBLEDeviceInfoProtocol;
@protocol ThingBLEWriteNotifyProtocol <NSObject>

@property (nonatomic, strong) ThingBLEWriteNotify *writeNotify;

@property(nonatomic, weak) id<ThingBLEWriteNotifyDelegate> delegate;

- (void)writeDataWithDeviceInfo:(id<ThingBLEDeviceInfoProtocol>)deviceInfo
                           type:(ThingBLEConfigType)type
                           data:(NSData *)data
                        success:(ThingSuccessData)success
                        failure:(ThingFailureError)failure;

@end

#endif /* ThingBLEWriteNotifyProtocol_h */
