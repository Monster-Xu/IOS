//
//  LogManager.m
//  自动日志管理器实现
//

#import "LogManager.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <sys/utsname.h>
#import <signal.h>
#import <execinfo.h>
#import <unistd.h>
#import <fcntl.h>
#import <string.h>

static int gCrashLogFD = -1;

static const char *crashSignalName(int signal) {
    switch (signal) {
        case SIGABRT: return "SIGABRT";
        case SIGSEGV: return "SIGSEGV";
        case SIGBUS:  return "SIGBUS";
        case SIGILL:  return "SIGILL";
        case SIGFPE:  return "SIGFPE";
        case SIGTRAP: return "SIGTRAP";
        default:      return "UNKNOWN";
    }
}

static void writeCrashSignalLog(int signal) {
    if (gCrashLogFD < 0) {
        return;
    }
    const char *signalName = crashSignalName(signal);
    char header[256];
    int headerLen = snprintf(header, sizeof(header),
                             "\n========== Signal Crash ==========\nSignal: %s (%d)\n",
                             signalName, signal);
    if (headerLen > 0) {
        write(gCrashLogFD, header, (size_t)headerLen);
    }

    void *callstack[128];
    int frames = backtrace(callstack, 128);
    backtrace_symbols_fd(callstack, frames, gCrashLogFD);

    const char *footer = "===============================\n";
    write(gCrashLogFD, footer, strlen(footer));
}

static void signalCrashHandler(int signo) {
    writeCrashSignalLog(signo);

    signal(signo, SIG_DFL);
    kill(getpid(), signo);
}

@interface LogManager ()

@property (nonatomic, strong) NSString *logFilePath;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) dispatch_queue_t logQueue;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL isAutoLogging;
@property (nonatomic, strong) NSMutableDictionary *activeRequests; // 追踪活跃的网络请求

@end

@implementation LogManager

+ (void)startAutoLogging {
    LogManager *manager = [self sharedManager];
    if (!manager.isAutoLogging) {
        manager.isAutoLogging = YES;
        [manager setupAutoLogging];
        [manager logInfo:@"========== 自动日志记录已启动 =========="];
    }
}

+ (instancetype)sharedManager {
    static LogManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupLogSystem];
    }
    return self;
}

- (void)setupLogSystem {
    _logQueue = dispatch_queue_create("com.app.logQueue", DISPATCH_QUEUE_SERIAL);
    _activeRequests = [NSMutableDictionary dictionary];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [_dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *logDirectory = [documentPath stringByAppendingPathComponent:@"Logs"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDateFormatter *fileDateFormatter = [[NSDateFormatter alloc] init];
    [fileDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [fileDateFormatter stringFromDate:[NSDate date]];
    
    _logFilePath = [logDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"app_log_%@.txt", dateString]];
    
    if (![fileManager fileExistsAtPath:_logFilePath]) {
        [fileManager createFileAtPath:_logFilePath contents:nil attributes:nil];
    }
    
    _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_logFilePath];
    [_fileHandle seekToEndOfFile];
    
    [self setupCrashHandler];
    
    // 添加自动清理设置
       [self setupAutoCleanup];
}

#pragma mark - 自动日志记录

- (void)setupAutoLogging {
    // 1. Hook UIViewController 生命周期
    [self hookViewControllerLifecycle];
    
    // 2. Hook UIControl 事件
    [self hookUIControlEvents];
    
    // 3. Hook 网络请求（NSURLSession）
    [self hookNetworkRequests];
    
    // 4. 监听应用生命周期
    [self observeAppLifecycle];
    
    // 5. 监听通知
    [self observeNotifications];
     
    // 6. 崩溃处理
    [self setupCrashHandler];
}

#pragma mark - Hook ViewController

- (void)hookViewControllerLifecycle {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [UIViewController class];
        
        [self swizzleMethod:@selector(viewDidLoad)
                  withClass:class
                 newSelector:@selector(log_viewDidLoad)];
        
        [self swizzleMethod:@selector(viewWillAppear:)
                  withClass:class
                 newSelector:@selector(log_viewWillAppear:)];
        
        [self swizzleMethod:@selector(viewDidAppear:)
                  withClass:class
                 newSelector:@selector(log_viewDidAppear:)];
        
        [self swizzleMethod:@selector(viewWillDisappear:)
                  withClass:class
                 newSelector:@selector(log_viewWillDisappear:)];
    });
}

#pragma mark - Hook UIControl

- (void)hookUIControlEvents {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [UIControl class];
        
        [self swizzleMethod:@selector(sendAction:to:forEvent:)
                  withClass:class
                 newSelector:@selector(log_sendAction:to:forEvent:)];
    });
}

#pragma mark - Hook 网络请求

