//
//  ThingBLEGroupAdvFrame.h
//  ThingSmartBLECoreKit
//
//  Copyright (c) 2014-2024 Thing Inc. (https://developer.thing.com)
//

#import "ThingBLEBeaconAdvFrame.h"

NS_ASSUME_NONNULL_BEGIN


@interface ThingBLEGroupAdvFrameParams : NSObject

@property (assign) NSUInteger sub_cmd; // len:2

@property (assign) NSUInteger data_len; // len:2

@property (strong) NSData *data; // len:data_len

@property (assign) NSUInteger align;

@property (strong) NSData *ccm_mic; // len:4

@end



@interface ThingBLEGroupAdvFrame : ThingBLEBeaconAdvFrame

@property (strong) NSData *seq;

@property (strong) NSData *src_addr;

@property (strong) NSData *dst_addr;

@property (strong) NSData *cmd;

@property (strong) NSData *nid;

@property (strong) NSData *TR; // TTL + RFU

// 0 - no_encrypt, 1 - AES_CCM, ble_net_key, 2 - AES_CCM, secret_key, bit4-7: RFU
@property (assign) NSUInteger enc_type;

@property (strong) NSData *ori_param;

@property (strong) NSData *confuseRes;

@property (strong) NSData *ccm_mic;

@property (strong) ThingBLEGroupAdvFrameParams *param;

@property (strong) NSData *crc;

- (instancetype)initWithBeaconData:(NSData *)advertisingData beaconKey:(NSString *)beaconKey;

- (void)additionDataWithNetKey:(NSString *)netKey secKey:(NSString *)secKey;

@end



@interface ThingBLEGroupProxyConfigRes : NSObject

@property (assign) NSUInteger opcode;

@property (assign) NSUInteger status;

@property (assign) NSUInteger listSize;

- (instancetype)initWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
