//
//  SCDMQTTFrameConnect.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTFrame.h"

@class SCDMQTTClient;

typedef union scd_mqtt_frame_connect_flags {
    
    /**
     * |----------------------------------------------------------------------------------
     * |     7    |    6     |      5     |  4   3  |     2    |       1      |     0    |
     * | username | password | willretain | willqos | willflag | cleansession | reserved |
     * |----------------------------------------------------------------------------------
     */
    UInt8 flags;
    struct scd_mqtt_frame_connect_flags_bits {
        UInt8 reserved: 1;
        UInt8 cleansession: 1;
        UInt8 willflag: 1;
        UInt8 willqos: 2;
        UInt8 willretain: 1;
        UInt8 password: 1;
        UInt8 username: 1;
    } bit;
    
} SCDMQTTFrameConnectFlags;

/**
 * MQTT CONNECT Frame
 */
@interface SCDMQTTFrameConnect : SCDMQTTFrame

@property (nonatomic, readwrite, assign) SCDMQTTFrameConnectFlags flags;
@property (nonatomic, readwrite, assign) BOOL flagUsername;
@property (nonatomic, readwrite, assign) BOOL flagPassword;
@property (nonatomic, readwrite, assign) BOOL flagWillRetain;
@property (nonatomic, readwrite, assign) UInt8 flagWillQOS;
@property (nonatomic, readwrite, assign) BOOL flagWill;
@property (nonatomic, readwrite, assign) BOOL flagCleanSession;

@property (nonatomic, readwrite, strong) SCDMQTTClient *client;

- (instancetype)initWithMQTTClient:(SCDMQTTClient *)client;

@end