- (void)hookNetworkRequests {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Hook NSURLSessionTask
        Class taskClass = [NSURLSessionTask class];
        [self swizzleMethod:@selector(resume)
                  withClass:taskClass
                 newSelector:@selector(log_resume)];
        
        // Hook NSURLSession 数据任务
        Class sessionClass = [NSURLSession class];
        [self swizzleMethod:@selector(dataTaskWithRequest:completionHandler:)
                  withClass:sessionClass
                 newSelector:@selector(log_dataTaskWithRequest:completionHandler:)];
        
        [self swizzleMethod:@selector(dataTaskWithURL:completionHandler:)
                  withClass:sessionClass
                 newSelector:@selector(log_dataTaskWithURL:completionHandler:)];
    });
}

#pragma mark - 应用生命周期

- (void)observeAppLifecycle {
    // 应用启动
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    // 进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    // 进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    // 即将终止
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    // 内存警告
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

#pragma mark - 通知监听

- (void)observeNotifications {
    // 键盘显示
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

#pragma mark - 应用生命周期回调

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSDictionary *info = @{
        @"version": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: @"unknown",
        @"build": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] ?: @"unknown",
        @"system": [[UIDevice currentDevice] systemVersion],
        @"device": [self getDeviceModel]
    };
    [self logUserAction:@"应用启动" params:info];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self logInfo:@"应用进入前台"];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self logInfo:@"应用进入后台"];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self logInfo:@"应用即将终止"];
}

- (void)applicationDidReceiveMemoryWarning:(NSNotification *)notification {
    [self logWarning:@"收到内存警告"];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [self logDebug:@"键盘将要显示"];
}

#pragma mark - Method Swizzling

- (void)swizzleMethod:(SEL)originalSelector withClass:(Class)class newSelector:(SEL)newSelector {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, newSelector);
    
    if (!originalMethod || !swizzledMethod) {
        return;
    }
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                           newSelector,
                           method_getImplementation(originalMethod),
                           method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - 崩溃处理

- (void)setupCrashHandler {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [self setupSignalHandlers];
}

- (void)setupSignalHandlers {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (gCrashLogFD < 0) {
            gCrashLogFD = open(self.logFilePath.UTF8String, O_WRONLY | O_APPEND);
        }
        signal(SIGABRT, signalCrashHandler);
        signal(SIGSEGV, signalCrashHandler);
        signal(SIGBUS, signalCrashHandler);
        signal(SIGILL, signalCrashHandler);
        signal(SIGFPE, signalCrashHandler);
        signal(SIGTRAP, signalCrashHandler);
    });
}

void uncaughtExceptionHandler(NSException *exception) {
    LogManager *manager = [LogManager sharedManager];
    NSString *timestamp = [manager.dateFormatter stringFromDate:[NSDate date]];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: @"unknown";
    NSString *appBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] ?: @"unknown";
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion] ?: @"unknown";
    NSString *deviceModel = [manager getDeviceModel] ?: @"unknown";
    NSString *threadName = [NSThread isMainThread] ? @"main" : (NSThread.currentThread.name.length > 0 ? NSThread.currentThread.name : @"background");
    NSString *appState = @"unknown";
    UIApplicationState state = UIApplication.sharedApplication.applicationState;
    if (state == UIApplicationStateActive) {
        appState = @"active";
    } else if (state == UIApplicationStateInactive) {
        appState = @"inactive";
    } else if (state == UIApplicationStateBackground) {
        appState = @"background";
    }

    NSString *crashLog = [NSString stringWithFormat:@"\n========== 崩溃日志 ==========\n时间: %@\n应用版本: %@ (%@)\n系统版本: %@\n设备型号: %@\n应用状态: %@\n线程: %@\n异常名称: %@\n异常原因: %@\n堆栈信息:\n%@\n==========================\n",
                         timestamp,
                         appVersion,
                         appBuild,
                         systemVersion,
                         deviceModel,
                         appState,
                         threadName,
                         exception.name,
                         exception.reason,
                         [exception.callStackSymbols componentsJoinedByString:@"\n"]];
    
    [manager writeLogToFile:crashLog];
    [manager.fileHandle synchronizeFile];
}

#pragma mark - 日志记录方法

- (void)logWithLevel:(LogLevel)level message:(NSString *)message {
    NSString *levelString = [self stringForLogLevel:level];
    NSString *timestamp = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *logMessage = [NSString stringWithFormat:@"[%@] [%@] %@\n", timestamp, levelString, message];
    
    [self writeLogToFile:logMessage];
    
    #ifdef DEBUG
    NSLog(@"%@", logMessage);
    #endif
}

- (void)logDebug:(NSString *)message {
    [self logWithLevel:LogLevelDebug message:message];
}

- (void)logInfo:(NSString *)message {
    [self logWithLevel:LogLevelInfo message:message];
}

