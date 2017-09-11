//
//  NSTimer+SCD.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "NSTimer+SCD.h"

@implementation NSTimer (SCD)

#pragma mark 创建被安排的计时器

/// 创建一个计时器，在指定的时间之后调用block
+ (NSTimer *)scd_createTimerAfterInterval:(const NSTimeInterval)interval block:(SCDBlock)block {
    NSTimer *timer = [NSTimer createTimerAfterInterval:interval atHandler:block];
    [timer start];
    return timer;
}

/// 创建一个计时器，在指定的时间间隔内重复调用块
+ (NSTimer *)scd_createEveryTimerWhenInterval:(const NSTimeInterval)interval block:(SCDBlock)block {
    NSTimer *timer = [NSTimer createEveryTimerWhenInterval:interval atHandler:block];
    [timer start];
    return timer;
}

/// 创建一个计时器，在指定的时间间隔内重复调用块
/// (计时器传递给调用块)
+ (NSTimer *)scd_createEveryTimerWhenInterval:(const NSTimeInterval)interval atTimerHandler:(SCDTimerBlock)block {
    NSTimer *timer = [NSTimer createEveryTimerWhenInterval:interval atTimerHandler:block];
    [timer start];
    return timer;
}

#pragma mark 创建没有被安排的计时器

/// 创建一个计时器，在指定的时间之后调用block
///
+ (NSTimer *)createTimerAfterInterval:(const NSTimeInterval)interval atHandler:(SCDBlock)block {
    
    NSTimeInterval fireDate = CFAbsoluteTimeGetCurrent() + interval;
    CFRunLoopTimerRef timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, ^(CFRunLoopTimerRef timer) {
        block();
    });
    
    return (__bridge NSTimer *)(timer);
}

/// 创建一个计时器，在指定的时间间隔内重复调用块
///
+ (NSTimer *)createEveryTimerWhenInterval:(const NSTimeInterval)interval atHandler:(SCDBlock)block {
    
    NSTimeInterval fireDate = CFAbsoluteTimeGetCurrent() + interval;
    CFRunLoopTimerRef timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, ^(CFRunLoopTimerRef timer) {
        block();
    });
    
    return (__bridge NSTimer *)(timer);
}

/// 创建一个计时器，在指定的时间间隔内重复调用块
/// (计时器传递给调用块)
///
+ (NSTimer *)createEveryTimerWhenInterval:(const NSTimeInterval)interval atTimerHandler:(SCDTimerBlock)block {
    
    NSTimeInterval fireDate = CFAbsoluteTimeGetCurrent() + interval;
    CFRunLoopTimerRef timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, ^(CFRunLoopTimerRef timer) {
        block((__bridge NSTimer *)(timer));
    });
    
    return (__bridge NSTimer *)(timer);
}

#pragma mark 手动操作

/// 在run loop中安排计时器
///
- (void)startAtRunLoop:(NSRunLoop *)runLoop modes:(const NSArray<NSRunLoopMode> * _Nullable)modes {
    const NSArray<NSRunLoopMode> *arrayMode;
    if (modes == nil) {
        arrayMode = [NSArray arrayWithObject:NSDefaultRunLoopMode];
    } else {
        arrayMode = modes;
    }
    for (NSRunLoopMode mode in arrayMode) {
        [runLoop addTimer:self forMode:mode];
    }
}

- (void)start {
    [self startAtRunLoop:[NSRunLoop currentRunLoop] modes:nil];
}

@end
