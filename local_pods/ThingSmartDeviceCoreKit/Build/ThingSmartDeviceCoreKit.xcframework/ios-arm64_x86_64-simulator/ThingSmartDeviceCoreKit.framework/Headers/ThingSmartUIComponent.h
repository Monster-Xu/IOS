//
//  ThingSmartUIComponent.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartUIComponent : NSObject

@property (nonatomic, copy) NSString *code;

@property (nonatomic, copy) NSString *version;

@property (nonatomic, assign) NSInteger sort;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *fileSize;

@property (nonatomic, copy) NSString *fileMd5;

@end

NS_ASSUME_NONNULL_END
