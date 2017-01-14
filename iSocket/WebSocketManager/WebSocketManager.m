//
//  WebSocketManager.m
//  iSocket
//
//  Created by ZN on 2017/1/13.
//  Copyright © 2017年 iSeen. All rights reserved.
//

#import "WebSocketManager.h"
#import "SocketRocket.h"

#define dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }

//和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
#define KHeartBeatID @"heart"

static  NSString *Khost = @"127.0.0.1";
static const uint16_t Kport = 6969;


@interface WebSocketManager ()<SRWebSocketDelegate>
{
    NSTimer *_heartBeat;
    NSTimeInterval _reConnectTime;
}
@property (nonatomic, strong) SRWebSocket *webSocket;
@end

@implementation WebSocketManager

#pragma mark - SRWebSocketDelegate Delegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"服务器返回接收的消息:%@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"连接成功");
    //连接成功 开始发送心跳
    [self initHeartBeat];
}

//open失败的时候调用
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"连接失败.....\n%@",error);
    //失败了就去重连
    [self reConnect];
}

//网络连接中断被调用
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",code,reason,wasClean);
    
    //如果是被用户自己中断的那么直接断开连接，否则开始重连
    if (code == DisConnectByUser) {
        NSLog(@"被用户关闭连接，不重连");
        [self disConnect];
    } else {
        NSLog(@"其他原因关闭连接，开始重连...");
        [self reConnect];
    }
    
    //断开连接时销毁心跳
    [self destoryHeartBeat];
}

//sendPing的时候，如果网络通的话，则会收到回调，但是必须保证ScoketOpen，否则会crash
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"收到pong回调");
}

//将收到的消息，是否需要把data转换为NSString，每次收到消息都会被调用，默认YES
//- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket {
//    NSLog(@"webSocketShouldConvertTextFrameToString");
//    return NO;
//}


#pragma mark - Public Methods

+ (instancetype)sharedInstance {
    static WebSocketManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)connect {
    [self initSocket];
    //每次正常连接的时候清零重连时间
    _reConnectTime = 0;
}

- (void)sendMessage:(NSString *)message {
    [_webSocket send:message];
}

- (void)pingPong {
    if (_webSocket) {
        [_webSocket sendPing:nil];
    }
}

- (void)disConnect {
    if (_webSocket) {
        [_webSocket closeWithCode:DisConnectByUser reason:@"用户主动断开"];
        _webSocket = nil;
    }
}

#pragma mark - Private Methods

- (void)initSocket {
    if (_webSocket) {
        return;
    }
    
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:%d", Khost, Kport]]];
    _webSocket.delegate = self;
    //设置代理queue
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    [_webSocket setDelegateOperationQueue:queue];
    
    //连接
    [_webSocket open];
}

//初始化心跳
- (void)initHeartBeat {
    dispatch_main_async_safe(^{
        
        [self destoryHeartBeat];
        
        __weak typeof(self) weakSelf = self;
        //心跳设置为3分钟，NAT超时一般为5分钟
        _heartBeat = [NSTimer scheduledTimerWithTimeInterval:3*60 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"heart");
            [weakSelf sendMessage:KHeartBeatID];
        }];
        [[NSRunLoop currentRunLoop] addTimer:_heartBeat forMode:NSRunLoopCommonModes];
    })
}

//取消心跳
- (void)destoryHeartBeat {
    dispatch_main_async_safe(^{
        if (_heartBeat) {
            [_heartBeat invalidate];
            _heartBeat = nil;
        }
    })
}

//重连机制
- (void)reConnect {
    [self disConnect];
    
    //超过一分钟就不再重连 所以只会重连5次 2^5 = 64
    if (_reConnectTime > 64) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _webSocket = nil;
        [self initSocket];
    });
    
    //重连时间2的指数级增长
    if (_reConnectTime == 0) {
        _reConnectTime = 2;
    } else {
        _reConnectTime *= 2;
    }
}


@end
