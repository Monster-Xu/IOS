//
//  ThingBLEStatusHandler.h
//  Pods
//
//

#import <Foundation/Foundation.h>
#import "ThingBLEStatusService.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ThingBLEDeviceInfoProtocol;
@interface ThingBLEStatusHandler : NSObject

ThingSDK_SINGLETON

@property (nonatomic, assign) BOOL autoScanning;

- (NSArray *)getUnActivedListInfo;

- (void)clearUnactiveList;

- (void)disconnectAllDevices;

- (NSInteger)getPeripheralRSSI:(NSString *)uuid __deprecated_msg("This method is deprecated, Use getPeripheralRSSI:mac: instead");

- (NSInteger)getPeripheralRSSI:(nullable NSString *)uuid mac:(nullable NSString *)mac;

#pragma mark - OTA Method
- (BOOL)isOTA:(NSString *)uuid;

- (NSInteger)getOTAStatus:(NSString *)uuid;

- (void)disconnectDevice:(id<ThingBLEDeviceInfoProtocol>)deviceInfo;

#pragma mark - ConnectManage
- (BOOL)handleConnectedDevices:(NSString *)uuid;

@end

NS_ASSUME_NONNULL_END
