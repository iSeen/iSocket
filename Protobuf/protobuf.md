# protobuf

[protobuf-objc安装](https://github.com/alexeyxo/protobuf-objc)

	brew install automake
	brew install libtool
	brew install protobuf

建立.proto, 生成.h/.m: 
`protoc --plugin=/usr/local/bin/protoc-gen-objc 文件名.proto --objc_out="./Generate"
`
