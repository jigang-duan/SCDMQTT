//
//  SCDMQTTFrameBuffer.h
//  SCDMQTT
//
//  Created by jiang.duan on 2015/9/11.
//  Copyright © 2015年 jiang.duan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCDMQTTFrameBuffer;
@class SCDMQTTFramePublish;

@protocol SCDMQTTFrameBufferDelegate <NSObject>

- (void)buffer:(SCDMQTTFrameBuffer * _Nonnull)buffer sendPublishFrame:(SCDMQTTFramePublish *_Nonnull)frame;

@end

@interface SCDMQTTFrameBuffer : NSObject

@property (nonatomic, readwrite, weak, nullable) id<SCDMQTTFrameBufferDelegate> delegate;

@property (nonatomic, readwrite, assign) UInt16 silosMaxNumber;
@property (nonatomic, readwrite, assign) NSTimeInterval timeout;

@property (nonatomic, readonly, assign) BOOL bufferEmpty;
@property (nonatomic, readonly, assign) BOOL bufferFull;
@property (nonatomic, readonly, assign) BOOL silosFull;

+ (instancetype _Nonnull)buffer;

- (BOOL)addPublishFrame:(SCDMQTTFramePublish *_Nonnull)frame;
- (void)sendSuccessWithMsgid:(UInt16)msgid;

@end
