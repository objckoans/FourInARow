//
//  Packet.h
//  FourInARow
//
//  Created by Calvin Cheng on 4/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const PacketKeyData;
extern NSString * const PacketKeyType;
extern NSString * const PackeyKeyAction;

typedef enum {
    PacketTypeUnknown = -1
} PacketType;

typedef enum {
    PacketActionUnknown = -1
} PacketAction;

@interface Packet : NSObject <NSCoding>

@property (strong, nonatomic) id data;
@property (assign, nonatomic) PacketType type;
@property (assign, nonatomic) PacketAction action;

- (id)initWithData:(id)data type:(PacketType)type action:(PacketAction)action;

@end
