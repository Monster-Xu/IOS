//
//  ThingBLEWifiConfigModel.h
//  ThingSmartBLECoreKit
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingBLEWifiConfigModel : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) long long homeId;
@property (nonatomic, strong) NSString *productId;
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) NSTimeInterval timeOut;
/// token
@property (nonatomic, copy) NSString *token;
/// country code
@property (nonatomic, copy) NSString *ccode;

@end

@interface ThingBLETransportRequest : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) NSTimeInterval queryWifiListTimeout;
@property (nonatomic, assign) int maxWifiListCount;

@end

@interface ThingBLEConfigStateModel : NSObject

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) int configStage;
@property (nonatomic, assign) int status;

@end

@interface ThingBLEWifiModel : NSObject

@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, assign) int rssi;
@property (nonatomic, strong) NSString *sec;

@end

NS_ASSUME_NONNULL_END
