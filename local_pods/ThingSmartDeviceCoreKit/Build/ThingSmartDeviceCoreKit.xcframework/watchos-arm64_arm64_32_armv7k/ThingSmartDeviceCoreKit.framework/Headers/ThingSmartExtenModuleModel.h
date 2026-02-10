//
//  ThingSmartExtenModuleModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ThingSmartExtenModule;
@interface ThingSmartExtenModuleModel : NSObject

@property (nonatomic, assign) NSInteger includeEmtInfo;

@property (nonatomic, strong) ThingSmartExtenModule *module;

@end


@interface ThingSmartExtenNBTLD : NSObject

@property (nonatomic, copy) NSString *pv;

@property (nonatomic, copy) NSString *bv;

@property (nonatomic, copy) NSString *sv;

@property (nonatomic, copy) NSString *imei;

@property (nonatomic, copy) NSString *hbt;

@property (nonatomic, copy) NSString *apn;

@property (nonatomic, copy) NSString *opt;

@end


@interface ThingSmartExtenModule : NSObject

@property (nonatomic, assign) NSInteger emt;

@property (nonatomic, assign) NSInteger n_tld;

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, assign) NSInteger length;

@property (nonatomic, strong) NSString *nbJsonStr;

@property (nonatomic, strong) ThingSmartExtenNBTLD *content;

@property (nonatomic, assign) NSInteger state;

@property (nonatomic, copy) NSString *communicatePriority;

@property (nonatomic, assign) NSInteger bindState;

@property (nonatomic, strong) NSMutableArray *otaChannels;

@property (nonatomic, assign) NSInteger autoReport;

@end


@interface ThingSmartExtenModuleReport : NSObject
@property (nonatomic, copy) NSString *devId;
@property (nonatomic, copy) NSString *secKey;
@property (nonatomic, copy) NSString *localKey;
@property (nonatomic, copy) NSString *env;
@property (nonatomic, copy) NSString *region;
- (NSDictionary*)JSONParams;
@end


NS_ASSUME_NONNULL_END
