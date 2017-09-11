//
//  NSData+SCDMQTTReader.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "NSData+SCDMQTTReader.h"

@implementation NSData (NSData_SCDMQTTReader)

- (Byte)byteAtIndex:(NSUInteger)index
{
    if (self.length <= index) {
        return 0;
    }
    const Byte *bytes = self.bytes;
    return bytes[index];
}

- (UInt16)msgid
{
    if (self.length < 2) {
        return 0;
    }
    const Byte *bytes = self.bytes;
    return ((UInt16)bytes[0] << 8) + (UInt16)bytes[1];
}

@end
