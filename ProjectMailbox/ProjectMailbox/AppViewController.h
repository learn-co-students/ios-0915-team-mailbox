//
//  AppViewController.h
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import <Masonry/Masonry.h>
#import <MMDrawerController/MMDrawerController.h>
#import <MMDrawerController/MMDrawerVisualState.h>
#import "AppDelegate.h"

@interface AppViewController : ViewController

- (BOOL)prefersStatusBarHidden;
- (void)showMainPage;
- (void)showFirstPage;
- (void)showCreateBoardPage;
- (void)handleUserDidLogOut:(NSNotification *)notification;
- (void)handleUserDidLogInWithBoards:(NSNotification *)notification;
- (void)handleUserDidSignUp:(NSNotification *)notification;
- (void)setEmbeddedViewController:(UIViewController *)controller;

@end
