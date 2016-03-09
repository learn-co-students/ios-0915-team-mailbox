//
//  CreateBoardViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 12/6/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "CreateBoardViewController.h"
#import "TMBConstants.h"
#import "PAPUtility.h"
#import "TMBFriendsTableViewCell.h"
#import "TMBSideMenuViewController.h"
#import "TMBManageBoardsViewController.h"
#import "TMBSharedBoardID.h"


@interface CreateBoardViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *boardNameField;
@property (weak, nonatomic) IBOutlet UILabel *boardNameLabel;
@property (strong, nonatomic) PFObject *myNewBoard;
@property (nonatomic, strong) NSString *boardObjectId;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *boardFriendsTableView;
@property (nonatomic, strong) NSMutableArray *friendsForCurrentUser;
@property (nonatomic, strong) NSMutableArray *boardFriends;
@property (nonatomic, strong) NSMutableArray *duplicateFriends;
@property (nonatomic, strong) PFUser *foundFriend;
@property (nonatomic, strong) PFUser *currentUser;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lookUpFriendsLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveBoardButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

// Found a Friend View
@property (weak, nonatomic) IBOutlet UIImageView *foundFriendImage;
@property (weak, nonatomic) IBOutlet UILabel *foundFriendUsernameLabel;
@property (weak, nonatomic) IBOutlet UIView *foundFriendView;
@property (weak, nonatomic) IBOutlet UILabel *noUsersFoundLabel;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vertSpaceConstraint01;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *friendSearchLabelConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vertSpaceConstraint02;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *friendSearchViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vertSpaceConstraint03;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vertSpaceConstraint04;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveBtnConstraint;

@end


@implementation CreateBoardViewController



- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    NSLog(@" I'M IN THE VIEW DID APPEAR, CREATE BOARD VIEW CONTROLLER");
    
    [self adjustHeightOfTableview];

}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self checkInternetConnection];
    
    [self prefersStatusBarHidden];
    
    NSLog(@" I'M IN THE VIEW DID LOAD, CREATE BOARD VIEW CONTROLLER");
    
    self.friendsForCurrentUser = [NSMutableArray new];
    self.boardFriends = [NSMutableArray new];
    self.duplicateFriends = [NSMutableArray new];
    
    self.boardFriendsTableView.delegate = self;
    self.boardFriendsTableView.dataSource = self;
    
    // dismisses the keyboard when Done/Search key is tapped:
    self.boardNameField.delegate = self;
    self.searchField.delegate = self;
    
    
    // following methods are if you're coming from a segue @"selectedBoard"
    if (self.selectedBoard) {
        self.myNewBoard = self.selectedBoard;
    }
    
    if (self.boardNameToDisplay) {
    self.boardNameLabel.text = self.boardNameToDisplay;
    self.boardNameField.placeholder = @"Edit Board's Name";
    }
    
    if (self.shouldHideCancelButton) {
        self.cancelButton.hidden = self.shouldHideCancelButton;
    }
    
    if (self.boardFriendsToDisplay) {
        self.boardFriends = self.boardFriendsToDisplay;
    }
    
    if (self.boardObjectIdFromSelectedBoard) {
        self.boardObjectId = self.boardObjectIdFromSelectedBoard;
        NSLog(@" !!!!!!!!!!!!!!!!!!!!!!!! BOARD OBJ ID IS %@", self.boardObjectId);
    }
    // end of segue methods
    
    else {
        
        [self createNewBoardOnParseWithCompletion:^(NSString *objectId, NSError *error) {
            if (!error) {
                NSLog(@" NEW BOARD IS CREATED. BOARD ID IS: %@", self.boardObjectId);
                self.boardObjectId = self.myNewBoard.objectId;
            }
        }];
    }
    
    
    
    // hiding found/notfound friends views:
    self.foundFriendView.hidden = YES;
    self.noUsersFoundLabel.hidden = YES;
    
    [[PFUser currentUser] fetchInBackground];
    self.currentUser = [PFUser currentUser];
    
    [self queryCurrentUserFriendsWithCompletion:^(NSMutableArray *users, NSError *error) {
        NSLog(@"%@", users);
        [self.boardFriendsTableView reloadData];
        [self adjustHeightOfTableview];
    }];
    
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}


