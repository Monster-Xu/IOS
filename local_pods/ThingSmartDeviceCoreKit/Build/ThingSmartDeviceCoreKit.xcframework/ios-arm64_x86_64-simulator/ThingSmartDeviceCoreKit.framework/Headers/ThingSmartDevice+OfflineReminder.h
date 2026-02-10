//
//  ThingSmartDevice+OfflineReminder.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import "ThingSmartDevice.h"

NS_ASSUME_NONNULL_BEGIN

/// @brief Thing Smart device offline alerts: You can specify whether to support the offline alert function, set the status of the offline alert switch, and set the offline alert rules.
///
/// When offline alerts are enabled for the device, the device sends an offline notification to the specified user when the device goes offline. You can subscribe to the message push function to enable this feature.
///
@interface ThingSmartDevice (OfflineReminder)

/// Checks whether the device supports offline alerts.
///
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)getOfflineReminderSupportStatusWithSuccess:(nullable ThingSuccessBOOL)success failure:(nullable ThingFailureError)failure;


/// Returns the device offline notification status.
///
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)getOfflineReminderStatusWithSuccess:(nullable ThingSuccessBOOL)success failure:(nullable ThingFailureError)failure;


/// Sets the device offline notification.
///
/// @param status  Sends a notification when the device goes offline. 
/// @param success Called when the task is finished.
/// @param failure Called when the task is interrupted by an error.
- (void)setOfflineReminderStatus:(BOOL)status success:(nullable ThingSuccessBOOL)success failure:(nullable ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END
