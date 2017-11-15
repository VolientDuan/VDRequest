//
//  VDRequest.m
//  VDRequest
//
//  Created by baimo on 17/8/16.
//  Copyright © 2017年 zhuiyou. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "VDRequest.h"
#import "NSURLSessionVDExtend.h"

@interface VDRequest()<NSURLSessionDelegate>

@property (nonatomic, strong)NSMutableArray *requestArray;

@property (nonatomic, strong) NSProgress *uploadProgress;
@property (nonatomic, strong) NSProgress *downloadProgress;

@end
@implementation VDRequest
static dispatch_queue_t vd_request_manager_queue() {
    static dispatch_queue_t vd_session_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vd_session_queue = dispatch_queue_create("com.volientduan.vdrequest.manager.queue", DISPATCH_QUEUE_SERIAL);
    });
    return vd_session_queue;
}
static void vd_request_manager_queue_block(dispatch_block_t block){
    dispatch_sync(vd_request_manager_queue(), block);
}
+ (VDRequest *)defaultManager{
    static VDRequest *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VDRequest alloc]init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
//        self.uploadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
//        self.uploadProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
//
//        self.downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
//        self.downloadProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
    }
    return self;
}

#pragma mark - 属性

- (NSMutableArray *)requestArray{
    if (!_requestArray) {
        _requestArray = [NSMutableArray array];
    }
    return _requestArray;
}

- (VDURLRequest *)request{
    if (!_request) {
        _request = [[VDURLRequest alloc]init];
    }
    return _request;
}
- (VDResponse *)response{
    if (!_response) {
        _response = [[VDResponse alloc]init];
    }
    return _response;
}

- (void)setBaseUrl:(NSString *)baseUrl{
    if (!_baseUrl||![_baseUrl isEqualToString:baseUrl]) {
        _baseUrl = baseUrl;
        self.request.baseUrl = baseUrl;
    }
}

#pragma mark - progress
- (void)addProgressForTask:(NSURLSessionTask *)task{
    __weak __typeof__(task) weakTask = task;
    
    self.uploadProgress.totalUnitCount = task.countOfBytesExpectedToSend;
    self.downloadProgress.totalUnitCount = task.countOfBytesExpectedToReceive;
    [self.uploadProgress setCancellable:YES];
    [self.uploadProgress setCancellationHandler:^{
        __typeof__(weakTask) strongTask = weakTask;
        [strongTask cancel];
    }];
    [self.uploadProgress setPausable:YES];
    [self.uploadProgress setPausingHandler:^{
        __typeof__(weakTask) strongTask = weakTask;
        [strongTask suspend];
    }];
    if ([self.uploadProgress respondsToSelector:@selector(setResumingHandler:)]) {
        [self.uploadProgress setResumingHandler:^{
            __typeof__(weakTask) strongTask = weakTask;
            [strongTask resume];
        }];
    }
    
    [self.downloadProgress setCancellable:YES];
    [self.downloadProgress setCancellationHandler:^{
        __typeof__(weakTask) strongTask = weakTask;
        [strongTask cancel];
    }];
    [self.downloadProgress setPausable:YES];
    [self.downloadProgress setPausingHandler:^{
        __typeof__(weakTask) strongTask = weakTask;
        [strongTask suspend];
    }];
    
    if ([self.downloadProgress respondsToSelector:@selector(setResumingHandler:)]) {
        [self.downloadProgress setResumingHandler:^{
            __typeof__(weakTask) strongTask = weakTask;
            [strongTask resume];
        }];
    }
    [task addObserver:self
               forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [task addObserver:self
               forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    [task addObserver:self
               forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [task addObserver:self
               forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToSend))
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
}
#pragma mark - 请求方法
- (void)sendRequest:(VDURLRequest *)request block:(VDResponseBlock)block{
    if (!request.URL) {
        block(nil,NO,VDRequestErrorURL);
        return;
    }
    __block NSURLSessionTask *dataTask = nil;
    vd_request_manager_queue_block(^{
        [self.requestArray addObject:request];
        dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            BOOL isSuccess = NO;
            NSInteger errorCode = VDRequestErrorUnknown;
            if (response) {
                errorCode = ((NSHTTPURLResponse *)response).statusCode;
                if (((NSHTTPURLResponse *)response).statusCode == 200) {
                    isSuccess = YES;
                }
            }else{
                errorCode = error.code;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.currentRequest = request;
                self.response.currentResponse = response;
                self.response.currentError = error;
                block(self.response.responseHandle(data),isSuccess,errorCode);
                self.currentRequest = nil;
                self.response.currentResponse = nil;
                self.response.currentError = nil;
            });
        }];
    });
    [dataTask resume];
}
- (void)sendRequestWithApi:(NSString *)api method:(NSString *)method type:(VDRequestType)type params:(id)params responseBlock:(VDResponseBlock)responseBlock{
    [self sendRequest:self.request.set(method,type,api,params) block:^(id response, BOOL isSuccess, NSInteger errorCode) {
        if (responseBlock) {
            responseBlock(response,isSuccess,errorCode);
        }
    }];
}

