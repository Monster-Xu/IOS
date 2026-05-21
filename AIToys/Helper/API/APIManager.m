//
//  APIManager.m
//  KunQiTong
//
//  Created by 乔不赖 on 2021/8/28.
//

#import "APIManager.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AppDelegate.h"
#import "CompressImageData.h"
#import "NSDictionary+KeySortJoin.h"
#import "SVProgressHUD.h"
#import "LogManager.h"
#import "ATLanguageHelper.h"

// 添加缺少的宏定义
#ifndef WEAK_SELF
#define WEAK_SELF __weak typeof(self) weakSelf = self;
#endif

#ifndef STRONG_SELF
#define STRONG_SELF __strong typeof(weakSelf) strongSelf = weakSelf;
#endif

#ifndef LocalString
#define LocalString(key) NSLocalizedString(key, nil)
#endif

// 添加可能缺失的常量定义
#ifndef KCURRENT_HOME_ID
#define KCURRENT_HOME_ID @"KCURRENT_HOME_ID"
#endif

static NSString * const successMsg = @"Operation successful";
static NSString * const failureMsg = @"Data anomaly";
static NSString * const netErrorMsg = @"Network abnormality";

// 常量定义
static NSTimeInterval const kDefaultTimeoutInterval = 30.0;
static NSTimeInterval const kUploadTimeoutInterval = 60.0;
static NSInteger const kMaxImageSizeInBytes = 8 * 1000 * 1000; // 8MB
static NSInteger const kCompressedImageSizeInBytes = 1024 * 1024; // 1MB

#define ApiVersion [UIApplication sharedApplication].appVersion

@interface APIManager ()

@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;
@property (nonatomic, strong) NSMutableSet<NSURLSessionDataTask *> *activeTasks;
@property (nonatomic, strong) dispatch_queue_t networkQueue;

@end

@implementation APIManager

+ (NSString *)localizedMessageForError:(NSError *)error {
    if (!error) {
        return LocalString(@"网络请求失败，请稍后重试");
    }
    return [self localizedMessageForString:error.localizedDescription];
}

+ (NSString *)localizedMessageForString:(NSString *)message {
    if (message.length == 0) {
        return LocalString(@"网络请求失败，请稍后重试");
    }
    NSString *trimmedMessage = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lowercaseMessage = trimmedMessage.lowercaseString;
    if ([lowercaseMessage containsString:@"request timed out"] ||
        [lowercaseMessage containsString:@"timed out"] ||
        [lowercaseMessage containsString:@"timeout"]) {
        return LocalString(@"加载超时，请重试");
    }
    if ([lowercaseMessage containsString:@"too frequent"] ||
        [lowercaseMessage containsString:@"too many requests"] ||
        [lowercaseMessage containsString:@"too often"]) {
        return LocalString(@"请稍后重试");
    }
    if ([lowercaseMessage containsString:@"server connection failed"] ||
        [lowercaseMessage containsString:@"cannot connect to host"] ||
        [lowercaseMessage containsString:@"cannot find host"]) {
        return LocalString(@"服务器繁忙，请稍后重试");
    }
    if ([lowercaseMessage containsString:@"network abnormality"] ||
        [lowercaseMessage containsString:@"network connection"] ||
        [lowercaseMessage containsString:@"internet appears to be offline"] ||
        [lowercaseMessage containsString:@"not connected to internet"]) {
        return LocalString(@"网络请求失败，请稍后重试");
    }
    return trimmedMessage;
}

#pragma mark -- 上传图片
- (void)uploadImg:(UIImage *)img
             isH5:(BOOL)isH5
             Succ:(void(^)(NSString *data))succ
             fail:(failBlock)fail {
    
    if (!img) {
        if (fail) fail(@"图片不能为空");
        return;
    }
    
    // 使用后台队列进行图片处理，避免阻塞主线程
    dispatch_async(self.networkQueue, ^{
        @autoreleasepool {
            NSString *url = isH5 ? [NSString stringWithFormat:@"%@Order/upload_imgss.html", [APIPortConfiguration baseURL]] : @"up_imgs.html";
            
            // 检查原始图片大小
            NSData *originalData = UIImageJPEGRepresentation(img, 1.0);
            NSLog(@"原始图片大小: %li KB", originalData.length / 1024);
            
            if (originalData.length > kMaxImageSizeInBytes) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (fail) fail(@"图片文件不能大于8MB");
                });
                return;
            }
            
            // 压缩图片
            UIImage *compressedImage = [CompressImageData compressImgQuality:img toByte:kCompressedImageSizeInBytes];
            if (!compressedImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (fail) fail(@"图片压缩失败");
                });
                return;
            }
            
            // 切换回主队列执行上传
            dispatch_async(dispatch_get_main_queue(), ^{
                [self uploadImages:url 
                        parameters:nil 
                        imageArray:@[compressedImage] 
                          fileName:@"pic" 
                          progress:nil
                           success:^(id result) {
                               [self handleUploadImageResult:result isH5:isH5 success:succ failure:fail];
                           } 
                           failure:^(NSError *error) {
                               if (fail) fail(@"上传失败，请检查网络后重试");
                           }];
            });
        }
    });
}

