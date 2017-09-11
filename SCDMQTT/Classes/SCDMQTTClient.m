//
//  SCDMQTTClient.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTClient.h"
#import "SCDMQTTFrame.h"
#import "SCDMQTTFramePublish.h"
#import "SCDMQTTFrameConnect.h"
#import "SCDMQTTFramePubAck.h"
#import "SCDMQTTFrameSubscribe.h"
#import "SCDMQTTFrameUnsubscribe.h"
#import "SCDMQTTMessage.h"
#import "SCDMQTTReader.h"
#import "NSData+SCDMQTTReader.h"
#import "NSTimer+SCD.h"

@implementation SCDMQTTClient {
    
    SCDMQTTFrameBuffer *_buffer;
    
    NSTimer *_aliveTimer;
    
    NSTimer *_autoReconnTimer;
    BOOL _disconnectExpectedly;
    
    NSMutableDictionary<NSNumber *, NSDictionary<NSString *, NSNumber *> *> *_subscriptionsWaitingAck;
    NSMutableDictionary<NSNumber *, NSDictionary<NSString *, NSNumber *> *> *_unsubscriptionsWaitingAck;
    
    // global message id
    UInt16 _gmid;
    GCDAsyncSocket *_socket;
    SCDMQTTReader *_reader;
}

@dynamic bufferSilosTimeout, bufferSilosMaxNumber;
@dynamic logLevel;

