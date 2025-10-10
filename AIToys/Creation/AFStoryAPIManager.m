//
//  AFStoryAPIManager.m
//  AIToys
//
//  Created by xuxuxu on 2025/10/5.
//

#import "AFStoryAPIManager.h"

// 基础URL配置
static NSString * const kAFAPIBaseURL = @"https://api.example.com/api/v1";

@interface AFStoryAPIManager ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end

@implementation AFStoryAPIManager

+ (instancetype)sharedManager {
    static AFStoryAPIManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFStoryAPIManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupSessionManager];
    }
    return self;
}

- (void)setupSessionManager {
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAFAPIBaseURL]];
    
    // 设置请求序列化器
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.sessionManager.requestSerializer.timeoutInterval = 30.0;
    
    // 设置通用请求头
    [self.sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.sessionManager.requestSerializer setValue:@"Bearer {access_token}" forHTTPHeaderField:@"Authorization"];
    [self.sessionManager.requestSerializer setValue:@"{family_id}" forHTTPHeaderField:@"X-Family-Id"];
    
    // 设置响应序列化器
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/html", nil];
}

- (APIResponseModel *)parseResponseObject:(id)responseObject {
    APIResponseModel *response = [[APIResponseModel alloc] init];
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        response.code = [dict[@"code"] integerValue];
        response.message = dict[@"message"] ?: @"";
        response.data = dict[@"data"];
        response.timestamp = [dict[@"timestamp"] longLongValue];
        response.requestId = dict[@"requestId"] ?: @"";
    }
    return response;
}

#pragma mark - 故事相关接口

- (NSURLSessionDataTask *)createStory:(CreateStoryRequestModel *)request
                              success:(AFAPISuccessBlock)success
                              failure:(AFAPIFailureBlock)failure {
    // 设置动态请求头
    [self.sessionManager.requestSerializer setValue:[[NSUUID UUID] UUIDString] forHTTPHeaderField:@"X-Request-Id"];
    
    return [self.sessionManager POST:@"/stories" 
                          parameters:[request toDictionary] 
                             headers:nil 
                            progress:nil 
                             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        APIResponseModel *response = [self parseResponseObject:responseObject];
        if (success) success(response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) failure(error);
    }];
}

- (NSURLSessionDataTask *)getStoriesWithPage:(PageRequestModel *)page
                                     success:(void(^)(StoryListResponseModel *response))success
                                     failure:(AFAPIFailureBlock)failure {
    return [self.sessionManager GET:@"/stories" 
                         parameters:[page toQueryParameters] 
                            headers:nil 
                           progress:nil 
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        APIResponseModel *apiResponse = [self parseResponseObject:responseObject];
        if (apiResponse.isSuccess && success) {
            // 这里可以集成 YYModel 或 Mantle 等进行自动映射
            StoryListResponseModel *storyResponse = [[StoryListResponseModel alloc] init];
            
            // 手动解析数据（实际项目中建议使用自动映射）
            if ([apiResponse.data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = apiResponse.data;
                storyResponse.total = [data[@"total"] integerValue];
                
                NSArray *list = data[@"list"];
                NSMutableArray<VoiceStoryModel *> *stories = [NSMutableArray array];
                for (NSDictionary *item in list) {
                    VoiceStoryModel *story = [self parseStoryFromDict:item];
                    [stories addObject:story];
                }
                storyResponse.list = stories;
            }
            
            success(storyResponse);
        } else if (failure) {
            NSError *error = [NSError errorWithDomain:@"APIError" 
                                                 code:apiResponse.code 
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            failure(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) failure(error);
    }];
}

- (NSURLSessionDataTask *)getStoryDetailWithId:(NSInteger)storyId
                                       success:(void(^)(VoiceStoryModel *story))success
                                       failure:(AFAPIFailureBlock)failure {
    NSDictionary *params = @{@"storyId": @(storyId)};
    
    return [self.sessionManager GET:@"/stories/detail" 
                         parameters:params 
                            headers:nil 
                           progress:nil 
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        APIResponseModel *apiResponse = [self parseResponseObject:responseObject];
        if (apiResponse.isSuccess && success) {
            VoiceStoryModel *story = [self parseStoryFromDict:apiResponse.data];
            success(story);
        } else if (failure) {
            NSError *error = [NSError errorWithDomain:@"APIError" 
                                                 code:apiResponse.code 
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            failure(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) failure(error);
    }];
}

- (NSURLSessionDataTask *)deleteStoryWithId:(NSInteger)storyId
                                    success:(AFAPISuccessBlock)success
                                    failure:(AFAPIFailureBlock)failure {
    NSDictionary *params = @{@"storyId": @(storyId)};
    
    return [self.sessionManager POST:@"/stories/delete" 
                          parameters:params 
                             headers:nil 
                            progress:nil 
                             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        APIResponseModel *response = [self parseResponseObject:responseObject];
        if (success) success(response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) failure(error);
    }];
}

- (NSURLSessionDataTask *)synthesizeStory:(SynthesizeStoryRequestModel *)request
                                  success:(AFAPISuccessBlock)success
                                  failure:(AFAPIFailureBlock)failure {
    return [self.sessionManager POST:@"/stories/synthesize" 
                          parameters:[request toDictionary] 
                             headers:nil 
                            progress:nil 
                             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        APIResponseModel *response = [self parseResponseObject:responseObject];
        if (success) success(response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) failure(error);
    }];
}

#pragma mark - 声音相关接口

- (NSURLSessionDataTask *)createVoice:(CreateVoiceRequestModel *)request
                              success:(AFAPISuccessBlock)success
                              failure:(AFAPIFailureBlock)failure {
    return [self.sessionManager POST:@"/voices/clone" 
                          parameters:[request toDictionary] 
                             headers:nil 
                            progress:nil 
                             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        APIResponseModel *response = [self parseResponseObject:responseObject];
        if (success) success(response);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) failure(error);
    }];
}

