//
//  AnalyticsConstants.m
//  AIToys
//
//  Created by AI Assistant on 2025/8/21.
//

#import "AnalyticsConstants.h"

#pragma mark - 层级常量实现

NSString * const kAnalyticsLevel1_Home = @"首页";
NSString * const kAnalyticsLevel1_Login = @"登录";
NSString * const kAnalyticsLevel1_Family = @"家庭";
NSString * const kAnalyticsLevel1_Creation = @"创作";
NSString * const kAnalyticsLevel1_Mine = @"我的";

NSString * const kAnalyticsLevel2_AddDevice = @"添加设备";
NSString * const kAnalyticsLevel2_DevicePanel = @"";
NSString * const kAnalyticsLevel2_AddMember = @"添加成员";
NSString * const kAnalyticsLevel2_RemoveMember = @"移除成员";

#pragma mark - 事件名称常量实现

// 首页相关事件
NSString * const kAnalyticsEvent_ClickBanner = @"点击banner页";
NSString * const kAnalyticsEvent_AddDevice_Click = @"添加设备_点击";
NSString * const kAnalyticsEvent_AddDevice_ManualClick = @"添加设备_手动点击";

NSString * const kAnalyticsEvent_AddDevice_Success = @"添加设备_添加成功";
NSString * const kAnalyticsEvent_AddDevice_Failed = @"添加设备_添加失败";
NSString * const kAnalyticsEvent_MyDevice_Click = @"homepage_tap_device_card";
NSString * const kAnalyticsEvent_MyDoll_Click = @"我的公仔_点击";
NSString * const kAnalyticsEvent_DiscoverCreativeDoll = @"doll_activated";
NSString * const kAnalyticsEvent_Explore_ClickDoll = @"探索_点击公仔";

// 账户相关事件
NSString * const kAnalyticsEvent_Account_LoginSuccess = @"login_result";

// 家庭相关事件
NSString * const kAnalyticsEvent_Family_AddMember = @"send_add_home_member_request";
NSString * const kAnalyticsEvent_Family_RemoveMember = @"家庭空间_移除成员";
NSString * const kAnalyticsEvent_Family_ModifyMemberPermission = @"home_member_renamed";

#pragma mark - 上报时机常量实现

NSString * const kAnalyticsTrigger_OnClick = @"点击时";
NSString * const kAnalyticsTrigger_OnPairSuccess = @"配对成功时";
NSString * const kAnalyticsTrigger_OnDeviceActivated = @"配网成功，设备ID激活时";
NSString * const kAnalyticsTrigger_OnAddFailed = @"添加失败时";
NSString * const kAnalyticsTrigger_OnLoginSuccess = @"登录成功时";
NSString * const kAnalyticsTrigger_OnAddCompleted = @"编辑完成，发出邀请家庭成员请求时";
NSString * const kAnalyticsTrigger_OnRemoveCompleted = @"移除完成时";
NSString * const kAnalyticsTrigger_OnModifyCompleted = @"重命名家庭成员成功时";

#pragma mark - 属性键常量实现

NSString * const kAnalyticsProperty_BannerId = @"banner_id";
NSString * const kAnalyticsProperty_BannerName = @"banner_name";
NSString * const kAnalyticsProperty_PID = @"pid";

NSString * const kAnalyticsProperty_DeviceId = @"device_id";
NSString * const kAnalyticsProperty_FailureReason = @"failure_reason";
NSString * const kAnalyticsProperty_ErrorCode = @"error_code";
NSString * const kAnalyticsProperty_DollId = @"dollID";
NSString * const kAnalyticsProperty_DollName = @"dollName";
NSString * const kAnalyticsProperty_AccountId = @"account_id";
NSString * const kAnalyticsProperty_LoginTime = @"login_time";
NSString * const kAnalyticsProperty_LoginRegion = @"login_region";
NSString * const kAnalyticsProperty_MemberPermission = @"memberpermission";
NSString * const kAnalyticsProperty_FamilyId = @"home_id";
NSString * const kAnalyticsProperty_HomeId = @"homeid";
NSString * const kAnalyticsProperty_FamilyMemberId = @"familymemberid";
NSString * const kAnalyticsProperty_HomeOwnerId = @"homeownerid";
NSString * const kAnalyticsProperty_UserId = @"family_member_id";

#pragma mark - 权限类型常量实现

NSString * const kAnalyticsPermission_Owner = @"owner";
NSString * const kAnalyticsPermission_Admin = @"admin";
NSString * const kAnalyticsPermission_Normal = @"normal";


