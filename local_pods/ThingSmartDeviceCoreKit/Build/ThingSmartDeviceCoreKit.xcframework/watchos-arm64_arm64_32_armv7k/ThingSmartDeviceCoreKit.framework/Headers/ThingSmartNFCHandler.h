//
//  ThingSmartNFCHandler.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ThingSmartNFCActType) {
    ThingSmartNFCActTypePair = 0,
    ThingSmartNFCActTypeCtrl = 1,
};

@interface ThingSmartNFCEntity : NSObject

@property (nonatomic, assign) BOOL sdkHandled;

@property (nonatomic, assign) ThingSmartNFCActType actType;

@property (nonatomic, assign) NSInteger subType;

@property (nonatomic, strong) NSString *codeContent;

@property (nonatomic, strong) NSError *error;

@end


@interface ThingSmartNFCHandler : NSObject

- (ThingSmartNFCEntity *)handleUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
