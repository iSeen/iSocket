# Socket

[概念](#概念)  
[即时通讯-IM](#即时通讯-IM)  
[相关文章](#相关文章)

## <a id="概念"></a>概念

### TCP/IP
TCP/IP（Transmission Control Protocol / Internet Protocol）即传输控制协议/网间协议，定义了主机如何连入因特网及数据如何在它们之间传输的标准.

从字面意思来看TCP/IP是TCP和IP协议的合称，但实际上TCP/IP协议是指因特网整个TCP/IP协议族。不同于ISO模型的七个分层，TCP/IP协议参考模型把所有的TCP/IP系列协议归类到四个抽象层中:

	应用层：TFTP，HTTP，SNMP，FTP，SMTP，DNS，Telnet 等等
	传输层：TCP，UDP
	网络层：IP，ICMP，OSPF，EIGRP，IGMP
	数据链路层：SLIP，CSLIP，PPP，MTU

每一抽象层建立在低一层提供的服务上，并且为高一层提供服务，如下:

![](http://ohlkc37yo.bkt.clouddn.com/2017011267289707f253.jpg)

备注:  
ISO/OSI网络体系结构 和 TCP/IP协议模型, 关系如下: [查看详情](http://blog.csdn.net/htyurencaotang/article/details/11473015)

	其中物理层、数据链路层和网络层通常被称作媒体层，是网络工程师所研究的对象；
	传输层、会话层、表示层和应用层则被称作主机层，是用户所面向和关心的内容。

![](http://ohlkc37yo.bkt.clouddn.com/20170112182600bec8a0f.gif)
	
	TCP/IP是传输层协议，主要解决数据如何在网络中传输；
	HTTP是应用层协议，主要解决如何包装数据。

	我们在传输数据时，可以只使用传输层（TCP/IP），但是那样的话，由于没有应用层，便无法识别数据内容.
	如果想要使传输的数据有意义，则必须使用应用层协议，应用层协议很多，有HTTP、FTP、TELNET等等，也可以自己定义应用层协议。
	WEB使用HTTP作传输层协议，以封装HTTP文本信息，然后使用TCP/IP做传输层协议将它发送到网络上。
	
	Socket是对TCP/IP协议的封装，Socket本身并不是协议，而是一个调用接口（API），通过Socket，我们才能使用TCP/IP协议。

###### TCP连接
手机能够使用联网功能是因为手机底层实现了TCP/IP协议，可以使手机终端通过无线网络建立TCP连接。TCP协议可以对上层网络提供接口，使上层网络数据的传输建立在“无差别”的网络之上。

建立起一个TCP连接需要经过“三次握手”：

	第一次握手：客户端发送syn包(syn=j)到服务器，并进入SYN_SEND状态，等待服务器确认；
	第二次握手：服务器收到syn包，必须确认客户的SYN（ack=j+1），同时自己也发送一个SYN包（syn=k），即SYN+ACK包，此时服务器进入SYN_RECV状态；
	第三次握手：客户端收到服务器的SYN＋ACK包，向服务器发送确认包ACK(ack=k+1)，此包发送完毕，客户端和服务器进入ESTABLISHED状态，完成三次握手。
	
	备注:
	握手过程中传送的包里不包含数据，三次握手完毕后，客户端与服务器才正式开始传送数据。
	理想状态下，TCP连接一旦建立，在通信双方中的任何一方主动关闭连接之前，TCP 连接都将被一直保持下去。
	断开连接时服务器和客户端均可以主动发起断开TCP连接的请求，断开过程需要经过“四次握手”（过程就不细写了，就是服务器和客户端交互，最终确定断开）


###### HTTP连接

HTTP协议:  
超文本传送协议(HypertextTransfer Protocol )，是建立在TCP协议之上的一种应用, 一个属于应用层的面向对象的协议.

WWW的核心——HTTP协议.

HTTP连接最显著的特点:  
客户端发送的每次请求都需要服务器回送响应，在请求结束后，会主动释放连接。从建立连接到关闭连接的过程称为“一次连接”。

因此HTTP连接是一种“短连接”.  
要保持客户端程序的在线状态，需要不断地向服务器发起连接请求。  
通常的做法:  
是即使不需要获得任何数据，客户端也保持每隔一段固定的时间向服务器发送一次“保持连接”的请求，服务器在收到该请求后对客户端进行回复，表明知道客户端“在线”。  
若服务器长时间无法收到客户端的请求，则认为客户端“下线”，若客户端长时间无法收到服务器的回复，则认为网络已经断开。



---
### Socket
>Socket, 又称"套接字"，包含进行网络通信必须的五种信息：

	连接使用的协议，
	本地主机的IP地址，本地进程的协议端口，
	远地主机的IP地址，远地进程的协议端口。

	备注:
	两个进程如果需要进行通讯最基本的一个前提是能够唯一的标识一个进程. 
	IP层的ip地址可以唯一标示主机，TCP层协议和端口号可以唯一标示主机的一个进程，
	这样就可以利用 "ip地址＋协议＋端口号" 唯一标识网络中的一个进程. 
	能够唯一标示网络中的进程后，就可以利用socket进行通信.

Socket是系统提供的用于网络通信的方法。它的实质并不是一种协议，没有规定计算机应当怎么样传递消息，只是给程序员提供了一个发送消息的接口，程序员使用这个接口提供的方法，发送与接收消息。

Socket描述了一个IP、端口对。它简化了程序员的操作，知道对方的IP以及PORT(端口)就可以给对方发送消息，再由服务器端来处理发送的这些消息。所以，Socket一定包含了通信的双发，即客户端（Client）与服务端（server）。

>建立Socket连接至少需要一对套接字:

	一个运行于客户端，称为ClientSocket，
	一个运行于服务器端，称为ServerSocket。
	
>套接字之间的连接过程分为三个步骤：

服务器监听：  
服务器端套接字并不定位具体的客户端套接字，而是处于等待连接的状态，实时监控网络状态，等待客户端的连接请求。
	
客户端请求：  
指客户端的套接字提出连接请求，要连接的目标是服务器端的套接字。为此，客户端的套接字必须首先描述它要连接的服务器的套接字，指出服务器端套接字的地址和端口号，然后就向服务器端套接字提出连接请求。
	
连接确认：  
当服务器端套接字监听到或者说接收到客户端套接字的连接请求时，就响应客户端套接字的请求，建立一个新的线程，把服务器端套接字的描述发给客户端，一旦客户端确认了此描述，双方就正式建立连接。而服务器端套接字继续处于监听状态，继续接收其他客户端套接字的连接请求。
	
Socket是在应用层和传输层之间的一个抽象层，它把TCP/IP层复杂的操作抽象为几个简单的接口供应用层调用已实现进程在网络中通信.
![](http://ohlkc37yo.bkt.clouddn.com/2017011290136socketTCPIP.jpg)

@区别混淆
> Socket连接与TCP连接  

创建Socket连接时，可以指定使用的传输层协议，Socket可以支持不同的传输层协议（TCP或UDP），当使用TCP协议进行连接时，该Socket连接就是一个TCP连接。

>Socket连接与HTTP连接

由于通常情况下Socket连接就是TCP连接，因此Socket连接一旦建立，通信双方即可开始相互发送数据内容，直到双方连接断开。但在实际网络应用中，客户端到服务器之间的通信往往需要穿越多个中间节点，例如路由器、网关、防火墙等，大部分防火墙默认会关闭长时间处于非活跃状态的连接而导致 Socket 连接断连，因此需要通过轮询告诉网络，该连接处于活跃状态。

而HTTP连接使用的是“请求—响应”的方式，不仅在请求时需要先建立连接，而且需要客户端向服务器发出请求后，服务器端才能回复数据。

很多情况下，需要服务器端主动向客户端推送数据，保持客户端与服务器数据的实时与同步。   
此时若双方建立的是Socket连接，服务器就可以直接将数据传送给客户端；  
若双方建立的是HTTP连接，则服务器需要等到客户端发送一次请求后才能将数据传回给客户端.  
因此，客户端定时向服务器端发送连接请求，不仅可以保持在线，同时也是在“询问”服务器是否有新的数据，如果有就将数据传给客户端。



---
### Socket通信流程
每一个应用或者说服务，都有一个端口。比如DNS的53端口，http的80端口。我们能由DNS请求到查询信息，是因为DNS服务器时时刻刻都在监听53端口，当收到我们的查询请求以后，就能够返回我们想要的IP信息。

Socket是 "打开—(读/写)—关闭" 模式的实现，以使用TCP协议通讯的Socket为例，其交互流程大概如下:

![](http://ohlkc37yo.bkt.clouddn.com/201701122540socket jiaohuliucheng.png)

	·服务器根据地址类型（ipv4,ipv6）、socket类型、协议创建socket
	·服务器为socket绑定ip地址和端口号
	·服务器socket监听端口号请求，随时准备接收客户端发来的连接，这时候服务器的socket并没有被打开
	
	>客户端创建socket
	>客户端打开socket，根据服务器ip地址和端口号试图连接服务器socket
	
	·服务器socket接收到客户端socket请求，被动打开，开始接收客户端请求，直到客户端返回连接信息。这时候socket进入阻塞状态，所谓阻塞即accept()方法一直到客户端返回连接信息后才返回，开始接收下一个客户端谅解请求
	
	>客户端连接成功，向服务器发送连接状态信息
	
	·服务器accept方法返回，连接成功
	
	>客户端向socket写入信息
	
	·服务器读取信息
	
	>客户端关闭
	
	·服务器端关闭







## <a id="即时通讯-IM"></a> 即时通讯-IM
### IM_应用场景: 
一切高实时性的场景，都适合使用IM来做:
	
	视频会议、聊天、私信
	弹幕、抽奖
	互动游戏
	协同编辑
	股票基金实时报价、体育实况更新、
	基于位置的应用：Uber、滴滴司机位置
	在线教育
	智能家居

### IM_发展史
##### 1.(短)轮询
频繁的一问一答 (一般网络请求: 一问一答)  
##### 2.长轮询
耐心地一问一答  
一种轮询方式是否为长轮询，是根据`服务端的处理方式`来决定的，与客户端没有关系。  

长轮询和短轮询最大的区别:  

	短轮询: 去服务端查询的时候，不管服务端有没有变化，服务器就立即返回结果了。  
	长轮询: 服务器如果检测到库存量没有变化的话，将会把当前请求挂起一段时间（这个时间也叫作超时时间，一般是几十秒）。在这个时间里，服务器会去检测库存量有没有变化，检测到变化就立即返回，否则就一直等到超时为止.

##### 3.长连接 (HTML5 WebSocket: 双向)
WebSocket 是 HTML5 开始提供的一种浏览器与服务器间进行全双工通讯的网络技术。  
在 WebSocket API 中，浏览器和服务器只需要要做一个握手的动作，然后，浏览器和服务器之间就形成了一条快速通道。两者之间就直接可以数据互相传送。

#### 总结: 轮询与长连接
发展历史：从长短轮询到长连接，使用 WebSocket 来替代 HTTP;  
移动端长连接是趋势, 最大的特点是节省 Header 所消耗的流量;

长短轮询与长短连接的主要区别:

    概念范畴不同：长短轮询是应用层概念, 长短连接是传输层概念
    协商方式不同：一种轮询方式是否为长轮询，是根据服务端的处理方式来决定的，与客户端没有关系。一个 TCP 连接是否为长连接，是通过设置 HTTP 的 Connection Header 来决定的，而且是需要两边都设置才有效。
    实现方式不同：轮询的长短，是服务器通过编程的方式手动挂起请求来实现的。连接的长短,是通过协议来规定和实现的。

长连接实现方式里的协议选择:
常见的协议有：XMPP、SIP、MQTT、私有协议。

	XMPP 	优点：协议开源，可拓展性强，在各个端(包括服务器)有各种语言的实现，开发者接入方便； 
	    	缺点：缺点也是不少，XML表现力弱、有太多冗余信息、流量大，实际使用时有大量天坑。
	    	
	MQTT 	优点：协议简单，流量少；订阅+推送模式，非常适合Uber、滴滴的小车轨迹的移动。
		 	缺点：它并不是一个专门为 IM 设计的协议，多使用于推送。IM 情景要复杂得多，pub、sub，比如：加入对话、创建对话等等事件。
		 	
	私有协议 市面上几乎所有主流IM APP都是是使用私有协议，一个被良好设计的私有协议优点非常明显。
	  		优点：高效，节约流量(一般使用二进制协议)，安全性高，难以破解； 
			缺点：在开发初期没有现有样列可以参考，对于设计者的要求比较高。

### IM_数据传输格式
主要是JSON 、ProtocolBuffer、XML ...

ProtocolBuffer 优势:
	
	1.使用 ProtocolBuffer 减少 Payload
    滴滴打车40%；
    携程之前分享过，说是采用新的Protocol Buffer数据格式+Gzip压缩后的Payload大小降低了15%-45%。数据序列化耗时下降了80%-90%。

	2.采用高效安全的私有协议，支持长连接的复用，稳定省电省流量
	【高效】提高网络请求成功率，消息体越大，失败几率随之增加。
	【省流量】流量消耗极少，省流量。一条消息数据用Protobuf序列化后的大小是 JSON 的1/10、XML格式的1/20、是二进制序列化的1/10。同 XML 相比， Protobuf 性能优势明显。它以高效的二进制方式存储，比 XML 小 3 到 10 倍，快 20 到 100 倍。
	【省电】省电
	【高效心跳包】同时心跳包协议对IM的电量和流量影响很大，对心跳包协议上进行了极简设计：仅 1 Byte 。
	【易于使用】开发人员通过按照一定的语法定义结构化的消息格式，然后送给命令行工具，工具将自动生成相关的类，可以支持java、c++、python、Objective-C等语言环境。通过将这些类包含在项目中，可以很轻松的调用相关方法来完成业务消息的序列化与反序列化工作。语言支持：原生支持c++、java、python、Objective-C等多达10余种语言。 2015-08-27 Protocol Buffers v3.0.0-beta-1中发布了Objective-C(Alpha)版本， 2016-07-28 3.0 Protocol Buffers v3.0.0正式版发布，正式支持 Objective-C。
	【可靠】微信和手机 QQ 这样的主流 IM 应用也早已在使用它（采用的是改造过的Protobuf协议）

ProtocolBuffer 缺点：

	1.可能会造成 APP 的包体积增大，通过 Google 提供的脚本生成的 Model，会非常“庞大”，Model 一多，包体积也就会跟着变大。	
	2.如果 Model 过多，可能导致 APP 打包后的体积骤增，但 IM 服务所使用的 Model 非常少，比如在 ChatKit-OC 中只用到了一个 Protobuf 的 Model：Message对象，对包体积的影响微乎其微。
	3.在使用过程中要合理地权衡包体积以及传输效率的问题，据说去哪儿网，就曾经为了减少包体积，进而减少了 Protobuf 的使用。



### 实现方式:  

#### 1.使用第三方IM服务  
	类似LeanCloud、环信、融云、云信 ... 
	底层协议基本上都是TCP, 方案成熟
	缺点: 定制化程度太高, 贵. 若IM非主要功能, 辅助功能, 可考虑.

#### 2.自己实现
需要考虑:  

	1）传输协议的选择，TCP还是UDP？(技术成熟用UDP+私有协议, 否则用TCP)
	2）选择使用哪种聊天协议：(基于OS底层Socket自己封装 / 第三方框架基础上封装)
	    基于Scoket原生：代表框架 CocoaAsyncSocket / 自定义封装
	    基于WebScoket：代表框架 SocketRocket。
	    基于MQTT：代表框架 MQTTKit。
	    基于XMPP：代表框架 XMPPFramework。
	3）传输数据的格式: ProtocolBuffer > JSON > XML
	4）还需考虑的问题:
	可靠性: 例如TCP的长连接如何保持，心跳机制，PingPong机制, 断线重连机制, QoS机制等, 以及在大文件传输的时候使用分片上传、断点续传、秒传技术等来保证文件的传输;
	安全性: 防止DNS污染、帐号安全、第三方服务器鉴权、单点登录等
	其他优化:
	类似微信，服务器不做聊天记录的存储，只在本机进行缓存，这样可以减少对服务端数据的请求，一方面减轻了服务器的压力，另一方面减少客户端流量的消耗。
	我们进行http连接的时候尽量采用上层API，类似NSUrlSession。而网络框架尽量使用AFNetWorking3。因为这些上层网络请求都用的是HTTP/2 ，我们请求的时候可以复用这些连接。


#### 心跳机制

	心跳: 用来检测TCP连接的双方是否可用.  
	TCP的KeepAlive机制: 只能保证连接的存在，但是并不能保证客户端以及服务端的可用性.
	
>比如: 某台服务器因为某些原因导致负载超高，CPU 100%，无法响应任何业务请求，但是使用 TCP 探针则仍旧能够确定连接状态，这就是典型的连接活着但业务提供方已死的状态。

心跳机制作用:  
    客户端发起心跳Ping（一般都是客户端），假如设置在10秒后如果没有收到回调，那么说明服务器或者客户端某一方出现问题，这时候我们需要主动断开连接。  
    服务端也是一样，会维护一个socket的心跳间隔，当约定时间内，没有收到客户端发来的心跳，我们会知道该连接已经失效，然后主动断开连接。

真正需要心跳机制的原因: 主要是在于国内运营商NAT超时。国内的运营商一般NAT超时的时间为5分钟，所以通常我们心跳设置的时间间隔为3-5分钟。

#### PingPong机制
解决: 心跳间隔的3-5分钟如果连接假在线（例如在地铁电梯这种环境下）无法保证消息的即时性的问题;

![](http://ohlkc37yo.bkt.clouddn.com/2017011339341socketpingpangack.jpg)


当服务端发出一个Ping，客户端没有在约定的时间内返回响应的ack，则认为客户端已经不在线，这时我们Server端会主动断开Scoket连接，并且改由APNS推送的方式发送消息。

同样的是，当客户端去发送一个消息，因为我们迟迟无法收到服务端的响应ack包，则表明客户端或者服务端已不在线，我们也会显示消息发送失败，并且断开Scoket连接。

还记得我们之前CocoaSyncSockt的例子所讲的获取消息超时就断开吗？其实它就是一个PingPong机制的客户端实现。我们每次可以在发送消息成功后，调用这个超时读取的方法，如果一段时间没收到服务器的响应，那么说明连接不可用，则断开Scoket连接.

#### 断线重连机制
理论上，我们自己主动去断开的Scoket连接（例如退出账号，APP退出到后台等等），不需要重连。其他的连接断开，我们都需要进行断线重连。
一般解决方案是尝试重连几次，如果仍旧无法重连成功，那么不再进行重连。


#### QoS机制
QoS（Quality of Service，服务质量）指一个网络能够利用各种基础技术，为指定的网络通信提供更好的服务能力, 是网络的一种安全机制， 是用来解决网络延迟和阻塞等问题的一种技术。 





## <a id="相关文章"></a>相关文章
[iOS即时通讯，从入门到“放弃”？](http://www.jianshu.com/p/2dbb360886a8)

[为什么说基于TCP的移动端IM仍然需要心跳保活？](http://www.52im.net/thread-281-1-1.html)

[微信,QQ这类IM app怎么做——谈谈Websocket](http://www.jianshu.com/p/bcefda55bce4)

[移动端IM/推送系统的协议选型：UDP还是TCP？](http://www.52im.net/thread-33-1-1.html)

[IM 即时通讯技术在多应用场景下的技术实现，以及性能调优（iOS视角）](http://www.jianshu.com/p/8cd908148f9e)  

[《基于HTTP2的全新APNs协议》](https://github.com/ChenYilong/iOS9AdaptationTips/blob/master/%E5%9F%BA%E4%BA%8EHTTP2%E7%9A%84%E5%85%A8%E6%96%B0APNs%E5%8D%8F%E8%AE%AE/%E5%9F%BA%E4%BA%8EHTTP2%E7%9A%84%E5%85%A8%E6%96%B0APNs%E5%8D%8F%E8%AE%AE.md)  

[Socket使用大全](http://blog.csdn.net/ch_soft/article/details/7369705)

[关于iOS socket都在这里了](http://www.cocoachina.com/ios/20160602/16572.html)
