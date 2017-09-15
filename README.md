# VDRequest
一个基于原生网络框架NSURLSession的请求封装，普通的HTTP请求支持JSON和XML解析(默认为JSON解析)和表单上传文件(支持多文件)

## 如何导入：
### CocoaPods
#### 已安装CocoaPods:
在项目的`Podfile`文件中加入`pod 'VDRequest', '~> 1.0.4'`后进入文件目录`pod install`,如果失败建议`pod update`
#### 直接下载
下载此项目后将`RequestTool`中的文件拖到需要添加的项目中，其中包含一下六个文件：

1. `VDRequest.h`
2. `VDRequest.m`
3. `VDResponse.h`
4. `VDResponse.m`
5. `VDRequestManager.h`
6. `VDRequestManager.m`

## 如何使用：
### 以GET请求方法为例

````
NSDictionary *params = @{
                             @"key":@"201cd6c770038",
                             @"card":@"6228480402564890018"
                             };
    [[VDRequestManager defaultManager]GET:@"http://apicloud.mob.com/appstore/bank/card/query" params:params responseBlock:^(id response, BOOL isSuccess, NSInteger errorCode) {
        NSLog(@"\nresponse:%@\nerrorCode:%ld",[response vd_utf8],errorCode);
    }];
````

### 对应的链式方法如下：

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

![请求结果示例](https://github.com/VolientDuan/VDRequest/blob/master/sources/img/eg/get_response.png)


