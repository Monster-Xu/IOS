//
//  ThingSmartBLEMeshCtrlManager.h
//  ThingSmartBLEKit
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com)
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartBLEMeshCtrlManager : NSObject <ThingSmartBLEKitEntry>

@property (nonatomic, strong) NSNumber *homeId;

@property (nonatomic, copy) NSString *meshID;

@property (nonatomic, copy) NSString *beaconKey;

@property (nonatomic, copy) NSString *netKey;

- (void)updateMeshModel:(ThingSmartBleMeshModel *)meshModel;

- (void)createBLEMeshWithHomeId:(NSNumber *)homeId success:(ThingSuccessID)success failure:(ThingFailureError)failure;

- (void)configProxyNode:(ThingSmartDeviceModel *)deviceModel;

- (void)queryDpWithDpId:(NSString *)dpId nodeId:(NSString *)nodeId success:(ThingSuccessID)success failure:(ThingFailureError)failure;

- (void)publishDps:(NSDictionary *)dps nodeId:(NSString *)nodeId ack:(BOOL)ack success:(ThingSuccessID)success failure:(ThingFailureError)failure;

- (void)groupJoinWithDevId:(NSString *)devId localId:(NSString *)localId success:(ThingSuccessID)success failure:(ThingFailureError)failure;

- (void)groupRemoveWithDevId:(NSString *)devId localId:(NSString *)localId success:(ThingSuccessID)success failure:(ThingFailureError)failure;

- (void)coverGroupWithDevice:(ThingSmartDeviceModel *)deviceModel success:(ThingSuccessID)success failure:(ThingFailureError)failure;

- (void)groupRemoveAllWithDevId:(NSString *)devId success:(ThingSuccessID)success failure:(ThingFailureError)failure;

- (void)groupListQueryWithDevId:(NSString *)devId success:(ThingSuccessID)success failure:(ThingFailureError)failure;

- (void)updateNetKey:(NSString *)netKey devId:(NSString *)devId;

- (void)BLEMeshScanAdvertisingData:(NSData *)advertisingData;

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
