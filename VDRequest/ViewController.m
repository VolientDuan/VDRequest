//
//  ViewController.m
//  VDRequest
//
//  Created by baimo on 17/8/14.
//  Copyright © 2017年 zhuiyou. All rights reserved.
//

#import "ViewController.h"
#import "VDRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //请求方法调用示例
    NSDictionary *params = @{
                             @"key":@"201cd6c770038",
                             @"card":@"6228480402564890018"
                             };
    
    [VDRequest.defaultManager.request addHeaderValue:@"YES" forKey:@"test"];
    
    VDRequest.defaultManager.GET(@"http://apicloud.mob.com/appstore/bank/card/query",params,^(id response, BOOL isSuccess, NSInteger errorCode) {
        NSLog(@"\nresponse:%@\nerrorCode:%ld",[response vd_utf8],errorCode);
        NSLog(@"\nrequest:%@",VDRequest.defaultManager.currentRequest.vd_utf8);
    });
    
    // xml解析示例(没去找免费xml接口了直接本地解析吧)
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"person.xml" ofType:nil]];
    VDResponse *resp = [[VDResponse alloc]init];
    resp.type = VDResponseTypeXml;
    id result = resp.responseHandle(data);
    NSLog(@"reslut:%@",[result vd_utf8]);
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
