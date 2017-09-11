//
//  SCDMQTTFramePubAck.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTFrame.h"

/**
 * MQTT PUBACK Frame
 */
@interface SCDMQTTFramePubAck : SCDMQTTFrame

@property (nonatomic, readwrite, assign) UInt16 msgid;

- (instancetype)initWithType:(SCDMQTTFrameType)type msgid:(UInt16)msgid;

@end
