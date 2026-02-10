//
//  ThingSmartUIPanelInfo.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//


#import <Foundation/Foundation.h>
#import "ThingSmartUIComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartUIPanelInfo : NSObject

@property (nonatomic, strong) NSString *uiId;
@property (nonatomic, strong) NSString *uiVersion;
@property (nonatomic, strong) NSString *uiName;

@property (nonatomic, strong) NSString *fileSize;
@property (nonatomic, strong) NSString *fileMd5;
@property (nonatomic, strong) NSString *appRnVersion;
@property (nonatomic, strong) NSString *ui;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *uiPhase;
@property (nonatomic, strong) NSString *uiType;
@property (nonatomic, assign) NSInteger attribute;
@property (nonatomic, assign) NSInteger rnBizPack;
@property (nonatomic, strong) NSString *uiBizClientId;
@property (nonatomic, assign) BOOL rnFind;
@property (nonatomic, strong) NSArray<ThingSmartUIComponent *> *uiComponentList;

@end

NS_ASSUME_NONNULL_END
