//
//  AFStoryAPIManager.h
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "APIRequestModel.h"
#import "APIResponseModel.h"
#import "VoiceStoryModel.h"
#import "VoiceModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^AFAPISuccessBlock)(APIResponseModel *response);
typedef void(^AFAPIFailureBlock)(NSError *error);

@interface AFStoryAPIManager : NSObject

+ (instancetype)sharedManager;

#pragma mark - 故事相关接口

// 创建故事
- (NSURLSessionDataTask *)createStory:(CreateStoryRequestModel *)request
                              success:(AFAPISuccessBlock)success
                              failure:(AFAPIFailureBlock)failure;

// 查询故事列表
- (NSURLSessionDataTask *)getStoriesWithPage:(PageRequestModel *)page
                                     success:(void(^)(StoryListResponseModel *response))success
                                     failure:(AFAPIFailureBlock)failure;

// 查询故事详情
- (NSURLSessionDataTask *)getStoryDetailWithId:(NSInteger)storyId
                                       success:(void(^)(VoiceStoryModel *story))success
                                       failure:(AFAPIFailureBlock)failure;

// 编辑故事
- (NSURLSessionDataTask *)updateStory:(UpdateStoryRequestModel *)request
                              success:(AFAPISuccessBlock)success
                              failure:(AFAPIFailureBlock)failure;

// 删除故事
- (NSURLSessionDataTask *)deleteStoryWithId:(NSInteger)storyId
                                    success:(AFAPISuccessBlock)success
                                    failure:(AFAPIFailureBlock)failure;

// 故事音频合成
- (NSURLSessionDataTask *)synthesizeStory:(SynthesizeStoryRequestModel *)request
                                  success:(AFAPISuccessBlock)success
                                  failure:(AFAPIFailureBlock)failure;

#pragma mark - 声音相关接口

// 创建声音（开始克隆）
- (NSURLSessionDataTask *)createVoice:(CreateVoiceRequestModel *)request
                              success:(AFAPISuccessBlock)success
                              failure:(AFAPIFailureBlock)failure;

// 查询声音列表
- (NSURLSessionDataTask *)getVoicesWithStatus:(NSInteger)status
                                      success:(void(^)(VoiceListResponseModel *response))success
                                      failure:(AFAPIFailureBlock)failure;

// 查询声音详情
- (NSURLSessionDataTask *)getVoiceDetailWithId:(NSInteger)voiceId
                                       success:(void(^)(VoiceModel *voice))success
                                       failure:(AFAPIFailureBlock)failure;

// 编辑声音
- (NSURLSessionDataTask *)updateVoice:(UpdateVoiceRequestModel *)request
                              success:(AFAPISuccessBlock)success
                              failure:(AFAPIFailureBlock)failure;

// 删除声音
- (NSURLSessionDataTask *)deleteVoiceWithId:(NSInteger)voiceId
                                    success:(AFAPISuccessBlock)success
                                    failure:(AFAPIFailureBlock)failure;

#pragma mark - 通用资源接口

// 获取官方插画列表
- (NSURLSessionDataTask *)getIllustrationsSuccess:(void(^)(IllustrationListResponseModel *response))success
                                          failure:(AFAPIFailureBlock)failure;

// 获取官方音色列表
- (NSURLSessionDataTask *)getOfficialVoicesSuccess:(void(^)(VoiceListResponseModel *response))success
                                           failure:(AFAPIFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END