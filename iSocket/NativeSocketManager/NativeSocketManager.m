//
//  NativeSocketManager.m
//  iSocket
//
//  Created by ZN on 2017/1/13.
//  Copyright © 2017年 iSeen. All rights reserved.
//

#import "NativeSocketManager.h"

#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface NativeSocketManager ()
@property (nonatomic, assign) int clientSocket;
@end

@implementation NativeSocketManager

#pragma mark - Public Methods

+ (instancetype)sharedInstance {
    static NativeSocketManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        instance = [[self alloc] init];
        [instance initSocket];
        [instance receiveMessage];
    });
    return instance;
}

- (void)connect {
    [self initSocket];
}

- (void)receiveMessage {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(recieveAction) object:nil];
    [thread start];
}

- (void)sendMessage:(NSString *)message {
    const char *send_Message = [message UTF8String];
    send(self.clientSocket, send_Message, strlen(send_Message) + 1, 0);
}

- (void)disConnect {
    close(self.clientSocket); //关闭连接
}


#pragma mark - Event Response

//接收消息
- (void)recieveAction{
    while (1) {
        char recv_Message[1024] = {0};
        recv(self.clientSocket, recv_Message, sizeof(recv_Message), 0);
        printf("%s\n",recv_Message);
    }
}


#pragma mark - Private Methods

- (void)initSocket {
    //每次连接前，先断开连接
    if (_clientSocket != 0) {
        [self disConnect];
        _clientSocket = 0;
    }
    
    //创建客户端socket
    _clientSocket = CreateClinetSocket();
    //服务器IP
    const char *server_ip = "127.0.0.1";
    //服务器端口
    short server_port = 6969;
    
    //连接服务器等于0说明连接失败
    if (ConnectionToServer(_clientSocket, server_ip, server_port) == 0) {
        printf("Connect to server error\n");
        return ;
    }
    //走到这说明连接成功
    printf("Connect to server success\n");
}

static int CreateClinetSocket() {
    int ClinetSocket = 0;
    //创建一个socket,返回值为Int。（注socket其实就是Int类型）
    //第一个参数 addressFamily:  IPv4(AF_INET) 或 IPv6(AF_INET6)。
    //第二个参数 type 表示 socket 的类型，通常是流stream(SOCK_STREAM) 或 数据报文datagram(SOCK_DGRAM)
    //第三个参数 protocol 参数通常设置为0，以便让系统自动为选择我们合适的协议，对于 stream socket 来说会是 TCP 协议(IPPROTO_TCP)，而对于 datagram来说会是 UDP 协议(IPPROTO_UDP)。
    ClinetSocket = socket(AF_INET, SOCK_STREAM, 0);
    return ClinetSocket;
}

static int ConnectionToServer(int client_socket, const char *server_ip, unsigned short port) {
    
    //生成一个sockaddr_in类型结构体
    struct sockaddr_in sAddr = {0};
    sAddr.sin_len = sizeof(sAddr);
    //设置IPv4
    sAddr.sin_family = AF_INET;
    
    //inet_aton是一个改进的方法来将一个字符串IP地址转换为一个32位的网络序列IP地址
    //如果这个函数成功，函数的返回值非零，如果输入地址不正确则会返回零。
    inet_aton(server_ip, &sAddr.sin_addr);
    
    //htons是将整型变量从主机字节顺序转变成网络字节顺序，赋值端口号
    sAddr.sin_port = htons(port);
    
    //用socket和服务端地址，发起连接。
    //客户端向特定网络地址的服务器发送连接请求，连接成功返回0，失败返回 -1。
    //注意：该接口调用会阻塞当前线程，直到服务器返回。
    if (connect(client_socket, (struct sockaddr *)&sAddr, sizeof(sAddr)) == 0) {
        return client_socket;
    }
    return 0;
}

/*
 备注:
 
 //socket 创建并初始化 socket，返回该 socket 的文件描述符，如果描述符为 -1 表示创建失败。
 int socket(int addressFamily, int type,int protocol)
 
 //关闭socket连接
 int close(int socketFileDescriptor)
 
 //将 socket 与特定主机地址与端口号绑定，成功绑定返回0，失败返回 -1。
 int bind(int socketFileDescriptor,sockaddr *addressToBind,int addressStructLength)
 
 //接受客户端连接请求并将客户端的网络地址信息保存到 clientAddress 中。
 int accept(int socketFileDescriptor,sockaddr *clientAddress, int clientAddressStructLength)
 
 //客户端向特定网络地址的服务器发送连接请求，连接成功返回0，失败返回 -1。
 int connect(int socketFileDescriptor,sockaddr *serverAddress, int serverAddressLength)
 
 //使用 DNS 查找特定主机名字对应的 IP 地址。如果找不到对应的 IP 地址则返回 NULL。
 hostent* gethostbyname(char *hostname)
 
 //通过 socket 发送数据，发送成功返回成功发送的字节数，否则返回 -1。
 int send(int socketFileDescriptor, char *buffer, int bufferLength, int flags)
 
 //从 socket 中读取数据，读取成功返回成功读取的字节数，否则返回 -1。
 int receive(int socketFileDescriptor,char *buffer, int bufferLength, int flags)
 
 //通过UDP socket 发送数据到特定的网络地址，发送成功返回成功发送的字节数，否则返回 -1。
 int sendto(int socketFileDescriptor,char *buffer, int bufferLength, int flags, sockaddr *destinationAddress, int destinationAddressLength)
 
 //从UDP socket 中读取数据，并保存发送者的网络地址信息，读取成功返回成功读取的字节数，否则返回 -1 。
 int recvfrom(int socketFileDescriptor,char *buffer, int bufferLength, int flags, sockaddr *fromAddress, int *fromAddressLength)
 
 */

@end
