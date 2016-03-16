//
//  TMBFindFriendsViewController.h
//  ProjectMailbox
//
//  Created by Flatiron on 12/10/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "ViewController.h"
#import "PAPUtility.h"
#import "TMBFriendsTableViewCell.h"

@interface TMBFindFriendsViewController : ViewController

@property (nonatomic, strong) PFUser *foundFriend;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *friendsForCurrentUser;

- (BOOL)prefersStatusBarHidden;
- (void)checkInternetConnection;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)pushDownFriendsTable;
- (void)displayAlert;
- (void)adjustHeightOfTableview;

@end