- (void)checkInternetConnection {
    
    // check connection to a very small, fast loading site:
    NSURL *scriptUrl = [NSURL URLWithString:@"http://apple.com/contact"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (!data) {
        self.lookUpFriendsLabel.text = @"No Internet Connection";
        self.boardFriendsTableView.hidden = YES;
        self.saveBoardButton.hidden = YES;
        NSLog(@"Device is not connected to the internet");
        
    } else {
        NSLog(@"Device is connected to the internet");
    }
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // because there are 2 text fields in the VC:
    
    if (textField == self.boardNameField) {
        // Done key was pressed - dismiss keyboard
        [textField resignFirstResponder];
        return YES;
    } else {
        // Search key was pressed - dismiss keyboard, perform friend search
        [textField resignFirstResponder];
        [self searchFriendsButtonTapped:nil];
    }
    
    return YES;
}


- (IBAction)searchFriendsButtonTapped:(UIButton *)sender {
    
    // setting the textfield.text to the user name
    NSString *username = self.searchField.text;
    
    [self queryAllUsersWithUsername:username completion:^(NSArray *allFriends, NSError *error) {
        
        if (!error && allFriends.count > 0) {
            
            self.foundFriendView.hidden = NO;
            self.noUsersFoundLabel.hidden = YES;
            
            // setting foundFriends View to display a friend:
            
            PFUser *aFriend = [allFriends firstObject];
            self.foundFriend = aFriend;
            
            NSString *firstName = aFriend[@"First_Name"];
            NSString *lastName = aFriend[@"Last_Name"];
            
            self.foundFriendUsernameLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            // setting user profile photo:
            
            PFFile *imageFile = aFriend[@"profileImage"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *profileImage = [UIImage imageWithData:data];
                    self.foundFriendImage.image = profileImage;
                    // puts image in a circle:
                    self.foundFriendImage.contentMode = UIViewContentModeScaleAspectFill;
                    self.foundFriendImage.layer.cornerRadius = self.foundFriendImage.frame.size.width / 2;
                    self.foundFriendImage.clipsToBounds = YES;
                    
                }
            }];
            
        }
        
        if (allFriends.count == 0) {
            self.foundFriendView.hidden = YES;
            self.noUsersFoundLabel.text = [NSString stringWithFormat:@"No friends found with username: %@", username];
            self.noUsersFoundLabel.hidden = NO;
        }
        
    }];
    
    self.searchField.text = @"";
    [self.searchField resignFirstResponder];
    
}


- (IBAction)addFriendButtonTapped:(UIButton *)sender {
    
    // add user to all user friends and to board friends simultaneously. unique add.
    // add check if allfriends array contains this friend, then remove them from allfriends array
    
    if (self.foundFriend && self.foundFriend != self.currentUser) {
        
        [self addUserToAllFriendsOnParse:self.foundFriend completion:^(NSArray *allFriends, NSError *error) {
            NSLog(@"added new user to friends!");
            NSLog(@"%@", allFriends);
        }];
        
        if ( [self.friendsForCurrentUser containsObject:self.foundFriend] ) {
            [self.friendsForCurrentUser removeObject:self.foundFriend];
        }
        
        [self addUserToBoardFriendsOnParse:self.foundFriend completion:^(NSError *error) {
            NSLog(@"added new user to board!");
        }];
        
        if ( ![self.boardFriends containsObject:self.foundFriend] ) {
            [self.boardFriends addObject:self.foundFriend];
        }
        
        [self.boardFriendsTableView reloadData];
        [self adjustHeightOfTableview];
    }
    
    if (self.foundFriend == self.currentUser) {
        [self displayAlert];
    }
    
    // hiding found friends view:
    self.foundFriendView.hidden = YES;
    self.searchField.text = @"";
    
}


