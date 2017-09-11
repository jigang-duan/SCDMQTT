//
//  SCDMQTTLogger.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTLogger.h"

@implementation SCDMQTTLogger

+ (instancetype)sharedLogger
{
    static SCDMQTTLogger *__sharedLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedLogger = [[self alloc] init];
    });
    return __sharedLogger;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _minLevel = SCDMQTTLoggerLevelWarning;
    }
    return self;
}

- (void)logWithLevel:(SCDMQTTLoggerLevel)level message:(NSString *)message
{
    if (level >= _minLevel) {
        NSLog(@"SCDMQTT(%lu): %@", (unsigned long)level, message);
    }
}

- (void)debugWithMessage:(NSString *)message
{
    [self logWithLevel:SCDMQTTLoggerLevelDebug message:message];
}

- (void)warningWithMessage:(NSString *)message
{
    [self logWithLevel:SCDMQTTLoggerLevelWarning message:message];
}

- (void)errorWithMessage:(NSString *)message
{
    [self logWithLevel:SCDMQTTLoggerLevelError message:message];
}

@end

void printDebug(NSString *message)
{
    [SCDMQTTLogger.sharedLogger debugWithMessage:message];
}

void printWarning(NSString *message)
{
    [SCDMQTTLogger.sharedLogger warningWithMessage:message];
}

void printError(NSString *message)
{
    [SCDMQTTLogger.sharedLogger errorWithMessage:message];
}

