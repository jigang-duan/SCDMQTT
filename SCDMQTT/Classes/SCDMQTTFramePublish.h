//
//  SCDMQTTFramePublish.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTFrame.h"

@interface SCDMQTTFramePublish : SCDMQTTFrame

@property (nonatomic, readwrite, assign) UInt16 msgid;
@property (nonatomic, readwrite, copy) NSString *topic;
@property (nonatomic, readwrite, copy) NSData *data;

- (instancetype)initWithMsgid:(UInt16)msgid topic:(NSString *)topic payload:(NSData *)payload;
- (instancetype)initWithHeader:(UInt8)header data:(NSData *)data;

- (void)unpack;

@end
