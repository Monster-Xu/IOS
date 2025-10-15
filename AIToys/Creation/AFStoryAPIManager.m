// AFStoryAPIManager.m
#import "AFStoryAPIManager.h"
#import "APIManager.h"
#import "APIPortConfiguration.h"

@implementation AFStoryAPIManager

+ (instancetype)sharedManager {
    static AFStoryAPIManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFStoryAPIManager alloc] init];
    });
    return manager;
}

#pragma mark - Helper Methods

- (APIResponseModel *)parseResponseObject:(id)responseObject {
    APIResponseModel *response = [[APIResponseModel alloc] init];
    
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        response.code = [dict[@"code"] integerValue];
        response.message = dict[@"msg"] ?: dict[@"message"] ?: @"";
        response.data = dict[@"data"];
        response.timestamp = [dict[@"timestamp"] longLongValue];
        response.requestId = dict[@"requestId"] ?: @"";
    } else {
        response.code = -1;
        response.message = @"响应格式错误";
    }
    
    return response;
}

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

#pragma mark - 故事相关接口

- (void)createStory:(CreateStoryRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = [request toDictionary];
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getCreateStoryUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)getStoriesWithPage:(PageRequestModel *)page
                   success:(void(^)(StoryListResponseModel *response))success
                   failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = [page toQueryParameters];
    
    [[APIManager shared] GET:[APIPortConfiguration getStoriesListUrl]
                   parameter:parameters
                     success:^(id result, id data, NSString *msg) {
        APIResponseModel *apiResponse = [self parseResponseObject:result];
        if (apiResponse.isSuccess) {
            StoryListResponseModel *storyResponse = [[StoryListResponseModel alloc] init];
            
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
            
            if (success) success(storyResponse);
        } else {
            NSError *error = [NSError errorWithDomain:@"APIError"
                                                 code:apiResponse.code
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)getStoryDetailWithId:(NSInteger)storyId
                     success:(void(^)(VoiceStoryModel *story))success
                     failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = @{@"storyId": @(storyId)};
    
    [[APIManager shared] GET:[APIPortConfiguration getStoryDetailUrl]
                   parameter:parameters
                     success:^(id result, id data, NSString *msg) {
        APIResponseModel *apiResponse = [self parseResponseObject:result];
        if (apiResponse.isSuccess) {
            VoiceStoryModel *story = [self parseStoryFromDict:apiResponse.data];
            if (success) success(story);
        } else {
            NSError *error = [NSError errorWithDomain:@"APIError"
                                                 code:apiResponse.code
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)updateStory:(UpdateStoryRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = [request toDictionary];
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getUpdateStoryUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)deleteStoryWithId:(NSInteger)storyId
                  success:(void(^)(APIResponseModel *response))success
                  failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = @{@"storyId": @(storyId)};
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getDeleteStoryUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)synthesizeStory:(SynthesizeStoryRequestModel *)request
                success:(void(^)(APIResponseModel *response))success
                failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = [request toDictionary];
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getSynthesizeStoryUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

#pragma mark - 声音相关接口

- (void)createVoice:(CreateVoiceRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = [request toDictionary];
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getCreateVoiceUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)getVoicesWithStatus:(NSInteger)status
                    success:(void(^)(VoiceListResponseModel *response))success
                    failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = status > 0 ? @{@"cloneStatus": @(status)} : nil;
    
    [[APIManager shared] GET:[APIPortConfiguration getVoicesListUrl]
                   parameter:parameters
                     success:^(id result, id data, NSString *msg) {
        APIResponseModel *apiResponse = [self parseResponseObject:result];
        if (apiResponse.isSuccess) {
            VoiceListResponseModel *voiceResponse = [[VoiceListResponseModel alloc] init];
            
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
            
            if (success) success(voiceResponse);
        } else {
            NSError *error = [NSError errorWithDomain:@"APIError"
                                                 code:apiResponse.code
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)getVoiceDetailWithId:(NSInteger)voiceId
                     success:(void(^)(VoiceModel *voice))success
                     failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = @{@"voiceId": @(voiceId)};
    
    [[APIManager shared] GET:[APIPortConfiguration getVoiceDetailUrl]
                   parameter:parameters
                     success:^(id result, id data, NSString *msg) {
        APIResponseModel *apiResponse = [self parseResponseObject:result];
        if (apiResponse.isSuccess) {
            VoiceModel *voice = [self parseVoiceFromDict:apiResponse.data];
            if (success) success(voice);
        } else {
            NSError *error = [NSError errorWithDomain:@"APIError"
                                                 code:apiResponse.code
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)updateVoice:(UpdateVoiceRequestModel *)request
            success:(void(^)(APIResponseModel *response))success
            failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = [request toDictionary];
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getUpdateVoiceUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)deleteVoiceWithId:(NSInteger)voiceId
                  success:(void(^)(APIResponseModel *response))success
                  failure:(StoryAPIFailureBlock)failure {
    
    NSDictionary *parameters = @{@"voiceId": @(voiceId)};
    
    [[APIManager shared] POSTJSON:[APIPortConfiguration getDeleteVoiceUrl]
                        parameter:parameters
                          success:^(id result, id data, NSString *msg) {
        APIResponseModel *response = [self parseResponseObject:result];
        if (success) success(response);
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

#pragma mark - 通用资源接口

- (void)getIllustrationsSuccess:(void(^)(IllustrationListResponseModel *response))success
                       failure:(StoryAPIFailureBlock)failure {
    
    [[APIManager shared] GET:[APIPortConfiguration getIllustrationsUrl]
                   parameter:nil
                     success:^(id result, id data, NSString *msg) {
        APIResponseModel *apiResponse = [self parseResponseObject:result];
        if (apiResponse.isSuccess) {
            IllustrationListResponseModel *illustrationResponse = [[IllustrationListResponseModel alloc] init];
            
            if ([apiResponse.data isKindOfClass:[NSArray class]]) {
                NSArray *list = apiResponse.data;
                NSMutableArray<IllustrationModel *> *illustrations = [NSMutableArray array];
                for (NSDictionary *item in list) {
                    IllustrationModel *illustration = [[IllustrationModel alloc] init];
                    illustration.name = item[@"name"] ?: @"";
                    illustration.url = item[@"url"] ?: @"";
                    [illustrations addObject:illustration];
                }
                illustrationResponse.list = illustrations;
                illustrationResponse.total = illustrations.count;
            }
            
            if (success) success(illustrationResponse);
        } else {
            NSError *error = [NSError errorWithDomain:@"APIError"
                                                 code:apiResponse.code
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

- (void)getOfficialVoicesSuccess:(void(^)(VoiceListResponseModel *response))success
                        failure:(StoryAPIFailureBlock)failure {
    
    [[APIManager shared] GET:[APIPortConfiguration getOfficialVoicesUrl]
                   parameter:nil
                     success:^(id result, id data, NSString *msg) {
        APIResponseModel *apiResponse = [self parseResponseObject:result];
        if (apiResponse.isSuccess) {
            VoiceListResponseModel *voiceResponse = [[VoiceListResponseModel alloc] init];
            
            if ([apiResponse.data isKindOfClass:[NSArray class]]) {
                NSArray *list = apiResponse.data;
                NSMutableArray<VoiceModel *> *voices = [NSMutableArray array];
                for (NSDictionary *item in list) {
                    VoiceModel *voice = [self parseVoiceFromDict:item];
                    [voices addObject:voice];
                }
                voiceResponse.list = voices;
                voiceResponse.total = voices.count;
            }
            
            if (success) success(voiceResponse);
        } else {
            NSError *error = [NSError errorWithDomain:@"APIError"
                                                 code:apiResponse.code
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            if (failure) failure(error);
        }
    } failure:^(NSError *error, NSString *msg) {
        if (failure) {
            NSError *apiError = [NSError errorWithDomain:@"APIError"
                                                    code:error.code
                                                userInfo:@{NSLocalizedDescriptionKey: msg ?: error.localizedDescription}];
            failure(apiError);
        }
    }];
}

@end