-(void)displayAlert {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"You are already part of this board"
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   //Handle button action here
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (IBAction)addUserToBoardButtonTapped:(UIButton *)sender {
    
    TMBFriendsTableViewCell *tappedCell = (TMBFriendsTableViewCell*)[[sender superview] superview];
    
    NSIndexPath *selectedIP = [self.boardFriendsTableView indexPathForCell:tappedCell];
    
    NSInteger index = selectedIP.row - self.boardFriends.count;
    
    PFUser *aFriend = self.friendsForCurrentUser[index];
    
    [self addUserToBoardFriendsOnParse:aFriend completion:^(NSError *error) {

        if (!error) {
            NSLog(@"friend added to board!");
            
        } else {
            NSLog(@"friend NOT added to board!");
        }
    }];
    
    [self.friendsForCurrentUser removeObject:aFriend];
    [self.boardFriends addObject:aFriend];
    
    [self.boardFriendsTableView reloadData];
    [self adjustHeightOfTableview];
    
}


- (IBAction)removeUserFromBoardButtonTapped:(UIButton *)sender {
    
    TMBFriendsTableViewCell *tappedCell = (TMBFriendsTableViewCell*)[[sender superview] superview];
    
    NSIndexPath *selectedIP = [self.boardFriendsTableView indexPathForCell:tappedCell];
    
    NSInteger index = selectedIP.row;
    
    PFUser *aFriend = self.boardFriends[index];
    
    [self removeUserFromBoardFriendsOnParse:aFriend completion:^(NSError *error) {
        if (!error) {
            NSLog(@"friend removed from board!");
            
        } else {
            NSLog(@"friend NOT removed from to board!");
        }

    }];

    [self.boardFriends removeObject:aFriend];
    [self.friendsForCurrentUser addObject:aFriend];

    [self.boardFriendsTableView reloadData];
    [self adjustHeightOfTableview];
    
}


- (void)adjustHeightOfTableview {
    
    CGFloat minHeight = 60;
    CGFloat height = self.boardFriendsTableView.contentSize.height - 1;
    
    if (height < minHeight)
        height = minHeight;
        
    // set the height constraint
    
    CGFloat scrollViewHeight =
    self.vertSpaceConstraint01.constant +
    self.friendSearchLabelConstraint.constant +
    self.vertSpaceConstraint02.constant +
    self.friendSearchViewConstraint.constant +
    self.vertSpaceConstraint03.constant +
    height +
    self.vertSpaceConstraint04.constant +
    self.saveBtnConstraint.constant + 60 ;
    
    if (self.shouldHideCancelButton) {
        scrollViewHeight = scrollViewHeight + 120;
    }
        
    NSLog(@"SCROLL VIEW HEIGHT %f", scrollViewHeight);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.tableViewHeightConstraint.constant = height;
        self.scrollView.contentSize = CGSizeMake(320, scrollViewHeight) ;
        [self.view setNeedsUpdateConstraints];
    }];
    
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger numberOfFriends = self.friendsForCurrentUser.count + self.boardFriends.count;
    NSLog(@"numberOfRows getting called: %lu", numberOfFriends);
    
    NSLog(@" ......... IM IN THE TABLEVIEW NUMBER OF ROWS METHOD ......... ");
    
    return numberOfFriends;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *currentFriend;
    TMBFriendsTableViewCell *cell;
    
    NSInteger index = indexPath.row;
    NSInteger boardFriendsCount = self.boardFriends.count;
    
    if (boardFriendsCount > index) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"boardFriendsCell"
                                               forIndexPath:indexPath];
        
        currentFriend = self.boardFriends[indexPath.row];

    } else {
        
        NSInteger newIndex = index - boardFriendsCount;
    
        cell = [tableView dequeueReusableCellWithIdentifier:@"allFriendsCell"
                                               forIndexPath:indexPath];
        
        currentFriend = self.friendsForCurrentUser[newIndex];
        
    }
    
    NSString *firstName = currentFriend[@"First_Name"];
    NSString *lastName = currentFriend[@"Last_Name"];
    
    cell.fromUserNameLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    PFFile *imageFile = currentFriend[@"profileImage"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            
            UIImage *profileImage = [UIImage imageWithData:data];
            cell.userProfileImage.image = [UIImage imageNamed:@"default-profile-image.jpg"];
            cell.userProfileImage.image = profileImage;
            cell.userProfileImage.contentMode = UIViewContentModeScaleAspectFill;
            cell.userProfileImage.layer.cornerRadius = cell.userProfileImage.frame.size.width / 2;
            cell.userProfileImage.clipsToBounds = YES;
        }
    }];
    
    return cell;
    
}


