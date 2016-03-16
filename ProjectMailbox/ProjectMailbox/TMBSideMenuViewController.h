//
//  TMBSideMenuViewController.h
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "ViewController.h"
#import <MMDrawerController/MMDrawerController.h>
#import <Parse/Parse.h>
#import "TMBBoard.h"
#import "TMBSharedBoardID.h"
#import "TMBBoardTableViewCell.h"
#import "TMBBoardController.h"
#import "AppViewController.h"

@interface TMBSideMenuViewController : ViewController

@property (nonatomic) NSInteger boardCount;
@property (strong, nonatomic) NSMutableArray *userBoards;
@property (strong, nonatomic) NSString *boardID;

- (void)deleteButtonTappedInCreateBoardVC:(NSNotification *)notification;
- (void)saveButtonTappedInCreateBoardVC:(NSNotification *)notification;
- (void)newBoardCreatedInCreateBoardVC:(NSNotification *)notification;
- (void)checkInternetConnection;
- (void)adjustHeightOfTableview;


@end
