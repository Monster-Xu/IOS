//
//  ThingBLEWeatherModel.h
//  ThingSmartBLECoreKit
//
//  Created by liuguang on 2021/12/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThingBLEWeatherModel : NSObject

/// current temperatures
@property (nonatomic, assign) NSInteger temp;

/// minimum temperatures
@property (nonatomic, assign) NSInteger tempH;

/// maximum temperatures
@property (nonatomic, assign) NSInteger tempL;

/// weather conditions
@property (nonatomic, strong) NSString *condition;


- (NSDictionary *)modelToDictionary;

@end

NS_ASSUME_NONNULL_END
