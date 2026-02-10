//
//  ThingBLEPointEventService.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingBLEEventWayModel : NSObject
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *subCategory;
@property (nonatomic, strong) NSString *thirdCategory;
@property (nonatomic, strong) NSString *device_id;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSString *pv;
@property (nonatomic, strong) NSString *extend;

@end

@interface ThingBLEEventConnectWayModel : ThingBLEEventWayModel
@property (nonatomic, strong) NSString *connectTypeStrategy;
@property (nonatomic, strong) NSString *result;
@property (nonatomic, strong) NSString *errorCode;

@end


@interface ThingBLEPointEventService : NSObject

- (void)reportConnectWayToClouldWithDeviceId:(NSString *)devId result:(NSUInteger)result errorCode:(nullable NSString *)errorCode;


- (void)reportConnectWayToClouldWithModel:(ThingBLEEventConnectWayModel *)connectWayModel ;

@end

NS_ASSUME_NONNULL_END
