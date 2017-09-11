//
//  SCDMQTTReader.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@class SCDMQTTMessage;
@class SCDMQTTReader;
/**
 * MQTT Reader Delegate
 */
@protocol SCDMQTTReaderDelegate <NSObject>

- (void)didReceiveConnAck:(SCDMQTTReader *)reader connack:(UInt8)connack;
- (void)didReceivePublish:(SCDMQTTReader *)reader message:(SCDMQTTMessage *)message msgid:(UInt16)msgid;
- (void)didReceivePubAck:(SCDMQTTReader *)reader msgid:(UInt16)msgid;
- (void)didReceivePubRec:(SCDMQTTReader *)reader msgid:(UInt16)msgid;
- (void)didReceivePubRel:(SCDMQTTReader *)reader msgid:(UInt16)msgid;
- (void)didReceivePubComp:(SCDMQTTReader *)reader msgid:(UInt16)msgid;
- (void)didReceiveSubAck:(SCDMQTTReader *)reader msgid:(UInt16)msgid;
- (void)didReceiveUnsubAck:(SCDMQTTReader *)reader msgid:(UInt16)msgid;
- (void)didReceivePong:(SCDMQTTReader *) reader;

@end

@interface SCDMQTTReader : NSObject

- (instancetype)initWithAsyncSocket:(GCDAsyncSocket *)socket delegate:(id<SCDMQTTReaderDelegate>)delegate;

- (void)start;

- (void)headerReady:(UInt8)header;

- (void)lengthReady:(UInt8)byte;

- (void)payloadReady:(NSData *)data;

@end