- (instancetype)initWithClientID:(NSString *)clientID host:(NSString *)host post:(UInt16)post
{
    self = [super init];
    if (self) {
        _host = [host copy];
        _port = post;
        _clientID = clientID;
        _secureMQTT = NO;
        _cleanSession = YES;
        _backgroundOnSocket = NO;
        _connState = SCDMQTTConnStateInitial;
        _dispatchQueue = dispatch_get_main_queue();
        
        _buffer = [SCDMQTTFrameBuffer buffer];
        _buffer.delegate = self;
        
        _keepAlive = 60;
        
        _autoReconnect = NO;
        _autoReconnectTimeInterval = 20.0;
        _disconnectExpectedly = NO;
        
        _enableSSL = NO;
        _allowUntrustCACertificate = NO;
        
        _subscriptions = [NSMutableDictionary dictionary];
        _subscriptionsWaitingAck = [NSMutableDictionary dictionary];
        _unsubscriptionsWaitingAck = [NSMutableDictionary dictionary];
        
        _gmid = 1;
        _socket = [[GCDAsyncSocket alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_aliveTimer invalidate];
    [_autoReconnTimer invalidate];
    
    _socket.delegate = nil;
    [_socket disconnect];
}

#pragma mark getter setter

- (NSTimeInterval)bufferSilosTimeout
{
    return _buffer.timeout;
}

- (void)setBufferSilosTimeout:(NSTimeInterval)newValue
{
    _buffer.timeout = newValue;
}

- (NSUInteger)bufferSilosMaxNumber
{
    return _buffer.silosMaxNumber;
}

- (void)setBufferSilosMaxNumber:(NSUInteger)newValue
{
    _buffer.silosMaxNumber = newValue;
}

- (SCDMQTTLoggerLevel)logLevel
{
    return [SCDMQTTLogger sharedLogger].minLevel;
}

- (void)setLogLevel:(SCDMQTTLoggerLevel)newValue
{
    [SCDMQTTLogger sharedLogger].minLevel = newValue;
}

#pragma mark public function

- (BOOL)connect
{
    [_socket setDelegate:self delegateQueue:_dispatchQueue];
    _reader = [[SCDMQTTReader alloc] initWithAsyncSocket:_socket delegate:self];
    
    NSError *error;
    if (![_socket connectToHost:_host onPort:_port error:&error]) {
        logError(@"socket 连接错误: %@", error.description);
        return NO;
    }
    
    _connState = SCDMQTTConnStateConnecting;
    return YES;
}

- (void)disconnect
{
    _disconnectExpectedly = NO;
    [self internal_disconnect];
}

- (void)internal_disconnect
{
    [self sendFrame:[[SCDMQTTFrame alloc] initWithType:SCDMQTTFrameTypeDisconnect]  tag:-0xE0];
    [_socket disconnect];
}

- (void)ping
{
    logDebuf(@"ping");
    [self sendFrame:[[SCDMQTTFrame alloc] initWithType:SCDMQTTFrameTypePingreq]  tag:-0xC0];
    if (_delegate) {
        [_delegate mqttDidPing:self];
    }
}

- (UInt16)publishWithTopic:(NSString *)topic string:(NSString *)string qos:(SCDMQTTQOS)qos retained:(BOOL)retained dup:(BOOL)dup
{
    SCDMQTTMessage *message = [[SCDMQTTMessage alloc] initWithTopic:topic string:string qos:qos retained:retained dup:dup];
    return [self publishWithMessage:message];
}

- (UInt16)publishWithMessage:(SCDMQTTMessage *)message
{
    UInt16 msgid = [self nextMessageID];
    SCDMQTTFramePublish *frame = [[SCDMQTTFramePublish alloc] initWithMsgid:msgid topic:message.topic payload:message.payload];
    frame.qos = message.qos;
    frame.retained = message.retained;
    frame.dup = message.dup;
    [_buffer addPublishFrame:frame];
    
    if (_delegate) {
        [_delegate mqtt:self didPublishMessage:message msgid:msgid];
    }
    
    return msgid;
}

- (UInt16)subscribeWithTopic:(NSString *)topic qos:(SCDMQTTQOS)qos
{
    UInt16 msgid = [self nextMessageID];
    SCDMQTTFrameSubscribe *frame = [[SCDMQTTFrameSubscribe alloc] initWithMsgid:msgid topic:topic reqos:qos];
    [self sendFrame:frame tag:msgid];
    _unsubscriptionsWaitingAck[[NSNumber numberWithUnsignedShort:msgid]] = @{topic: [NSNumber numberWithUnsignedChar:qos]};
    return msgid;
}

- (UInt16)unsubscribeWithTopic:(NSString *)topic
{
    UInt16 msgid = [self nextMessageID];
    SCDMQTTFrameUnsubscribe *frame = [[SCDMQTTFrameUnsubscribe alloc] initWithMsgid:msgid topic:topic];
    [self sendFrame:frame tag:msgid];
    return msgid;
}

#pragma mark SCDMQTTFrameBufferDelegate

- (void)buffer:(SCDMQTTFrameBuffer *)buffer sendPublishFrame:(SCDMQTTFramePublish *)frame
{
    [self sendFrame:frame tag:frame.msgid];
}


#pragma mark GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    logDebuf(@"连接到 %@ : %hu", host, port);
    
#if TARGET_OS_IPHONE
    if (_backgroundOnSocket) {
        [_socket performBlock:^{
            [sock enableBackgroundingOnSocket];
        }];
    }
#endif
    
    if (_enableSSL) {
        if (_sslSettings == nil) {
            if (_allowUntrustCACertificate) {
                [sock startTLS:@{GCDAsyncSocketManuallyEvaluateTrust : @YES}];
            } else {
                [sock startTLS:nil];
            }
        } else {
            if (_sslSettings) {
                _sslSettings[GCDAsyncSocketManuallyEvaluateTrust] = @YES;
                [_socket startTLS:_sslSettings];
            }
        }
    } else {
        [self sendConnectFrame];
    }
}


- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler
{
    logDebuf(@"didReceiveTrust");
    if (_delegate) {
        [_delegate mqtt:self didReceiveTrust:trust completionHandler:completionHandler];
    }
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    logDebuf(@"socketDidSecure");
    [self sendConnectFrame];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    logDebuf(@"Socket 写消息 tag: %ld", tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    switch (tag) {
        case SCDMQTTReadTagHeader:
            [_reader headerReady:[data byteAtIndex:0]];
            break;
        case SCDMQTTReadTagLength:
            [_reader lengthReady:[data byteAtIndex:0]];
            break;
        case SCDMQTTReadTagPayload:
            [_reader payloadReady:data];
            break;
        default:
            break;
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    _socket.delegate = nil;
    _connState = SCDMQTTConnStateDisconnected;
    if (_delegate) {
        [_delegate mqttDidDisconnect:self withError:err];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_autoReconnTimer) {
            [_autoReconnTimer invalidate];
        }
        if (!_disconnectExpectedly && _autoReconnect) {
            __weak typeof(self) _wself = self;
            _autoReconnTimer = [NSTimer scd_createEveryTimerWhenInterval:_autoReconnectTimeInterval block:^{
                logDebuf(@"try reconnect");
                __strong typeof(self) _sself = _wself;
                if (_sself) {
                    [_sself connect];
                }
            }];
        }
    });
}

#pragma mark SCDMQTTReaderDelegate

- (void)didReceiveConnAck:(SCDMQTTReader *)reader connack:(UInt8)connack
{
    logDebuf(@"CONNACK Received: %hhu", connack);
    
    SCDMQTTConnAck ack;
    if (0  == connack) {
        ack = SCDMQTTConnAckAccept;
        _connState = SCDMQTTConnStateConnected;
    } if ((connack >= 1) && (connack <= 5)) {
        ack = connack;
        [self internal_disconnect];
    } if (connack > 5) {
        ack = SCDMQTTConnAckReserved;
        [self internal_disconnect];
    } else {
        [self internal_disconnect];
        return;
    }
    
    if (_delegate) {
        [_delegate mqtt:self didConnectAck:ack];
    }
    
    if (ack == SCDMQTTConnAckAccept) {
        if (_autoReconnTimer) {
            [_autoReconnTimer invalidate];
        }
        _disconnectExpectedly = NO;
    }
    
    if (ack == SCDMQTTConnAckAccept && _keepAlive > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_aliveTimer invalidate];
            __weak typeof(self) _wself = self;
            
            _aliveTimer = [NSTimer scd_createEveryTimerWhenInterval:(_keepAlive/2 + 1) atTimerHandler:^(NSTimer * timer) {
                __strong typeof(self) _sself = _wself;
                if (_sself == nil) {
                    return;
                }
                if (_sself.connState == SCDMQTTConnStateConnected) {
                    [_sself ping];
                } else {
                    [timer invalidate];
                }
            }];;
        });
    }
}

