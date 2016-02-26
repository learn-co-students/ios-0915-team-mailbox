//
//  TMBFindFriendsViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 12/10/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBFindFriendsViewController.h"
#import "TMBConstants.h"
#import "PAPUtility.h"
#import "TMBFriendsTableViewCell.h"

@interface TMBFindFriendsViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *foundFriendImage;
@property (weak, nonatomic) IBOutlet UILabel *foundFriendUsernameLabel;
@property (weak, nonatomic) IBOutlet UIView *foundFriendView;
@property (weak, nonatomic) IBOutlet UITableView *allFriendsTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic, strong) PFUser *foundFriend;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *friendsForCurrentUser;
@property (weak, nonatomic) IBOutlet UILabel *noUsersFoundLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *yourFriendsLabel;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vertSpaceConstraint01;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *friendSearchLabelConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vertSpaceConstraint02;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *animatedConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraintCompact;

@end


@implementation TMBFindFriendsViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"I'M IN THE VIEW DID LOAD, FIND FRIENDS VIEW CONTROLLER");
    
    [self prefersStatusBarHidden];
    
    [self checkInternetConnection];
    
    self.allFriendsTableView.delegate = self;
    self.allFriendsTableView.dataSource = self;
    self.searchField.delegate = self;
    // dismisses the keyboard when the Search key is tapped: (it unhides the noUsersFoundLabel for some reason)
    // [self textFieldShouldReturn:self.searchField];
    
    // hiding found/notfound friends views:
    self.noUsersFoundLabel.hidden = YES;
    self.foundFriendView.hidden = YES;
    
    self.friendsForCurrentUser = [NSMutableArray new];
    
    [[PFUser currentUser] fetchInBackground];
    self.currentUser = [PFUser currentUser];
    
    [self queryCurrentUserFriendsWithCompletion:^(NSMutableArray *users, NSError *error) {
        NSLog(@"DID IT WORK??? YAY!! %@", users);
        [self.allFriendsTableView reloadData];
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
        self.yourFriendsLabel.text = @"No Internet Connection";
        self.allFriendsTableView.hidden = YES;
        NSLog(@"Device is not connected to the internet");

    } else {
        NSLog(@"Device is connected to the internet");
    }
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // search key was pressed - dismiss keyboard, call on search friend method
    [textField resignFirstResponder];
    [self searchFriendButtonTapped:nil];
    
    return YES;
}


- (IBAction)searchFriendButtonTapped:(UIButton *)sender {
    
    // setting the textfield.text to the user name
    NSString *username = self.searchField.text;
    
    [self queryAllUsersWithUsername:username completion:^(NSArray *allFriends, NSError *error) {
        
        if (!error && allFriends.count > 0) {
            
            self.foundFriendView.hidden = NO;
            self.noUsersFoundLabel.hidden = YES;
            [self pushDownFriendsTable];
            
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
            [self pushDownFriendsTable];
        }
        
    }];
    
    self.searchField.text = @"";
    
}


- (void)pushDownFriendsTable {
    
    if ((self.foundFriendView.hidden == NO && self.animatedConstraint.constant <= 32) ||
        (self.noUsersFoundLabel.hidden == NO && self.animatedConstraint.constant <= 32)) {
        
        [UIView animateWithDuration:.4 animations:^{
            self.animatedConstraint.constant = self.animatedConstraint.constant + 60;
            [self.view layoutIfNeeded];
        }];
    }
    
}


- (IBAction)addUserToAllFriendsButtonTapped:(UIButton *)sender {
    
    if (self.foundFriend && self.foundFriend != self.currentUser) {
        
        [self addUserToAllFriendsOnParse:self.foundFriend completion:^(NSArray *allFriends, NSError *error) {
            NSLog(@"complete!");
            NSLog(@"%@", allFriends);
        }];
        
        if ( ![self.friendsForCurrentUser containsObject:self.foundFriend] ) {
            [self.friendsForCurrentUser addObject:self.foundFriend];
        }
        
        [self.allFriendsTableView reloadData];
        [self adjustHeightOfTableview];
    }
    
    if (self.foundFriend == self.currentUser) {
        [self displayAlert];
    }
    
    // hiding found friends view:
    self.foundFriendView.hidden = YES;
    self.searchField.text = @"";
    
}


