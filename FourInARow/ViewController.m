//
//  ViewController.m
//  FourInARow
//
//  Created by Calvin Cheng on 3/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import "ViewController.h"
#import "GameController.h"
#import "HostGameViewController.h"
#import "JoinGameTableViewController.h"

// make our ViewController conform to HostGameViewControllerDelegate and JoinGameViewControllerDelegate
@interface ViewController () <GameControllerDelegate, HostGameViewControllerDelegate, JoinGameViewControllerDelegate>

@property (strong, nonatomic) GameController *gameController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide disconnectButton and replayButton
    [self.disconnectButton setHidden:YES];
    [self.replayButton setHidden:YES];
    [self.boardView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)hostGame:(id)sender {
    HostGameViewController *hc = [[HostGameViewController alloc] init];
    [hc setDelegate:self];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:hc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (IBAction)joinGame:(id)sender {
    JoinGameTableViewController *jc = [[JoinGameTableViewController alloc] init];
    [jc setDelegate:self];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:jc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (IBAction)disconnect:(id)sender {
    [self endGame];
}

- (IBAction)replay:(id)sender {
}

- (void)startGameWithSocket:(GCDAsyncSocket *)socket {
    self.gameController = [[GameController alloc] initWithSocket:socket];
    [self.gameController setDelegate:self];
    
    // Hide or Show buttons
    [self.hostButton setHidden:YES];
    [self.joinButton setHidden:YES];
    [self.disconnectButton setHidden:NO];
}

- (void)endGame {
    [self.gameController setDelegate:nil];
    [self setGameController:nil];
    
    // Hide or Show buttons
    [self.hostButton setHidden:NO];
    [self.joinButton setHidden:NO];
    [self.disconnectButton setHidden:YES];
}

// HostGameViewControllerDelegate methods
- (void)controller:(HostGameViewController *)controller didHostGameSocket:(GCDAsyncSocket *)socket {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self startGameWithSocket:socket];
    
    // Let's test our connection
    [self.gameController testConnection];
}

- (void)controllerDidCancelHosting:(HostGameViewController *)controller {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// JoinGameViewControllerDelegate methods
- (void)controller:(JoinGameTableViewController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self startGameWithSocket:socket];
}

- (void)controllerDidCancelJoining:(JoinGameTableViewController *)controller {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// GameControllerDelegate methods
- (void)controllerDidDisconnect:(GameController *)controller {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self endGame];
}

@end