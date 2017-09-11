//
//  SCDMQTTFramePublish.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTFramePublish.h"
#import "SCDMQTTLogger.h"
#import "NSString+SCDMQTTFrame.h"

@implementation SCDMQTTFramePublish

#pragma mark Init

- (instancetype)initWithMsgid:(UInt16)msgid topic:(NSString *)topic payload:(NSData *)payload
{
    self = [super initWithType:SCDMQTTFrameTypePublish payload:payload];
    if (self) {
        _msgid = msgid;
        _topic = [topic copy];
    }
    return self;
}

- (instancetype)initWithHeader:(UInt8)header data:(NSData *)data
{
    self = [super initWithHeader:header];
    if (self) {
        _data = [data copy];
    }
    return self;
}

- (void)unpack
{
    _msgid = 0;
    
    // topic
    if (_data == nil || _data.length < 2) {
        logWarning(@"无效格式的接收消息.");
        return;
    }
    
    const UInt8 *bytes = _data.bytes;
    UInt8 msb = bytes[0];
    UInt8 lsb = bytes[1];
    const UInt16 len = ((UInt16)msb << 8) + (UInt16)lsb;
    int pos = 2 + (int)len;
    
    if (_data.length < pos) {
        logWarning(@"无效格式的接收消息.");
        return;
    }
    
    _topic = [[NSString alloc] initWithBytes:(bytes+2) length:len encoding:NSUTF8StringEncoding];
    
    // msgid
    if (self.header.bit.qos != 0) {
        if (_data.length < pos + 2) {
            logWarning(@"无效格式的接收消息.");
            return;
        }
        msb = bytes[pos];
        lsb = bytes[pos + 1];
        pos += 2;
        _msgid = ((UInt16)msb << 8) + (UInt16)lsb;
    }
    
    // plyload
    int end = (int)(_data.length - 1);
    if ((end - pos) >= 0) {
        self.payload = [NSData dataWithBytes:(bytes + pos) length:end - pos];
    } else {
        self.payload = [NSData data];
    }
}

#pragma mark override

- (void)pack
{
    // variable header
    NSMutableData *header = [NSMutableData dataWithData:self.variableHeader];
    [header appendData:[_topic bytesWithLength]];
    if (self.header.bit.qos > 0) {
        Byte hlMsgid[] = hlBytes(_msgid);
        [header appendBytes:hlMsgid length:sizeof(UInt16)];
    }
    self.variableHeader = [NSData dataWithData:header];
}

@end
