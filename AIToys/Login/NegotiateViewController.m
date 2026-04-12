//
//  NegotiateViewController.m
//  AIToys
//
//  Created by xuxuxu on 2025/9/26.
//

#import "NegotiateViewController.h"

@interface NegotiateViewController ()

@end

@implementation NegotiateViewController

- (NSString *)currentAgreementLanguageCode {
    NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject.lowercaseString ?: @"en";
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

- (NSURL *)localizedAgreementURLForType:(NSInteger)type bundle:(NSBundle *)bundle {
    NSString *languageCode = [self currentAgreementLanguageCode];
    NSDictionary<NSNumber *, NSDictionary<NSString *, NSString *> *> *localizedFileMap = @{
        @0: @{
            @"en": @"Talenpal User Privacy Policy.docx",
            @"fr": @"Politique de Confidentialité des Utilisateurs de Talenpal.docx",
            @"de": @"Talenpal Datenschutzrichtlinie für Nutzer.docx",
            @"es": @"Política de Privacidad de Usuario de Talenpal.docx",
            @"ar": @"سياسة خصوصية مستخدمي Talenpal.docx"
        },
        @1: @{
            @"en": @"Talenpal Terms of Use.docx",
            @"fr": @"Conditions d'Utilisation de Talenpal.docx",
            @"de": @"Nutzungsbedingungen von Talenpal.docx",
            @"es": @"Términos de Uso de Talenpal.docx",
            @"ar": @"شروط استخدام Talenpal.docx"
        },
        @2: @{
            @"en": @"Talenpal Terms of Use.docx",
            @"fr": @"Conditions d'Utilisation de Talenpal.docx",
            @"de": @"Nutzungsbedingungen von Talenpal.docx",
            @"es": @"Términos de Uso de Talenpal.docx",
            @"ar": @"شروط استخدام Talenpal.docx"
        },
        @3: @{
            @"en": @"Talenpal AI Notice.docx",
            @"fr": @"Avis d'IA de Talenpal.docx",
            @"de": @"Talenpal KI-Hinweis.docx",
            @"es": @"Aviso de IA de Talenpal.docx",
            @"ar": @"إشعار الذكاء الاصطناعي Talenpal.docx"
        }
    };

    NSDictionary<NSString *, NSString *> *fileMap = localizedFileMap[@(type)];
    NSString *targetFileName = fileMap[languageCode] ?: fileMap[@"en"];
    if (targetFileName.length == 0) {
        return nil;
    }

    NSArray<NSURL *> *resourceURLs = [bundle URLsForResourcesWithExtension:@"docx" subdirectory:nil];
    for (NSURL *resourceURL in resourceURLs) {
        if ([[resourceURL lastPathComponent] isEqualToString:targetFileName]) {
            return resourceURL;
        }
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 配置WKWebView
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    // 加载文档
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *fileURL = [self localizedAgreementURLForType:self.type bundle:bundle];

    if (fileURL) {
        // WKWebView 需要使用 loadFileURL:allowingReadAccessToURL: 方法加载本地文件
        [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL.URLByDeletingLastPathComponent];
    } else {
        NSLog(@"文档文件未找到");
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败: %@", error.localizedDescription);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"文档加载完成");
}

@end


