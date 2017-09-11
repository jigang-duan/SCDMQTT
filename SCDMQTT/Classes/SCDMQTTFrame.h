//
//  SCDMQTTFrame.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCDMQTTClient.h"

/**
 * MQTT Frame Type
 */
typedef NS_ENUM(UInt8, SCDMQTTFrameType) {
    SCDMQTTFrameTypeReserved = 0x00,
    SCDMQTTFrameTypeConnect = 0x01,
    SCDMQTTFrameTypeConnack = 0x02,
    SCDMQTTFrameTypePublish = 0x03,
    SCDMQTTFrameTypePuback = 0x04,
    SCDMQTTFrameTypePubrec = 0x05,
    SCDMQTTFrameTypePubrel = 0x06,
    SCDMQTTFrameTypePubcomp = 0x07,
    SCDMQTTFrameTypeSubscribe = 0x08,
    SCDMQTTFrameTypeSuback = 0x09,
    SCDMQTTFrameTypeUnsubscribe = 0x0A,
    SCDMQTTFrameTypeUnsuback = 0x0B,
    SCDMQTTFrameTypePingreq = 0x0C,
    SCDMQTTFrameTypePingresp = 0x0D,
    SCDMQTTFrameTypeDisconnect = 0x0E
};

typedef union scd_mqtt_frame_header {
    
    /**
     * |--------------------------------------
     * | 7 6 5 4 |     3    |  2 1  | 0      |
     * |  Type   | DUP flag |  QoS  | RETAIN |
     * |--------------------------------------
     */
    UInt8 header;
    struct scd_mqtt_frame_header_bits {
        UInt8 retain: 1;
        SCDMQTTQOS qos: 2;
        UInt8 dup: 1;
        SCDMQTTFrameType type: 4;
    } bit;
    
} SCDMQTTFrameHeader;

@interface SCDMQTTFrame : NSObject

@property (nonatomic, readwrite, assign) SCDMQTTFrameHeader header;
@property (nonatomic, readonly, assign) UInt8 type;
@property (nonatomic, readwrite, assign) BOOL dup;
@property (nonatomic, readwrite, assign) SCDMQTTQOS qos;
@property (nonatomic, readwrite, assign) BOOL retained;

@property (nonatomic, readwrite, copy) NSData * _Nonnull variableHeader;
@property (nonatomic, readwrite, copy) NSData * _Nonnull payload;


- (instancetype _Nonnull)initWithHeader:(UInt8)header;
- (instancetype _Nonnull)initWithType:(SCDMQTTFrameType)type;
- (instancetype _Nonnull)initWithType:(SCDMQTTFrameType)type payload:(NSData * _Nonnull)payload;
- (instancetype _Nonnull)initWithType:(SCDMQTTFrameType)type variableHeader:(NSData * _Nonnull)variableHeader payload:(NSData * _Nonnull)payload;

+ (instancetype _Nonnull)frameWithHeader:(UInt8)type;
+ (instancetype _Nonnull)frameWithType:(SCDMQTTFrameType)type payload:(nonnull NSData *)payload;
+ (instancetype _Nonnull)frameWithType:(SCDMQTTFrameType)type variableHeader:(NSData * _Nonnull)variableHeader payload:(NSData * _Nonnull)payload;

- (NSData *_Nonnull)data;

@end