- (void)POST:(NSString *)api params:(id)params responseBlock:(VDResponseBlock)responseBlock{
    [self sendRequestWithApi:api method:@"POST" type:self.request.requestType params:params responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
        if (responseBlock) {
            responseBlock(response,isSuccess,errorCode);
        }
    }];
}
- (void)GET:(NSString *)api params:(id)params responseBlock:(VDResponseBlock)responseBlock{
    [self sendRequestWithApi:api method:@"GET" type:self.request.requestType params:params responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
        if (responseBlock) {
            responseBlock(response,isSuccess,errorCode);
        }
    }];
}

- (void)formDataUploadWithApi:(NSString *)api params:(id)params files:(NSDictionary *)files responseBlock:(VDResponseBlock)responseBlock{
    [self sendRequestWithApi:api method:@"POST" type:VDRequestTypeFormData params:[self combineParams:params files:files] responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
        responseBlock(response, isSuccess, errorCode);
    }];
}
#pragma mark 链式方法
- (void(^)(NSString *, id, VDResponseBlock))POST{
    return ^(NSString *api, id params ,VDResponseBlock block){
        [self POST:api params:params responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
            block(response,isSuccess,errorCode);
        }];
    };
}
- (void(^)(NSString *, id, VDResponseBlock))GET{
    return ^(NSString *api, id params ,VDResponseBlock block){
        [self GET:api params:params responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
            block(response,isSuccess,errorCode);
        }];
    };
}
- (void (^)(NSString *, NSString *, VDRequestType, id, VDResponseBlock))sendRequest{
    return ^(NSString *api ,NSString *method , VDRequestType type,id params ,VDResponseBlock block){
        [self sendRequestWithApi:api method:method type:type params:params responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
            block(response,isSuccess,errorCode);
        }];
    };
}
- (void (^)(NSString *, id, NSDictionary *, VDResponseBlock))uploadFiles{
    return ^(NSString *api ,id params , NSDictionary *files,VDResponseBlock block){
        [self formDataUploadWithApi:api params:params files:files responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
            block(response,isSuccess,errorCode);
        }];
    };
}
#pragma mark - handler
- (NSDictionary *)combineParams:(NSDictionary *)params files:(NSDictionary *)files{
    NSMutableDictionary *result = [[NSMutableDictionary alloc]initWithDictionary:params];
    if (files) {
        NSArray *keys = files.allKeys;
        for (NSString *key in keys) {
            id file = files[key];
            if (files&&[file isKindOfClass:[NSData class]]&&[file isKindOfClass:[UIImage class]]) {
                [result setObject:file forKey:key];
            }
        }
    }
    return result;
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    
}
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    
}

@end
