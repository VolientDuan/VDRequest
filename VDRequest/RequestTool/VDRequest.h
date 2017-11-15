//
//  VDRequest.h
//  VDRequest
//
//  Created by baimo on 17/8/16.
//  Copyright © 2017年 zhuiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDURLRequest.h"
#import "VDResponse.h"

@interface VDRequest : NSObject
@property (nonatomic, strong)VDURLRequest *request;
@property (nonatomic, strong)VDResponse *response;
@property (class,readonly,strong)VDRequest *defaultManager;
@property (nonatomic, strong)VDURLRequest *currentRequest;

@property (nonatomic, strong)NSString *baseUrl;
//POST请求
- (void)POST:(NSString *)api params:(id)params responseBlock:(VDResponseBlock)responseBlock;
//GET请求
- (void)GET:(NSString *)api params:(id)params responseBlock:(VDResponseBlock)responseBlock;

/**
 可自定义的请求方法

 @param api 请求的API
 @param method 请求方法：GET,POST,PUT...
 @param type 请求类型
 @param params 参数
 @param responseBlock 响应结果回调
 */
- (void)sendRequestWithApi:(NSString *)api
                    method:(NSString *)method
                      type:(VDRequestType)type
                    params:(id)params
             responseBlock:(VDResponseBlock)responseBlock;

/**
 表单上传文件(图片，doc，压缩包等文件)，支持多文件

 @param api 请求的API
 @param params 参数s
 @param files 文件(文件以键值对的形式存放至字典中，文件可以是UIImage和NSData)
 @param responseBlock 响应结果回调
 */
- (void)formDataUploadWithApi:(NSString *)api
                       params:(id)params
                        files:(NSDictionary *)files
                responseBlock:(VDResponseBlock)responseBlock;

#pragma mark - 链式方法 (和上面的方法一一对应, 满足某人(作者本人)的强迫症)

- (void(^)(NSString *api, id params, VDResponseBlock block))POST;
- (void(^)(NSString *api, id params, VDResponseBlock block))GET;
- (void(^)(NSString *api, NSString *method, VDRequestType type, id params, VDResponseBlock block))sendRequest;
- (void(^)(NSString *api, id params, NSDictionary *files,VDResponseBlock block))uploadFiles;
@end
