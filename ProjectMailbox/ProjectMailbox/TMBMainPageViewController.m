//
//  TMBMainPageViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 11/29/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBMainPageViewController.h"
#import <MMDrawerController/MMDrawerController.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@end

@implementation TMBMainPageViewController

- (void)viewDidLoad {
    
    
}

- (IBAction)logOutButtonTapped:(id)sender {
    
    [PFUser logOut];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogOutNotification" object:nil];
    
}

- (IBAction)menuButtonTapped:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHamburgerMenuNotification" object:nil];
    
}

@end