- (void)logWarning:(NSString *)message {
    [self logWithLevel:LogLevelWarning message:message];
}

- (void)logError:(NSString *)message {
    [self logWithLevel:LogLevelError message:message];
}

- (void)logUserAction:(NSString *)action params:(NSDictionary *)params {
    NSString *paramsString = @"";
    if (params && params.count > 0) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        if (jsonData) {
            paramsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    
    NSString *message = [NSString stringWithFormat:@"用户操作: %@ | 参数: %@", action, paramsString];
    [self logWithLevel:LogLevelInfo message:message];
}

#pragma mark - API 和错误日志记录

- (void)logAPIRequest:(NSURLRequest *)request {
    if (!request) return;
    
    NSString *requestId = [NSUUID UUID].UUIDString;
    NSMutableDictionary *requestInfo = [NSMutableDictionary dictionary];
    
    requestInfo[@"requestId"] = requestId;
    requestInfo[@"url"] = request.URL.absoluteString ?: @"";
    requestInfo[@"method"] = request.HTTPMethod ?: @"GET";
    requestInfo[@"timestamp"] = @([[NSDate date] timeIntervalSince1970]);
    
    // 记录请求头
    if (request.allHTTPHeaderFields.count > 0) {
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        for (NSString *key in request.allHTTPHeaderFields) {
            // 过滤敏感信息
            if ([key.lowercaseString containsString:@"authorization"] ||
                [key.lowercaseString containsString:@"token"] ||
                [key.lowercaseString containsString:@"password"]) {
                headers[key] = @"[已隐藏]";
            } else {
                headers[key] = request.allHTTPHeaderFields[key];
            }
        }
        requestInfo[@"headers"] = headers;
    }
    
    // 记录请求体
    if (request.HTTPBody) {
        NSString *bodyString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        if (bodyString) {
            // 尝试解析JSON并过滤敏感信息
            NSError *error;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:&error];
            if (!error && [jsonObject isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *sanitizedBody = [(NSDictionary *)jsonObject mutableCopy];
                [self sanitizeParameters:sanitizedBody];
                requestInfo[@"body"] = sanitizedBody;
            } else {
                requestInfo[@"body"] = bodyString.length > 1000 ? [bodyString substringToIndex:1000] : bodyString;
            }
        }
    }
    
    // 存储请求信息用于后续匹配响应
    self.activeRequests[requestId] = requestInfo;
    
    NSString *logMessage = [NSString stringWithFormat:@"🚀 API请求开始 [%@] %@ %@", 
                           requestId, request.HTTPMethod ?: @"GET", request.URL.absoluteString ?: @""];
    [self logWithLevel:LogLevelInfo message:logMessage];
    
    // 记录请求体内容（简化版本用于INFO级别）
    if (request.HTTPBody && request.HTTPBody.length > 0) {
        NSString *bodyString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        if (bodyString) {
            NSError *error;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:&error];
            if (!error && jsonObject) {
                NSMutableDictionary *displayBody = [(NSDictionary *)jsonObject mutableCopy];
                [self sanitizeParameters:displayBody];
                NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:displayBody 
                                                                         options:NSJSONWritingPrettyPrinted 
                                                                           error:nil];
                if (prettyJsonData) {
                    NSString *prettyJsonString = [[NSString alloc] initWithData:prettyJsonData encoding:NSUTF8StringEncoding];
                    if (prettyJsonString.length <= 800) {
                        [self logWithLevel:LogLevelInfo message:[NSString stringWithFormat:@"📤 请求数据 [%@]:\n%@", requestId, prettyJsonString]];
                    } else {
                        NSString *truncatedJson = [prettyJsonString substringToIndex:800];
                        [self logWithLevel:LogLevelInfo message:[NSString stringWithFormat:@"📤 请求数据 [%@] (已截断):\n%@\n...[还有 %lu 字符]", 
                                                               requestId, truncatedJson, (unsigned long)(prettyJsonString.length - 800)]];
                    }
                }
            } else {
                // 非JSON请求体
                NSString *truncatedBody = bodyString.length > 500 ? [bodyString substringToIndex:500] : bodyString;
                [self logWithLevel:LogLevelInfo message:[NSString stringWithFormat:@"📤 请求数据 [%@] (文本):\n%@%@", 
                                                       requestId, truncatedBody, 
                                                       bodyString.length > 500 ? @"\n...[已截断]" : @""]];
            }
        } else {
            [self logWithLevel:LogLevelInfo message:[NSString stringWithFormat:@"📤 请求数据 [%@]: [二进制数据，长度: %lu 字节]", 
                                                   requestId, (unsigned long)request.HTTPBody.length]];
        }
    }
    
    // 记录详细请求信息（DEBUG级别）
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestInfo options:NSJSONWritingPrettyPrinted error:nil];
    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self logWithLevel:LogLevelDebug message:[NSString stringWithFormat:@"🔍 请求详情 [%@]: %@", requestId, jsonString]];
    }
}

