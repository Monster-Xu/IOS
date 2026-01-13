//
//  UpgradeSwitchInfoAPI.m
//  AIToys
//
//  Created by xuxuxu on 2026/1/12.
//

#import "UpgradeSwitchInfo.h"
#import "NavigateToNativePageResponseModel.h"

@implementation UpgradeSwitchInfo

#pragma mark - ThingMiniAppExtApiProtocol Required Methods

- (NSString *)apiName {
    NSLog(@"[UpgradeSwitchInfoAPI] apiName 被调用，返回: UpgradeSwitchInfoAPI");
    return @"UpgradeSwitchInfoAPI";
}

#pragma mark - ThingMiniAppExtApiProtocol Optional Methods

- (BOOL)canIUseExtApi {
    NSLog(@"[UpgradeSwitchInfoAPI] canIUseExtApi 被调用，返回: YES");
    return YES;
}


- (void)invokeExtApi:(nonnull id<ThingMiniAppExtApiContext>)context
              params:(nullable NSDictionary *)params
             success:(nonnull ThingMiniExtApiResponseCallback)success
                fail:(nonnull ThingMiniExtApiResponseCallback)fail{
    NSString *deviceId = params[@"deviceId"];
    
    
    NSInteger status = 1; // 0：关闭, 1：开启。
        [[ThingSmartDevice deviceWithDeviceId:deviceId] saveUpgradeInfoWithSwitchValue:status success:^{
            success([NavigateToNativePageResponseModel successExtApiModelWithData:@{@"deviceId": deviceId,@"succuess":@"1"}]);
        } failure:^(NSError *error) {
            fail([NavigateToNativePageResponseModel failureExtApiModel:@"" errorMsg:@"" Data:@{@"success":@"0",@"error":error}]);
        }];
    
    
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

@end
