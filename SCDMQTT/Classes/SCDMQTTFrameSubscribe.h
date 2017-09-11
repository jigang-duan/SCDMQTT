//
//  SCDMQTTFrameSubscribe.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTFrame.h"

/**
 * MQTT SUBSCRIBE Frame
 */
@interface SCDMQTTFrameSubscribe : SCDMQTTFrame

@property (nonatomic, readwrite, assign) UInt16 msgid;
@property (nonatomic, readwrite, copy) NSString *topic;
@property (nonatomic, readwrite, assign) SCDMQTTQOS reqos;

- (instancetype)initWithMsgid:(UInt16)msgid topic:(NSString *)topic reqos:(SCDMQTTQOS)reqos;

@end
