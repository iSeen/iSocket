//
//  ViewController.m
//  iSocket
//
//  Created by ZN on 2017/1/10.
//  Copyright © 2017年 iSeen. All rights reserved.
//

#import "ViewController.h"
//#import "Person.pbobjc.h"

#import "NativeSocketManager.h"
#import "CocoaAsyncSocketManager.h"
#import "WebSocketManager.h"

@interface ViewController ()

//@property (nonatomic, strong) NativeSocketManager *manager;
//@property (nonatomic, strong) CocoaAsyncSocketManager *manager;
@property (nonatomic, strong) WebSocketManager *manager;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UIButton *disConnectBtn;

@property (weak, nonatomic) IBOutlet UIButton *sendPingBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self testProtobuf];
    
//    [self loadSocket]; //运行Socket项目
}

- (void)testProtobuf {
    
}

- (void)loadSocket {
    //先运行服务器(项目目录中的node.js) 终端运行 node fileName
    //    _manager = [NativeSocketManager sharedInstance];
    //    _manager = [CocoaAsyncSocketManager sharedInstance];
    _manager = [WebSocketManager sharedInstance];
    
    [_sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    [_connectBtn addTarget:self action:@selector(connectAction) forControlEvents:UIControlEventTouchUpInside];
    [_disConnectBtn addTarget:self action:@selector(disConnectAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_sendPingBtn addTarget:self action:@selector(pingAction) forControlEvents:UIControlEventTouchUpInside];
}


- (void)sendAction {
    if (_textField.text.length == 0) {
        return;
    }
    [_manager sendMessage:_textField.text];
}

- (void)connectAction {
    [_manager connect];
}

- (void)disConnectAction {
    [_manager disConnect];
}

- (void)pingAction {
    [_manager pingPong];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
