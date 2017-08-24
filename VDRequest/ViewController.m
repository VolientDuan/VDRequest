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
    [[VDRequestManager defaultManager]GET:@"http://apicloud.mob.com/appstore/bank/card/query?key=201cd6c770038&card=487845545454544554" params:nil responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
        NSLog(@"response:%@\nerrorCode:%ld",response,errorCode);
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
