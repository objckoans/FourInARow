//
//  BoardCell.m
//  FourInARow
//
//  Created by Calvin Cheng on 5/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import "BoardCell.h"

@implementation BoardCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.cellType = BoardCellTypeEmpty;
    }
    
    return self;
}

- (void)setCellType:(BoardCellType)cellType {
    if (_cellType != cellType) {
        _cellType = cellType;
        [self updateView];
    }
}

- (void)updateView {
    self.backgroundColor = (self.cellType = BoardCellTypeMine) ? [UIColor yellowColor] : (self.cellType == BoardCellTypeYours) ? [UIColor redColor] : [UIColor whiteColor];
}

@end
