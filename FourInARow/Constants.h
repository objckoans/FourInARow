//
//  Constants.h
//  FourInARow
//
//  Created by Calvin Cheng on 5/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

typedef enum {
    GameStateUnknown = -1,
    GameStateMyTurn,
    GameStateYourTurn,
    GameStateIWin,
    GameStateYouWin
} GameState;