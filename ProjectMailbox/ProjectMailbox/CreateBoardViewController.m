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


@interface CreateBoardViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *boardNameField;
@property (strong, nonatomic) PFObject *myNewBoard;
@property (nonatomic, strong) NSString *myNewBoardObjectId;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *boardFriendsTableView;
@property (nonatomic, strong) NSMutableArray *friendsForCurrentUser;
@property (nonatomic, strong) NSMutableArray *boardFriends;
@property (nonatomic, strong) PFUser *foundFriend;
@property (nonatomic, strong) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

// Found a Friend View
@property (weak, nonatomic) IBOutlet UIImageView *foundFriendImage;
@property (weak, nonatomic) IBOutlet UILabel *foundFriendUsernameLabel;
@property (weak, nonatomic) IBOutlet UIView *allFoundFriendView;
@property (weak, nonatomic) IBOutlet UILabel *noUsersFoundLabel;

@end


@implementation CreateBoardViewController



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self adjustHeightOfTableview];
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self prefersStatusBarHidden];
    
    NSLog(@"IN VIEW DID LOAD CREATE BOARD VC.........");
    
    self.friendsForCurrentUser = [NSMutableArray new];
    self.boardFriends = [NSMutableArray new];
    
    self.boardFriendsTableView.delegate = self;
    self.boardFriendsTableView.dataSource = self;
    
    
    // hiding found/notfound friends views:
    self.allFoundFriendView.hidden = YES;
    self.noUsersFoundLabel.hidden = YES;
    
    [[PFUser currentUser] fetchInBackground];
    self.currentUser = [PFUser currentUser];
    
    [self queryCurrentUserFriendsWithCompletion:^(NSMutableArray *users, NSError *error) {
        NSLog(@"%@", users);
        [self.boardFriendsTableView reloadData];
        [self adjustHeightOfTableview];
    }];
    
    [self createNewBoardOnParseWithCompletion:^(NSString *objectId, NSError *error) {
        if (!error) {
            NSLog(@"NEW BOARD CREATED");
            self.myNewBoardObjectId = self.myNewBoard.objectId;
            NSLog(@"NEW BOARD ID IS: %@", self.myNewBoardObjectId);
        }
    }];
    
    
    // loging in this app as Inga for now
    
    //    if (![PFUser currentUser]){
    //        [PFUser logInWithUsernameInBackground:@"ingakyt@gmail.com" password:@"test" block:^(PFUser * _Nullable user, NSError * _Nullable error) {
    //            NSLog(@"logged in user: %@ \nwith error: %@", user, error);
    //                }];
    //    }
    
    [self queryAllBoardsCreatedByUser:[PFUser currentUser] completion:^(NSArray *boardsCreatedByUser, NSError *error) {
        
        for (PFObject *object in boardsCreatedByUser) {
            
            NSString *boardName = object[@"boardName"];
            NSDate *updatedAt = [object updatedAt];
            NSLog(@"=========== 1st CREATED BY USER - BOARD NAMES ARE: %@ updated at %@", boardName, updatedAt);
        }
    }];
    
    [self queryAllBoardsContainingUser:[PFUser currentUser] completion:^(NSArray *boardsContainingUser, NSError *error) {
        
        for (PFObject *object in boardsContainingUser) {
    
            NSString *boardName = object[@"boardName"];
            NSDate *updatedAt = [object updatedAt];
            NSLog(@"=========== 2nd CONTAINS USER - BOARD NAMES ARE: %@ updated at %@", boardName, updatedAt);
        }
    }];
    
    
    // dismisses the keyboard when Done/Search key is tapped:
    self.boardNameField.delegate = self;
    self.searchField.delegate = self;
    
    
    // setting dynamimc table view height:
//    CGRect tableFrame = self.boardFriendsTableView.frame;
//    tableFrame.size.height = 60 * (self.friendsForCurrentUser.count + self.boardFriends.count);
//    self.boardFriendsTableView.frame = tableFrame;
    
//    self.tableViewHeightConstraint.constant = 60 * (self.friendsForCurrentUser.count + self.boardFriends.count);
//    [self.boardFriendsTableView needsUpdateConstraints];
    
    [self tableViewHeightConstraint];
    
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
            
            self.allFoundFriendView.hidden = NO;
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
            self.allFoundFriendView.hidden = YES;
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
    self.allFoundFriendView.hidden = YES;
    self.searchField.text = @"";
    
}



-(void)displayAlert {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Friending Yourself?"
                                  message:@"The database will get confused, so better not."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   //Handle OK button action here
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


- (void)adjustHeightOfTableview
{
    CGFloat height = self.boardFriendsTableView.contentSize.height;
    CGFloat maxHeight = self.boardFriendsTableView.superview.frame.size.height - self.boardFriendsTableView.frame.origin.y;
    CGFloat minHeight = 62;
    
    // if the height of the content is greater than the maxHeight of
    // total space on the screen, limit the height to the size of the
    // superview.
    
    if (height > maxHeight)
        height = maxHeight;
    
    if (height < minHeight)
        height = minHeight;
        
    // now set the height constraint accordingly
    
    [UIView animateWithDuration:0.25 animations:^{
        self.tableViewHeightConstraint.constant = height;
        [self.view setNeedsUpdateConstraints];
    }];
}
//- (NSLayoutConstraint *)tableViewHeightConstraint
//{
//    self.tableViewHeightConstraint.constant = 60 * (self.friendsForCurrentUser.count + self.boardFriends.count);
//    [self.boardFriendsTableView needsUpdateConstraints];
//    
//    return self.tableViewHeightConstraint;
//}



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
    
    // if they named the board this updates the name
    NSString *boardName = self.boardNameField.text;
    self.myNewBoard[@"boardName"] = boardName;
    
    [self.myNewBoard saveEventually];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
}



- (IBAction)cancelButtonTapped:(UIButton *)sender {
    
        [self.myNewBoard deleteEventually];
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
}



- (IBAction)backgroundTapped:(id)sender {
    
    [self.view endEditing:YES];
    
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
            }
            completionBlock(self.friendsForCurrentUser, error);
        }
    }];
    
}



// passing a board, getting back an array containing 1 board object
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

- (IBAction)closeButtonTapped:(id)sender {
    
    
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    [self.myNewBoard deleteEventually];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}







//- (void)queryBoardFriendsWithCompletion:(void(^)(NSMutableArray *boardUsers, NSError *error))completionBlock {
//
////    PFQuery *query = self.myNewBoard;
//    PFQuery *query = [PFQuery queryWithClassName:@"Board"];
// //   [query whereKey:@"boardFriends" equalTo:self.myNewBoard[@"allFriends"]];
//    [query includeKey:@"boardFriends"];
//
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//        if (!error) {
//            for (PFUser *eachUser in [object objectForKey:@"boardFriends"]) {
//                [self.boardFriends addObject:eachUser];
//            }
//            completionBlock(self.boardFriends, error);
//        }
//    }];
//
//}




@end
