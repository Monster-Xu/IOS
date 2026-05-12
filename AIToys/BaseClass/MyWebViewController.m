//
//  BaseViewController.h
//  KunQiTong
//
//  Created by 乔不赖 on 2021/8/28.
//

#import "MyWebViewController.h"
#import <WebKit/WebKit.h>
#import "APIPortConfiguration.h"
#import "ATLanguageHelper.h"
#import "APIManager.h"
#import "UserInfo.h"

@interface ATWeakScriptMessageDelegate : NSObject <WKScriptMessageHandler>
@property (nonatomic, weak) id<WKScriptMessageHandler> delegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate;
@end

@implementation ATWeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end

@interface MyWebViewController ()
<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation MyWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    NSURL *url = [self webURLForMainUrl:self.mainUrl ?: @"http://192.168.1.74:8710/course/api/course/view/introduce/1287995003540406274"];
    if (url.isFileURL) {
        [self.webView loadFileURL:url allowingReadAccessToURL:url.URLByDeletingLastPathComponent];
    } else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    [self.navigationController.navigationBar setBarTintColor:UIColor.redColor];
}
-(void)setMainUrl:(NSString *)mainUrl{
    _mainUrl = mainUrl;
}

- (void)dealloc {
    //移除观察者
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"TalenpalBridge"];
//    [_webView removeObserver:self forKeyPath:@"title"];
    NSLog(@"%@ -- dealloc", self.class);
}

#pragma mark -- UI

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addScriptMessageHandler:[[ATWeakScriptMessageDelegate alloc] initWithDelegate:self] name:@"TalenpalBridge"];
    WKUserScript *bridgeScript = [[WKUserScript alloc] initWithSource:[self talenpalBridgeSource] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:bridgeScript];
    //创建网页配置对象
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = userContentController;
    config.applicationNameForUserAgent = [NSString stringWithFormat:@"TalenpalApp/%@ (platform=ios)", APP_VERSION ?: @""];
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-Nav_And_Tabbar_Height) configuration:config];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webView];
    //进度条
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 2)];
    _progressView.tintColor = mainColor;
    _progressView.trackTintColor = [UIColor clearColor];
    [self.view addSubview:_progressView];
    
    //添加监测网页加载进度的观察者
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
//    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark -- KVO

//kvo 监听进度 必须实现此方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == _webView) {
        self.progressView.progress = _webView.estimatedProgress;
        if (_webView.estimatedProgress >= 1.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 0;
            });
        }
    } else if ([keyPath isEqualToString:@"title"] && object == _webView) {
//        self.navigationItem.title = _webView.title;
    }
}

#pragma mark -- private method

/**
 清理缓存
 */
- (void)clearWbCache {
    if ([[[UIDevice currentDevice]systemVersion]intValue ] >= 9.0) {
        NSArray * types =@[WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeDiskCache]; // 9.0之后才有的
        NSSet *websiteDataTypes = [NSSet setWithArray:types];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
        }];
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSLog(@"%@", cookiesFolderPath);
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
}

#pragma mark -- event click

- (NSString *)talenpalBridgeSource {
    return @"(function(){"
    "if(window.TalenpalBridge&&window.TalenpalBridge.call){return;}"
    "window.TalenpalBridge=window.TalenpalBridge||{};"
    "window.TalenpalBridge.call=function(method,payload,callbackId){"
    "window.webkit.messageHandlers.TalenpalBridge.postMessage({method:method,payload:payload,callbackId:callbackId});"
    "};"
    "window.TalenpalBridge.__resolve=window.TalenpalBridge.__resolve||function(){};"
    "window.TalenpalBridge.__emit=window.TalenpalBridge.__emit||function(){};"
    "})();";
}

- (NSURL *)webURLForMainUrl:(NSString *)mainUrl {
    if (mainUrl.length == 0) {
        return [NSURL URLWithString:@"about:blank"];
    }
    NSURL *url = [NSURL URLWithString:mainUrl];
    if (url) {
        return url;
    }
    return [NSURL fileURLWithPath:mainUrl];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![message.name isEqualToString:@"TalenpalBridge"] || ![message.body isKindOfClass:NSDictionary.class]) {
        return;
    }
    NSDictionary *body = (NSDictionary *)message.body;
    NSString *method = [body[@"method"] isKindOfClass:NSString.class] ? body[@"method"] : @"";
    NSString *callbackId = [body[@"callbackId"] isKindOfClass:NSString.class] ? body[@"callbackId"] : @"";
    if ([method isEqualToString:@"getAuthToken"]) {
        [self handleGetAuthTokenWithCallbackId:callbackId];
    } else if ([method isEqualToString:@"getEnvInfo"]) {
        [self resolveBridgeCallback:callbackId response:@{@"code": @0, @"data": [self bridgeEnvInfo]}];
    } else if ([method isEqualToString:@"refreshAuthToken"]) {
        [self handleRefreshAuthTokenWithCallbackId:callbackId];
    } else if ([method isEqualToString:@"closeWebView"]) {
        NSDictionary *payload = [self bridgePayloadDictionaryFromBody:body];
        if ([payload[@"reason"] isEqualToString:@"auth_expired"]) {
            [UserInfo clearMyUser];
            [UserInfo showLogin];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self resolveBridgeCallback:callbackId response:@{@"code": @4004, @"message": @"Unsupported bridge method"}];
    }
}

