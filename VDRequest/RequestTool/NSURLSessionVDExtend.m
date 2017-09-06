//
//  NSURLSessionVDExtend.m
//  VDRequest
//
//  Created by baimo on 17/9/6.
//  Copyright © 2017年 zhuiyou. All rights reserved.
//

#import "NSURLSessionVDExtend.h"

@implementation NSURLSession (NSURLSessionVDExtend)
+ (NSURLSession *)sessionWithDelegate:(id<NSURLSessionDelegate>)delegate{

    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 1;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:delegate delegateQueue:operationQueue];
    return session;
}
@end
