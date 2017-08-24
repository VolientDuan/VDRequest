# VDRequest
一个基于原生网络框架NSURLSession的请求封装，包含一般HTTP请求(回调默认为JSON解析)和表单上传文件(支持多文件)

### 如何导入：
##### CocoaPods
已安装CocoaPods:`pod 'VDRequest'`
##### 直接下载
下载此项目后将`RequestTool`中的文件拖到需要添加的项目中，其中包含：

* VDRequest.h
* VDRequest.m
* VDResponse.h
* VDResponse.m
* VDRequestManager.h
* VDRequestManager.m

### 如何使用：
#### 以GET请求方法为例

````
NSDictionary *params = @{
                             @"key":@"201cd6c770038",
                             @"card":@"6228480402564890018"
                             };
    [[VDRequestManager defaultManager]GET:@"http://apicloud.mob.com/appstore/bank/card/query" params:params responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
        NSLog(@"\nresponse:%@\nerrorCode:%ld",[response vd_utf8],errorCode);
    }];
````

#### 对应的链式方法如下：

```
NSDictionary *params = @{
                             @"key":@"201cd6c770038",
                             @"card":@"6228480402564890018"
                             };
VDRequestManager.defaultManager.GET(@"http://apicloud.mob.com/appstore/bank/card/query",params,^(id response, BOOL isSuccess, NSInteger errorCode) {
        NSLog(@"\nresponse:%@\nerrorCode:%ld",[response vd_utf8],errorCode);
    });
```
请求结果示例：

![请求结果示例](https://github.com/VolientDuan/VDRequest/sources/img/eg/get_response.png)