// 提取上传图片结果处理逻辑
- (void)handleUploadImageResult:(id)result 
                           isH5:(BOOL)isH5 
                        success:(void(^)(NSString *data))success
                        failure:(failBlock)failure {
    if (!result) {
        if (failure) failure(@"上传结果为空");
        return;
    }
    
    if (isH5) {
        if ([result[@"code"] isEqualToString:@"200"]) {
            if ([result[@"data"] isKindOfClass:[NSArray class]]) {
                NSArray *arr = result[@"data"];
                if (arr.count > 0 && success) {
                    success([NSString stringWithFormat:@"%@", arr[0]]);
                }
            }
        } else {
            if (failure) {
                NSString *msg = result[@"msg"] ?: @"上传失败";
                failure(msg);
            }
        }
    } else {
        if (success && result[@"data"]) {
            success(result[@"data"]);
        }
    }
}

#pragma mark -- 单例方法
+ (instancetype)shared {
    static APIManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[APIManager alloc] init];
        manager.netStatus = NetStatus_Unknown;
        manager.activeTasks = [NSMutableSet set];
        manager.networkQueue = dispatch_queue_create("com.kunqitong.network", DISPATCH_QUEUE_CONCURRENT);
        [manager startNetStatusNotify];
        
        // 显示状态栏网络活动指示器
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    });
    return manager;
}

#pragma mark -- 网络状态监听
- (void)startNetStatusNotify {
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    __weak typeof(self) weakSelf = self;
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        // 避免频繁的状态更新
        if ((NSInteger)status == strongSelf.netStatus) return;
        
        NSInteger oldStatus = strongSelf.netStatus;
        strongSelf.netStatus = (NSInteger)status;
        
        // 根据网络状态发送相应的通知
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkReachableWifi" object:nil];
                    break;
                case AFNetworkReachabilityStatusUnknown:
                case AFNetworkReachabilityStatusNotReachable:
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotReachable" object:nil];
                    // 取消所有正在进行的请求
                    [strongSelf cancelAllTasks];
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    // 蜂窝网络连接，可以添加相应处理
                    break;
                default:
                    break;
            }
            
            // 发送网络状态变化通知
            NSDictionary *userInfo = @{
                @"newStatus": @((NSInteger)status),
                @"oldStatus": @(oldStatus)
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkStatusChanged" 
                                                                object:strongSelf 
                                                              userInfo:userInfo];
        });
    }];
    
    [self.reachabilityManager startMonitoring];
}

#pragma mark -- 请求管理
- (void)cancelAllTasks {
    @synchronized (self.activeTasks) {
        for (NSURLSessionDataTask *task in self.activeTasks) {
            if (task.state == NSURLSessionTaskStateRunning) {
                [task cancel];
            }
        }
        [self.activeTasks removeAllObjects];
    }
}

- (void)addTask:(NSURLSessionDataTask *)task {
    if (!task) return;
    @synchronized (self.activeTasks) {
        [self.activeTasks addObject:task];
    }
}

- (void)removeTask:(NSURLSessionDataTask *)task {
    if (!task) return;
    @synchronized (self.activeTasks) {
        [self.activeTasks removeObject:task];
    }
}

