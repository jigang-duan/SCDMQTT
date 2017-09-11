//
//  SCDMQTTMessage.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTMessage.h"

@implementation SCDMQTTMessage

- (instancetype)initWithTopic:(NSString *)topic
                      payload:(NSData *)payload
                          qos:(SCDMQTTQOS)qos
                     retained:(BOOL)retained
                          dup:(BOOL)dup
{
    self = [super init];
    if (self) {
        _topic = [topic copy];
        _payload = [payload copy];
        _qos = qos;
        _retained = retained;
        _dup = dup;
    }
    return self;
}

- (instancetype)initWithTopic:(NSString *)topic payload:(NSData *)payload
{
    return [self initWithTopic:topic payload:payload qos:SCDMQTTQOS1 retained:NO dup:NO];
}

- (instancetype)initWithTopic:(NSString *)topic
                       string:(NSString *)string
                          qos:(SCDMQTTQOS)qos
                     retained:(BOOL)retained
                          dup:(BOOL)dup
{
    return [self initWithTopic:topic payload:[string dataUsingEncoding:NSUTF8StringEncoding] qos:qos retained:retained dup:dup];
}

- (instancetype)initWithTopic:(NSString *)topic string:(NSString *)string
{
    return [self initWithTopic:topic string:string qos:SCDMQTTQOS1 retained:NO dup:NO];
}

+ (instancetype)messageWithTopic:(NSString *)topic
                         payload:(NSData *)payload
                             qos:(SCDMQTTQOS)qos
                        retained:(BOOL)retained
                             dup:(BOOL)dup
{
    return [[self alloc] initWithTopic:topic payload:payload qos:qos retained:retained dup:dup];
}

- (NSString *)string {
    return [[NSString alloc] initWithData:_payload encoding:NSUTF8StringEncoding];
}

@end


@implementation SCDMQTTWill

- (instancetype)initWithTopic:(NSString *)topic message:(NSString *)message
{
    self = [super initWithTopic:topic string:message];
    if (self) {
    }
    return self;
}

@end
