//
//  CreateBoardViewController.h
//  ProjectMailbox
//
//  Created by Flatiron on 12/6/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "PAPUtility.h"
#import "TMBFriendsTableViewCell.h"
#import "TMBSideMenuViewController.h"
#import "TMBManageBoardsViewController.h"

@interface CreateBoardViewController : ViewController

@property (strong, nonatomic) PFObject *myNewBoard;
@property (nonatomic, strong) NSString *boardObjectId;
@property (nonatomic, strong) NSMutableArray *friendsForCurrentUser;
@property (nonatomic, strong) NSMutableArray *boardFriends;
@property (nonatomic, strong) NSMutableArray *duplicateFriends;
@property (nonatomic, strong) PFUser *foundFriend;
@property (nonatomic, strong) PFUser *currentUser;

// from a segue:
@property (strong, nonatomic) PFObject *selectedBoard;
@property (nonatomic, strong) NSString *boardObjectIdFromSelectedBoard;
@property (nonatomic, strong) NSString *boardNameToDisplay;
@property (nonatomic, strong) NSMutableArray *boardFriendsToDisplay;
@property (nonatomic) BOOL shouldHideSaveBoardButton;
@property (nonatomic) BOOL shouldHideCancelButton;

@end
