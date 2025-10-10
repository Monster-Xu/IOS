# AFNetworking 编译错误修复指南

## 🚨 问题描述

AFStoryAPIManager.m 中出现编译错误：
```
error: No visible @interface for 'AFHTTPSessionManager' declares the selector 'POST:parameters:progress:success:failure:'
```

## 🔍 问题原因

这个错误通常由以下原因引起：

1. **AFNetworking 版本不兼容**
   - AFNetworking 2.x 和 3.x/4.x 版本的方法签名不同
   - 项目中可能使用了错误的方法名

2. **头文件导入问题**
   - 没有正确导入 AFNetworking 头文件
   - CocoaPods 或 Framework 配置问题

3. **方法签名变化**
   - AFNetworking 较新版本使用了不同的方法参数

## 🛠️ 解决方案

### 方案1：检查 AFNetworking 版本

1. **检查 Podfile** (如果使用 CocoaPods)
```ruby
pod 'AFNetworking', '~> 4.0'  # 或其他版本
```

2. **检查导入方式**
```objc
#import <AFNetworking/AFNetworking.h>
// 或
#import "AFNetworking.h"
```

### 方案2：使用正确的方法签名

**AFNetworking 4.x 版本应该使用：**
```objc
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(nullable id)parameters
                       headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                      progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                       success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
```

**AFNetworking 3.x 版本应该使用：**
```objc
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(nullable id)parameters
                      progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                       success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
```

### 方案3：使用兼容版本

如果 AFNetworking 版本问题难以解决，可以使用我们提供的兼容版本：

1. **使用 AFStoryAPIManager_Compatible.m**
   - 这个文件使用原生 NSURLSession 实现
   - 保持相同的 API 接口
   - 避免 AFNetworking 版本兼容问题

2. **替换导入**
```objc
// 在需要使用的地方
#import "AFStoryAPIManager_Compatible.h"  // 而不是 AFStoryAPIManager.h
```

## 🔧 推荐修复步骤

### 步骤1：确定 AFNetworking 版本
```bash
# 如果使用 CocoaPods
pod list | grep AFNetworking

# 如果手动集成，检查 AFNetworking 的版本号
```

### 步骤2：根据版本修复方法调用

**如果是 AFNetworking 4.x：**
```objc
return [self.sessionManager POST:@"/stories" 
                      parameters:[request toDictionary] 
                         headers:nil 
                        progress:nil 
                         success:^(NSURLSessionDataTask *task, id responseObject) {
    // success handling
} failure:^(NSURLSessionDataTask *task, NSError *error) {
    // error handling
}];
```

**如果是 AFNetworking 3.x：**
```objc
return [self.sessionManager POST:@"/stories" 
                      parameters:[request toDictionary] 
                        progress:nil 
                         success:^(NSURLSessionDataTask *task, id responseObject) {
    // success handling
} failure:^(NSURLSessionDataTask *task, NSError *error) {
    // error handling
}];
```

### 步骤3：验证修复

1. 清理项目：`Product -> Clean Build Folder`
2. 重新编译
3. 检查是否还有编译错误

## 🎯 最终建议

由于 AFNetworking 版本兼容性问题比较复杂，我建议：

1. **短期解决方案**：使用 `AFStoryAPIManager_Compatible.m`
   - 立即解决编译问题
   - 保持功能完整性
   - 避免版本依赖问题

2. **长期解决方案**：统一项目的 AFNetworking 版本
   - 确定项目使用的 AFNetworking 版本
   - 更新所有相关代码使用正确的 API
   - 或者考虑迁移到原生 URLSession

## 📝 使用兼容版本的步骤

1. 将 `AFStoryAPIManager_Compatible.m` 添加到项目
2. 在 `CreationViewController.m` 中确保导入正确的头文件
3. 兼容版本提供了相同的接口，无需修改调用代码

这样可以确保项目能够正常编译和运行，同时保持所有网络功能的完整性。