- (void)logAPIResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error {
    if (!response && !error) return;
    
    NSString *requestId = nil;
    NSString *url = response.URL.absoluteString ?: @"unknown";
    
    // 尝试找到对应的请求ID
    for (NSString *key in self.activeRequests.allKeys) {
        NSDictionary *requestInfo = self.activeRequests[key];
        if ([requestInfo[@"url"] isEqualToString:url]) {
            requestId = key;
            break;
        }
    }
    
    if (!requestId) {
        requestId = [NSUUID UUID].UUIDString;
    }
    
    NSMutableDictionary *responseInfo = [NSMutableDictionary dictionary];
    responseInfo[@"requestId"] = requestId;
    responseInfo[@"url"] = url;
    responseInfo[@"timestamp"] = @([[NSDate date] timeIntervalSince1970]);
    
    if (error) {
        // 网络错误
        responseInfo[@"success"] = @NO;
        responseInfo[@"error"] = @{
            @"code": @(error.code),
            @"domain": error.domain ?: @"",
            @"description": error.localizedDescription ?: @"",
            @"failureReason": error.localizedFailureReason ?: @"",
            @"recoverySuggestion": error.localizedRecoverySuggestion ?: @""
        };
        
        [self logWithLevel:LogLevelError message:[NSString stringWithFormat:@"❌ API请求失败 [%@] %@ - %@", 
                                                 requestId, url, error.localizedDescription]];
    } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        responseInfo[@"statusCode"] = @(httpResponse.statusCode);
        responseInfo[@"headers"] = httpResponse.allHeaderFields ?: @{};
        
        BOOL isSuccess = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300;
        responseInfo[@"success"] = @(isSuccess);
        
        // 解析响应数据
        if (data && data.length > 0) {
            responseInfo[@"dataSize"] = @(data.length);
            
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (responseString) {
                NSError *jsonError;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                if (!jsonError && jsonObject) {
                    // 记录结构化的JSON数据
                    responseInfo[@"data"] = jsonObject;
                    responseInfo[@"dataType"] = @"JSON";
                    
                    // 同时保存原始字符串（用于完整记录）
                    if (responseString.length <= 5000) {
                        responseInfo[@"rawResponse"] = responseString;
                    } else {
                        responseInfo[@"rawResponse"] = [NSString stringWithFormat:@"%@\n...[数据过长，已截断，完整长度: %lu 字符]", 
                                                      [responseString substringToIndex:5000], 
                                                      (unsigned long)responseString.length];
                    }
                    
                    // 检查是否为服务器错误响应
                    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
                        if (jsonDict[@"error"] || jsonDict[@"errors"] || !isSuccess) {
                            [self logServerError:jsonDict fromAPI:url];
                        }
                    }
                } else {
                    // 非JSON数据
                    responseInfo[@"dataType"] = @"Text/Other";
                    
                    // 限制响应内容长度，但保存更多内容用于调试
                    if (responseString.length <= 3000) {
                        responseInfo[@"rawData"] = responseString;
                    } else {
                        responseInfo[@"rawData"] = [NSString stringWithFormat:@"%@\n...[数据过长，已截断，完整长度: %lu 字符]", 
                                                  [responseString substringToIndex:3000], 
                                                  (unsigned long)responseString.length];
                    }
                }
            } else {
                // 无法转换为字符串的二进制数据
                responseInfo[@"dataType"] = @"Binary";
                responseInfo[@"rawData"] = [NSString stringWithFormat:@"[二进制数据，长度: %lu 字节]", (unsigned long)data.length];
            }
        } else {
            responseInfo[@"dataSize"] = @0;
            responseInfo[@"data"] = @"[无响应数据]";
        }
        
        NSString *statusEmoji = isSuccess ? @"✅" : @"❌";
        NSString *dataInfo = responseInfo[@"dataSize"] ? [NSString stringWithFormat:@" | 数据大小: %@ 字节", responseInfo[@"dataSize"]] : @"";
        [self logWithLevel:isSuccess ? LogLevelInfo : LogLevelWarning 
                   message:[NSString stringWithFormat:@"%@ API响应 [%@] %@ - 状态码: %ld%@", 
                           statusEmoji, requestId, url, (long)httpResponse.statusCode, dataInfo]];
        
        // 记录响应数据内容（简化版本用于INFO级别）
        if (responseInfo[@"data"] && ![responseInfo[@"data"] isEqual:@"[无响应数据]"]) {
            NSString *dataType = responseInfo[@"dataType"] ?: @"Unknown";
            if ([dataType isEqualToString:@"JSON"]) {
                // JSON数据的简化显示
                NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:responseInfo[@"data"] 
                                                                         options:NSJSONWritingPrettyPrinted 
                                                                           error:nil];
                if (prettyJsonData) {
                    NSString *prettyJsonString = [[NSString alloc] initWithData:prettyJsonData encoding:NSUTF8StringEncoding];
                    if (prettyJsonString.length <= 1000) {
                        [self logWithLevel:LogLevelInfo message:[NSString stringWithFormat:@"📦 响应数据 [%@]:\n%@", requestId, prettyJsonString]];
                    } else {
                        NSString *truncatedJson = [prettyJsonString substringToIndex:1000];
                        [self logWithLevel:LogLevelInfo message:[NSString stringWithFormat:@"📦 响应数据 [%@] (已截断):\n%@\n...[还有 %lu 字符]", 
                                                               requestId, truncatedJson, (unsigned long)(prettyJsonString.length - 1000)]];
                    }
                }
            } else {
                // 非JSON数据的显示
                NSString *rawData = responseInfo[@"rawData"] ?: @"[无法显示数据]";
                [self logWithLevel:LogLevelInfo message:[NSString stringWithFormat:@"📦 响应数据 [%@] (%@):\n%@", requestId, dataType, rawData]];
            }
        }
    }
    
    // 记录详细响应信息（DEBUG级别）
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseInfo options:NSJSONWritingPrettyPrinted error:nil];
    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self logWithLevel:LogLevelDebug message:[NSString stringWithFormat:@"🔍 响应详情 [%@]: %@", requestId, jsonString]];
    }
    
    // 如果有完整的原始响应数据，也记录到DEBUG级别
    if (responseInfo[@"rawResponse"]) {
        [self logWithLevel:LogLevelDebug message:[NSString stringWithFormat:@"📄 完整响应内容 [%@]:\n%@", requestId, responseInfo[@"rawResponse"]]];
    }
    
    // 移除已完成的请求
    if (requestId) {
        [self.activeRequests removeObjectForKey:requestId];
    }
}

