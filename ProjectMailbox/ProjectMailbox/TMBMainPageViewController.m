//
//  TMBMainPageViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 11/29/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBMainPageViewController.h"
#import <MMDrawerController/MMDrawerController.h>

@implementation TMBMainPageViewController

- (void)viewDidLoad {
    
    UIViewController *leftDrawer = [[UIViewController alloc]init];
    
    UIViewController *center = [[UIViewController alloc]init];
    
    MMDrawerController *drawerController = [[MMDrawerController alloc]initWithCenterViewController:center leftDrawerViewController:leftDrawer];
    
}

- (IBAction)logOutButtonTapped:(id)sender {
    
    [PFUser logOut];
    
    [self performSegueWithIdentifier:@"ReturnToIntro" sender:nil];
    
}


@end
