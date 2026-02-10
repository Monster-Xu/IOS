//
//  StarteBLEListening.m
//  AIToys
//
//  Created by xuxuxu on 2026/1/24.
//

#import "StarteBLEListening.h"
#import "NavigateToNativePageResponseModel.h"

@implementation StarteBLEListening


#pragma mark - ThingMiniAppExtApiProtocol Required Methods

- (NSString *)apiName {
    NSLog(@"[StarteBLEListeningAPI] apiName 被调用，返回: StarteBLEListeningAPI");
    return @"StarteBLEListeningAPI";
}

#pragma mark - ThingMiniAppExtApiProtocol Optional Methods

- (BOOL)canIUseExtApi {
    NSLog(@"[StarteBLEListeningAPI] canIUseExtApi 被调用，返回: YES");
    return YES;
}


- (void)invokeExtApi:(nonnull id<ThingMiniAppExtApiContext>)context
              params:(nullable NSDictionary *)params
             success:(nonnull ThingMiniExtApiResponseCallback)success
                fail:(nonnull ThingMiniExtApiResponseCallback)fail{
    // 设置代理
//    [ThingSmartBLEManager sharedInstance].delegate = self;

    // 开始扫描
    [[ThingSmartBLEManager sharedInstance] startListening:YES];
    
    
}

- (id<ThingMiniAppExtApiModelProtocol>)invokeExtApiSync:(nonnull id<ThingMiniAppExtApiContext>)context
                                                 params:(nullable NSDictionary *)params{
    // 同步方法不适用于页面跳转，返回错误
    return [NavigateToNativePageResponseModel failureExtApiModel:@""
                                                        errorMsg:@"页面跳转不支持同步调用"];
}




/// 小程序生命周期：小程序活跃状态，小程序启动时触发
- (void)onMiniAppResume{
    
}

/// 小程序生命周期：小程序暂停状态，如退到后台、小程序被其他小程序覆盖时触发
- (void)onMiniAppPause{
    
}

/// 小程序生命周期：小程序销毁状态，小程序关闭时触发
- (void)onMiniAppDestroy{
    
}
- (void)didDiscoveryDeviceWithDeviceInfo:(ThingBLEAdvModel *)deviceInfo {
    // 成功扫描到未激活的设备
    // 若设备已激活，则不会走此回调，且会自动进行激活连接
}
@end