- (NSURLSessionDataTask *)getVoicesWithStatus:(NSInteger)status
                                      success:(void(^)(VoiceListResponseModel *response))success
                                      failure:(AFAPIFailureBlock)failure {
    NSDictionary *params = status > 0 ? @{@"cloneStatus": @(status)} : nil;
    
    return [self.sessionManager GET:@"/voices" 
                         parameters:params 
                            headers:nil 
                           progress:nil 
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        APIResponseModel *apiResponse = [self parseResponseObject:responseObject];
        if (apiResponse.isSuccess && success) {
            VoiceListResponseModel *voiceResponse = [[VoiceListResponseModel alloc] init];
            
            // 手动解析声音数据
            if ([apiResponse.data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = apiResponse.data;
                voiceResponse.total = [data[@"total"] integerValue];
                
                NSArray *list = data[@"list"];
                NSMutableArray<VoiceModel *> *voices = [NSMutableArray array];
                for (NSDictionary *item in list) {
                    VoiceModel *voice = [self parseVoiceFromDict:item];
                    [voices addObject:voice];
                }
                voiceResponse.list = voices;
            }
            
            success(voiceResponse);
        } else if (failure) {
            NSError *error = [NSError errorWithDomain:@"APIError" 
                                                 code:apiResponse.code 
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            failure(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) failure(error);
    }];
}

#pragma mark - Helper Methods

- (VoiceStoryModel *)parseStoryFromDict:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return [[VoiceStoryModel alloc] init];
    }
    
    VoiceStoryModel *story = [[VoiceStoryModel alloc] init];
    
    story.storyId = [dict[@"storyId"] integerValue];
    story.storyName = dict[@"storyName"] ?: @"";
    story.storyContent = dict[@"storyContent"];
    story.storySummary = dict[@"storySummary"];
    story.storyType = [dict[@"storyType"] integerValue];
    story.storyTypeDesc = dict[@"storyTypeDesc"];
    story.protagonistName = dict[@"protagonistName"];
    story.storyLength = [dict[@"storyLength"] integerValue];
    story.illustrationUrl = dict[@"illustrationUrl"];
    
    story.voiceId = [dict[@"voiceId"] integerValue];
    story.voiceName = dict[@"voiceName"];
    story.audioUrl = dict[@"audioUrl"];
    
    story.storyStatus = [dict[@"storyStatus"] integerValue];
    story.statusDesc = dict[@"statusDesc"];
    story.errorMsg = dict[@"errorMsg"];
    
    story.dollId = [dict[@"dollId"] integerValue];
    story.dollName = dict[@"dollName"];
    
    story.createTime = dict[@"createTime"];
    story.updateTime = dict[@"updateTime"];
    
    return story;
}

- (VoiceModel *)parseVoiceFromDict:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return [[VoiceModel alloc] init];
    }
    
    VoiceModel *voice = [[VoiceModel alloc] init];
    
    voice.voiceId = [dict[@"voiceId"] integerValue];
    voice.voiceName = dict[@"voiceName"] ?: @"";
    voice.avatarUrl = dict[@"avatarUrl"];
    
    voice.cloneStatus = [dict[@"cloneStatus"] integerValue];
    voice.statusDesc = dict[@"statusDesc"];
    voice.errorMsg = dict[@"errorMsg"];
    
    voice.sampleAudioUrl = dict[@"sampleAudioUrl"];
    voice.sampleText = dict[@"sampleText"];
    
    voice.bindStoryCount = [dict[@"bindStoryCount"] integerValue];
    
    voice.createTime = dict[@"createTime"];
    voice.updateTime = dict[@"updateTime"];
    
    return voice;
}

@end