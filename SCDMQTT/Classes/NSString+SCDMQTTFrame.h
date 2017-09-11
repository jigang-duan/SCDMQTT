//
//  NSString+SCDMQTTFrame.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SCDMQTTFrame)

- (NSData *_Nonnull)bytesWithLength;

@end

#define HightByte(val)          (Byte)((val & 0xFF00) >> 8)
#define LowByte(val)            (Byte)(val & 0x00FF)
#define hlBytes(val)            { HightByte(val), LowByte(val) }

#define Bool2Bit(val)           (Byte)(val ? 1 : 0)
#define Bit2Bool(bit)           ((bit == 0) ? NO : YES)
#define bitAt(val, offset)      ((val >> offset) & 0x01)
