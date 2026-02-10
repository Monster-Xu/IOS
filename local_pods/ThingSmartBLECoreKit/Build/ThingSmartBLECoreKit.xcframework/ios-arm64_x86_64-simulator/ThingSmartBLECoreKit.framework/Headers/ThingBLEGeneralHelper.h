//
//  ThingBLEGeneralHelper.h
//  ThingSmartBLECoreKit
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ThingBLESupportConnect) {
    ThingBLESupportConnect_DEFAULT   = 1,  
    ThingBLESupportConnect_REQUEST   = 2,  
    ThingBLESupportConnect_KEEP      = 3,  
    ThingBLESupportConnect_NONEED    = 4,  
};

typedef NS_ENUM(NSUInteger, ThingBLESupportDisconnect) {
    ThingBLESupportDisconnect_INTIME               = 1,    
    ThingBLESupportDisconnect_REQUEST              = 2,    
    ThingBLESupportDisconnect_DEFAULT              = 3,    
    ThingBLESupportDisconnect_INTIME_REQUEST       = 4,    
};

NS_ASSUME_NONNULL_BEGIN

@interface ThingBLEGeneralHelper : NSObject

+ (ThingBLESupportConnect)configConnect:(NSDictionary *)configMetas;

+ (ThingBLESupportDisconnect)configDisconnect:(NSDictionary *)configMetas;

+ (NSString *)string2JSONString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
