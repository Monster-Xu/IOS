//
//  APIPortConfiguration.m
//  AIToys
//
//  Created by qdkj on 2025/8/20.
//

#import "APIPortConfiguration.h"

@implementation APIPortConfiguration

/// 所有接口请求的基础域名
+ (NSString *)baseURL {
    ///当前环境 1、测试  2、生产
    NSInteger type = [[NSUserDefaults standardUserDefaults] integerForKey:KCURRENT_API_TYPE];
    if (type == 2) {
        return @"https://app.talenpalussaastest.com/";
    } else{
        return @"https://app.talenpalussaastest.com/";
    }
}

/// 登录接口
+ (NSString *)getLoginUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/member/auth/login"];
}

/// 首页
+ (NSString *)getHomeDoolListUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/instance/page"];
}

/// 首页探索
+ (NSString *)getHomeExploreListUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/model/list"];
}

/// 首页Banner
+ (NSString *)getHomeBannerListUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/banner/list"];
}

/// 启动图
+ (NSString *)getSplashScreenUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/splash-screen/list"];
}

/// 手动添加设备列表
+ (NSString *)getDoolModelListUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/model/list"];
}

/// 请求公仔信息
+ (NSString *)getDoolModelGetUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/model/get-by-hardware"];
}

/// 删除公仔
+ (NSString *)getDoolDeleteUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/instance/delete"];
}

/// 公仔排序
+ (NSString *)getDoolSortUrl {
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/doll/instance/sort"];
}

/// 创建app配置属性
+ (NSString *)getAppPropertyCreateUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-property/create"];
}

/// 获取app配置属性
+ (NSString *)getAppPropertyUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-property/page"];
}

/// 根据key获取app配置属性
+ (NSString *)getAppPropertyByKeyUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-property/get-by-key"];
}

/// 埋点上报接口
+ (NSString *)getEventLogCreateUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-event-log/create"];
}

/// 获取用户头像列表
+ (NSString *)getAppAvatarListUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-avatar/list"];
}

/// 上传用户头像
+ (NSString *)getAppAvatarUpdateUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-avatar/update"];
}

/// 获取用户头像
+ (NSString *)getAppAvatarUrl{
    return [[APIPortConfiguration baseURL] stringByAppendingString:@"app-api/content/app-avatar/get"];
}


@end
