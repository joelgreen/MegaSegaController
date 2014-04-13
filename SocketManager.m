//
//  SocketManager.m
//  SuperChat
//
//  Created by Joel Green on 1/11/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import "SocketManager.h"

#define HOST @"23.236.155.170"
#define PORT 7331
#define TERMINATOR @"e958248b"


//#define HOST @"localhost"
//#define PORT 6542 mikes balls

@interface SocketManager()

@property GCDAsyncSocket *socket;

@end

@implementation SocketManager

- (NSData *)incomingMessage
{
    if (!_incomingMessage) {
        _incomingMessage = [[NSData alloc] init];
    }
    return _incomingMessage;
}

- (id)init
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *err = nil;
    if (![self.socket connectToHost:HOST onPort:PORT error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
    }
    
    self.socket.delegate = self;
        
    [self.socket readDataWithTimeout:-1 tag:0];
    return self;
}

- (void)sendCommand:(NSDictionary *)commandDict
{
    //json format { “command” : “key”, “type” : “up”, “user” : “0123”, “keyCode” : “88”}
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:commandDict options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableData *data1 = [NSMutableData dataWithData:data];
    NSData *terminator = [TERMINATOR dataUsingEncoding:NSUTF8StringEncoding];
    
    [data1 appendData:terminator];
    
    [self.socket writeData:data1
               withTimeout:-1
                       tag:1];
    
    NSLog(@"%@",[[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding]);
}


- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    [self handleIncommingMessage:data];
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)handleIncommingMessage:(NSData *)message
{
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:message options:0 error:nil];
    NSLog(@"Parsed object in SocketManager.handleIncommingMessage: %@",parsedObject);
    
    @try {
        //this is a hackathon so suck my balls mother fuckers
        NSString *playerNumber = [parsedObject objectForKey:@"playerNumber"];
        if ([playerNumber isEqualToString:@"1"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SetToPlayer1" object:self];
        } else if ([playerNumber isEqualToString:@"2"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SetToPlayer2" object:self];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
}


- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Conntected to host: %@, on port: %d",HOST,PORT);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didConnectToSocket" object:nil userInfo:nil];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"Socket Disconnected, attempting to reconnect");
    if (![self.socket connectToHost:HOST onPort:PORT error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
    }
    
    [self.socket readDataWithTimeout:-1 tag:0];
    
    //TODO: Notify that the socket reconnected so that we can resend the subscribed chatrooms
}


@end
