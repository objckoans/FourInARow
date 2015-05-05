//
//  JoinGameTableViewController.h
//  FourInARow
//
//  Created by Calvin Cheng on 3/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCDAsyncSocket;
@protocol JoinGameViewControllerDelegate;

@interface JoinGameTableViewController : UITableViewController

@property (weak, nonatomic) id delegate;

@end

@protocol JoinGameViewControllerDelegate
- (void)controller:(JoinGameTableViewController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket;
- (void)controllerDidCancelJoining:(JoinGameTableViewController *)controller;
@end