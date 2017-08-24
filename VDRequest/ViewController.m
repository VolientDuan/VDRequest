//
//  ViewController.m
//  VDRequest
//
//  Created by baimo on 17/8/14.
//  Copyright © 2017年 zhuiyou. All rights reserved.
//

#import "ViewController.h"
#import "VDRequestManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *params = @{
                             @"key":@"201cd6c770038",
                             @"card":@"6228480402564890018"
                             };
    [[VDRequestManager defaultManager]GET:@"http://apicloud.mob.com/appstore/bank/card/query" params:params responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
        NSLog(@"\nresponse:%@\nerrorCode:%ld",[response vd_utf8],errorCode);
    }];
    
    VDRequestManager.defaultManager.GET(@"http://apicloud.mob.com/appstore/bank/card/query",params,^(id response, BOOL isSuccess, NSInteger errorCode) {
        NSLog(@"\nresponse:%@\nerrorCode:%ld",[response vd_utf8],errorCode);
    });
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
