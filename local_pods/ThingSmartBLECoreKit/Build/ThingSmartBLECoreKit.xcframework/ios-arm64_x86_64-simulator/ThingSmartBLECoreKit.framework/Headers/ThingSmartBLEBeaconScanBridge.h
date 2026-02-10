//
//  ThingSmartBLEBeaconScanBridge.h
//  ThingSmartBLECoreKit
//

#import <Foundation/Foundation.h>
#import <ThingBluetooth/ThingBluetooth.h>
#import "ThingBLEDeviceInfoProtocol.h"



typedef void(^ThingBLEBeaconScanCallback)(ThingBLEPeripheral * _Nullable p, id<ThingBLEDeviceInfoProtocol> _Nullable deviceInfo);

NS_ASSUME_NONNULL_BEGIN
@class ThingBLEScan;


@protocol ThingSmartBLEBeaconScanDelegate <NSObject>
- (void)centralManagerDidUpdatePowerState:(BOOL)isPowerOn;
@end

@interface ThingSmartBLEBeaconScanBridge : NSObject
@property (nonatomic, strong) ThingBLEScan *scan;
@property (nonatomic, weak) id<ThingSmartBLEBeaconScanDelegate> delegate;

ThingSDK_SINGLETON
- (void)startBleBeaconScanWithDeviceId:(NSString *)deviceId uuid:(NSString *)uuid callBack:(ThingBLEBeaconScanCallback)callback __deprecated_msg("This method is deprecated, Use `startBleBeaconScanWithDeviceId:uuid:macId:callBack:` instead");

- (void)startBleBeaconScanWithDeviceId:(NSString *)deviceId uuid:(NSString *)uuid macId:(NSString *)macid callBack:(ThingBLEBeaconScanCallback)callback;


- (void)startBleBeaconScanning:(ThingBLEBeaconScanCallback)callback;

- (void)stopScan __deprecated_msg("This method is deprecated, Use `stopBleBeaconScan` instead");
- (void)stopBeaconScan __deprecated_msg("This method is deprecated, Use `stopBleBeaconScan` instead");
- (void)stopBleBeaconScan;
@end

NS_ASSUME_NONNULL_END
