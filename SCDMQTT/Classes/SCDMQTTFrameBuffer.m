//
//  SCDMQTTFrameBuffer.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTFrameBuffer.h"
#import "SCDMQTTLogger.h"
#import "SCDMQTTFramePublish.h"
#import "NSTimer+SCD.h"

@implementation SCDMQTTFrameBuffer {
    
    NSMutableArray<SCDMQTTFramePublish *> *_silos;
    NSMutableArray<SCDMQTTFramePublish *> *_buffer;
    NSUInteger _bufferSize;
}

@dynamic bufferEmpty;
@dynamic bufferFull;
@dynamic silosFull;

#pragma mark Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        _silos = [NSMutableArray array];
        _buffer = [NSMutableArray array];
        _bufferSize = 1000;
        _silosMaxNumber = 10;
        _timeout = 60.0;
    }
    return self;
}

+ (instancetype)buffer
{
    return [[self alloc] init];
}

#pragma mark getter setter
- (BOOL)isBufferEmpty
{
    return _buffer.count == 0;
}

- (BOOL)isBufferFull
{
    return _buffer.count >= _bufferSize;
}

- (BOOL)isSilosFull
{
    return _silos.count >= _silosMaxNumber;
}


#pragma mark public function

// //返回NO 意味着框架被拒绝，因为缓冲区满了
- (BOOL)addPublishFrame:(SCDMQTTFramePublish *)frame
{
    if (!self.bufferFull) {
        logDebuf(@"缓冲区已经满了，消息(%d)被废弃了。", frame.msgid);
        return NO;
    }
    
    [_buffer addObject:frame];
    [self tryTransport];
    return YES;
}

- (void)sendSuccessWithMsgid:(UInt16)msgid
{
    __weak typeof(self) _wself = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        __strong typeof(self) _sself = _wself;
        if (_sself) {
            [_sself removeFrameFormSilosWithMsgid:msgid];
            logDebuf(@"发送Frame成功: %d", msgid);
        }
    });
}

#pragma mark private function

//尝试将一个Frame从缓冲区传输到筒仓
- (void)tryTransport
{
    if (self.bufferEmpty || self.silosFull) {
        return;
    }
    
    //取出最早的帧
    SCDMQTTFramePublish * frame = _buffer[0];
    [_buffer removeObjectAtIndex:0];
    
    [self sendPublishFrame: frame];
    
    [NSTimer scd_createTimerAfterInterval:SCD_Second(_timeout) block:^{
        UInt16 msgid = frame.msgid;
        if ([self removeFrameFormSilosWithMsgid:msgid]) {
            logDebuf(@"超时的Frame: %d", msgid);
        }
    }];
    
    //在运输后继续尝试
    if (frame.qos == 0) {
        [self tryTransport];
    } else {
        [_silos addObject:frame];
        if (self.silosFull) {
            [self tryTransport];
        }
    }
}

- (void)sendPublishFrame:(SCDMQTTFramePublish *)frame
{
    if (_delegate) {
        [_delegate buffer:self sendPublishFrame:frame];
    }
}

- (BOOL)removeFrameFormSilosWithMsgid:(UInt16)msgid
{
    BOOL success = NO;
    for (SCDMQTTFramePublish *item in _silos) {
        if (item.msgid == msgid) {
            success = YES;
            [_silos removeObject:item];
            [self tryTransport];
            break;
        }
    }
    return success;
}

@end
