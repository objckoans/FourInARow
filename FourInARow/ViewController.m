//
//  ViewController.m
//  FourInARow
//
//  Created by Calvin Cheng on 3/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import "ViewController.h"

#import "BoardCell.h"
#import "GameController.h"
#import "HostGameViewController.h"
#import "JoinGameTableViewController.h"

#define kMatrixWidth 7
#define kMatrixHeight 6

// make our ViewController conform to HostGameViewControllerDelegate and JoinGameViewControllerDelegate
@interface ViewController () <GameControllerDelegate, HostGameViewControllerDelegate, JoinGameViewControllerDelegate>

@property (assign, nonatomic) GameState gameState;
@property (strong, nonatomic) GameController *gameController;

@property (strong, nonatomic) NSArray *board;
@property (strong, nonatomic) NSMutableArray *matrix;

@end

@implementation ViewController

- (void)addDiscToColumn:(NSInteger)column withType:(BoardCellType)cellType {
    // Update Matrix
    NSMutableArray *columnArray = [self.matrix objectAtIndex:column];
    [columnArray addObject:@(cellType)];
    
    // Update Cells
    BoardCell *cell = [[self.board objectAtIndex:column] objectAtIndex:([columnArray count] - 1)];
    [cell setCellType:cellType];
}

// Infer the column based on coordinates of `point`
- (NSInteger)columnForPoint:(CGPoint)point {
    return floorf(point.x / floorf(self.boardView.frame.size.width / kMatrixWidth));
}

- (void)addDiscToColumn:(UITapGestureRecognizer *)tgr {
    if (self.gameState >= GameStateIWin) {
        // notify players
    } else if (self.gameState != GameStateMyTurn) {
        // not your turn (not current player's turn)
        NSString *message = NSLocalizedString(@"It's not your turn", nil);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        // update game state, send packet, notify players if some one has won the game
        NSInteger column = [self columnForPoint:[tgr locationInView:tgr.view]];
        [self addDiscToColumn:column withType:BoardCellTypeMine];
    }
}

- (void)resetGame {
    [self.replayButton setHidden:YES];
    
    CGSize size = self.boardView.frame.size;
    CGFloat cellWidth = floorf(size.width / kMatrixWidth);
    CGFloat cellHeight = floorf(size.height / kMatrixHeight);
    NSMutableArray *buffer = [[NSMutableArray alloc] initWithCapacity:kMatrixWidth];
    
    for (int i = 0; i < kMatrixWidth; i++) {
        NSMutableArray *column = [[NSMutableArray alloc] initWithCapacity:kMatrixHeight];
        
        for (int j = 0; j < kMatrixHeight; j++) {
            CGRect frame = CGRectMake(i * cellWidth, (size.height - ((j + 1) * cellHeight)), cellWidth, cellHeight);
            BoardCell *cell = [[BoardCell alloc] initWithFrame:frame];
            [cell setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
            [self.boardView addSubview:cell];
            [column addObject:cell];
        }
        
        [buffer addObject:column];
    }
    
    // Initialize board
    self.board = [[NSArray alloc] initWithArray:buffer];
    
    // Initialize matrix
    self.matrix = [[NSMutableArray alloc] initWithCapacity:kMatrixWidth];
    
    for (int i = 0; i < kMatrixWidth; i++) {
        NSMutableArray *column = [[NSMutableArray alloc] initWithCapacity:kMatrixHeight];
        [self.matrix addObject:column];
    }
}

- (void)setupView {
    [self resetGame];
    
    // configure subviews
    [self.disconnectButton setHidden:YES];
    [self.replayButton setHidden:YES];
    [self.boardView setHidden:YES];
    [self.gameStateLabel setHidden:YES];
    
    // Add tap gesture recognizer
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addDiscToColumn:)];
    [self.boardView addGestureRecognizer:tgr];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide disconnectButton and replayButton
    [self setupView];
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

- (IBAction)disconnect:(id)sender {
    [self endGame];
}

- (IBAction)replay:(id)sender {
}

- (void)startGameWithSocket:(GCDAsyncSocket *)socket {
    self.gameController = [[GameController alloc] initWithSocket:socket];
    [self.gameController setDelegate:self];
    
    // Hide or Show buttons
    [self.boardView setHidden:NO];
    [self.hostButton setHidden:YES];
    [self.joinButton setHidden:YES];
    [self.disconnectButton setHidden:NO];
    [self.gameStateLabel setHidden:NO];
}

- (void)endGame {
    [self.gameController setDelegate:nil];
    [self setGameController:nil];
    
    // Hide or Show
    [self.boardView setHidden:YES];
    [self.hostButton setHidden:NO];
    [self.joinButton setHidden:NO];
    [self.disconnectButton setHidden:YES];
    [self.gameStateLabel setHidden:YES];
}

// HostGameViewControllerDelegate methods
- (void)controller:(HostGameViewController *)controller didHostGameSocket:(GCDAsyncSocket *)socket {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self startGameWithSocket:socket];
    
    // Let's test our connection
    [self.gameController testConnection];
}

- (void)controllerDidCancelHosting:(HostGameViewController *)controller {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// JoinGameViewControllerDelegate methods
- (void)controller:(JoinGameTableViewController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self startGameWithSocket:socket];
}

- (void)controllerDidCancelJoining:(JoinGameTableViewController *)controller {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// GameControllerDelegate methods
- (void)controllerDidDisconnect:(GameController *)controller {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self endGame];
}

@end