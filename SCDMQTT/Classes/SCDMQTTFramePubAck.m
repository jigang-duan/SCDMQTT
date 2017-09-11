//
//  SCDMQTTFramePubAck.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTFramePubAck.h"
#import "SCDMQTTClient.h"
#import "NSString+SCDMQTTFrame.h"

/**
 * MQTT PUBACK Frame
 */
@implementation SCDMQTTFramePubAck

#pragma mark Init

- (instancetype)initWithType:(SCDMQTTFrameType)type msgid:(UInt16)msgid
{
    self = [super initWithType:type];
    if (self) {
        if (type == SCDMQTTFrameTypePubrel) {
            self.qos = SCDMQTTQOS1;
        }
        _msgid = msgid;
    }
    return self;
}

#pragma mark override

- (void)pack
{
    NSMutableData *header = [NSMutableData dataWithData:self.variableHeader];
    Byte hlMsgid[] = hlBytes(_msgid);
    [header appendBytes:hlMsgid length:sizeof(UInt16)];
    self.variableHeader = [NSData dataWithData:header];
}

@end