- (void)didReceivePublish:(SCDMQTTReader *)reader message:(SCDMQTTMessage *)message msgid:(UInt16)msgid
{
    logDebuf(@"CPUBLISH Received from: %@", message.topic);
    
    if (_delegate) {
        [_delegate mqtt:self didReceiveMessage:message msgid:msgid];
    }
    if (SCDMQTTQOS1 == message.qos) {
        [self pubackWithFrameType:SCDMQTTFrameTypePuback msgid:msgid];
    } else if (SCDMQTTQOS2 == message.qos) {
        [self pubackWithFrameType:SCDMQTTFrameTypePubrec msgid:msgid];
    }
}

- (void)didReceivePubAck:(SCDMQTTReader *)reader msgid:(UInt16)msgid
{
    logDebuf(@"PUBACK Received: %hu", msgid);
    [_buffer sendSuccessWithMsgid:msgid];
    if (_delegate) {
        [_delegate mqtt:self didPublishAckMsgid:msgid];
    }
}

- (void)didReceivePubRec:(SCDMQTTReader *)reader msgid:(UInt16)msgid
{
    logDebuf(@"PUBREC Received: %hu", msgid);
    [self pubackWithFrameType:SCDMQTTFrameTypePubrel msgid:msgid];
}

- (void)didReceivePubRel:(SCDMQTTReader *)reader msgid:(UInt16)msgid
{
    logDebuf(@"PUBREL Received: %hu", msgid);
    [self pubackWithFrameType:SCDMQTTFrameTypePubcomp msgid:msgid];
}

