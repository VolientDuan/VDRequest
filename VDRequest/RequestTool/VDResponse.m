//
//  VDResponse.m
//  VDRequest
//
//  Created by baimo on 17/8/16.
//  Copyright © 2017年 zhuiyou. All rights reserved.
//

#import "VDResponse.h"
@interface VDResponse()<NSXMLParserDelegate>

@end
@implementation VDResponse
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
    [parser parse];
    NSLog(@"\n【VDResponse】xml response is develping!");
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
- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment{
    
}
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock{
    
}
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    
}
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    
}
- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI{
    
    
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
}
- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix{
    
}
@end
