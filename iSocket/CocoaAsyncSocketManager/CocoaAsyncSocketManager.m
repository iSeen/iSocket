//
//  CocoaAsyncSocketManager.m
//  iSocket
//
//  Created by ZN on 2017/1/13.
//  Copyright © 2017年 iSeen. All rights reserved.
//

#import "CocoaAsyncSocketManager.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>    //TCP
//#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h> //UDP

static  NSString *Khost = @"127.0.0.1";
static const uint16_t Kport = 6969;

@interface CocoaAsyncSocketManager ()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *gcdSocket;
@end

@implementation CocoaAsyncSocketManager

#pragma mark - GCDAsyncSocketDelegate Delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
    NSLog(@"连接成功: host:%@, port:%d", host, port);
    [self checkPingPong];
    
    //心跳写在这...
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"断开连接: host:%@,port:%d", sock.localHost, sock.localPort);
    //断线重连写在这...
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"发送消息,tag:%ld",tag);
    //判断是否成功发送，如果没收到响应，则说明连接断了，则想办法重连
    [self checkPingPong];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到消息：%@", message);
    
    //每次调用该方法
    [self receiveMessage];
}

//分段去获取消息的回调
//- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
//    NSLog(@"分段获取回调,length:%ld,tag:%ld",partialLength,tag);
//}


//为上一次设置的读取数据代理续时 (如果设置超时为-1，则永远不会调用到)
//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
//    NSLog(@"来延时，tag:%ld,elapsed:%f,length:%ld",tag,elapsed,length);
//    return 10;
//}


#pragma mark - Public Methods

+ (instancetype)sharedInstance {
    static CocoaAsyncSocketManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        instance = [[self alloc] init];
        [instance initSocket];
    });
    return instance;
}

- (void)connect {
    [_gcdSocket connectToHost:Khost onPort:Kport error:nil];
}

- (void)sendMessage:(NSString *)message {
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    //Timeout 设置请求时间
    [_gcdSocket writeData:data withTimeout:-1 tag:110];
}

- (void)receiveMessage {
    /*
     读取当前未读消息, 若没有未读消息则等待,若有未读消息则调用一次代理方法, 所以每次接收到消息还得再次调用一次该方法
     监听读数据的代理，只能监听10秒
     10秒过后调用是否续时的代理方法(shouldTimeoutReadWithTag)
     若选择不续时，那么10秒到了还没收到消息，那么Scoket会自动断开连接
     -1永远监听，不超时，但是只收一次消息
     */
    [_gcdSocket readDataWithTimeout:-1 tag:110];
    
    //看能不能读到这条消息发送成功的回调消息，如果2秒内没收到，则断开连接
    //    [gcdSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:2 maxLength:50000 tag:110];
}

- (void)disConnect {
    [_gcdSocket disconnect];
}


#pragma mark - Private Methods

- (void)initSocket {
    _gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

//用Pingpong机制来看是否有反馈
- (void)checkPingPong {
    //pingpong设置为3秒，如果3秒内没得到反馈就会自动断开连接
    [_gcdSocket readDataWithTimeout:3 tag:110];
}

@end