- (void)logServerError:(NSDictionary *)errorInfo fromAPI:(NSString *)apiPath {
    NSMutableDictionary *errorLog = [NSMutableDictionary dictionary];
    errorLog[@"type"] = @"服务器错误";
    errorLog[@"api"] = apiPath ?: @"unknown";
    errorLog[@"timestamp"] = [self.dateFormatter stringFromDate:[NSDate date]];
    errorLog[@"errorInfo"] = errorInfo;
    
    // 提取常见的错误字段
    NSString *errorCode = nil;
    NSString *errorMessage = nil;
    
    if ([errorInfo isKindOfClass:[NSDictionary class]]) {
        // 尝试不同的错误格式
        errorCode = errorInfo[@"code"] ?: errorInfo[@"error_code"] ?: errorInfo[@"errorCode"];
        errorMessage = errorInfo[@"message"] ?: errorInfo[@"error"] ?: errorInfo[@"msg"] ?: errorInfo[@"error_message"];
        
        if ([errorCode isKindOfClass:[NSNumber class]]) {
            errorCode = [(NSNumber *)errorCode stringValue];
        }
    }
    
    NSString *logMessage = [NSString stringWithFormat:@"🔥 服务器错误 - API: %@ | 错误码: %@ | 消息: %@", 
                           apiPath ?: @"unknown", errorCode ?: @"无", errorMessage ?: @"无详细信息"];
    [self logWithLevel:LogLevelError message:logMessage];
    
    // 记录完整错误信息
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorLog options:NSJSONWritingPrettyPrinted error:nil];
    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self logWithLevel:LogLevelError message:[NSString stringWithFormat:@"服务器错误详情: %@", jsonString]];
    }
}

- (void)logSDKError:(NSError *)error fromSDK:(NSString *)sdkName context:(NSDictionary *)context {
    if (!error) return;
    
    NSMutableDictionary *errorLog = [NSMutableDictionary dictionary];
    errorLog[@"type"] = @"SDK错误";
    errorLog[@"sdk"] = sdkName ?: @"unknown";
    errorLog[@"timestamp"] = [self.dateFormatter stringFromDate:[NSDate date]];
    
    // 错误基本信息
    errorLog[@"error"] = @{
        @"code": @(error.code),
        @"domain": error.domain ?: @"",
        @"description": error.localizedDescription ?: @"",
        @"failureReason": error.localizedFailureReason ?: @"",
        @"recoverySuggestion": error.localizedRecoverySuggestion ?: @""
    };
    
    // 用户信息
    if (error.userInfo && error.userInfo.count > 0) {
        NSMutableDictionary *sanitizedUserInfo = [error.userInfo mutableCopy];
        [self sanitizeParameters:sanitizedUserInfo];
        errorLog[@"userInfo"] = sanitizedUserInfo;
    }
    
    // 上下文信息
    if (context && context.count > 0) {
        NSMutableDictionary *sanitizedContext = [context mutableCopy];
        [self sanitizeParameters:sanitizedContext];
        errorLog[@"context"] = sanitizedContext;
    }
    
    NSString *logMessage = [NSString stringWithFormat:@"⚠️ SDK错误 - %@ | 错误码: %ld | %@", 
                           sdkName ?: @"未知SDK", (long)error.code, error.localizedDescription ?: @"无描述"];
    [self logWithLevel:LogLevelError message:logMessage];
    
    // 记录完整错误信息
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorLog options:NSJSONWritingPrettyPrinted error:nil];
    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self logWithLevel:LogLevelError message:[NSString stringWithFormat:@"SDK错误详情: %@", jsonString]];
    }
}