#pragma mark -- 统一请求处理方法
- (void)performRequest:(NSString *)urlStr
                method:(NSString *)method
           contentType:(NSString *)contentType
            parameters:(NSDictionary *_Nullable)parameters
               success:(void(^)(id result, id data, NSString *msg))success
               failure:(void(^)(NSError *error, NSString *msg))failure {
    
    // 检查网络状态
    if (self.netStatus == NetStatus_NoNet) {
        if (failure) {
            failure(nil, netErrorMsg);
        }
        [SVProgressHUD showErrorWithStatus:netErrorMsg];
        return;
    }
    
    NSURLSessionDataTask *task = [self myRequestWithUrlStr:urlStr
                                                    method:method
                                               contentType:contentType
                                                parameters:parameters
                                         completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        // 请求完成后从活跃任务列表中移除
        NSURLSessionDataTask *currentTask = (NSURLSessionDataTask *)[(NSHTTPURLResponse *)response URL];
        [self removeTask:currentTask];
        
        NSLog(@"\n网络请求: %@\n参数: %@\n结果: %@", urlStr, parameters, responseObject);
        
       
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errorMsg = [self errorMessageFromError:error];
                if (failure) failure(error, errorMsg);
                [SVProgressHUD showErrorWithStatus:errorMsg];
                [[LogManager sharedManager]logAPIResponse:response data:nil error:error];
            });
            return;
        }
        if (parameters&&responseObject) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            [[LogManager sharedManager]logAPIResponse:response data:jsonData error:error];
        };
        // 统一响应处理
        [self handleResponse:responseObject
                      urlStr:urlStr
                     success:success
                     failure:failure];
    }];
    
    // 添加到活跃任务列表
    [self addTask:task];
}

// 统一响应处理
- (void)handleResponse:(id)responseObject
                urlStr:(NSString *)urlStr
               success:(void(^)(id result, id data, NSString *msg))success
               failure:(void(^)(NSError *error, NSString *msg))failure {
    
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) failure(nil, @"返回数据格式错误");
        });
        return;
    }
    
    [APIManager verifyResult:responseObject
                        succ:^(id data, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 处理登录相关逻辑
            if ([urlStr isEqualToString:[APIPortConfiguration getLoginUrl]]) {
                [self saveSelfData:data];
            }
            
            if (success) success(responseObject, data, msg);
        });
    } fail:^(int code, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) failure(nil, msg);
            [SVProgressHUD showErrorWithStatus:msg];
        });
    }];
}

// 统一错误消息处理
- (NSString *)errorMessageFromError:(NSError *)error {
    switch (error.code) {
        case NSURLErrorTimedOut:
            return LocalString(@"加载超时，请重试");
        case NSURLErrorNotConnectedToInternet:
        case NSURLErrorNetworkConnectionLost:
            return LocalString(@"网络请求失败，请稍后重试");
        case NSURLErrorCannotFindHost:
        case NSURLErrorCannotConnectToHost:
            return LocalString(@"服务器繁忙，请稍后重试");
        default:
            return [APIManager localizedMessageForError:error];
    }
}

#pragma mark -- GET请求
- (void)GET:(NSString *)urlStr
  parameter:(NSDictionary *_Nullable)parameter
    success:(void(^)(id result, id data, NSString *msg))success
    failure:(void(^)(NSError *error, NSString *msg))failure {
    
    [self performRequest:urlStr
                  method:@"GET"
             contentType:@"application/x-www-form-urlencoded"
              parameters:parameter
                 success:success
                 failure:failure];
}

- (void)GETTxt:(NSString *)urlStr
     parameter:(NSDictionary *)parameter
       success:(void(^)(id result, id data, NSString *msg))success
       failure:(void(^)(NSError *error, NSString *msg))failure {
    
    AFHTTPSessionManager *manager = [self AFHTTPSessionManager];
    
    // 对url中的中文字符进行转码
    NSString *str = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // GET请求
    NSURLSessionDataTask *task = [manager GET:str 
                                   parameters:parameter 
                                      headers:@{} 
                                     progress:^(NSProgress *downloadProgress) {
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self removeTask:task];
        NSLog(@"网络请求成功 - URL: %@, 参数: %@, 结果: %@", urlStr, parameter, responseObject);
        
        // 特殊处理某些URL
        if ([urlStr isEqualToString:@"http://114.116.108.180/kqt_app_self_belay.txt"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) success(responseObject, nil, nil);
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) success(responseObject, responseObject, @"获取成功");
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self removeTask:task];
        NSLog(@"网络请求失败 - URL: %@, Error: %@", urlStr, error.localizedDescription);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *errorMsg = [self errorMessageFromError:error];
            if (failure) failure(error, errorMsg);
            [SVProgressHUD showErrorWithStatus:errorMsg];
        });
    }];
    
    [self addTask:task];
}

#pragma mark -- POST请求
- (void)POST:(NSString *)urlStr
   parameter:(NSDictionary *_Nullable)parameter
     success:(void(^)(id result, id data, NSString *msg))success
     failure:(void(^)(NSError *error, NSString *msg))failure {
    
    [self performRequest:urlStr
                  method:@"POST"
             contentType:@"application/x-www-form-urlencoded"
              parameters:parameter
                 success:success
                 failure:failure];
}

