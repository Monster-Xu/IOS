//
//  ATLanguageHelper.h
//  AIToys
//
//  Created by Codex.
//

#import <Foundation/Foundation.h>
#import <ThingSmartBizCore/ThingSmartBizCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATLanguageHelper : NSObject

+ (NSString *)currentLanguageCode;
+ (NSString *)normalizedLanguageCode:(NSString *)languageCode;
+ (void)applyLanguageCode:(NSString *)languageCode;
+ (void)applyStoredLanguageConfiguration;
+ (BOOL)isSupportedLanguageCode:(NSString *)languageCode;
+ (NSString *)miniAppLangType;
+ (ThingSmartBizLanguageKey)thingSmartBizLanguageKey;
+ (BOOL)isRTLLanguage;
+ (void)applyGlobalRTLConfiguration;

@end

NS_ASSUME_NONNULL_END
