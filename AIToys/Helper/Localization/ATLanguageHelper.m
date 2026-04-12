//
//  ATLanguageHelper.m
//  AIToys
//
//  Created by Codex.
//

#import "ATLanguageHelper.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static const void *kATLanguageBundleKey = &kATLanguageBundleKey;
static NSString * const kATSelectedLanguageCodeKey = @"ATSelectedLanguageCode";

@interface ATLanguageBundle : NSBundle
@end

@implementation ATLanguageBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle *languageBundle = objc_getAssociatedObject(self, kATLanguageBundleKey);
    if (languageBundle) {
        return [languageBundle localizedStringForKey:key value:value table:tableName];
    }
    return [super localizedStringForKey:key value:value table:tableName];
}

@end

@implementation ATLanguageHelper

+ (NSString *)currentLanguageCode {
    NSString *manualLanguageCode = [[NSUserDefaults standardUserDefaults] stringForKey:kATSelectedLanguageCodeKey];
    if ([self isSupportedLanguageCode:manualLanguageCode]) {
        return [self normalizedLanguageCode:manualLanguageCode];
    }
    NSString *systemLanguageCode = [NSLocale preferredLanguages].firstObject ?: @"en";
    return [self normalizedLanguageCode:systemLanguageCode];
}

+ (NSString *)normalizedLanguageCode:(NSString *)languageCode {
    NSString *normalized = languageCode.lowercaseString ?: @"en";
    if ([normalized hasPrefix:@"zh"]) {
        return @"zh-Hans";
    }
    if ([normalized hasPrefix:@"fr"]) {
        return @"fr";
    }
    if ([normalized hasPrefix:@"de"]) {
        return @"de";
    }
    if ([normalized hasPrefix:@"es"]) {
        return @"es";
    }
    if ([normalized hasPrefix:@"ar"]) {
        return @"ar";
    }
    return @"en";
}

+ (void)applyLanguageCode:(NSString *)languageCode {
    NSString *normalized = [self normalizedLanguageCode:languageCode];
    [[NSUserDefaults standardUserDefaults] setObject:normalized forKey:kATSelectedLanguageCodeKey];
    [[NSUserDefaults standardUserDefaults] setObject:@[normalized] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] setObject:normalized forKey:@"AppleLocale"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self applyLanguageBundleForCode:normalized];
}

+ (void)applyStoredLanguageConfiguration {
    [self applyLanguageBundleForCode:[self currentLanguageCode]];
}

+ (BOOL)isSupportedLanguageCode:(NSString *)languageCode {
    if (languageCode.length == 0) {
        return NO;
    }
    NSString *normalized = [self normalizedLanguageCode:languageCode];
    return [@[@"zh-Hans", @"en", @"fr", @"de", @"es", @"ar"] containsObject:normalized];
}

+ (void)applyLanguageBundleForCode:(NSString *)languageCode {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [ATLanguageBundle class]);
    });

    NSString *normalized = [self normalizedLanguageCode:languageCode];
    NSString *path = [[NSBundle mainBundle] pathForResource:normalized ofType:@"lproj"];
    NSBundle *bundle = path.length > 0 ? [NSBundle bundleWithPath:path] : nil;
    objc_setAssociatedObject([NSBundle mainBundle], kATLanguageBundleKey, bundle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSString *)miniAppLangType {
    NSString *preferredLanguage = [self currentLanguageCode];
    if ([preferredLanguage hasPrefix:@"zh"]) {
        return @"zh_CN";
    }
    if ([preferredLanguage hasPrefix:@"ar"]) {
        return @"ar";
    }
    if ([preferredLanguage hasPrefix:@"fr"]) {
        return @"fr";
    }
    if ([preferredLanguage hasPrefix:@"de"]) {
        return @"de";
    }
    if ([preferredLanguage hasPrefix:@"es"]) {
        return @"es";
    }
    return @"en";
}

+ (BOOL)isRTLLanguage {
    NSString *preferredLanguage = [self currentLanguageCode];
    NSString *languageCode = [[preferredLanguage componentsSeparatedByString:@"-"] firstObject] ?: @"en";
    NSLocaleLanguageDirection direction = [NSLocale characterDirectionForLanguage:languageCode];
    return direction == NSLocaleLanguageDirectionRightToLeft;
}

+ (void)applyGlobalRTLConfiguration {
    UISemanticContentAttribute attribute = [self isRTLLanguage] ? UISemanticContentAttributeForceRightToLeft : UISemanticContentAttributeForceLeftToRight;
    [UIView appearance].semanticContentAttribute = attribute;
    [UINavigationBar appearance].semanticContentAttribute = attribute;
    [UITabBar appearance].semanticContentAttribute = attribute;
    [UITableView appearance].semanticContentAttribute = attribute;
    [UICollectionView appearance].semanticContentAttribute = attribute;
}

@end
