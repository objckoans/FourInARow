//
//  GameController.h
//  FourInARow
//
//  Created by Calvin Cheng on 5/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@protocol GameControllerDelegate;

@interface GameController : NSObject

@property (weak, nonatomic) id delegate;

- (id)initWithSocket:(GCDAsyncSocket *)socket;

- (void)testConnection;

@end

@protocol GameControllerDelegate <NSObject>

- (void)controllerDidDisconnect:(GameController *)controller;

@end