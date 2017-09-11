//
//  SCDMQTTReader.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTReader.h"
#import "SCDMQTTMessage.h"
#import "SCDMQTTFramePublish.h"
#import "NSData+SCDMQTTReader.h"
#import "CocoaAsyncSocket/GCDAsyncSocket.h"

@implementation SCDMQTTReader {
    
    GCDAsyncSocket *_socket;
    SCDMQTTFrameHeader _header;
    NSUInteger _length;
    NSData *_data;
    int _multiply;
    id<SCDMQTTReaderDelegate> _delegate;
    NSTimeInterval _timeout;
}

#pragma mark Init

- (instancetype)initWithAsyncSocket:(GCDAsyncSocket *)socket delegate:(id<SCDMQTTReaderDelegate>)delegate
{
    self = [super init];
    if (self) {
        _socket = socket;
        _delegate = delegate;
        _header.header = 0;
        _length = 0;
        _data = [NSData data];
        _multiply = 1;
        _timeout = 30000.0;
    }
    return self;
}

#pragma mark public function

- (void)start
{
    [self readHeader];
}

- (void)headerReady:(UInt8)header
{
    logDebuf(@"准备读头: %d", header);
    _header.header = header;
    [self readLength];
}

- (void)lengthReady:(UInt8)byte
{
    _length += (NSUInteger)((int)(byte & 127) * _multiply);
    //done
    if ((byte & 0x80) == 0) {
        if (_length == 0) {
            [self frameReady];
        } else {
            [self readPayload];
        }
    } else {
        // more
        _multiply *= 128;
        [self readLength];
    }
}

- (void)payloadReady:(NSData *)data
{
    _data = [data copy];
    [self frameReady];
}

#pragma mark private function

- (void)readHeader
{
    [self reset];
    [_socket readDataToLength:1 withTimeout:-1 tag:SCDMQTTReadTagHeader];
}

- (void)readLength
{
    [_socket readDataToLength:1 withTimeout:_timeout tag:SCDMQTTReadTagLength];
}

- (void)readPayload
{
    [_socket readDataToLength:_length withTimeout:_timeout tag:SCDMQTTReadTagPayload];
}


- (void)frameReady
{
    UInt16 i_msgid = 0;
    SCDMQTTMessage *message = nil;
    
    // handle frame
    switch (_header.bit.type) {
        case SCDMQTTFrameTypeConnack:
            [_delegate didReceiveConnAck:self connack:[_data byteAtIndex:1]];
            break;
        case SCDMQTTFrameTypePublish:
            message = [self unpackPublishOutputMsgid:&i_msgid];
            if (message) {
                [_delegate didReceivePublish:self message:message msgid:i_msgid];
            }
            break;
        case SCDMQTTFrameTypePuback:
            [_delegate didReceivePubAck:self msgid:[_data msgid]];
            break;
        case SCDMQTTFrameTypePubrec:
            [_delegate didReceivePubRec:self msgid:[_data msgid]];
            break;
        case SCDMQTTFrameTypePubrel:
            [_delegate didReceivePubRel:self msgid:[_data msgid]];
            break;
        case SCDMQTTFrameTypePubcomp:
            [_delegate didReceivePubComp:self msgid:[_data msgid]];
            break;
        case SCDMQTTFrameTypeSuback:
            [_delegate didReceiveSubAck:self msgid:[_data msgid]];
            break;
        case SCDMQTTFrameTypeUnsuback:
            [_delegate didReceiveUnsubAck:self msgid:[_data msgid]];
            break;
        case SCDMQTTFrameTypePingresp:
            [_delegate didReceivePong:self];
            break;
        default:
            break;
    }
    
    [self readHeader];
}


- (SCDMQTTMessage *)unpackPublishOutputMsgid:(UInt16 *)pmsgid
{
    SCDMQTTFramePublish *frame = [[SCDMQTTFramePublish alloc] initWithHeader:_header.header data:_data];
    [frame unpack];
    
    UInt16 msgid = frame.msgid;
    if (msgid) {
        *pmsgid = 0;
        return nil;
    }
    
    *pmsgid = msgid;
    return [SCDMQTTMessage messageWithTopic:frame.topic payload:frame.payload qos:frame.qos retained:frame.retained dup:frame.dup];
}

- (void)reset
{
    _length = 0;
    _multiply = 1;
    _header.header = 0;
    _data = [NSData data];
}

inline UInt16 msgid(NSData *data)
{
    if (data.length < 2) {
        return 0;
    }
    const Byte *bytes = data.bytes;
    return ((UInt16)bytes[0] << 8) + (UInt16)bytes[1];
}

@end
