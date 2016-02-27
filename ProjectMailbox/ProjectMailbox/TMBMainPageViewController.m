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

@end

@implementation TMBMainPageViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@" I'M IN THE VIEW DID LOAD, MAIN PAGE VIEW CONTROLLER");
    
    [self setupLeftMenuButton];
}


- (void)setupLeftMenuButton {
    
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}


- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


- (IBAction)addButtonTapped:(id)sender {
    
    UIAlertController *view = [UIAlertController
                               alertControllerWithTitle:@"Add to your Mosaic"
                               message:@""
                               preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *picture = [UIAlertAction
                              actionWithTitle:@"Picture"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  UIViewController *pictureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TMBImageCardViewController"];
                                  [self presentViewController:pictureVC animated:YES completion:nil];
                                  [view dismissViewControllerAnimated:YES completion:nil];
                              }];
    
    UIAlertAction *text = [UIAlertAction
                           actionWithTitle:@"Text"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               UIViewController *textVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TMBTextCardViewController"];
                               [self presentViewController:textVC animated:YES completion:nil];
                               [view dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    UIAlertAction *doodle = [UIAlertAction
                            actionWithTitle:@"Doodle"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                UIViewController *doodleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TMBDoodleViewController"];
                                [self presentViewController:doodleVC animated:YES completion:nil];
                                [view dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    
    [view addAction:picture];
    [view addAction:text];
    [view addAction:doodle];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
    
}



@end


