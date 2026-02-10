//
//  ThingSmartDevice+WiFiBackup.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#if TARGET_OS_IOS

#import "ThingSmartDevice.h"

/// @brief The Smart Device Wi-Fi Alternative Switching function allows you to get an alternative Wi-Fi network.
///
/// When the current Wi-Fi network is not available, the device automatically switches to the alternative Wi-Fi network to ensure that the device can work as expected.
///
API_AVAILABLE(ios(10.0))
@interface ThingSmartDevice (WiFiBackup)

/// Returns the current Wi-Fi information.
/// @param success Called when the task is finished. ThingSuccessDict is returned.
/// @param failure Called when the task is interrupted by an error.
- (void)getCurrentWifiInfoWithSuccess:(ThingSuccessDict)success failure:(ThingFailureError)failure;


/// Returns the current Wi-Fi information.
/// @param timeout  The request timed out.
/// @param success Called when the task is finished. ThingSuccessDict is returned.
/// @param failure Called when the task is interrupted by an error.
- (void)getCurrentWifiInfoWithTimeout:(NSTimeInterval)timeout success:(ThingSuccessDict)success failure:(ThingFailureError)failure;


/// Returns a list of alternative Wi-Fi networks.
/// @param success Called when the task is finished. ThingSuccessDict is returned.
/// @param failure Called when the task is interrupted by an error.
- (void)getBackupWifiListWithSuccess:(ThingSuccessDict)success failure:(ThingFailureError)failure;


/// Sets up a list of alternative networks.
/// @param list A list of alternative Wi-Fi networks.
/// @param success Called when the task is finished. A list of ThingSmartBackupWifiModel is returned.
/// @param failure Called when the task is interrupted by an error.
- (void)setBackupWifiList:(NSArray<ThingSmartBackupWifiModel *> *)list success:(ThingSuccessDict)success failure:(ThingFailureError)failure;


/// Switches to a saved alternative Wi-Fi network.
/// @param hash The hash for the service set identifier (SSID) and password. The value is returned from the device.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)switchToBackupWifiWithHash:(NSString *)hash success:(ThingSuccessDict)success failure:(ThingFailureError)failure;


/// Switches to a new alternative Wi-Fi network.
/// @param ssid The SSID.
/// @param password The SSID.
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)switchToBackupWifiWithSSID:(NSString *)ssid password:(NSString *)password success:(ThingSuccessDict)success failure:(ThingFailureError)failure;


@end

#endif
