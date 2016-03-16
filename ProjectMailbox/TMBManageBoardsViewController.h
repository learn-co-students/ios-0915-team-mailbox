//
//  TMBManageBoardsViewController.h
//  ProjectMailbox
//
//  Created by Flatiron on 1/5/16.
//  Copyright © 2016 Joseph Kiley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMBBoardTableViewCell.h"
#import <Parse/Parse.h>
#import "CreateBoardViewController.h"

@interface TMBManageBoardsViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *adminBoards;
@property (strong, nonatomic) NSMutableArray *adminBoardFriends;
@property (strong, nonatomic) NSMutableArray *memberBoards;
@property (strong, nonatomic) NSString *boardID;

- (BOOL)prefersStatusBarHidden;
- (void)deleteButtonTappedInCreateBoardVC:(NSNotification *)notification;
- (void)saveButtonTappedInCreateBoardVC:(NSNotification *)notification;
- (void)checkInternetConnection;
- (void)adjustHeightOfTableview;

@end