- (IBAction)saveNewBoardTapped:(UIButton *)sender {
    
    // THIS METHOD REALLY UPDATES THE BOARD CREATED IN THE VIEWDIDLOAD
    // check if they named the board, if not - error message, if yes - dismiss view
    
    if ([self.boardNameField.text isEqualToString:@""]) {
        [self displayNoNameAlert];
        
    } else {
        // if they named the board this updates the name on Parse
        NSString *boardName = self.boardNameField.text;
        self.myNewBoard[@"boardName"] = boardName;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"UserTappedSaveBoardButton"
                              object:self.myNewBoard];
        
        [self.myNewBoard saveEventually];
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }

}


- (void)displayNoNameAlert {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Please Give Your Board a Name"
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   //Handle button action here
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (IBAction)cancelButtonTapped:(UIButton *)sender {
    
    [self.myNewBoard deleteEventually];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}


- (IBAction)closeButtonTapped:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}


- (IBAction)backgroundTapped:(id)sender {
    
    [self.view endEditing:YES];
    
}


- (IBAction)deleteBoardContentsButtonTapped:(UIButton *)sender {
    
    [self displayDeletingContentAlert];
    
}


- (IBAction)deleteBoardButtonTapped:(UIButton *)sender {
    
    [self displayDeletingBoardAlert];
    
}


- (void)displayDeletingContentAlert {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Are You Sure?"
                                message:@"Images and comments for this board will be deleted"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *deleteButton = [UIAlertAction
                               actionWithTitle:@"Reset Board"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   //Handle button action here
                                   [self queryAndDeleteBoardContentWithCompletion:^(BOOL success) {
                                       
                                           NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                                           [center postNotificationName:@"UserTappedResetBoardButton"
                                                                 object:nil];
                                       
                                   }];
                                   
                                   [self dismissViewControllerAnimated:YES
                                                            completion:nil];
                                   
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       //Handle button action here
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];
    
    [alert addAction:cancelButton];
    [alert addAction:deleteButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)displayDeletingBoardAlert {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Are you sure?"
                                message:@"This board will be deleted"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   //Handle button action here
                                
                                   [self deleteBoardContentWithCompletion:^(BOOL success) {
                                       if (success) {
                                           NSLog(@"\n\n SUCCESS!! selected board deleted in create board VC \n\n");
                                       }
                                   }];
                                   
                                   [self dismissViewControllerAnimated:YES completion:nil];
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                   //Handle OK button action here
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                               }];

    [alert addAction:cancelButton];
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}



/*****************************
 *         PARSE CALLS       *
 *****************************/


- (void)createNewBoardOnParseWithCompletion:(void(^)(NSString *objectId, NSError *error))completionBlock {
    
    self.myNewBoard = [PFObject objectWithClassName:@"Board"];
    [self.myNewBoard setObject:[PFUser currentUser] forKey:kTMBBoardFromUserKey];
    self.myNewBoard[@"boardName"] = @"My Board";
    [self.myNewBoard saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            completionBlock(self.myNewBoard.objectId, error);
        }
    }];
    
}


