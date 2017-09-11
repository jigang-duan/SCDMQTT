//
//  NSData+SCDMQTTReader.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSData_SCDMQTTReader)

- (Byte)byteAtIndex:(NSUInteger)index;
- (UInt16)msgid;

@end

#define SCD_MB(val)     (val * 1024 * 1024)