// 敏感信息过滤辅助方法
- (void)sanitizeParameters:(NSMutableDictionary *)parameters {
    NSArray *sensitiveKeys = @[@"password", @"token", @"secret", @"key", @"authorization", @"auth",
                              @"credential", @"private", @"secure", @"pwd", @"pass"];
    
    for (NSString *key in parameters.allKeys) {
        for (NSString *sensitiveKey in sensitiveKeys) {
            if ([key.lowercaseString containsString:sensitiveKey.lowercaseString]) {
                parameters[key] = @"[已隐藏]";
                break;
            }
        }
        
        // 递归处理嵌套字典
        if ([parameters[key] isKindOfClass:[NSMutableDictionary class]]) {
            [self sanitizeParameters:parameters[key]];
        } else if ([parameters[key] isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *mutableDict = [parameters[key] mutableCopy];
            [self sanitizeParameters:mutableDict];
            parameters[key] = mutableDict;
        }
    }
}

#pragma mark - 文件操作

- (void)writeLogToFile:(NSString *)log {
    dispatch_async(self.logQueue, ^{
        @try {
            NSData *data = [log dataUsingEncoding:NSUTF8StringEncoding];
            if (data && self.fileHandle) {
                [self.fileHandle writeData:data];
            }
        } @catch (NSException *exception) {
            NSLog(@"写入日志失败: %@", exception);
        }
    });
}

- (void)exportLogsWithCompletion:(void (^)(NSURL * _Nullable, NSError * _Nullable))completion {
    dispatch_async(self.logQueue, ^{
        @try {
            [self.fileHandle synchronizeFile];
            
            NSString *logDirectory = [self.logFilePath stringByDeletingLastPathComponent];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *logFiles = [fileManager contentsOfDirectoryAtPath:logDirectory error:nil];
            
            // 导出到 Documents 目录（可在"文件"app 中访问）
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *exportDirectory = [documentsPath stringByAppendingPathComponent:@"ExportedLogs"];
            
            // 创建导出目录
            if (![fileManager fileExistsAtPath:exportDirectory]) {
                [fileManager createDirectoryAtPath:exportDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            // 生成导出文件名
            NSDateFormatter *exportFormatter = [[NSDateFormatter alloc] init];
            [exportFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
            NSString *exportFileName = [NSString stringWithFormat:@"AppLogs_%@.txt", [exportFormatter stringFromDate:[NSDate date]]];
            NSString *exportPath = [exportDirectory stringByAppendingPathComponent:exportFileName];
            
            // 合并最近7天的日志文件
            NSMutableString *allLogs = [NSMutableString string];
            [allLogs appendString:@"========== 应用日志导出 ==========\n"];
            [allLogs appendFormat:@"导出时间: %@\n", [self.dateFormatter stringFromDate:[NSDate date]]];
            [allLogs appendFormat:@"应用版本: %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
            [allLogs appendFormat:@"系统版本: %@\n", [[UIDevice currentDevice] systemVersion]];
            [allLogs appendFormat:@"设备型号: %@\n\n", [self getDeviceModel]];
            
            // 计算7天前的日期
            NSDate *sevenDaysAgo = [[NSDate date] dateByAddingTimeInterval:-7 * 24 * 60 * 60];
            NSDateFormatter *fileNameFormatter = [[NSDateFormatter alloc] init];
            [fileNameFormatter setDateFormat:@"yyyy-MM-dd"];
            
            // 按日期排序日志文件
            NSArray *sortedLogFiles = [logFiles sortedArrayUsingComparator:^NSComparisonResult(NSString *file1, NSString *file2) {
                return [file1 compare:file2];
            }];
            
            for (NSString *fileName in sortedLogFiles) {
                if ([fileName hasPrefix:@"app_log_"]) {
                    // 从文件名中提取日期
                    NSString *dateString = [fileName stringByReplacingOccurrencesOfString:@"app_log_" withString:@""];
                    dateString = [dateString stringByReplacingOccurrencesOfString:@".txt" withString:@""];
                    
                    NSDate *fileDate = [fileNameFormatter dateFromString:dateString];
                    
                    // 只处理最近7天的日志文件
                    if (fileDate && [fileDate compare:sevenDaysAgo] != NSOrderedAscending) {
                        NSString *filePath = [logDirectory stringByAppendingPathComponent:fileName];
                        NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                        if (content) {
                            [allLogs appendFormat:@"\n========== %@ ==========\n", fileName];
                            [allLogs appendString:content];
                        }
                    }
                }
            }
            
            // 如果没有找到最近7天的日志文件，添加提示
            if (allLogs.length <= 200) { // 只有头部信息
                [allLogs appendString:@"\n⚠️ 最近7天内没有日志记录\n"];
            }
            
            // 写入导出文件
            NSError *writeError = nil;
            [allLogs writeToFile:exportPath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (writeError) {
                    if (completion) completion(nil, writeError);
                } else {
                    NSURL *fileURL = [NSURL fileURLWithPath:exportPath];
                    if (completion) completion(fileURL, nil);
                }
            });
            
        } @catch (NSException *exception) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"LogManagerError" code:-1 userInfo:@{NSLocalizedDescriptionKey: exception.reason}];
                if (completion) completion(nil, error);
            });
        }
    });
}

