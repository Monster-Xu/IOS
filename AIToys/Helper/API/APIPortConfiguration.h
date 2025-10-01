//
//  APIPortConfiguration.h
//  AIToys
//
//  Created by qdkj on 2025/8/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIPortConfiguration : NSObject

/// 所有接口请求的基础域名
+ (NSString *)baseURL;
/// 登录接口
+ (NSString *)getLoginUrl;

/// 首页
+ (NSString *)getHomeDoolListUrl;

/// 首页探索
+ (NSString *)getHomeExploreListUrl;

/// 首页Banner
+ (NSString *)getHomeBannerListUrl;
/// 启动图
+ (NSString *)getSplashScreenUrl;

/// 手动添加设备列表
+ (NSString *)getDoolModelListUrl;

/// 请求公仔信息
+ (NSString *)getDoolModelGetUrl;

/// 删除公仔
+ (NSString *)getDoolDeleteUrl;

/// 公仔排序
+ (NSString *)getDoolSortUrl;

/// 创建app配置属性
+ (NSString *)getAppPropertyCreateUrl;

/// 获取app配置属性
+ (NSString *)getAppPropertyUrl;

/// 根据key获取app配置属性
+ (NSString *)getAppPropertyByKeyUrl;

/// 埋点上报接口
+ (NSString *)getEventLogCreateUrl;

/// 获取用户头像列表
+ (NSString *)getAppAvatarListUrl;

/// 上传用户头像
+ (NSString *)getAppAvatarUpdateUrl;

/// 获取用户头像
+ (NSString *)getAppAvatarUrl;

@end

NS_ASSUME_NONNULL_END
