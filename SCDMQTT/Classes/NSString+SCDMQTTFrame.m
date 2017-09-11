//
//  NSString+SCDMQTTFrame.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "NSString+SCDMQTTFrame.h"

@implementation NSString (SCDMQTTFrame)

- (NSData *)bytesWithLength
{
    const char *chars = [self UTF8String];
    const size_t len = strlen(chars);
    Byte hl[] = hlBytes(len);
    NSMutableData *bytes = [NSMutableData dataWithBytes:hl length:sizeof(UInt16)];
    [bytes appendBytes:chars length:len];
    return [NSData dataWithData:bytes];
}

@end
