//
//  PTSocketManager.m
//  SZH_IMDemo1
//
//  Created by 智衡宋 on 2017/9/27.
//  Copyright © 2017年 智衡宋. All rights reserved.
//

#import "PTSocketManager.h"
#import <SocketRocket.h>

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

static  NSString * Khost = @"127.0.0.1";
static const uint16_t Kport = 6969;

@interface PTSocketManager ()<SRWebSocketDelegate>
{
    SRWebSocket      *webSocket;
    NSTimer          *heartBeat;
    NSTimeInterval   reConnectTime;
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
    if (webSocket) {
        return;
    }
    webSocket = [[SRWebSocket alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:%d",Khost,Kport]]];
    webSocket.delegate = self;
    
    //设置代理线程queue
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 1;
    [webSocket setDelegateOperationQueue:queue];
    
    //连接
    [webSocket open];
}

//初始化心跳
- (void)initHeartBeat {
    
    dispatch_main_async_safe(^{
        __weak typeof(self) weakSelf = self;
        [weakSelf destroyHeartBeat];
        //心跳设置为3分钟，NAT超时一般为5分钟
        heartBeat = [NSTimer scheduledTimerWithTimeInterval:3*60 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"心跳");
            //和服务器端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
            [weakSelf sendMsg:@"heart"];
        }];
        [[NSRunLoop currentRunLoop] addTimer:heartBeat forMode:NSRunLoopCommonModes];
    })
    
}

//销毁心跳
- (void)destroyHeartBeat {
    
    dispatch_main_async_safe(^{
        if (heartBeat) {
            [heartBeat invalidate];
            heartBeat = nil;
        }
    })
    
}

#pragma mark ---------- 连接服务器

- (void)connect {
    
    [self initSocket];
    //每次正常连接的时候清零重连时间
    reConnectTime = 0;
    
}

#pragma mark ---------- 断开服务器

- (void)disconnect {
    
    if (webSocket) {
        [webSocket close];
        webSocket = nil;
    }
    
}

#pragma mark ---------- 发送消息

- (void)sendMsg:(NSString *)msg {
    
    [webSocket send:msg];
   
}

#pragma mark ---------- 重连机制

- (void)reConnect {
    
    [self disconnect];
    //超过一分钟就不再重连 所以只会重连5次 2^5 = 64
    if (reConnectTime > 64) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        webSocket = nil;
        [self initSocket];
    });
    
    if (reConnectTime == 0) {
        reConnectTime = 2;
    } else {
        reConnectTime *= 2;
    }
    
}


#pragma mark ---------- 获取信息



- (void)ping {
    
    [webSocket sendPing:nil];
    
}


#pragma mark ---------- SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"服务器返回收到信息：%@",message);
    
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"连接成功");
    //连接成功了开始心跳
    [self initHeartBeat];
}

//open失败的时候调用
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"连接失败。。。。\n%@",error);
    
    //失败了就去重连
    [self reConnect];
}

//网络连接中断就被调用
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
     NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",code,reason,wasClean);
    
    if (code == disConnectByUser) {
        [self disconnect];
    } else {
        [self reConnect];
    }
    
    //断开连接时销毁心跳
    [self destroyHeartBeat];
}

//sendPing的时候，如果网络通的话，则会收到回调，但是必须保证SocketOpen,否则会Crash
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"收到pong回调");
}

//将收到的消息，是否需要把data转换为nsstring,每次收到消息都会被调用，默认YES
//- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket {
//    return NO;
//}

@end
