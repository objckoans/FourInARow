//
//  ViewController.m
//  FourInARow
//
//  Created by Calvin Cheng on 3/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import "ViewController.h"
#import "HostGameViewController.h"
#import "JoinGameTableViewController.h"

// make our ViewController conform to HostGameViewControllerDelegate and JoinGameViewControllerDelegate
@interface ViewController () <HostGameViewControllerDelegate, JoinGameViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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

// HostGameViewControllerDelegate methods
- (void)controller:(HostGameViewController *)controller didHostGameSocket:(GCDAsyncSocket *)socket {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)controllerDidCancelHosting:(HostGameViewController *)controller {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// JoinGameViewControllerDelegate methods
- (void)controller:(JoinGameTableViewController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)controllerDidCancelJoining:(JoinGameTableViewController *)controller {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end