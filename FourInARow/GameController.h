//
//  GameController.h
//  FourInARow
//
//  Created by Calvin Cheng on 5/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;

@interface GameController : NSObject

- (id)initWithSocket:(GCDAsyncSocket *)socket;

@end
