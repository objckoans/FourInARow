//
//  HostGameViewController.h
//  FourInARow
//
//  Created by Calvin Cheng on 3/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCDAsyncSocket;
@protocol HostGameViewControllerDelegate;

@interface HostGameViewController : UIViewController

@property (weak, nonatomic) id delegate;

@end

@protocol HostGameViewControllerDelegate
- (void)controller:(HostGameViewController *)controller didHostGameSocket:(GCDAsyncSocket *)socket;
- (void)controllerDidCancelHosting:(HostGameViewController *)controller;
@end