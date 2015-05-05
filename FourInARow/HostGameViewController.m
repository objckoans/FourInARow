//
//  HostGameViewController.m
//  FourInARow
//
//  Created by Calvin Cheng on 3/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import "HostGameViewController.h"
#import "CocoaAsyncSocket/GCDAsyncSocket.h"
#import "Packet.h"

@interface HostGameViewController () <NSNetServiceDelegate, GCDAsyncSocketDelegate>

@property (strong, nonatomic) NSNetService *service;
@property (strong, nonatomic) GCDAsyncSocket *socket;

@end

@implementation HostGameViewController

- (void)cancel:(id)sender {
    [self.delegate controllerDidCancelHosting:self];
    [self endBroadcast];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupView {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self startBroadcast];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)startBroadcast {
    // Initialize GCDAsyncSocket
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Start Listening for Incoming Connections
    NSError *error = nil;
    if ([self.socket acceptOnPort:0 error:&error]) {
        // Initialize Service
        self.service = [[NSNetService alloc] initWithDomain:@"local." type:@"_fourinarow._tcp." name:@"" port:[self.socket localPort]];
        
        // Configure Service
        [self.service setDelegate:self];
        
        // Publish Service
        [self.service publish];
        
    } else {
        NSLog(@"Unable to create socket. Error %@ with user info %@.", error, [error userInfo]);
    }
}

// NSNetServiceDelegate methods
- (void)netServiceDidPublish:(NSNetService *)service {
    NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
}

- (void)netService:(NSNetService *)service didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@", [service domain], [service type], [service name], errorDict);
}

// GCDAsyncSocketDelegate methods
- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"Accepted New Socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    [self.delegate controller:self didHostGameSocket:newSocket];
    [self endBroadcast];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)endBroadcast {
    if (self.socket) {
        [self.socket setDelegate:nil delegateQueue:NULL];
        [self setSocket:nil];
    }
    
    if (self.service) {
        [self.service setDelegate:nil];
        [self setService:nil];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.socket == socket) {
        [self.socket setDelegate:nil];
        [self setSocket:nil];
    }
}

- (void)sendPacket:(Packet *)packet {
    NSLog(@"HostGameViewController sendPacket");
    // Encode packet data
    NSMutableData *packetData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:packetData];
    [archiver encodeObject:packet forKey:@"packet"];
    [archiver finishEncoding];
    
    // Initiaize Buffer
    NSMutableData *buffer = [[NSMutableData alloc] init];
    
    // Fill Buffer
    uint64_t headerLength = [packetData length];
    [buffer appendBytes:&headerLength length:sizeof(uint64_t)];
    [buffer appendBytes:[packetData bytes] length:[packetData length]];
    
    // Write Buffer
    [self.socket writeData:buffer withTimeout:-1.0 tag:0];
}

- (void)dealloc {
    if (_delegate) {
        _delegate = nil;
    }
    
    if (_socket) {
        [_socket setDelegate:nil delegateQueue:NULL];
        _socket = nil;
    }
}

@end