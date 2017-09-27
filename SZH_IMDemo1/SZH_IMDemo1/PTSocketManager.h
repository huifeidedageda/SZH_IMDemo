//
//  PTSocketManager.h
//  SZH_IMDemo1
//
//  Created by 智衡宋 on 2017/9/27.
//  Copyright © 2017年 智衡宋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTSocketManager : NSObject

+ (instancetype)manager;

//连接服务器
- (void)connect;
//断开连接
- (void)disconnect;
//发送消息
- (void)sendMsg:(NSString *)msg;
//接受消息
- (void)pullMsg;

@end
