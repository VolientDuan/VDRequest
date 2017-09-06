//
//  NSURLSessionVDExtend.h
//  VDRequest
//
//  Created by baimo on 17/9/6.
//  Copyright © 2017年 zhuiyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (NSURLSessionVDExtend)
+ (NSURLSession *)sessionWithDelegate:(id<NSURLSessionDelegate>)delegate;

@end
