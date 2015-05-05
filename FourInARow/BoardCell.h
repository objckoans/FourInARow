//
//  BoardCell.h
//  FourInARow
//
//  Created by Calvin Cheng on 5/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BoardCellTypeEmpty = -1,
    BoardCellTypeMine,
    BoardCellTypeYours
} BoardCellType;

@interface BoardCell : UIView

@property (assign, nonatomic) BoardCellType cellType;

@end
