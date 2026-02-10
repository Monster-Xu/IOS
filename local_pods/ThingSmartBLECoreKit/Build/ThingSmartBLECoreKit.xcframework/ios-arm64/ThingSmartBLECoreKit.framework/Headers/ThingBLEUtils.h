//
//  ThingBLEUtils.h
//  ThingSmartKit
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.thing.com)
//

#import <Foundation/Foundation.h>
#import "NSObject+ThingSDKSubValue.h"
#import "ThingBLEDeviceInfoProtocol.h"

@interface ThingBLEUtils : NSObject


+ (NSString *)hexStrToBCDCode:(NSString *)hexStr;

+ (NSString *)versionStringToHexString:(NSString *)versionStr;

+ (NSString *)hexStringFromString:(NSString *)string;

+ (NSString *)stringFromHexString:(NSString *)hexString;

+ (NSString *)numberWithHexString:(NSString *)hexString;
+ (NSString *)getBinaryByHex:(NSString *)hex;
+ (NSString *)getHexByBinary:(NSString *)binary;

+ (NSString *)ToHex:(unsigned int)number;

+ (NSString *)getCustomPariseByBinary:(NSString *)hex;

+ (NSString *)getHexByCustomParise:(NSString *)string;

+ (NSString *)dataTransfromBigOrSmall:(NSString *)string;

+ (NSString *)addZeroToFront:(NSString *)str withLength:(int)length;

+ (NSString *)addZeroToBack:(NSString *)str withLength:(int)length;

// CRC32
+ (int32_t)crc32:(NSData *)data;

+ (NSString *)md5WithData:(NSData *)data;

+ (NSString *)generateTradeNO:(int)kNumber;

+ (BOOL)containVisiableString:(NSString *)string;
+ (NSInteger)getDecimalByBinary:(NSString *)binary;

/// DC:2B:C7:D6:12:34 to DC2BC7D61234
+ (NSString *)standardMacString2MacString:(NSString *)standardMacString;

+ (NSString *)tyHexString:(NSString *)str;

+ (NSDictionary *)dicFromJsonData:(NSData *)data;

+ (NSArray *)arrayFromJsonData:(NSData *)data;
+ (void)sendDeviceActiveInfo:(id<ThingBLEDeviceInfoProtocol>)dev data:(NSData *)data packageMaxSize:(NSInteger)maxSize type:(ThingBLEConfigType)type success:(ThingSuccessHandler)success failure:(ThingFailureError)failure;

+ (NSData *)twoByteHexDataFromString:(NSString *)input;

+ (uint8_t)crc8:(NSData *)data;

+ (NSDictionary *)klvDps:(NSData *)data schema:(id)schema;

@end
