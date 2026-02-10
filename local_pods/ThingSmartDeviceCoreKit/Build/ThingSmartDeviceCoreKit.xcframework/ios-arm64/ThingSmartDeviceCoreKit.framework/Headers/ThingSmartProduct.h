//
//  ThingSmartProduct.h
//  ThingSmartDeviceCoreKit
//
//  Copyright (c) 2014-2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingSmartProduct : NSObject

/// Get product models frome cache priority, if cache not contain then from cloud.
/// Notice: One product id match One version, if missing default use "1.0.0"
/// - Parameters:
///   - productIds: prodcut id.
///   - versions: product version. default for "1.0.0"
///   - success: success handler.
///   - failure: failure handler.
+ (void)getProductListWithProductIds:(NSArray<NSString *> *)productIds versions:(NSArray<NSString *> *)versions success:(nonnull void (^)(NSArray * _Nonnull))success failure:(ThingFailureError)failure;

/// Get product models from cloud only.
/// Notice: One product id match One version, if missing default use "1.0.0"
/// - Parameters:
///   - productIds: prodcut id list.
///   - version: product version list. default for "1.0.0"
///   - success: success handler.
///   - failure: failure handler.
+ (void)getProductListFromCloudWithProductIds:(NSArray<NSString *> *)productIds
                                     versions:(NSArray<NSString *> *)versions
                                      success:(void (^)(NSArray *productList))success
                                      failure:(nullable ThingFailureError)failure;

@end

NS_ASSUME_NONNULL_END
