//
//  ATLanguageHelper.m
//  AIToys
//
//  Created by Codex.
//

#import "ATLanguageHelper.h"
#import <UIKit/UIKit.h>

@implementation ATLanguageHelper

+ (NSString *)miniAppLangType {
    NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject.lowercaseString ?: @"en";
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
    NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject ?: @"en";
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
