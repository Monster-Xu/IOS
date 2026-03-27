//
//  ATLanguageHelper.h
//  AIToys
//
//  Created by Codex.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATLanguageHelper : NSObject

+ (NSString *)miniAppLangType;
+ (BOOL)isRTLLanguage;
+ (void)applyGlobalRTLConfiguration;

@end

NS_ASSUME_NONNULL_END
