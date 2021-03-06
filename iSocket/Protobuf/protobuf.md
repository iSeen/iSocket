# protobuf

### 初识
Protocol buffers  
是一个用来序列化结构化数据的技术，支持多种语言诸如C++、Java以及Python语言，可以使用该技术来持久化数据或者序列化成网络传输的数据。相比较一些其他的XML技术而言，该技术的一个明显特点就是更加节省空间（以二进制流存储）、速度更快以及更加灵活。

编写一个protocol buffers应用需要经历如下三步：
	
	1、定义消息格式文件(消息协议原型定义文件)，最好以proto作为后缀名.
	2、使用Google提供的protocol buffers编译器来生成代码文件，一般为.h和.cc文件，主要是对消息格式以特定的语言方式描述.
	3、使用protocol buffers库提供的API来编写应用程序.
	
### 安装 
[protobuf-objc安装](https://github.com/alexeyxo/protobuf-objc)

	brew install automake
	brew install libtool
	brew install protobuf

项目Podfile加入以下内容, 并`pod install`

	pod 'Protobuf'

编写.proto原型文件  
.proto目录下执行以下命令, 会在同目录下生成OC文件 .h/.m: 并拖入项目中, 若出现语法之类错误, 可在工程 Target/Build Phases/Compile Sources/ .proto.m 后面加入 `-fno-objc-arc`
	
	protoc 文件名.proto --objc_out="./"
	或者
	protoc --plugin=/usr/local/bin/protoc-gen-objc 文件名.proto --objc_out="./"




### 参考文章
[Google Protocol Buffer 的使用和原理](http://www.ibm.com/developerworks/cn/linux/l-cn-gpb)

[Google Protocol Buffers浅析（一）](http://www.cnblogs.com/royenhome/archive/2010/10/29/1864860.html)

[iOS之ProtocolBuffer搭建和示例demo](http://www.cnblogs.com/tandaxia/p/6181534.html)

[分享iOS使用ProtocolBuffer的方法](http://blog.csdn.net/leihaoyude/article/details/49274601)