//
//  SCDMQTTClient.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCDMQTTFrameBuffer.h"
#import "SCDMQTTLogger.h"
#import "SCDMQTTReader.h"
#import "CocoaAsyncSocket/GCDAsyncSocket.h"

@class SCDMQTTWill;
@class SCDMQTTMessage;
@protocol GCDAsyncSocketDelegate;
@protocol SCDMQTTReaderDelegate;

/**
 * QOS
 */
typedef NS_ENUM(UInt8, SCDMQTTQOS) {
    SCDMQTTQOS0 = 0,
    SCDMQTTQOS1 = 1,
    SCDMQTTQOS2 = 2
};

/**
 * Connection State
 */
typedef NS_ENUM(UInt8, SCDMQTTConnState) {
    SCDMQTTConnStateInitial = 0,
    SCDMQTTConnStateConnecting,
    SCDMQTTConnStateConnected,
    SCDMQTTConnStateDisconnected
};

/**
 * Connection Ack
 */
typedef NS_ENUM(UInt8, SCDMQTTConnAck) {
    SCDMQTTConnAckAccept  = 0,
    SCDMQTTConnAckUnacceptableProtocolVersion,
    SCDMQTTConnAckIdentifierRejected,
    SCDMQTTConnAckServerUnavailable,
    SCDMQTTConnAckBadUsernameOrPassword,
    SCDMQTTConnAckNotAuthorized,
    SCDMQTTConnAckReserved
};

/**
 * asyncsocket read tag
 */
typedef NS_ENUM(NSUInteger, SCDMQTTReadTag) {
    SCDMQTTReadTagHeader = 0,
    SCDMQTTReadTagLength,
    SCDMQTTReadTagPayload
};


typedef void(^CompletionBlock)(BOOL);

@class SCDMQTTClient;
@protocol SCDMQTTDelegate <NSObject>

@required

- (void)mqtt:(SCDMQTTClient *_Nonnull)client didConnectAck:(SCDMQTTConnAck)ack;
- (void)mqtt:(SCDMQTTClient *_Nonnull)client didPublishMessage:(SCDMQTTMessage *_Nonnull)message msgid:(UInt16)msgid;
- (void)mqtt:(SCDMQTTClient *_Nonnull)client didPublishAckMsgid:(UInt16)msgid;
- (void)mqtt:(SCDMQTTClient *_Nonnull)client didReceiveMessage:(SCDMQTTMessage *_Nonnull)message msgid:(UInt16)msgid;
- (void)mqtt:(SCDMQTTClient *_Nonnull)client didSubscribeTopic:(NSString *_Nonnull)topic;
- (void)mqtt:(SCDMQTTClient *_Nonnull)client didUnsubscribeTopic:(NSString *_Nonnull)topic;
- (void)mqttDidPing:(SCDMQTTClient *_Nonnull)client;
- (void)mqttDidReceivePong:(SCDMQTTClient *_Nonnull)client;
- (void)mqttDidDisconnect:(SCDMQTTClient *_Nonnull)client withError:(NSError *_Nullable)error;

@optional
- (void)mqtt:(SCDMQTTClient *_Nonnull)client didReceiveTrust:(SecTrustRef _Nonnull)trust completionHandler:(void (^_Nullable)(BOOL))completionHandler;
- (void)mqtt:(SCDMQTTClient *_Nonnull)client didPublishComplete:(UInt16)msgid;

@end


/// MQTT client
///
@interface SCDMQTTClient : NSObject <SCDMQTTFrameBufferDelegate, GCDAsyncSocketDelegate, SCDMQTTReaderDelegate>

@property (nonatomic, readwrite, copy, nonnull) NSString *host;
@property (nonatomic, readwrite, assign) UInt16 port;
@property (nonatomic, readwrite, copy, nonnull) NSString *clientID;

@property (nonatomic, readwrite, copy, nullable) NSString *userName;
@property (nonatomic, readwrite, copy, nullable) NSString *password;

@property (nonatomic, readwrite, assign) BOOL cleanSession;
@property (nonatomic, readwrite, assign) UInt16 keepAlive;

@property (nonatomic, readwrite, strong, nullable) SCDMQTTWill *willMessage;

@property (nonatomic, readwrite, assign, nonnull) dispatch_queue_t dispatchQueue;

@property (nonatomic, readwrite, assign) BOOL secureMQTT;

@property (nonatomic, readwrite, weak, nullable) id<SCDMQTTDelegate> delegate;

@property (nonatomic, readwrite, assign) BOOL backgroundOnSocket;

@property (nonatomic, readwrite, assign) SCDMQTTConnState connState;

@property (nonatomic, readwrite, assign) NSTimeInterval bufferSilosTimeout;
@property (nonatomic, readwrite, assign) NSUInteger bufferSilosMaxNumber;

// auto reconnect
@property (nonatomic, readwrite, assign) BOOL autoReconnect;
@property (nonatomic, readwrite, assign) NSTimeInterval autoReconnectTimeInterval;

// log
@property (nonatomic, readwrite, assign) SCDMQTTLoggerLevel logLevel;

// ssl
@property (nonatomic, readwrite, assign) BOOL enableSSL;
@property (nonatomic, readwrite, copy, nonnull) NSMutableDictionary<NSString *, NSObject *> *sslSettings;
@property (nonatomic, readwrite, assign) BOOL allowUntrustCACertificate;

// subscribed topics. (dictionary structure -> [msgid: [topicString: QoS]])
@property (nonatomic, readwrite, copy, nonnull) NSMutableDictionary<NSNumber *, NSDictionary<NSString *, NSNumber *> *> *subscriptions;

- (BOOL)connect;
- (void)disconnect;
- (void)ping;

- (UInt16)subscribeWithTopic:(NSString *_Nonnull)topic qos:(SCDMQTTQOS)qos;
- (UInt16)unsubscribeWithTopic:(NSString *_Nonnull)topic;
- (UInt16)publishWithTopic:(NSString *_Nonnull)topic string:(NSString *_Nonnull)string qos:(SCDMQTTQOS)qos retained:(BOOL)retained dup:(BOOL)dup;
- (UInt16)publishWithMessage:(SCDMQTTMessage *_Nonnull)message;

@end
