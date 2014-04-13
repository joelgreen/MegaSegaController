//
//  SocketManager.h
//  SuperChat
//
//  Created by Joel Green on 1/11/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"


@interface SocketManager : NSObject <UIApplicationDelegate, GCDAsyncSocketDelegate>

@property (nonatomic, strong)NSData *incomingMessage;

- (void)sendCommand:(NSDictionary *)command;


@end
