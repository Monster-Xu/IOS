//
//  NSObject+ThingSDKSubValue.h
//  ThingSmartBLEKit
//
//

#import <Foundation/Foundation.h>

@interface NSData (ThingSDKSubValue)

- (NSData *)thingsdk_subdataWithRange:(NSRange)range;

@end


@interface NSString (ThingSDKSubValue)

- (NSString *)thingsdk_substringFromIndex:(NSUInteger)from;

- (NSString *)thingsdk_substringToIndex:(NSUInteger)to;

- (NSString *)thingsdk_substringWithRange:(NSRange)range;

@end
