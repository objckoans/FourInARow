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

- (void)addDiscToColumn:(UITapGestureRecognizer *)tgr {
    
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
    [self.hostButton setHidden:YES];
    [self.joinButton setHidden:YES];
    [self.disconnectButton setHidden:NO];
}

- (void)endGame {
    [self.gameController setDelegate:nil];
    [self setGameController:nil];
    
    // Hide or Show buttons
    [self.hostButton setHidden:NO];
    [self.joinButton setHidden:NO];
    [self.disconnectButton setHidden:YES];
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