- (void)POSTJSON:(NSString *)urlStr
       parameter:(NSDictionary *_Nullable)parameter
         success:(void(^)(id result, id data, NSString *msg))success
         failure:(void(^)(NSError *error, NSString *msg))failure {
    
    [self performRequest:urlStr
                  method:@"POST"
             contentType:@"application/json"
              parameters:parameter
                 success:success
                 failure:failure];
}

#pragma mark -- PUT请求
- (void)PUT:(NSString *)urlStr
  parameter:(NSDictionary *_Nullable)parameter
    success:(void(^)(id result, id data, NSString *msg))success
    failure:(void(^)(NSError *error, NSString *msg))failure {
    
    [self performRequest:urlStr
                  method:@"PUT"
             contentType:@"application/x-www-form-urlencoded"
              parameters:parameter
                 success:success
                 failure:failure];
}

- (void)PUTJSON:(NSString *)urlStr
      parameter:(NSDictionary *_Nullable)parameter
        success:(void(^)(id result, id data, NSString *msg))success
        failure:(void(^)(NSError *error, NSString *msg))failure {
    
    [self performRequest:urlStr
                  method:@"PUT"
             contentType:@"application/json"
              parameters:parameter
                 success:success
                 failure:failure];
}

#pragma mark -- DELETE请求
- (void)DELETE:(NSString *)urlStr
     parameter:(NSDictionary *_Nullable)parameter
       success:(void(^)(id result, id data, NSString *msg))success
       failure:(void(^)(NSError *error, NSString *msg))failure {
    
    [self performRequest:urlStr
                  method:@"DELETE"
             contentType:@"application/x-www-form-urlencoded"
              parameters:parameter
                 success:success
                 failure:failure];
}

#pragma mark -- private methods

// AFN的相关设置
- (AFHTTPSessionManager *)AFHTTPSessionManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 添加 Header
    if (kMyUser.accessToken) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", kMyUser.accessToken] 
                         forHTTPHeaderField:@"Authorization"];
    }
    
    // 申明返回结果的类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                        @"text/html", 
                                                        @"application/json", 
                                                        @"text/plain", 
                                                        @"text/json",
                                                        @"text/javascript",
                                                        @"multipart/form-data", nil];
    
    // 设置超时时间
    manager.requestSerializer.timeoutInterval = kDefaultTimeoutInterval;
    
    // 证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    [manager setSecurityPolicy:securityPolicy];
    
    return manager;
}

- (NSURLSessionDataTask *)myRequestWithUrlStr:(NSString *)urlStr
                                       method:(NSString *)methodStr
                                  contentType:(NSString *)contentType
                                   parameters:(NSDictionary *_Nullable)parameters
                            completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    
    // 参数校验
    if (!urlStr || urlStr.length == 0) {
        if (completionHandler) {
            NSError *error = [NSError errorWithDomain:@"APIManagerErrorDomain" 
                                               code:-1 
                                           userInfo:@{NSLocalizedDescriptionKey: @"URL不能为空"}];
            completionHandler(nil, nil, error);
        }
        return nil;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = kDefaultTimeoutInterval;
    configuration.timeoutIntervalForResource = kDefaultTimeoutInterval * 2;
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSMutableURLRequest *request;
    
    @try {
        if ([contentType isEqualToString:@"application/json"]) {
            AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
            response.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", nil];
            manager.responseSerializer = response;
            request = [[AFJSONRequestSerializer serializer] requestWithMethod:methodStr 
                                                                     URLString:urlStr 
                                                                    parameters:parameters 
                                                                         error:nil];
        } else {
            AFHTTPResponseSerializer *response = [AFHTTPResponseSerializer serializer];
            response.acceptableContentTypes = [NSSet setWithObjects:
                                              @"text/html", @"application/json", @"text/plain", 
                                              @"text/json", @"text/javascript", nil];
            manager.responseSerializer = response;
            request = [[AFHTTPRequestSerializer serializer] requestWithMethod:methodStr 
                                                                     URLString:urlStr 
                                                                    parameters:parameters 
                                                                         error:nil];
        }
    } @catch (NSException *exception) {
        NSLog(@"创建请求失败: %@", exception);
        if (completionHandler) {
            NSError *error = [NSError errorWithDomain:@"APIManagerErrorDomain" 
                                               code:-2 
                                           userInfo:@{NSLocalizedDescriptionKey: @"创建请求失败"}];
            completionHandler(nil, nil, error);
        }
        return nil;
    }
    
    // 设置请求头
    [self configureRequest:request withContentType:contentType];
    
    // 添加签名
    [self addSignatureToRequest:request withParameters:parameters];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request
                                                   uploadProgress:nil 
                                                 downloadProgress:nil  
                                                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        // 错误处理
        if (error) {
            NSLog(@"网络请求失败 - URL: %@, Error: %@", urlStr, error.localizedDescription);
        }
        
        // JSON解析处理
        if (responseObject && [responseObject isKindOfClass:[NSData class]]) {
            NSError *jsonError;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject 
                                                           options:NSJSONReadingMutableContainers 
                                                             error:&jsonError];
            if (!jsonError) {
                responseObject = jsonObject;
            }
        }
        
        if (completionHandler) {
            completionHandler(response, responseObject, error);
        }
    }];
    
    [dataTask resume];
    return dataTask;
}

