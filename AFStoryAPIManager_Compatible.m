//
//  AFStoryAPIManager_Compatible.m
//  兼容版本的 AFNetworking API 管理器
//  
//  如果 AFNetworking 版本不兼容，可以使用这个替代版本
//  Created by xuxuxu on 2025/10/5.
//

#import "AFStoryAPIManager.h"

// 使用原生 NSURLSession 作为后备方案
@interface AFStoryAPIManager ()
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, copy) NSString *baseURL;
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
        [self setupCompatibleSession];
    }
    return self;
}

- (void)setupCompatibleSession {
    self.baseURL = @"https://api.example.com/api/v1";
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 30.0;
    config.timeoutIntervalForResource = 60.0;
    
    self.urlSession = [NSURLSession sessionWithConfiguration:config];
}

- (NSURLRequest *)createRequestWithMethod:(NSString *)method 
                                     path:(NSString *)path 
                               parameters:(NSDictionary *)parameters {
    NSString *urlString = [self.baseURL stringByAppendingString:path];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 设置请求方法
    request.HTTPMethod = method;
    
    // 设置通用请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"Bearer {access_token}" forHTTPHeaderField:@"Authorization"];
    [request setValue:@"{family_id}" forHTTPHeaderField:@"X-Family-Id"];
    [request setValue:[[NSUUID UUID] UUIDString] forHTTPHeaderField:@"X-Request-Id"];
    
    // 处理参数
    if (parameters) {
        if ([method isEqualToString:@"GET"]) {
            // GET 请求参数拼接到URL
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
            NSMutableArray *queryItems = [NSMutableArray array];
            for (NSString *key in parameters) {
                NSString *value = [NSString stringWithFormat:@"%@", parameters[key]];
                [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value]];
            }
            components.queryItems = queryItems;
            request.URL = components.URL;
        } else {
            // POST 请求参数放在 body
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
            if (!error) {
                request.HTTPBody = jsonData;
            }
        }
    }
    
    return request;
}

- (NSURLSessionDataTask *)performRequest:(NSURLRequest *)request 
                                 success:(void(^)(id responseObject))success 
                                 failure:(void(^)(NSError *error))failure {
    return [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (failure) failure(error);
                return;
            }
            
            if (!data) {
                NSError *noDataError = [NSError errorWithDomain:@"APIError" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"No data received"}];
                if (failure) failure(noDataError);
                return;
            }
            
            NSError *jsonError;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                if (failure) failure(jsonError);
                return;
            }
            
            if (success) success(jsonObject);
        });
    }];
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
    NSURLRequest *urlRequest = [self createRequestWithMethod:@"POST" 
                                                        path:@"/stories" 
                                                  parameters:[request toDictionary]];
    
    NSURLSessionDataTask *task = [self performRequest:urlRequest success:^(id responseObject) {
        APIResponseModel *response = [self parseResponseObject:responseObject];
        if (success) success(response);
    } failure:failure];
    
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)getStoriesWithPage:(PageRequestModel *)page
                                     success:(void(^)(StoryListResponseModel *response))success
                                     failure:(AFAPIFailureBlock)failure {
    NSURLRequest *urlRequest = [self createRequestWithMethod:@"GET" 
                                                        path:@"/stories" 
                                                  parameters:[page toQueryParameters]];
    
    NSURLSessionDataTask *task = [self performRequest:urlRequest success:^(id responseObject) {
        APIResponseModel *apiResponse = [self parseResponseObject:responseObject];
        if (apiResponse.isSuccess && success) {
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
            
            success(storyResponse);
        } else if (failure) {
            NSError *error = [NSError errorWithDomain:@"APIError" 
                                                 code:apiResponse.code 
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            failure(error);
        }
    } failure:failure];
    
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)deleteStoryWithId:(NSInteger)storyId
                                    success:(AFAPISuccessBlock)success
                                    failure:(AFAPIFailureBlock)failure {
    NSDictionary *params = @{@"storyId": @(storyId)};
    NSURLRequest *urlRequest = [self createRequestWithMethod:@"POST" 
                                                        path:@"/stories/delete" 
                                                  parameters:params];
    
    NSURLSessionDataTask *task = [self performRequest:urlRequest success:^(id responseObject) {
        APIResponseModel *response = [self parseResponseObject:responseObject];
        if (success) success(response);
    } failure:failure];
    
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)createVoice:(CreateVoiceRequestModel *)request
                              success:(AFAPISuccessBlock)success
                              failure:(AFAPIFailureBlock)failure {
    NSURLRequest *urlRequest = [self createRequestWithMethod:@"POST" 
                                                        path:@"/voices/clone" 
                                                  parameters:[request toDictionary]];
    
    NSURLSessionDataTask *task = [self performRequest:urlRequest success:^(id responseObject) {
        APIResponseModel *response = [self parseResponseObject:responseObject];
        if (success) success(response);
    } failure:failure];
    
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)getVoicesWithStatus:(NSInteger)status
                                      success:(void(^)(VoiceListResponseModel *response))success
                                      failure:(AFAPIFailureBlock)failure {
    NSDictionary *params = status > 0 ? @{@"cloneStatus": @(status)} : nil;
    NSURLRequest *urlRequest = [self createRequestWithMethod:@"GET" 
                                                        path:@"/voices" 
                                                  parameters:params];
    
    NSURLSessionDataTask *task = [self performRequest:urlRequest success:^(id responseObject) {
        APIResponseModel *apiResponse = [self parseResponseObject:responseObject];
        if (apiResponse.isSuccess && success) {
            VoiceListResponseModel *voiceResponse = [[VoiceListResponseModel alloc] init];
            success(voiceResponse);
        } else if (failure) {
            NSError *error = [NSError errorWithDomain:@"APIError" 
                                                 code:apiResponse.code 
                                             userInfo:@{NSLocalizedDescriptionKey: apiResponse.errorMessage}];
            failure(error);
        }
    } failure:failure];
    
    [task resume];
    return task;
}

#pragma mark - Other required methods...

- (NSURLSessionDataTask *)getStoryDetailWithId:(NSInteger)storyId
                                       success:(void(^)(VoiceStoryModel *story))success
                                       failure:(AFAPIFailureBlock)failure {
    // 实现代码...
    return nil;
}

- (NSURLSessionDataTask *)synthesizeStory:(SynthesizeStoryRequestModel *)request
                                  success:(AFAPISuccessBlock)success
                                  failure:(AFAPIFailureBlock)failure {
    // 实现代码...  
    return nil;
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