//
//  ThingBLEFindMacDelegate.h
//  ThingSmartBLECoreKit
//
//  Created by Thing on 2022/3/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ThingBLEFindMacDelegate <NSObject>

@optional

- (nullable NSString *)findDeviceMacFromUUID:(nullable NSString *)uuid;

@end

NS_ASSUME_NONNULL_END
