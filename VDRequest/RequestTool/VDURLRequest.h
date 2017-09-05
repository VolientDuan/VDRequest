//
//  VDURLRequest.h
//  VDRequest
//
//  Created by baimo on 17/8/16.
//  Copyright © 2017年 zhuiyou. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, VDRequestType){
    VDRequestTypeJson = 0,
    VDRequestTypeFormData
};
@interface VDURLRequest : NSMutableURLRequest
@property (nonatomic, strong)NSString *baseUrl;
@property (nonatomic, strong)NSString *contentType;
@property (nonatomic, assign)VDRequestType requestType;

- (instancetype)init;//默认为json

- (void)addHeaderValue:(NSString *)value forKey:(NSString *)key;
- (VDURLRequest *(^)(NSString *method, VDRequestType type, NSString *api, id params))set;

@end
