//
//  NativeSocketManager.h
//  iSocket
//
//  Created by ZN on 2017/1/13.
//  Copyright © 2017年 iSeen. All rights reserved.
//

// OS底层(C语言)Socket 简单实现IM

#import <Foundation/Foundation.h>

@interface NativeSocketManager : NSObject

+ (instancetype)sharedInstance;

- (void)connect;
- (void)sendMessage:(NSString *)message;
- (void)receiveMessage;
- (void)disConnect;

@end
