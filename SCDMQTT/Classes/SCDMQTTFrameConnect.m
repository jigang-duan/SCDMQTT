//
//  SCDMQTTFrameConnect.m
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import "SCDMQTTFrameConnect.h"
#import "SCDMQTTClient.h"
#import "SCDMQTTMessage.h"
#import "NSString+SCDMQTTFrame.h"

const static UInt8 kPROTOCOL_LEVEL = 4;
const static NSString *kPROTOCOL_VERSION = @"MQTT/3.1.1";
const static NSString *kPROTOCOL_MAGIC = @"MQTT";

/**
 * MQTT CONNECT Frame
 */
@implementation SCDMQTTFrameConnect

@dynamic flagUsername;
@dynamic flagPassword;
@dynamic flagWillRetain;
@dynamic flagWillQOS;
@dynamic flagWill;
@dynamic flagCleanSession;

#pragma mark Init

- (instancetype)initWithMQTTClient:(SCDMQTTClient *)client
{
    self = [super initWithType:SCDMQTTFrameTypeConnect];
    if (self) {
        _client = client;
    }
    return self;
}

#pragma mark getter setter

- (BOOL)isFlagUsername
{
    return Bit2Bool(_flags.bit.username);
}

- (void)setFlagUsername:(BOOL)flagUsername
{
    _flags.bit.username = flagUsername;
}

- (BOOL)isFlagPassword
{
    return Bit2Bool(_flags.bit.password);
}

- (void)setFlagPassword:(BOOL)flagPassword
{
    _flags.bit.password = flagPassword;
}

- (BOOL)isFlagWillRetain
{
    return Bit2Bool(_flags.bit.willretain);
}

- (void)setFlagWillRetain:(BOOL)flagWillRetain
{
    _flags.bit.willretain = flagWillRetain;
}

- (UInt8)flagWillQOS
{
    return _flags.bit.willqos;
}

- (void)setFlagWillQOS:(UInt8)flagWillQOS
{
    _flags.bit.willqos = flagWillQOS;
}

- (BOOL)isFlagWill
{
    return Bit2Bool(_flags.bit.willflag);
}

- (void)setFlagWill:(BOOL)flagWill
{
    _flags.bit.willflag = flagWill;
}

- (BOOL)isFlagCleanSession
{
    return Bit2Bool(_flags.bit.cleansession);
}

- (void)setFlagCleanSession:(BOOL)flagCleanSession
{
    _flags.bit.cleansession = flagCleanSession;
}

#pragma mark override

- (void)pack
{
    // variable header
    NSMutableData *header = [NSMutableData dataWithData:self.variableHeader];
    [header appendData:[kPROTOCOL_MAGIC bytesWithLength]];
    [header appendBytes:&kPROTOCOL_LEVEL length:sizeof(kPROTOCOL_LEVEL)];
    
    // payload
    NSMutableData *pld = [NSMutableData dataWithData:self.payload];
    [pld appendData:_client.clientID.bytesWithLength];
    if (_client) {
        SCDMQTTWill *will = _client.willMessage;
        if (will) {
            self.flagWill = YES;
            self.flagWillQOS = will.qos;
            self.flagWillRetain = will.retained;
            [pld appendData:will.topic.bytesWithLength];
            [pld appendData:will.payload];
        }
        if (_client.userName) {
            self.flagUsername = YES;
            [pld appendData:[_client.userName bytesWithLength]];
        }
        if (_client.password) {
            self.flagPassword = YES;
            [pld appendData:[_client.password bytesWithLength]];
        }
        
        // flags
        self.flagCleanSession = _client.cleanSession;
        [header appendBytes:&_flags length:sizeof(_flags)];
        Byte hlKeepAlive[] = hlBytes(_client.keepAlive);
        [pld appendBytes:hlKeepAlive length:sizeof(UInt16)];
    }
    
    self.variableHeader = header;
    self.payload = pld;
}

@end