- (void)clearLogs {
    dispatch_async(self.logQueue, ^{
        [self.fileHandle synchronizeFile];
        
        NSString *logDirectory = [self.logFilePath stringByDeletingLastPathComponent];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *logFiles = [fileManager contentsOfDirectoryAtPath:logDirectory error:nil];
        
        for (NSString *fileName in logFiles) {
            if ([fileName hasPrefix:@"app_log_"]) {
                NSString *filePath = [logDirectory stringByAppendingPathComponent:fileName];
                [fileManager removeItemAtPath:filePath error:nil];
            }
        }
        
        // 重新创建文件（不需要 error 参数）
        [fileManager createFileAtPath:self.logFilePath contents:nil attributes:nil];
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.logFilePath];
        [self.fileHandle seekToEndOfFile];
    });
}

- (NSString *)getLogFileSize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *logDirectory = [self.logFilePath stringByDeletingLastPathComponent];
    NSArray *logFiles = [fileManager contentsOfDirectoryAtPath:logDirectory error:nil];
    
    unsigned long long totalSize = 0;
    for (NSString *fileName in logFiles) {
        if ([fileName hasPrefix:@"app_log_"]) {
            NSString *filePath = [logDirectory stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:nil];
            totalSize += [attrs fileSize];
        }
    }
    
    return [self formatFileSize:totalSize];
}

#pragma mark - 辅助方法

- (NSString *)stringForLogLevel:(LogLevel)level {
    switch (level) {
        case LogLevelDebug:   return @"DEBUG";
        case LogLevelInfo:    return @"INFO";
        case LogLevelWarning: return @"WARNING";
        case LogLevelError:   return @"ERROR";
        default:              return @"UNKNOWN";
    }
}

- (NSString *)formatFileSize:(unsigned long long)size {
    if (size < 1024) {
        return [NSString stringWithFormat:@"%llu B", size];
    } else if (size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2f KB", size / 1024.0];
    } else {
        return [NSString stringWithFormat:@"%.2f MB", size / (1024.0 * 1024.0)];
    }
}

