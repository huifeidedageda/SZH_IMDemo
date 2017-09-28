//
//  MQTTManager.h
//  SZH_IMDemo1
//
//  Created by 智衡宋 on 2017/9/28.
//  Copyright © 2017年 智衡宋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQTTManager : NSObject

+ (instancetype)manager;

//连接
- (void)connect;
//断开
- (void)disConnect;
//发送消息
- (void)sendMsg:(NSString *)msg;

@end
