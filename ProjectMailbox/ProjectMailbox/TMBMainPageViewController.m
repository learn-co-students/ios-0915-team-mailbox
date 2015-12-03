//
//  TMBMainPageViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 11/29/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBMainPageViewController.h"
#import <MMDrawerController/MMDrawerVisualState.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import <MMDrawerController/MMDrawerController.h>
#import <MMDrawerController/MMDrawerBarButtonItem.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@end

@implementation TMBMainPageViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupLeftMenuButton];

}

- (IBAction)logOutButtonTapped:(id)sender {
    
    [PFUser logOut];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogOutNotification" object:nil];
    
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
@end