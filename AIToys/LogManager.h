//
//  LogManager.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LogLevel) {
    LogLevelDebug = 0,
    LogLevelInfo,
    LogLevelWarning,
    LogLevelError
};

@interface LogManager : NSObject

// 启动全局自动记录（只需调用一次）
+ (void)startAutoLogging;

// 单例访问
+ (instancetype)sharedManager;

// 手动记录日志（可选）
- (void)logWithLevel:(LogLevel)level message:(NSString *)message;
- (void)logDebug:(NSString *)message;
- (void)logInfo:(NSString *)message;
- (void)logWarning:(NSString *)message;
- (void)logError:(NSString *)message;

// 记录用户操作（可选）
- (void)logUserAction:(NSString *)action params:(nullable NSDictionary *)params;

// 记录接口请求和响应
- (void)logAPIRequest:(NSURLRequest *)request;
- (void)logAPIResponse:(NSURLResponse *)response data:(nullable NSData *)data error:(nullable NSError *)error;

// 记录服务器错误
- (void)logServerError:(NSDictionary *)errorInfo fromAPI:(NSString *)apiPath;

// 记录SDK错误
- (void)logSDKError:(NSError *)error fromSDK:(NSString *)sdkName context:(nullable NSDictionary *)context;

// 导出日志
- (void)exportLogsWithCompletion:(void(^)(NSURL * _Nullable fileURL, NSError * _Nullable error))completion;

// 清空日志
- (void)clearLogs;

// 获取日志文件大小
- (NSString *)getLogFileSize;

// 自动清除7天前的日志
- (void)cleanupOldLogs;

@end

NS_ASSUME_NONNULL_END