- (void)queryCurrentUserFriendsWithCompletion:(void(^)(NSMutableArray *users, NSError *error))completionBlock {
    
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    [query includeKey:@"allFriends"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        if (!error) {
            for (PFUser *eachUser in [object objectForKey:@"allFriends"]) {
                [self.friendsForCurrentUser addObject:eachUser];
                
                if (self.boardFriendsToDisplay) {
                // remove duplicated friends ...
                for (PFUser *aFriend in self.boardFriendsToDisplay) {
                    if ( [self.friendsForCurrentUser containsObject:aFriend] ) {
                        [self.friendsForCurrentUser removeObject:aFriend];
                        [self.boardFriendsTableView reloadData];
                        [self adjustHeightOfTableview];
                    }
                }
                }
                
            }
            completionBlock(self.friendsForCurrentUser, error);
        }
    }];
    
}


- (void)queryAllFriendsOnBoard:(NSString *)boardID completion:(void(^)(NSMutableArray *boardFriends, NSError *error))completionBlock {
    
    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"objectId" equalTo:boardID];
    [boardQuery includeKey:@"boardFriends"];
    [boardQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable board, NSError * _Nullable error) {
        
        if (!error && board.firstObject[@"boardFriends"]) {
            NSLog(@" ..... INSIDE PARSE CALL: %@ board friends came back", board.firstObject[@"boardFriends"]);
            NSLog(@" ..... INSIDE PARSE CALL: %lu board friends came back", board.count);
            
            completionBlock(board.firstObject[@"boardFriends"], error);
        } else {
            NSLog(@" ..... CURRENT BOARD HAS NO COLLABORATORS");
        }
    }];
    
}


- (void)queryAllUsersWithUsername:(NSString *)username completion:(void(^)(NSArray *allFriends, NSError *error))completionBlock {
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        completionBlock(objects, error);
        
    }];
    
}


- (void)addUserToAllFriendsOnParse:(PFUser *)user completion:(void(^)(NSArray *allFriends, NSError *error))completionBlock {
    
    PFObject *newFriend = user;
    PFUser *currentUser = [PFUser currentUser];
    [currentUser addUniqueObject:newFriend forKey:@"allFriends"];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        completionBlock([currentUser objectForKey:@"allFriends"], error);
    }];
    
}


- (void)removeUserFromAllFriendsOnParse:(PFUser *)user completion:(void(^)(NSArray *allFriends, NSError *error))completionBlock {
    
    PFObject *newFriend = user;
    PFUser *currentUser = [PFUser currentUser];
    [currentUser removeObject:newFriend forKey:@"allFriends"];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        completionBlock([currentUser objectForKey:@"allFriends"], error);
    }];
    
}


- (void)addUserToBoardFriendsOnParse:(PFObject *)user completion:(void(^)(NSError *error))completionBlock {
    
    [self.myNewBoard addUniqueObject:user forKey:@"boardFriends"];
    [self.myNewBoard saveInBackground];
}


- (void)removeUserFromBoardFriendsOnParse:(PFObject *)user completion:(void(^)(NSError *error))completionBlock {

    [self.myNewBoard removeObject:user forKey:@"boardFriends"];
    [self.myNewBoard saveInBackground];
}


- (void)queryAllBoardsCreatedByUser:(PFUser *)user completion:(void(^)(NSArray *boardsCreatedByUser, NSError *error))completionBlock {
    
    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"fromUser" equalTo:user];
    
    [boardQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable boardsCreatedByUser, NSError * _Nullable error) {
        completionBlock(boardsCreatedByUser, error);
    }];
}


- (void)queryAllBoardsContainingUser:(PFUser *)user completion:(void(^)(NSArray *boardsContainingUser, NSError *error))completionBlock {
    
    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"boardFriends" equalTo:PFUser.currentUser];
    
    [boardQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable boardsContainingUser, NSError * _Nullable error) {
        completionBlock(boardsContainingUser, error);
    }];
}