// 配置请求头
- (void)configureRequest:(NSMutableURLRequest *)request withContentType:(NSString *)contentType {
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // 设置语言
    NSString *languageCode = [ATLanguageHelper miniAppLangType];
    [request setValue:languageCode forHTTPHeaderField:@"Accept-Language"];
    
    // 设置认证头
    if (kMyUser.accessToken.length > 0) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@", kMyUser.accessToken] 
       forHTTPHeaderField:@"Authorization"];
    }
}

// 添加签名
- (void)addSignatureToRequest:(NSMutableURLRequest *)request withParameters:(NSDictionary *)parameters {
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionary];
    [headerDic setValue:@"talenpal" forKey:@"appId"];
    
    // 生成时间戳
    NSString *timestamp = [self getCurrentTimestamp];
    [headerDic setValue:timestamp forKey:@"timestamp"];
    
    // 生成随机字符串
    NSString *nonce = [self randomStringWithLength:10];
    [headerDic setValue:nonce forKey:@"nonce"];
    
    // 设置头部参数
    [request setValue:headerDic[@"appId"] forHTTPHeaderField:@"appId"];
    [request setValue:headerDic[@"timestamp"] forHTTPHeaderField:@"timestamp"];
    [request setValue:headerDic[@"nonce"] forHTTPHeaderField:@"nonce"];
    
    // 生成签名
    NSString *parmStr = [parameters sortedKeysJoinedByAmpersand] ?: @"";
    NSString *bodyStr = @"";
    
    NSData *bodyData = request.HTTPBody;
    if (bodyData && bodyData.length > 0) {
        bodyStr = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding] ?: @"";
    }
    
    NSString *headerStr = [headerDic sortedKeysJoinedByAmpersand];
    NSString *appSecret = @"IwJJp&JVBDJDNdPq8D";
    NSString *finalStr = [NSString stringWithFormat:@"%@%@%@%@", parmStr, bodyStr, headerStr, appSecret];
    NSString *signStr = [finalStr sha256String];
    
    [request setValue:signStr forHTTPHeaderField:@"sign"];
}

// 获取当前时间戳
- (NSString *)getCurrentTimestamp {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f", timeInterval];
}

// 生成随机字符串
- (NSString *)randomStringWithLength:(NSInteger)length {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (NSInteger i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random_uniform((u_int32_t)[letters length])]];
    }
    
    return randomString;
}


//上传视频 - 优化版本
- (void)uploadVideo:(NSString *)urlStr
          parameters:(NSDictionary *)parameter
               video:(NSData *)videoData
            fileName:(NSString *)name
            progress:(void (^)(NSProgress *uploadProgress))progress
             success:(void (^)(id result))success
             failure:(void (^)(NSError *error))failure {
    
    // 参数验证
    if (!urlStr || !videoData || !name) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"APIManagerErrorDomain" 
                                               code:-1 
                                           userInfo:@{NSLocalizedDescriptionKey: @"上传参数不能为空"}];
            failure(error);
        }
        return;
    }
    
    AFHTTPSessionManager *manager = [self AFHTTPSessionManager];
    manager.requestSerializer.timeoutInterval = kUploadTimeoutInterval;
    
    NSURLSessionDataTask *uploadTask = [manager POST:urlStr 
                                           parameters:parameter 
                                              headers:@{} 
                                constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        // 生成唯一的视频文件名
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString *dateStr = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.mp4", dateStr];
        
        [formData appendPartWithFileData:videoData 
                                    name:name 
                                fileName:fileName 
                                mimeType:@"video/mp4"];
        
    } progress:^(NSProgress *uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) progress(uploadProgress);
        });
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self removeTask:task];
        NSLog(@"视频上传成功 - URL: %@, 参数: %@, 结果: %@", urlStr, parameter, responseObject);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) success(responseObject);
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self removeTask:task];
        NSLog(@"视频上传失败 - URL: %@, Error: %@", urlStr, error.localizedDescription);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) failure(error);
        });
    }];
    
    [self addTask:uploadTask];
}