- (void)handleGetAuthTokenWithCallbackId:(NSString *)callbackId {
    NSString *accessToken = kMyUser.accessToken ?: @"";
    if (![ThingSmartUser sharedInstance].isLogin || accessToken.length == 0) {
        [self resolveBridgeCallback:callbackId response:@{@"code": @1001, @"message": @"User not logged in"}];
        return;
    }
    NSString *userId = kMyUser.userId.length > 0 ? kMyUser.userId : ([ThingSmartUser sharedInstance].uid ?: @"");
    [self resolveBridgeCallback:callbackId response:@{@"code": @0, @"data": @{@"accessToken": accessToken, @"userId": userId}}];
}

- (void)handleRefreshAuthTokenWithCallbackId:(NSString *)callbackId {
    NSString *refreshToken = kMyUser.refreshToken ?: @"";
    if (refreshToken.length == 0) {
        [self resolveBridgeCallback:callbackId response:@{@"code": @1002, @"message": @"Refresh token is empty"}];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@?refreshToken=%@", [APIPortConfiguration getRefreshTokenUrl], [self urlEncodedString:refreshToken]];
    [[APIManager shared] POST:url parameter:@{} success:^(id  _Nonnull result, id  _Nonnull data, NSString * _Nonnull msg) {
        if ([data isKindOfClass:NSDictionary.class]) {
            NSString *accessToken = data[@"accessToken"] ?: @"";
            NSString *newRefreshToken = data[@"refreshToken"] ?: @"";
            if (accessToken.length > 0) {
                kMyUser.accessToken = accessToken;
            }
            if (newRefreshToken.length > 0) {
                kMyUser.refreshToken = newRefreshToken;
            }
            [UserInfo saveMyUser];
            [self resolveBridgeCallback:callbackId response:@{@"code": @0, @"data": @{@"accessToken": kMyUser.accessToken ?: @""}}];
        } else {
            [self resolveBridgeCallback:callbackId response:@{@"code": @1002, @"message": @"Invalid refresh token response"}];
        }
    } failure:^(NSError * _Nonnull error, NSString * _Nonnull msg) {
        [self resolveBridgeCallback:callbackId response:@{@"code": @1002, @"message": msg ?: @"Refresh token failed"}];
    }];
}

- (NSDictionary *)bridgeEnvInfo {
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = window.safeAreaInsets;
    }
    NSString *locale = [[ATLanguageHelper currentLanguageCode] stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    if (locale.length == 0) {
        locale = @"en";
    }
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    return @{
        @"platform": @"ios",
        @"appVersion": APP_VERSION ?: @"",
        @"osVersion": UIDevice.currentDevice.systemVersion ?: @"",
        @"deviceModel": UIDevice.currentDevice.model ?: @"",
        @"locale": locale,
        @"langType": [ATLanguageHelper miniAppLangType] ?: @"en",
        @"timezone": timeZone.name ?: @"",
        @"safeAreaInsets": @{
            @"top": @(safeAreaInsets.top),
            @"bottom": @(safeAreaInsets.bottom),
            @"left": @(safeAreaInsets.left),
            @"right": @(safeAreaInsets.right)
        }
    };
}

- (void)resolveBridgeCallback:(NSString *)callbackId response:(NSDictionary *)response {
    if (callbackId.length == 0) {
        return;
    }
    NSData *responseData = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
    if (!responseData) {
        return;
    }
    NSString *callbackIdJSON = [self jsonStringLiteral:callbackId];
    NSString *responseJSON = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSString *script = [NSString stringWithFormat:@"window.TalenpalBridge&&window.TalenpalBridge.__resolve&&window.TalenpalBridge.__resolve(%@,%@)", callbackIdJSON, responseJSON];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView evaluateJavaScript:script completionHandler:nil];
    });
}

- (NSDictionary *)bridgePayloadDictionaryFromBody:(NSDictionary *)body {
    id payload = body[@"payload"];
    if ([payload isKindOfClass:NSDictionary.class]) {
        return payload;
    }
    if (![payload isKindOfClass:NSString.class]) {
        return @{};
    }
    NSData *data = [(NSString *)payload dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return @{};
    }
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [object isKindOfClass:NSDictionary.class] ? object : @{};
}

- (NSString *)jsonStringLiteral:(NSString *)value {
    NSMutableString *escaped = [value mutableCopy];
    [escaped replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"\n" withString:@"\\n" options:0 range:NSMakeRange(0, escaped.length)];
    [escaped replaceOccurrencesOfString:@"\r" withString:@"\\r" options:0 range:NSMakeRange(0, escaped.length)];
    return [NSString stringWithFormat:@"\"%@\"", escaped];
}

- (NSString *)urlEncodedString:(NSString *)value {
    NSMutableCharacterSet *allowedCharacters = [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
    [allowedCharacters addCharactersInString:@"-._~"];
    return [value stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters] ?: @"";
}



#pragma mark -- WKNavigationDelegate

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
}

// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString * urlStr = navigationAction.request.URL.absoluteString;
    NSLog(@"发送跳转请求：%@",urlStr);
    NSString *lastName =[[urlStr lastPathComponent] lowercaseString];
    //先判断是 TXT 文件
    if ([lastName containsString:@".txt"]) {
        
        NSData *data = [NSData dataWithContentsOfURL:navigationAction.request.URL];
        // 加载二进制文件
        [self.webView loadData:data MIMEType:@"text/html" characterEncodingName:@"UTF-8" baseURL:nil];
    }
    
    if ([lastName containsString:@".pdf"])
    {
        NSData *data = [NSData dataWithContentsOfURL:navigationAction.request.URL];
        [self.webView loadData:data MIMEType:@"application/pdf" characterEncodingName:@"UTF-8" baseURL:nil];
    }

    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}

// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    NSLog(@"当前跳转地址：%@",urlStr);
    
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
