//
//  VDResponse.m
//  VDRequest
//
//  Created by baimo on 17/8/16.
//  Copyright © 2017年 zhuiyou. All rights reserved.
//

#import "VDResponse.h"
@implementation NSObject(VD_UTF8)

- (NSString *)vd_utf8{
    NSString *desc = [self description];
    desc = [NSString stringWithCString:[desc cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    return desc;
}

@end

@interface VDResponse()<NSXMLParserDelegate>

@property (nonatomic, strong)NSMutableArray *xmlDataArray;
@property (nonatomic, strong)NSMutableDictionary *xmlDataDictionary;
@property (nonatomic, strong)NSString *xmlCharacter;

@end

@implementation VDResponse
- (NSString *)xmlCharacter{
    if (!_xmlCharacter) {
        _xmlCharacter = @"";
    }
    return _xmlCharacter;
}
- (NSMutableArray *)xmlDataArray{
    if (!_xmlDataArray) {
        _xmlDataArray = [NSMutableArray array];
    }
    return _xmlDataArray;
}
- (NSMutableDictionary *)xmlDataDictionary{
    if (!_xmlDataDictionary) {
        _xmlDataDictionary = [NSMutableDictionary dictionary];
    }
    return _xmlDataDictionary;
}
/**
 json返回数据处理
 
 @param response 返回数据
 @return 返处理后的JSON返回数据
 */
- (id)responseObjectJsonHandle:(NSData *)response{
    if (response == nil) {
        return nil;
    }
    id jsonObject = [NSJSONSerialization JSONObjectWithData:response
                                                    options:NSJSONReadingMutableContainers
                                                      error:nil];
    if (!jsonObject) {
        jsonObject = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    }
    return jsonObject;
}
- (id)responseObjectXMLHandle:(NSData *)response{
    if (response == nil) {
        return nil;
    }
    NSXMLParser *parser = [[NSXMLParser alloc]initWithData:response];
    parser.delegate = self;
    [parser setShouldResolveExternalEntities:YES];
    BOOL isSuccess = [parser parse];
    if (isSuccess) {
        
    }else{
        NSLog(@"\n【VDResponse】xml response parsing failure!");
    }
    id xmlObject = nil;
    xmlObject = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    return xmlObject;
}
- (id (^)(NSData *))responseHandle{
    return ^id(NSData *data){
        if (self.type == VDResponseTypeJson) {
            return [self responseObjectJsonHandle:data];
        }else if(self.type == VDResponseTypeXml){
            return [self responseObjectXMLHandle:data];
        }
        return nil;
    };
}

#pragma mark XML Parser Delegate
- (NSString *)deleteSpace:(NSString *)str{
    if (!str) {
        return nil;
    }
    NSString *str1= [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return [str2 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"" forKey:elementName];
    [self.xmlDataArray addObject:dic];
    NSLog(@"didStartElement:%@",elementName);
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    NSLog(@"foundCharacters:%@",string);
    self.xmlCharacter = [self deleteSpace:string];
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    NSLog(@"didEndElement:%@",elementName);
    NSMutableDictionary *dic = self.xmlDataArray[self.xmlDataArray.count-1];
    dic[elementName] = self.xmlCharacter;
    if (self.xmlDataArray.count > 1) {
        NSMutableDictionary *supDic = self.xmlDataArray[self.xmlDataArray.count-2];
        id value = supDic[supDic.allKeys[0]];
        if ([value isKindOfClass:[NSString class]]) {
            supDic[supDic.allKeys[0]] = dic;
        }
        [self.xmlDataArray removeObjectAtIndex:self.xmlDataArray.count-1];
    }
    NSLog(@"--------");
}
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    NSLog(@"-------parserDidEndDocument-------");
    
}

@end
