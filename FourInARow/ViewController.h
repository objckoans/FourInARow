//
//  ViewController.h
//  FourInARow
//
//  Created by Calvin Cheng on 3/5/15.
//  Copyright (c) 2015 Hello HQ Pte. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)hostGame:(id)sender;
- (IBAction)joinGame:(id)sender;
- (IBAction)disconnect:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *hostButton;
@property (strong, nonatomic) IBOutlet UIButton *joinButton;
@property (strong, nonatomic) IBOutlet UIButton *disconnectButton;


@end

