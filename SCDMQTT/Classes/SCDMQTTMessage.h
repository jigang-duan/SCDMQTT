//
//  SCDMQTTMessage.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCDMQTTClient.h"

@interface SCDMQTTMessage : NSObject

@property (nonatomic, readwrite, assign) SCDMQTTQOS qos;
@property (nonatomic, readwrite, assign) BOOL dup;

@property (nonatomic, readwrite, copy) NSString *topic;
@property (nonatomic, readwrite, copy) NSData *payload;
@property (nonatomic, readwrite, assign) BOOL retained;

@property (nonatomic, readonly, copy) NSString *string;

- (instancetype)initWithTopic:(NSString *)topic
                      payload:(NSData *)payload
                          qos:(SCDMQTTQOS)qos
                     retained:(BOOL)retained
                          dup:(BOOL)dup;

- (instancetype)initWithTopic:(NSString *)topic payload:(NSData *)payload;

- (instancetype)initWithTopic:(NSString *)topic
                       string:(NSString *)string
                          qos:(SCDMQTTQOS)qos
                     retained:(BOOL)retained
                          dup:(BOOL)dup;

- (instancetype)initWithTopic:(NSString *)topic string:(NSString *)string;

+ (instancetype)messageWithTopic:(NSString *)topic
                         payload:(NSData *)payload
                             qos:(SCDMQTTQOS)qos
                        retained:(BOOL)retained
                             dup:(BOOL)dup;
@end


@interface SCDMQTTWill : SCDMQTTMessage
@end
