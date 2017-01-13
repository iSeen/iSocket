//
//  WebSocketManager.h
//  iSocket
//
//  Created by ZN on 2017/1/13.
//  Copyright © 2017年 iSeen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DisConnectType) {
    DisConnectByServer = 1001,
    DisConnectByUser
};

@interface WebSocketManager : NSObject

+ (instancetype)sharedInstance;

- (void)connect;
- (void)sendMessage:(NSString *)message;
- (void)pingPong;
- (void)disConnect;

@end
