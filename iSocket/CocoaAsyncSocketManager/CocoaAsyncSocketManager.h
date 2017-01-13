//
//  CocoaAsyncSocketManager.h
//  iSocket
//
//  Created by ZN on 2017/1/13.
//  Copyright © 2017年 iSeen. All rights reserved.
//

// 使用CocoaAsyncSocket第三方框架(基于原生Socket封装) 实现IM

#import <Foundation/Foundation.h>

@interface CocoaAsyncSocketManager : NSObject

+ (instancetype)sharedInstance;

- (void)connect;
- (void)sendMessage:(NSString *)message;
- (void)receiveMessage;
- (void)disConnect;

@end
