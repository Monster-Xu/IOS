//
//  ThingSmartBackupWifiModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartBackupWifiModel : NSObject

@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *hashValue;
@property (nonatomic, strong) NSString *password;

+ (NSString *)getBase64HashValueWithLocalKey:(NSString *)localKey ssid:(NSString *)ssid psw:(NSString *)psw;

@end

NS_ASSUME_NONNULL_END
