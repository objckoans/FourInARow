//
//  JoinGameViewController.m
//  FourInARow
//
//  Created by Calvin Cheng on 3/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import "JoinGameViewController.h"
#import "CocoaAsyncSocket/GCDAsyncSocket.h"

@interface JoinGameViewController () <NSNetServiceDelegate, NSNetServiceBrowserDelegate, GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;

@end

@implementation JoinGameViewController

- (void)startBrowsing {
    if (self.services) {
        [self.services removeAllObjects];
    } else {
        self.services = [[NSMutableArray alloc] init];
    }
    
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [self.serviceBrowser setDelegate:self];
    [self.serviceBrowser searchForServicesOfType:@"_fourinarow._tcp" inDomain:@"local."];
}

- (void)stopBrowsing {
    // do something that stops our NSNetServiceBrowser
    NSLog(@"Stop browsing");
    if (self.serviceBrowser) {
        [self.serviceBrowser stop];
        [self.serviceBrowser setDelegate:nil];
        [self setServiceBrowser:nil];
    }
}

- (void)cancel:(id)sender {
    [self stopBrowsing];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupView {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self startBrowsing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// NSNetServiceBrowserDelegate methods
- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Update Services
    [self.services addObject:service];
    
    if(!moreComing) {
        // Sort Services
        [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        
        // Update Table View
        NSLog(@"Update table with located services");
        //[self.tableView reloadData];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Update Services
    [self.services removeObject:service];
    
    if(!moreComing) {
        // Update Table View
        NSLog(@"Update table when services are removed");
        // [self.tableView reloadData];
    }
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)serviceBrowser {
    [self stopBrowsing];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didNotSearch:(NSDictionary *)userInfo {
    [self stopBrowsing];
}

// NSNetServiceDelegate methods
- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    [service setDelegate:nil];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    // Connect With Service
    if ([self connectWithService:service]) {
        NSLog(@"Did Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
    } else {
        NSLog(@"Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
    }
}

// Custom method to determine whether connection is successful
- (BOOL)connectWithService:(NSNetService *)service {
    BOOL _isConnected = NO;
    
    // Copy Service Addresses
    NSArray *addresses = [[service addresses] mutableCopy];
    
    if (!self.socket || ![self.socket isConnected]) {
        // Initialize Socket
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // Connect
        while (!_isConnected && [addresses count]) {
            NSData *address = [addresses objectAtIndex:0];
            
            NSError *error = nil;
            if ([self.socket connectToAddress:address error:&error]) {
                _isConnected = YES;
                
            } else if (error) {
                NSLog(@"Unable to connect to address. Error %@ with user info %@.", error, [error userInfo]);
            }
        }
        
    } else {
        _isConnected = [self.socket isConnected];
    }
    
    return _isConnected;
}

// GCDAsyncSocketDelegate methods
- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
    
    // Start Reading
    [socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    NSLog(@"Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
    
    [socket setDelegate:nil];
    [self setSocket:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
