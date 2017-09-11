//
//  NSTimer+SCD.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SCDBlock)();
typedef void(^SCDTimerBlock)(NSTimer *);

@interface NSTimer (SCD)

/// 创建一个计时器，在指定的时间之后调用block
+ (NSTimer *)scd_createTimerAfterInterval:(const NSTimeInterval)interval block:(SCDBlock)block;

/// 创建一个计时器，在指定的时间间隔内重复调用块
+ (NSTimer *)scd_createEveryTimerWhenInterval:(const NSTimeInterval)interval block:(SCDBlock)block;

/// 创建一个计时器，在指定的时间间隔内重复调用块
/// (计时器传递给调用块)
+ (NSTimer *)scd_createEveryTimerWhenInterval:(const NSTimeInterval)interval atTimerHandler:(SCDTimerBlock)block;

@end


#define SCD_MilliSecond(interval)           (interval / 1000)
#define SCD_MilliSeconds(interval)          (interval / 1000)
#define SCD_MS(interval)                    (interval / 1000)

#define SCD_Second(interval)                (interval)
#define SCD_Seconds(interval)               (interval)

#define SCD_Minute(interval)                (interval * 60)
#define SCD_Minutes(interval)               (interval * 60)

#define SCD_Hour(interval)                  (interval * 3600)
#define SCD_Hours(interval)                 (interval * 3600)

#define SCD_Day(interval)                   (interval * 3600 * 24)
#define SCD_Days(interval)                  (interval * 3600 * 24)
