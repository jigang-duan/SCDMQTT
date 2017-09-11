//
//  SCDMQTTFrame.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTFrame.h"
#import "NSString+SCDMQTTFrame.h"

/**
 * MQTT Frame
 */
@implementation SCDMQTTFrame

@dynamic type;
@dynamic dup;
@dynamic qos;
@dynamic retained;

#pragma mark Init

- (instancetype)initWithHeader:(UInt8)header
{
    self = [super init];
    if (self) {
        _header.header = header;
        _variableHeader = [NSData data];
        _payload = [NSData data];
    }
    return self;
}

- (instancetype _Nonnull)initWithType:(SCDMQTTFrameType)type
{
    return [self initWithType:type variableHeader:[NSData data] payload:[NSData data]];
}

- (instancetype)initWithType:(SCDMQTTFrameType)type payload:(nonnull NSData *)payload
{
    return [self initWithType:type variableHeader:[NSData data] payload:payload];
}

- (instancetype)initWithType:(SCDMQTTFrameType)type variableHeader:(nonnull NSData *)variableHeader payload:(nonnull NSData *)payload
{
    self = [super init];
    if (self) {
        _header.bit.type = type;
        _variableHeader = [variableHeader copy];
        _payload = [payload copy];
    }
    return self;
}

+ (instancetype)frameWithHeader:(UInt8)header
{
    return [[SCDMQTTFrame alloc] initWithHeader:header];
}

+ (instancetype)frameWithType:(SCDMQTTFrameType)type payload:(nonnull NSData *)payload
{
    return [[SCDMQTTFrame alloc] initWithType:type payload:payload];
}

+ (instancetype)frameWithType:(SCDMQTTFrameType)type variableHeader:(nonnull NSData *)variableHeader payload:(nonnull NSData *)payload
{
    return [[SCDMQTTFrame alloc] initWithType:type variableHeader:variableHeader payload:payload];
}


#pragma mark getter setter

- (UInt8)type
{
    return _header.bit.type;
}

- (BOOL)isDup
{
    return Bit2Bool(_header.bit.dup);
}

- (void)setDup:(BOOL)dup
{
    _header.bit.dup = dup;
}

- (SCDMQTTQOS)qos
{
    return _header.bit.qos;
}

- (void)setQos:(SCDMQTTQOS)qos
{
    _header.bit.qos = qos;
}

- (BOOL)isRetained
{
    return Bit2Bool(_header.bit.retain);
}

- (void)setRetained:(BOOL)retained
{
    _header.bit.retain = retained;
}

#pragma mark encode

- (NSData *)data
{
    [self pack];
    NSMutableData *data = [NSMutableData dataWithBytes:&_header length:sizeof(_header)];
    [data appendData:[self encodeLength]];
    [data appendData:_variableHeader];
    [data appendData:_payload];
    return [NSData dataWithData:data];
}

- (NSData *)encodeLength
{
    NSMutableData *bytes = [NSMutableData data];
    UInt8 digit = 0;
    UInt32 len = (UInt32)_variableHeader.length + (UInt32)_payload.length;
    
    do {
        digit = len % 128;
        len = len / 128;
        if (len > 0) {
            digit = digit | 0x80;
        }
        [bytes appendBytes:&digit length:sizeof(digit)];
    } while (len > 0);
    
    return [NSData dataWithData:bytes];
}


- (void)pack
{
    return;
}

@end
