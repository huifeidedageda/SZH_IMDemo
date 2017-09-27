//
//  PTSocketManager.m
//  SZH_IMDemo1
//
//  Created by 智衡宋 on 2017/9/27.
//  Copyright © 2017年 智衡宋. All rights reserved.
//

#import "PTSocketManager.h"
#import <GCDAsyncSocket.h>

static NSString *Khost = @"127.0.0.1";
static const uint16_t Kport  = 6969;

@interface PTSocketManager ()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_gcdSocket;
}
@end

@implementation PTSocketManager
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static PTSocketManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[PTSocketManager alloc]init];
        [manager initSocket];
        
    });
    
    return manager;
}

#pragma mark ---------- 初始化

- (void)initSocket {
    
    _gcdSocket  = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}


#pragma mark ---------- 连接服务器

- (BOOL)connect {
    return [_gcdSocket connectToHost:Khost onPort:Kport error:nil];
}

#pragma mark ---------- 断开服务器

- (void)disconnect {
    
    [_gcdSocket disconnect];
    
}

#pragma mark ---------- 发送消息


- (void)sendMsg:(NSString *)msg {
    
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdSocket writeData:data withTimeout:-1 tag:110];
   
}


#pragma mark ---------- 获取信息


- (void)pullMsg {
    
    //监听读数据的代理，只能监听10秒，10秒过后调用代理方法  -1永远监听，不超时，但是只收一次消息，
    //所以每次接受到消息还得调用一次
    [_gcdSocket readDataWithTimeout:-1 tag:110];
    
}

//用Pingpong机制来看是否有反馈
- (void)checkPingPong
{
    //pingpong设置为3秒，如果3秒内没得到反馈就会自动断开连接
    [_gcdSocket readDataWithTimeout:3 tag:110];
    
}


#pragma mark ---------- GCDAsyncSocketDelegate

//连接成功调用
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
    NSLog(@"连接成功,host:%@,port:%d",host,port);
    [self checkPingPong];
    
}


//断开连接时调用

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
    NSLog(@"断开连接,host:%@,port:%d",sock.localHost,sock.localPort);
    
    //断线重连写在这...
    [self connect];
    
}

//发送信息回调

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    NSLog(@"写的回调,tag:%ld",tag);
    //判断是否成功发送，如果没收到响应，则说明连接断了，则想办法重连
    [self checkPingPong];
    
}

//读取信息回调

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到消息：%@",msg);
    
    [self pullMsg];
    
}

@end
