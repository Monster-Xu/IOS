//
//  ThingSmartBLEPairConfiguration.h
//  ThingSmartBLECoreKit
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol ThingSmartBLEPairConfiguration <NSObject>

@optional

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, copy) NSString *pwd;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *pid;
@property (nonatomic, strong) NSNumber *homeId;
@property (nonatomic, assign) BOOL bleActive;
@property (nonatomic, assign) NSUInteger timeout;
@property (nonatomic, strong) NSDictionary *extendParams;

@end

@interface ThingSmartBLEPairConfiguration : NSObject <ThingSmartBLEPairConfiguration>

@end

NS_ASSUME_NONNULL_END
