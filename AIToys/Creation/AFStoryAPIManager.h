// AFStoryAPIManager.h
#import <Foundation/Foundation.h>
#import "APIRequestModel.h"
#import "APIResponseModel.h"
#import "VoiceStoryModel.h"
#import "VoiceModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^StoryAPISuccessBlock)(APIResponseModel *response);
typedef void(^StoryAPIFailureBlock)(NSError *error);

@interface AFStoryAPIManager : NSObject

+ (instancetype)sharedManager;

#pragma mark - 故事相关接口

// 创建故事
- (void)createStory:(CreateStoryRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure;

// 查询故事列表
- (void)getStoriesWithPage:(PageRequestModel *)page
                   success:(void(^)(StoryListResponseModel *response))success
                   failure:(StoryAPIFailureBlock)failure;

// 查询故事详情
- (void)getStoryDetailWithId:(NSInteger)storyId
                     success:(void(^)(VoiceStoryModel *story))success
                     failure:(StoryAPIFailureBlock)failure;

// 编辑故事
- (void)updateStory:(UpdateStoryRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure;

// 删除故事
- (void)deleteStoryWithId:(NSInteger)storyId
                  success:(void(^)(APIResponseModel *response))success
                  failure:(StoryAPIFailureBlock)failure;

// 故事音频合成
- (void)synthesizeStory:(SynthesizeStoryRequestModel *)request
                success:(void(^)(APIResponseModel *response))success
                failure:(StoryAPIFailureBlock)failure;

#pragma mark - 声音相关接口

// 创建声音（开始克隆）
- (void)createVoice:(CreateVoiceRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure;

// 查询声音列表
- (void)getVoicesWithStatus:(NSInteger)status
                    success:(void(^)(VoiceListResponseModel *response))success
                    failure:(StoryAPIFailureBlock)failure;

// 查询声音详情
- (void)getVoiceDetailWithId:(NSInteger)voiceId
                     success:(void(^)(VoiceModel *voice))success
                     failure:(StoryAPIFailureBlock)failure;

// 编辑声音
- (void)updateVoice:(UpdateVoiceRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure;

// 删除声音
- (void)deleteVoiceWithId:(NSInteger)voiceId
                  success:(void(^)(APIResponseModel *response))success
                  failure:(StoryAPIFailureBlock)failure;

#pragma mark - 通用资源接口

// 获取官方插画列表
- (void)getIllustrationsSuccess:(void(^)(IllustrationListResponseModel *response))success
                       failure:(StoryAPIFailureBlock)failure;

// 获取官方音色列表
- (void)getOfficialVoicesSuccess:(void(^)(VoiceListResponseModel *response))success
                        failure:(StoryAPIFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