- (void)didReceivePubComp:(SCDMQTTReader *)reader msgid:(UInt16)msgid
{
    logDebuf(@"PUBCOMP Received: %hu", msgid);
    [_buffer sendSuccessWithMsgid:msgid];
    if (_delegate) {
        [_delegate mqtt:self didPublishComplete:msgid];
    }
}

- (void)didReceiveSubAck:(SCDMQTTReader *)reader msgid:(UInt16)msgid
{
    logDebuf(@"SUBACK Received: %hu", msgid);
    
    NSNumber *keyMsgid = [NSNumber numberWithUnsignedShort:msgid];
    NSDictionary<NSString *, NSNumber *> *topicDict = _subscriptionsWaitingAck[keyMsgid];
    [_subscriptionsWaitingAck removeObjectForKey:keyMsgid];
    if (topicDict) {
        NSArray<NSString *> *allkeys = topicDict.allKeys;
        NSString *topic = allkeys.firstObject;
        
        for (id key in _subscriptions.allKeys) {
            if ([_subscriptions[key].allKeys.firstObject isEqualToString:topic]) {
                [_subscriptions removeObjectForKey:key];
            }
        }
        
        _subscriptions[keyMsgid] = topicDict;
        if (_delegate) {
            [_delegate mqtt:self didSubscribeTopic:topic];
        }
    } else {
        logWarning(@"UNEXPECT SUBACK Received: %hu", msgid);
    }
}

- (void)didReceiveUnsubAck:(SCDMQTTReader *)reader msgid:(UInt16)msgid
{
    logDebuf(@"UNSUBACK Received: %hu", msgid);
    
    NSNumber *keyMsgid = [NSNumber numberWithUnsignedShort:msgid];
    NSDictionary<NSString *, NSNumber *> *topicDict = _unsubscriptionsWaitingAck[keyMsgid];
    [_unsubscriptionsWaitingAck removeObjectForKey:keyMsgid];
    if (topicDict) {
        NSArray<NSString *> *allkeys = topicDict.allKeys;
        NSString *topic = allkeys.firstObject;
        
        for (id key in _subscriptions.allKeys) {
            if ([_subscriptions[key].allKeys.firstObject isEqualToString:topic]) {
                [_subscriptions removeObjectForKey:key];
            }
        }
        
        if (_delegate) {
            [_delegate mqtt:self didUnsubscribeTopic:topic];
        }
    } else {
        logWarning(@"UNEXPECT UNSUBACK Received: %hu", msgid);
    }
}

- (void)didReceivePong:(SCDMQTTReader *)reader
{
    logDebuf(@"PONG Received");
    if (_delegate) {
        [_delegate mqttDidReceivePong:self];
    }
}

#pragma mark private function

- (void)sendFrame:(SCDMQTTFrame *)frame tag:(int)tag
{
    [_socket writeData:[frame data] withTimeout:-1 tag:tag];
}

- (void)sendFrame:(SCDMQTTFrame *)frame
{
    [self sendFrame:frame tag:0];
}

- (void)sendConnectFrame
{
    SCDMQTTFrame *frame = [[SCDMQTTFrameConnect alloc] initWithMQTTClient:self];
    [self sendFrame:frame];
    [_reader start];
}

- (UInt16)nextMessageID
{
    if (_gmid == UINT16_MAX) {
        _gmid = 0;
    }
    _gmid += 1;
    return _gmid;
}

- (void)pubackWithFrameType:(SCDMQTTFrameType)type msgid:(UInt16)msgid
{
    NSString *descr = nil;
    switch (type) {
        case SCDMQTTFrameTypePuback:
            descr = @"PUBACK";
            break;
        case SCDMQTTFrameTypePubrec:
            descr = @"PUBREC";
            break;
        case SCDMQTTFrameTypePubrel:
            descr = @"PUBREL";
            break;
        case SCDMQTTFrameTypePubcomp:
            descr = @"PUBCOMP";
            break;
        default:
            break;
    }
    
    if (descr) {
        logDebuf(@"发送 %@, %d", descr, msgid);
    }
    [self sendFrame:[[SCDMQTTFramePubAck alloc] initWithType:type msgid:msgid]];
}

@end
