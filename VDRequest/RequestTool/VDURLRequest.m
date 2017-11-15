//
//  VDRequest.m
//  VDRequest
//
//  Created by baimo on 17/8/16.
//  Copyright © 2017年 zhuiyou. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "VDURLRequest.h"
#define VDREQUEST_BOUNDARY @"VDREQUESTBOUNDARY"
#define VD_LINE @"\r\n"
@interface NSMutableData (body)
- (void)appendStr:(NSString *)str;

@end
@implementation NSMutableData (body)
- (void)appendStr:(NSString *)str{
    [self appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}


@end
@interface VDURLRequest()

/**
 分割线
 */
@property (nonatomic, strong)NSString *boundary;

@end
@implementation VDURLRequest

- (NSString *)boundary{
    if (!_boundary||_boundary.length==0) {
        _boundary = VDREQUEST_BOUNDARY;
    }
    return _boundary;
}

- (void)setContentType:(NSString *)contentType{
    [self addHeaderValue:contentType forKey:@"content-Type"];
}
- (void)setRequestType:(VDRequestType)requestType{
    switch (requestType) {
        case VDRequestTypeJson:
            self.contentType = @"application/json";
            break;
        case VDRequestTypeFormData:
            self.contentType = @"multipart/form-data";
            break;
        default:
            break;
    }
}
- (instancetype)init{
    self = [super init];
    if (self) {
        [self defaultSet];
    }
    return self;
}
- (void)defaultSet{
    self.requestType = VDRequestTypeJson;//设置为json
    self.timeoutInterval = 20;//超时时间设为20s
}
- (void)addHeaderValue:(NSString *)value forKey:(NSString *)key{
    if (value) {
        [self setValue:value forHTTPHeaderField:key];
    }
}
- (VDURLRequest *(^)(NSString *, VDRequestType, NSString *, id))set{
    return ^(NSString *method, VDRequestType type, NSString *api, id params){
        VDURLRequest *req = [self copyReq];
        req.HTTPMethod = method;
        req.requestType = type;
        [req urlHandler:api];
        [req paramsHandler:params];
        return req;
    };
}
- (VDURLRequest *)copyReq{
    VDURLRequest *req = [[VDURLRequest alloc]init];
    req.baseUrl = self.baseUrl;
    req.allHTTPHeaderFields = self.allHTTPHeaderFields;
    req.timeoutInterval = self.timeoutInterval;
    return req;
}
#pragma mark 参数处理

- (void)paramsHandler:(id)params{
    [self.HTTPMethod isEqualToString:@"GET"]?[self paramsGETHandler:params]:[self paramsPOSTHandler:params];
}
- (void)paramsPOSTHandler:(id)params{
    if (params == nil||self.URL == nil) {
        return;
    }
    if ([params isKindOfClass:[NSData class]]) {
        self.HTTPBody = params;
    }else if ([params isKindOfClass:[NSString class]]){
        self.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        if (self.requestType == VDRequestTypeJson) {
            self.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:NULL];
        }else if (self.requestType == VDRequestTypeFormData){
            [self paramsFormDataHandler:params];
        }
        
    }
}
- (void)paramsGETHandler:(id)params{
    if (params == nil||self.URL == nil) {
        return;
    }else if ([params isKindOfClass:[NSString class]]){
        self.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@",self.URL.absoluteString,params]];
    }else if ([params isKindOfClass:[NSDictionary class]]){
        NSMutableString *mutableStr = [NSMutableString stringWithString:self.URL.absoluteString];
        for (NSString *key in ((NSDictionary *)params).allKeys) {
            [mutableStr appendFormat:@"&%@=%@",key,params[key]];
        }
        self.URL = [NSURL URLWithString:[self fixUrl:mutableStr]];
    }else{
        NSLog(@"错误的参数类型");
    }
}

- (void)paramsFormDataHandler:(NSDictionary *)params{
    self.contentType = [[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",self.boundary];
    NSString *beginBoundary = [NSString stringWithFormat:@"--%@",self.boundary];
    NSString *endBoundary = [NSString stringWithFormat:@"%@--",beginBoundary];
    NSMutableData *bodyData = [NSMutableData data];
    NSArray *keys = params.allKeys;
    for (NSString *key in keys) {
        id value = params[key];
        //分割线，换一行
        [bodyData appendStr:[NSString stringWithFormat:@"%@%@",beginBoundary,VD_LINE]];
        if ([value isKindOfClass:[UIImage class]]||[value isKindOfClass:[NSData class]]) {
            [bodyData appendStr:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"\"%@",key,VD_LINE]];
            //设置文件类型:"application/octet-stream"为二进制流可转为任意文件形式，换两行
            [bodyData appendStr:[NSString stringWithFormat:@"Content-Type: application/octet-stream; charset=utf-8%@%@",VD_LINE,VD_LINE]];
            if ([value isKindOfClass:[UIImage class]]) {
                [bodyData appendData:UIImageJPEGRepresentation(value, 1.0)];
            }else{
                [bodyData appendData:value];
            }
            //设置图片后换一行
            [bodyData appendStr:VD_LINE];
        }else{
            //key后换两行 value后换一行
            [bodyData appendStr:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"%@%@%@%@",key,VD_LINE,VD_LINE,value,VD_LINE]];
        }
    }
    //结束分割线，换一行
    [bodyData appendStr:[NSString stringWithFormat:@"%@%@",endBoundary,VD_LINE]];
    [self addHeaderValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forKey:@"Content-Length"];
    self.HTTPBody = bodyData;
}
#pragma mark URL的处理

- (void)urlHandler:(NSString *)api{
    if ([self isUrl:api]) {
        self.URL = [NSURL URLWithString:[self deleteSpace:api]];
    }else{
        if ([self isUrl:self.baseUrl]) {
            self.URL = [self formartUrlWithApi:api];
        }else{
            NSLog(@"\n【VDRequest】:URL ERROR");
        }
    }
}
- (BOOL)isUrl:(NSString *)strUrl{
    if (!strUrl) {
        return NO;
    }else{
        NSURL *url = [NSURL URLWithString:[self deleteSpace:strUrl]];
        if ([url.scheme isEqualToString:@"http"]||[url.scheme isEqualToString:@"https"]) {
            return YES;
        }
    }
    return NO;
}
- (NSString *)deleteSpace:(NSString *)str{
    if (!str) {
        return nil;
    }
    NSString *str1= [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return [str2 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
}
- (NSString *)fixUrl:(NSString *)str{
    NSString *urlStr = [str stringByReplacingOccurrencesOfString:@"?" withString:@"&"];
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@"&&" withString:@"&"];
    NSRange range = [urlStr rangeOfString:@"&"];
    if (range.location != NSNotFound) {
        urlStr = [urlStr stringByReplacingCharactersInRange:range withString:@"?"];
    }
    return urlStr;
}
- (NSURL *)formartUrlWithApi:(NSString *)api{
    if (![self deleteSpace:api]) {
        return [NSURL URLWithString:[self deleteSpace:self.baseUrl]];
    }
    NSString *scheme = [NSURL URLWithString:self.baseUrl].scheme;
    NSString *firstUrl = [self.baseUrl substringFromIndex:[scheme isEqualToString:@"http"]?7:8];
    firstUrl = [NSString stringWithFormat:@"%@%@",firstUrl,api];
    firstUrl = [firstUrl stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    return [NSURL URLWithString:[self deleteSpace:[NSString stringWithFormat:@"%@://%@",scheme,firstUrl]]];
}

@end
