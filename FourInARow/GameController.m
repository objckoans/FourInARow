//
//  GameController.m
//  FourInARow
//
//  Created by Calvin Cheng on 5/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import "GameController.h"
#import "Packet.h"
#import "CocoaAsyncSocket/GCDAsyncSocket.h"

#define TAG_HEAD 0
#define TAG_BODY 1

@interface GameController() <GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;

@end

@implementation GameController

- (id)initWithSocket:(GCDAsyncSocket *)socket {
    self = [super init];
    
    if (self) {
        self.socket = socket;
        self.socket.delegate = self;
        [self.socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:TAG_HEAD];
    }
    
    return self;
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.socket == sock) {
        [self.socket setDelegate:nil];
        [self setSocket:nil];
    }

}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (self.socket == sock) {
        if (tag == 0) {
            uint64_t bodyLength = [self parseHeader:data];
            [sock readDataToLength:bodyLength withTimeout:-1.0 tag:1];
        } else if (tag == 1) {
            [self parseBody:data];
            [sock readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
        }
    }
}

- (void)sendPacket:(Packet *)packet {
    // Encode Packet Data
    NSMutableData *packetData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:packetData];
    [archiver encodeObject:packet forKey:@"packet"];
    [archiver finishEncoding];
    
    // Initialize Buffer
    NSMutableData *buffer = [[NSMutableData alloc] init];
    
    // Fill Buffer
    uint64_t headerLength = [packetData length];
    [buffer appendBytes:&headerLength length:sizeof(uint64_t)];
    [buffer appendBytes:[packetData bytes] length:[packetData length]];
    
    // Write Buffer
    [self.socket writeData:buffer withTimeout:-1.0 tag:0];
}

- (uint64_t)parseHeader:(NSData *)data {
    uint64_t headerLength = 0;
    memcpy(&headerLength, [data bytes], sizeof(uint64_t));
    
    return headerLength;
}

- (void)parseBody:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    Packet *packet = [unarchiver decodeObjectForKey:@"packet"];
    [unarchiver finishDecoding];
    
    NSLog(@"Packet Data > %@", packet.data);
    NSLog(@"Packet Type > %i", packet.type);
    NSLog(@"Packet Action > %i", packet.action);
}

- (void)dealloc {
    if (_socket) {
        [_socket setDelegate:nil delegateQueue:NULL];
        [_socket disconnect];
        _socket = nil;
    }
}

@end