- (NSString *)getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (void)dealloc {
    [_fileHandle closeFile];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 自动清理旧日志

- (void)cleanupOldLogs {
    [self cleanupOldLogsWithDays:7];
}

- (void)cleanupOldLogsWithDays:(NSInteger)days {
    dispatch_async(self.logQueue, ^{
        @try {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *logDirectory = [self.logFilePath stringByDeletingLastPathComponent];
            
            // 获取日志目录下的所有文件
            NSArray *logFiles = [fileManager contentsOfDirectoryAtPath:logDirectory error:nil];
            
            // 计算7天前的日期
            NSDate *sevenDaysAgo = [[NSDate date] dateByAddingTimeInterval:-days * 24 * 60 * 60];
            
            // 用于统计清理结果
            NSInteger cleanedCount = 0;
            unsigned long long cleanedSize = 0;
            
            for (NSString *fileName in logFiles) {
                // 只处理日志文件
                if ([fileName hasPrefix:@"app_log_"] && [fileName hasSuffix:@".txt"]) {
                    NSString *filePath = [logDirectory stringByAppendingPathComponent:fileName];
                    
                    // 获取文件属性
                    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
                    NSDate *fileModificationDate = [fileAttributes fileModificationDate];
                    
                    // 如果文件修改日期早于7天前，则删除
                    if (fileModificationDate && [fileModificationDate compare:sevenDaysAgo] == NSOrderedAscending) {
                        unsigned long long fileSize = [fileAttributes fileSize];
                        
                        if ([fileManager removeItemAtPath:filePath error:nil]) {
                            cleanedCount++;
                            cleanedSize += fileSize;
                            
                            // 记录清理的日志文件信息
                            NSString *logMessage = [NSString stringWithFormat:@"已清理旧日志文件: %@ (大小: %@, 修改时间: %@)",
                                                   fileName,
                                                   [self formatFileSize:fileSize],
                                                   [self.dateFormatter stringFromDate:fileModificationDate]];
                            [self logInfo:logMessage];
                        }
                    }
                }
            }
            
            // 记录清理总结
            if (cleanedCount > 0) {
                NSString *summary = [NSString stringWithFormat:@"日志清理完成: 删除了 %ld 个文件，共 %@",
                                    (long)cleanedCount,
                                    [self formatFileSize:cleanedSize]];
                [self logInfo:summary];
            } else {
                [self logDebug:@"未找到需要清理的旧日志文件"];
            }
            
        } @catch (NSException *exception) {
            [self logError:[NSString stringWithFormat:@"清理旧日志时发生异常: %@", exception.reason]];
        }
    });
}


#pragma mark - 定期自动清理

- (void)setupAutoCleanup {
    // 启动时执行一次清理
    [self cleanupOldLogs];
    
    // 每天自动清理一次（使用后台队列）
    dispatch_time_t daily = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(24 * 60 * 60 * NSEC_PER_SEC));
    dispatch_after(daily, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self cleanupOldLogs];
        // 递归调用以保持每天清理
        [self setupAutoCleanup];
    });
}
@end

#pragma mark - UIViewController Category

@implementation UIViewController (AutoLogging)

- (void)log_viewDidLoad {
    [self log_viewDidLoad];
    [[LogManager sharedManager] logInfo:[NSString stringWithFormat:@"页面加载: %@", NSStringFromClass([self class])]];
}

- (void)log_viewWillAppear:(BOOL)animated {
    [self log_viewWillAppear:animated];
    [[LogManager sharedManager] logInfo:[NSString stringWithFormat:@"页面将显示: %@", NSStringFromClass([self class])]];
}

- (void)log_viewDidAppear:(BOOL)animated {
    [self log_viewDidAppear:animated];
    [[LogManager sharedManager] logInfo:[NSString stringWithFormat:@"页面已显示: %@", NSStringFromClass([self class])]];
}

- (void)log_viewWillDisappear:(BOOL)animated {
    [self log_viewWillDisappear:animated];
    [[LogManager sharedManager] logInfo:[NSString stringWithFormat:@"页面将消失: %@", NSStringFromClass([self class])]];
}






@end

#pragma mark - UIControl Category

@implementation UIControl (AutoLogging)

- (void)log_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [self log_sendAction:action to:target forEvent:event];
    
    NSString *controlType = NSStringFromClass([self class]);
    NSString *actionName = NSStringFromSelector(action);
    NSString *targetName = target ? NSStringFromClass([target class]) : @"nil";
    
    NSString *title = @"";
    if ([self isKindOfClass:[UIButton class]]) {
        title = [(UIButton *)self currentTitle] ?: @"";
    }
    
    NSDictionary *params = @{
        @"控件类型": controlType,
        @"动作": actionName,
        @"目标": targetName,
        @"标题": title
    };
    
    [[LogManager sharedManager] logUserAction:@"控件点击" params:params];
}

@end

#pragma mark - NSURLSessionTask Category

@implementation NSURLSessionTask (AutoLogging)

- (void)log_resume {
    [self log_resume];
    
    if (self.currentRequest) {
        // 使用新的API请求日志记录方法
        [[LogManager sharedManager] logAPIRequest:self.currentRequest];
    }
}

@end

#pragma mark - NSURLSession Category

@implementation NSURLSession (AutoLogging)

- (NSURLSessionDataTask *)log_dataTaskWithRequest:(NSURLRequest *)request 
                                completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    
    // 包装completion handler以记录响应
    void (^wrappedHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        [[LogManager sharedManager] logAPIResponse:response data:data error:error];
        
        if (completionHandler) {
            completionHandler(data, response, error);
        }
    };
    
    return [self log_dataTaskWithRequest:request completionHandler:wrappedHandler];
}

- (NSURLSessionDataTask *)log_dataTaskWithURL:(NSURL *)url 
                            completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    
    // 包装completion handler以记录响应
    void (^wrappedHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        [[LogManager sharedManager] logAPIResponse:response data:data error:error];
        
        if (completionHandler) {
            completionHandler(data, response, error);
        }
    };
    
    return [self log_dataTaskWithURL:url completionHandler:wrappedHandler];
}



@end
