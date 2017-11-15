//
//  VDResponse.h
//  VDRequest
//
//  Created by baimo on 17/8/16.
//  Copyright © 2017年 zhuiyou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VDRequestError) {
    VDRequestErrorURL = 11111,
    VDRequestErrorUnknown
};

@interface NSObject(VD_UTF8)
- (NSString *)vd_utf8;
@end

/*普通请求回调*/
typedef void (^VDResponseBlock)(id response, BOOL isSuccess, NSInteger errorCode);

typedef NS_ENUM(NSInteger, VDResponseType){
    VDResponseTypeJson = 0,
    VDResponseTypeXml
};

@interface VDResponse : NSObject
@property (nonatomic, assign)VDResponseType type;
@property (nonatomic, strong)NSURLResponse *currentResponse;
@property (nonatomic, strong)NSError *currentError;
- (id (^)(NSData *data))responseHandle;

@end