//上传图片 - 优化版本
- (void)uploadImages:(NSString *)urlStr
          parameters:(NSDictionary *)parameter
          imageArray:(NSArray *)imageArray
            fileName:(NSString *)name
            progress:(void (^)(NSProgress *uploadProgress))progress
             success:(void (^)(id result))success
             failure:(void (^)(NSError *error))failure {
    
    // 参数验证
    if (!urlStr || !imageArray || imageArray.count == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"APIManagerErrorDomain" 
                                               code:-1 
                                           userInfo:@{NSLocalizedDescriptionKey: @"参数错误"}];
            failure(error);
        }
        return;
    }
    
    AFHTTPSessionManager *manager = [self AFHTTPSessionManager];
    manager.requestSerializer.timeoutInterval = kUploadTimeoutInterval;
    
    NSURLSessionDataTask *uploadTask = [manager POST:urlStr 
                                           parameters:parameter 
                                              headers:@{} 
                                constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        // 使用后台队列处理图片，避免阻塞主线程
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        for (NSInteger i = 0; i < imageArray.count; i++) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            @autoreleasepool {
                UIImage *image = imageArray[i];
                if (![image isKindOfClass:[UIImage class]]) {
                    dispatch_semaphore_signal(semaphore);
                    continue;
                }
                
                // 修复图片方向
                UIImage *normalizedImage = [self normalizeImageOrientation:image];
                
                // 转换为JPEG数据
                NSData *imageData = UIImageJPEGRepresentation(normalizedImage, 0.9);
                if (!imageData) {
                    dispatch_semaphore_signal(semaphore);
                    continue;
                }
                
                // 生成文件名
                NSString *fileName = [self generateImageFileName];
                NSString *fieldName = imageArray.count == 1 ? name : [NSString stringWithFormat:@"%@%ld", name, (long)i];
                
                [formData appendPartWithFileData:imageData 
                                            name:fieldName 
                                        fileName:fileName 
                                        mimeType:@"image/jpeg"];
                
                dispatch_semaphore_signal(semaphore);
            }
        }
        
    } progress:^(NSProgress *uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) progress(uploadProgress);
        });
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [self removeTask:task];
        NSLog(@"图片上传成功 - URL: %@, 参数: %@, 结果: %@", urlStr, parameter, responseObject);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) success(responseObject);
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self removeTask:task];
        NSLog(@"图片上传失败 - URL: %@, Error: %@", urlStr, error.localizedDescription);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) failure(error);
        });
    }];
    
    [self addTask:uploadTask];
}

// 修复图片方向
- (UIImage *)normalizeImageOrientation:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) {
        return image;
    }
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return normalizedImage ?: image;
}

// 生成图片文件名
- (NSString *)generateImageFileName {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@.jpg", dateStr];
}


+ (void)verifyResult:(id)result
                succ:(void(^)(id data, NSString *msg))success
                fail:(void(^)(int code, NSString *msg))failure
{
    /**
    * 网络请求状态码
    *
    * ' 500' => '客户不存在,请刷新页面后再试',
    * '401' => '签名失败，Token失效',
    */
    int code = [result[@"code"] intValue];
    NSString *msg = result[@"msg"];
    if (code == 0) {
        if (success) {
            if ([msg isKindOfClass:NSString.class]){
                if (msg.length == 0) {
                    msg = successMsg;
                }
            }
            success(result[@"data"], successMsg);
        }
    }else {
        if (failure) {
            if ([msg isKindOfClass:NSString.class]) {
                if (msg.length == 0) {
                    msg = failureMsg;
                }
            }
            if (code == 401) {
                msg = LocalString(@"登录信息已过期,请重新登录");
                [UserInfo clearMyUser];
                [CoreArchive removeStrForKey:KCURRENT_HOME_ID];
                [UserInfo showLogin];
                
            }else if (code == 701){
                
            }
            failure(code, msg);
        }
    }
}

//更新并保存用户资料
- (void)saveSelfData:(NSDictionary *)dic {
    UserInfo *model = [UserInfo mj_objectWithKeyValues:dic];
    if (model.accessToken) {
        kMyUser.accessToken = model.accessToken;
    }
    if (model.userId) {
        kMyUser.userId = model.userId;
    }
    if (model.refreshToken) {
        kMyUser.refreshToken = model.refreshToken;
    }
    [UserInfo saveMyUser];
}


