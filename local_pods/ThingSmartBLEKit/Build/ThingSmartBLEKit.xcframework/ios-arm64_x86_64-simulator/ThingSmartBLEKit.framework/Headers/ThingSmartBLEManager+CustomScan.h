//
//  ThingSmartBLEManager+CustomScan.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <ThingSmartBLEKit/ThingSmartBLEKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartBLEManager (CustomScan)

/// Detecting whether it is a Thing Bluetooth device through broadcast package content
/// - Parameter advertisingData: advertisingData
- (BOOL)isThingBLEDevice:(NSDictionary *)advertisingData;


/// External custom Bluetooth scan
/// - Parameter enable: The enable value is YES to enable custom scanning, otherwise it will not be enabled. Default is NO
- (void)enableCustomScan:(BOOL)enable;

- (void)thingCentralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI;

- (void)thingCentralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
- (void)thing_centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void)thingCentralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
