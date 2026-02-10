//
//  ThingSmartUIPanelModel.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//


#import <Foundation/Foundation.h>
#import "ThingSmartUIPanelInfo.h"
#import "ThingSmartCoreCache.h"

NS_ASSUME_NONNULL_BEGIN

@class ThingSmartRequestOperation;
@protocol ThingSmartModelFetcher <NSObject>

+ (ThingSmartRequestOperation *)operationWithParams:(NSDictionary *)params;

@end

@interface ThingSmartUIPanelModel : NSObject <ThingSmartCoreCacheProtocol, ThingSmartModelFetcher>

@property (nonatomic, strong) NSString *productId;
@property (nonatomic, strong) NSString *productVer;
@property (nonatomic, strong) NSDictionary *panelConfig;
@property (nonatomic, strong) NSDictionary *uiConfig;
@property (nonatomic, assign) long long i18nTime;
@property (nonatomic, strong) ThingSmartUIPanelInfo *uiInfo;

@end
NS_ASSUME_NONNULL_END