#pragma mark -- 获取当前VC
- (UIViewController *)getCurrentViewController
{
    
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    UIViewController* currentViewController = window.rootViewController;
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            
            currentViewController = currentViewController.presentedViewController;
        } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController* navigationController = (UINavigationController* )currentViewController;
            currentViewController = [navigationController.childViewControllers lastObject];
            
        } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController* tabBarController = (UITabBarController* )currentViewController;
            currentViewController = tabBarController.selectedViewController;
        } else {
            
            NSUInteger childViewControllerCount = currentViewController.childViewControllers.count;
            if (childViewControllerCount > 0) {
                
                currentViewController = currentViewController.childViewControllers.lastObject;
                
                return currentViewController;
            } else {
                
                return currentViewController;
            }
        }
        
    }
    return currentViewController;
}


// 在 APIManager.m 文件中添加以下实现

#pragma mark -- 简单文件上传方法实现

// 简单文件上传方法（最简版本）
- (void)uploadSingleFile:(NSString *)urlStr
                fileData:(NSData *)fileData
                fileName:(NSString *)fileName
                 success:(void (^)(id result))success
                 failure:(void (^)(NSError *error))failure {
    
    [self uploadSingleFile:urlStr
                  fileData:fileData
                  fileName:fileName
                  mimeType:nil
                   success:success
                   failure:failure];
}

// 简单文件上传方法（带MIME类型）
- (void)uploadSingleFile:(NSString *)urlStr
                fileData:(NSData *)fileData
                fileName:(NSString *)fileName
                mimeType:(NSString *)mimeType
                 success:(void (^)(id result))success
                 failure:(void (^)(NSError *error))failure {
    
    [self uploadSingleFile:urlStr
                  fileData:fileData
                  fileName:fileName
                parameters:nil
                  mimeType:mimeType
                   success:success
                   failure:failure];
}

// 简单文件上传方法（带参数）
- (void)uploadSingleFile:(NSString *)urlStr
                fileData:(NSData *)fileData
                fileName:(NSString *)fileName
              parameters:(NSDictionary *)parameters
                 success:(void (^)(id result))success
                 failure:(void (^)(NSError *error))failure {
    
    [self uploadSingleFile:urlStr
                  fileData:fileData
                  fileName:fileName
                parameters:parameters
                  mimeType:nil
                   success:success
                   failure:failure];
}

// 核心实现方法（私有）
- (void)uploadSingleFile:(NSString *)urlStr
                fileData:(NSData *)fileData
                fileName:(NSString *)fileName
              parameters:(NSDictionary *)parameters
                mimeType:(NSString *)mimeType
                 success:(void (^)(id result))success
                 failure:(void (^)(NSError *error))failure {
    
    // 参数验证
    if (!urlStr || urlStr.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"APIManagerErrorDomain"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: @"URL不能为空"}];
            failure(error);
        }
        return;
    }
    
    if (!fileData || fileData.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"APIManagerErrorDomain"
                                                 code:-2
                                             userInfo:@{NSLocalizedDescriptionKey: @"文件数据不能为空"}];
            failure(error);
        }
        return;
    }
    
    if (!fileName || fileName.length == 0) {
        fileName = @"file";
    }
    
    // 如果没有指定MIME类型，根据文件扩展名自动推断
    NSString *actualMimeType = mimeType;
    if (!actualMimeType) {
        actualMimeType = [APIManager mimeTypeForFileExtension:[fileName pathExtension]];
    }
    if (!actualMimeType) {
        actualMimeType = @"application/octet-stream";
    }
    
    // 检查网络状态
    if (self.netStatus == NetStatus_NoNet) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"APIManagerErrorDomain"
                                                 code:-3
                                             userInfo:@{NSLocalizedDescriptionKey: netErrorMsg}];
            failure(error);
        }
        [SVProgressHUD showErrorWithStatus:netErrorMsg];
        return;
    }
    
    // 检查文件大小（默认限制20MB）
    static NSInteger const kSimpleMaxFileSize = 20 * 1024 * 1024;
    if (fileData.length > kSimpleMaxFileSize) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"APIManagerErrorDomain"
                                                 code:-4
                                             userInfo:@{NSLocalizedDescriptionKey: @"文件大小不能超过20MB"}];
            failure(error);
        }
        return;
    }
    
    // 创建请求管理器
    AFHTTPSessionManager *manager = [self AFHTTPSessionManager];
    manager.requestSerializer.timeoutInterval = 30.0;
    
    // URL编码
    NSString *encodedURL = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // 显示上传提示
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:LocalString(@"上传中")];
    });
    
    // 创建上传任务
    NSURLSessionDataTask *uploadTask = [manager POST:encodedURL
                                          parameters:parameters
                                             headers:@{}
                           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        // 生成唯一的文件名，避免重复
        NSString *uniqueFileName = [self generateSimpleFileName:fileName];
        
        // 添加文件部分
        [formData appendPartWithFileData:fileData
                                    name:@"file"
                                fileName:uniqueFileName
                                mimeType:actualMimeType];
        
        // 添加额外的文件信息
        [formData appendPartWithFormData:[fileName dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"original_filename"];
        
        NSString *fileSizeStr = [NSString stringWithFormat:@"%lu", (unsigned long)fileData.length];
        [formData appendPartWithFormData:[fileSizeStr dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"file_size"];
        
    } progress:nil // 简单版本不提供进度回调
      success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [self removeTask:task];
        
        // 记录日志
        NSLog(@"📤 文件上传成功: %@ (%lu bytes)", fileName, (unsigned long)fileData.length);
        
        // 主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:nil];
            
            if (success) {
                success(responseObject);
            }
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [self removeTask:task];
        
        // 记录错误日志
        NSLog(@"❌ 文件上传失败: %@, 错误: %@", fileName, error.localizedDescription);
        
        // 生成友好的错误信息
        NSString *errorMessage = [self simpleErrorMessageForError:error];
        
        // 主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:errorMessage];
            
            if (failure) {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: errorMessage,
                    NSUnderlyingErrorKey: error
                };
                NSError *detailedError = [NSError errorWithDomain:@"APIManagerErrorDomain"
                                                             code:error.code
                                                         userInfo:userInfo];
                failure(detailedError);
            }
        });
    }];
    
    // 添加到任务管理
    [self addTask:uploadTask];
}