- (void)displayAlert {
    
    UIAlertController *alert=   [UIAlertController
                                  alertControllerWithTitle:@"This is You!"
                                  message:@"You are the admin of this account."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction
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


- (IBAction)unfollowButtonTapped:(UIButton *)sender {
    
    TMBFriendsTableViewCell *tappedCell = (TMBFriendsTableViewCell*)[[sender superview] superview];
    
    NSIndexPath *selectedIP = [self.allFriendsTableView indexPathForCell:tappedCell];
    PFUser *aFriend = self.friendsForCurrentUser[selectedIP.row];
    
    
    // do whatever parse stuff you need to delete the user
    // also remove from local array
    
    
    [self removeUserFromAllFriendsOnParse:aFriend completion:^(NSArray *allFriends, NSError *error) {
        if (!error) {
            NSLog(@"friend removed!");
        }
    }];
    
    [self.friendsForCurrentUser removeObject:aFriend];
    
    [self.allFriendsTableView deleteRowsAtIndexPaths:@[selectedIP] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.allFriendsTableView reloadData];
    [self adjustHeightOfTableview];
    
}


- (void)adjustHeightOfTableview {
    
    CGFloat minHeight = 60;
    CGFloat height = self.allFriendsTableView.contentSize.height - 1;
    
    if (height < minHeight)
        height = minHeight;
    
    // set the height constraint
    
    CGFloat scrollViewHeight =
    self.vertSpaceConstraint01.constant +
    self.friendSearchLabelConstraint.constant +
    self.vertSpaceConstraint02.constant +
    height + 60 ;
    
    NSLog(@"SCROLL VIEW HEIGHT %f", scrollViewHeight);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.tableViewHeightConstraint.constant = height;
        self.tableViewHeightConstraintCompact.constant = height;
        self.scrollView.contentSize = CGSizeMake(320, scrollViewHeight) ;
        [self.view setNeedsUpdateConstraints];
    }];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger numberOfFriends = self.friendsForCurrentUser.count;
    NSLog(@"numberOfRows getting called: %lu", self.friendsForCurrentUser.count);
    
    NSLog(@" ......... IM IN THE TABLEVIEW NUMBER OF ROWS METHOD ......... ");
    
    return numberOfFriends;
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"cellForRowAtIndexPath: has been called with an indexPath of %@", indexPath);
    
    TMBFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allFriendsCell" forIndexPath:indexPath];
    NSUInteger rowOfIndexPath = indexPath.row;
    
    
    // setting table rows to display friends
    
    PFObject *aFriend = self.friendsForCurrentUser[rowOfIndexPath];
    NSString *firstName = aFriend[@"First_Name"];
    NSString *lastName = aFriend[@"Last_Name"];
    cell.friendNameLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    // setting user profile photo
    
    PFFile *imageFile = aFriend[@"profileImage"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *profileImage = [UIImage imageWithData:data];
            cell.friendProfileImage.image = profileImage;
            // puts image in a circle:
            cell.friendProfileImage.contentMode = UIViewContentModeScaleAspectFill;
            cell.friendProfileImage.layer.cornerRadius = cell.friendProfileImage.frame.size.width / 2;
            cell.friendProfileImage.clipsToBounds = YES;
        }
    }];
    
    return cell;
    
}


- (IBAction)backgroundTapped:(id)sender {
    
    [self.view endEditing:YES];
    
}


- (IBAction)closeButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}



/*****************************
 *        QUERY METHODS      *
 *****************************/


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
    [currentUser addUniqueObject: newFriend forKey:@"allFriends"];
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




@end
