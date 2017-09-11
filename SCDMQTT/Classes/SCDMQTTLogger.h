//
//  SCDMQTTLogger.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SCDMQTTLoggerLevel) {
    SCDMQTTLoggerLevelOff,
    SCDMQTTLoggerLevelDebug,
    SCDMQTTLoggerLevelWarning,
    SCDMQTTLoggerLevelError
};

@interface SCDMQTTLogger : NSObject

+ (instancetype)sharedLogger;

@property (nonatomic, readwrite, assign) SCDMQTTLoggerLevel minLevel;

@end

void printDebug(NSString *message);
void printWarning(NSString *message);
void printError(NSString *message);

#define logDebuf(frmt, ...)         printDebug([NSString stringWithFormat:frmt, ##__VA_ARGS__])
#define logWarning(frmt, ...)       printWarning([NSString stringWithFormat:frmt, ##__VA_ARGS__])
#define logError(frmt, ...)         printError([NSString stringWithFormat:frmt, ##__VA_ARGS__])
