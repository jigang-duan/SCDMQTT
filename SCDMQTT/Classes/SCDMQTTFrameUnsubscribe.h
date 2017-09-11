//
//  SCDMQTTFrameUnsubscribe.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTFrame.h"

@interface SCDMQTTFrameUnsubscribe : SCDMQTTFrame

@property (nonatomic, readwrite, assign) UInt16 msgid;
@property (nonatomic, readwrite, copy) NSString *topic;

- (instancetype)initWithMsgid:(UInt16)msgid topic:(NSString *)topic;

@end