- (void)deleteBoardContentWithCompletion:(void (^)(BOOL success))completionBlock {
    
    
    [self queryAllBoardsCreatedByUser:[PFUser currentUser] completion:^(NSArray *boardsCreatedByUser, NSError *error) {
        
        if (boardsCreatedByUser) {
            
            NSUInteger boardCount = 0;
            boardCount = boardCount + boardsCreatedByUser.count;
            
            [self queryAllBoardsContainingUser:[PFUser currentUser] completion:^(NSArray *boardsContainingUser, NSError *error) {
                if (boardsContainingUser) {
                    
                    
                    NSUInteger totalBoardCount = boardCount;
                    totalBoardCount = boardCount + boardsContainingUser.count;
                    
                    
                    if (totalBoardCount <= 1) {
                        // create new board
                        [self createNewBoardOnParseWithCompletion:^(NSString *objectId, NSError *error) {
                            if (!error) {
                                // set new board id sigleton
                                [TMBSharedBoardID sharedBoardID].boardID = objectId;
                                [[TMBSharedBoardID sharedBoardID].boards setObject:self.myNewBoard forKey:objectId];
                                
                                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                                [center postNotificationName:@"NewBoardCreatedInCreateBoardVC"
                                                      object:self.myNewBoard];
                                
                                // update side nav with new board
                                completionBlock(YES);
                                
                                // delete contents
                                [self queryAndDeleteBoardContentWithCompletion:^(BOOL success) {
                                    NSLog(@"\n\n I'M IN THE deleteBoardContentWithCompletion, CREATE BOARD VIEW CONTROLLER. BOARDS <= 1. \n NEW BOARD CREATED. CONTENTS DELETED. NEW SHARED BOARD ID: %@ \n\n",[TMBSharedBoardID sharedBoardID].boardID);
                                    
                                // delete board
                                [self.selectedBoard deleteEventually];
                                    
                                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                                [center postNotificationName:@"UserTappedDeleteBoardButton"
                                                      object:self.selectedBoard];
                                    
                                NSLog(@" I'M IN THE createNewBoardOnParseWithCompletion, CREATE BOARD VIEW CONTROLLER. BOARDS <= 1. CONTENTS DELETED. BOARD %@ DELETED", self.selectedBoard);
                                }];
                                
                            }
                        }];
                        
                        
                        
                    } else {
                        // delete contents
                        [self queryAndDeleteBoardContentWithCompletion:^(BOOL success) {
                            if (success) {
                                
                                // delete board
                                [self.selectedBoard deleteEventually];
                                
                                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                                [center postNotificationName:@"UserTappedDeleteBoardButton"
                                                      object:self.selectedBoard];
                                
                                completionBlock(YES);
                                NSLog(@" I'M IN THE deleteBoardContentWithCompletion, CREATE BOARD VIEW CONTROLLER. BOARDS > 1. CONTENTS DELETED. BOARD %@ DELETED", self.selectedBoard);
                            }
                        }];
                    }
                    
                    
                }
                
            }];
        }
        
    }];
    
    
}


- (void)queryAndDeleteBoardContentWithCompletion:(void (^)(BOOL success))completionBlock {
    
    PFObject *boardPointer = [PFObject objectWithoutDataWithClassName:@"Board" objectId:self.boardObjectId];
    PFQuery *queryPhoto = [PFQuery queryWithClassName:@"Photo"];
    [queryPhoto whereKey:@"board" equalTo:boardPointer];
    [queryPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu board photo objects.", objects.count);
            [PFObject deleteAllInBackground:objects];
            completionBlock(YES);
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            completionBlock(NO);
        }
        
    }];
    
    
    PFQuery *queryActivity = [PFQuery queryWithClassName:@"Activity"];
    [queryActivity whereKey:@"board" equalTo:boardPointer];
    [queryActivity findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu board activity objects.", objects.count);
            [PFObject deleteAllInBackground:objects];
            completionBlock(YES);
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            completionBlock(NO);
        }
        
    }];
    
}


@end


