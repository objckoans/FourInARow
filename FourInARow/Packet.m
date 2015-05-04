//
//  Packet.m
//  FourInARow
//
//  Created by Calvin Cheng on 4/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import "Packet.h"

NSString * const PacketKeyData = @"data";
NSString * const PacketKeyType = @"type";
NSString * const PacketKeyAction = @"action";

@implementation Packet

- (id)initWithData:(id)data type:(PacketType)type action:(PacketAction)action {
    self = [super init];
    
    if (self) {
        self.data = data;
        self.type = type;
        self.action = action;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.data forKey:PacketKeyData];
    [aCoder encodeInteger:self.type forKey:PacketKeyType];
    [aCoder encodeInteger:self.action forKey:PacketKeyAction];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        [self setData:[aDecoder decodeObjectForKey:PacketKeyData]];
        [self setType:[aDecoder decodeIntForKey:PacketKeyType]];
        [self setAction:[aDecoder decodeIntForKey:PacketKeyAction]];
    }
    
    return self;
}

@end