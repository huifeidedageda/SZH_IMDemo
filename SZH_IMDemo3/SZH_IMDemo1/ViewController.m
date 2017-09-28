//
//  ViewController.m
//  SZH_IMDemo1
//
//  Created by 智衡宋 on 2017/9/27.
//  Copyright © 2017年 智衡宋. All rights reserved.
//

#import "ViewController.h"
#import "PTSocketManager.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *connectionButton;
@property (weak, nonatomic) IBOutlet UIButton *disConnectionButton;
@property (weak, nonatomic) IBOutlet UIButton *sendPingButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [PTSocketManager manager];
    
    [_sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_connectionButton addTarget:self action:@selector(connectionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_disConnectionButton addTarget:self action:@selector(disConnectionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_sendPingButton addTarget:self action:@selector(sendPingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

//发送消息
- (void)sendButtonAction:(UIButton *)button {
    if (_textField.text.length == 0) {
        return;
    }
    [[PTSocketManager manager] sendMsg:self.textField.text];
}

//连接服务器
- (void)connectionButtonAction:(UIButton *)button {
    [[PTSocketManager manager] connect];
}


//断开连接
- (void)disConnectionButtonAction:(UIButton *)button {
    [[PTSocketManager manager] disconnect];
}


//sendPing
- (void)sendPingButtonAction:(UIButton *)button {
    
    [[PTSocketManager manager] ping];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
