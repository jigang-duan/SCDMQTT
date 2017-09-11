//
//  SCDMQTTFrameUnsubscribe.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTFrameUnsubscribe.h"
#import "SCDMQTTClient.h"
#import "NSString+SCDMQTTFrame.h"

@implementation SCDMQTTFrameUnsubscribe

#pragma mark Init

- (instancetype)initWithMsgid:(UInt16)msgid topic:(NSString *)topic
{
    self = [super initWithType:SCDMQTTFrameTypeUnsubscribe];
    if (self) {
        _msgid = msgid;
        _topic = [topic copy];
        self.qos = SCDMQTTQOS1;
    }
    return self;
}

#pragma mark override

- (void)pack
{
    // variable header
    NSMutableData *header = [NSMutableData dataWithData:self.variableHeader];
    Byte hlMsgid[] = hlBytes(_msgid);
    [header appendBytes:hlMsgid length:sizeof(UInt16)];
    self.variableHeader = [NSData dataWithData:header];
    
    // payload
    NSMutableData *pld = [NSMutableData dataWithData:self.payload];
    [pld appendData:[_topic bytesWithLength]];
    self.payload = [NSData dataWithData:pld];
}

@end