#pragma mark -- 简单方法辅助函数

// 生成简单文件名
- (NSString *)generateSimpleFileName:(NSString *)originalName {
    if (!originalName || originalName.length == 0) {
        originalName = @"file";
    }
    
    // 获取文件扩展名
    NSString *extension = [originalName pathExtension];
    NSString *nameWithoutExt = [originalName stringByDeletingPathExtension];
    
    // 生成时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    
    // 组合文件名
    if (extension.length > 0) {
        return [NSString stringWithFormat:@"%@_%@.%@", nameWithoutExt, timestamp, extension];
    } else {
        return [NSString stringWithFormat:@"%@_%@", nameWithoutExt, timestamp];
    }
}

// 简单错误信息
- (NSString *)simpleErrorMessageForError:(NSError *)error {
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        switch (error.code) {
            case NSURLErrorTimedOut:
                return @"上传超时";
            case NSURLErrorNotConnectedToInternet:
                return @"网络连接失败";
            case NSURLErrorCannotConnectToHost:
                return @"无法连接服务器";
            case NSURLErrorCancelled:
                return @"上传已取消";
            default:
                break;
        }
    }
    
    // 根据状态码判断
    if ([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
        if (response.statusCode == 413) {
            return @"文件太大，服务器拒绝接收";
        } else if (response.statusCode == 415) {
            return @"不支持的文件类型";
        } else if (response.statusCode >= 500) {
            return @"服务器错误，请稍后重试";
        }
    }
    
    return @"上传失败，请重试";
}

// 根据文件扩展名获取MIME类型（类方法）
+ (NSString *)mimeTypeForFileExtension:(NSString *)extension {
    if (!extension) return nil;
    
    NSString *lowerExt = [extension lowercaseString];
    NSDictionary *mimeMap = @{
        // 图片
        @"jpg": @"image/jpeg",
        @"jpeg": @"image/jpeg",
        @"png": @"image/png",
        @"gif": @"image/gif",
        
        // 文档
        @"pdf": @"application/pdf",
        @"doc": @"application/msword",
        @"docx": @"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        @"xls": @"application/vnd.ms-excel",
        @"xlsx": @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        @"txt": @"text/plain",
        
        // 音频
        @"mp3": @"audio/mpeg",
        
        // 视频
        @"mp4": @"video/mp4",
        @"mov": @"video/quicktime",
        
        // 压缩
        @"zip": @"application/zip",
        @"rar": @"application/x-rar-compressed"
    };
    
    return mimeMap[lowerExt] ?: @"application/octet-stream";
}


@end

// 如果NSString+SHA256分类不存在，添加SHA256支持
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SHA256)

- (NSString *)sha256String {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}





@end
