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


@interface TMBFindFriendsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *foundFriendImage;
@property (weak, nonatomic) IBOutlet UILabel *foundFriendUsernameLabel;
@property (weak, nonatomic) IBOutlet UIView *allFoundFriendView;
@property (weak, nonatomic) IBOutlet UITableView *allFriendsTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic, strong) PFUser *foundFriend;
@property (nonatomic, strong) NSMutableArray *friendsForCurrentUser;
@property (weak, nonatomic) IBOutlet UILabel *noUsersFoundLabel;

@end



@implementation TMBFindFriendsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self prefersStatusBarHidden];
    
    NSLog(@"IN VIEW DID LOAD of FIND FREINDS VC.........");
    
    self.friendsForCurrentUser = [NSMutableArray new];
    
    self.allFriendsTableView.delegate = self;
    self.allFriendsTableView.dataSource = self;
    
    // hiding found/notfound friends views:
    self.allFoundFriendView.hidden = YES;
    self.noUsersFoundLabel.hidden = YES;
    
    [[PFUser currentUser] fetchInBackground];
    
    [self queryCurrentUserFriendsWithCompletion:^(NSMutableArray *users, NSError *error) {
        NSLog(@"DID IT WORK??? YAY!! %@", users);
        [self.allFriendsTableView reloadData];
    }];
    
}




- (IBAction)doneButtonTapped:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}




- (IBAction)searchFriendButtonTapped:(UIButton *)sender {
    
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
    
}



- (IBAction)addUserToAllFriendsButtonTapped:(UIButton *)sender {
    
    if (self.foundFriend) {
        
        [self addUserToAllFriendsOnParse:self.foundFriend completion:^(NSArray *allFriends, NSError *error) {
            NSLog(@"complete!");
            NSLog(@"%@", allFriends);
        }];
        
        if ( ![self.friendsForCurrentUser containsObject:self.foundFriend] ) {
        [self.friendsForCurrentUser addObject:self.foundFriend];
        }
        
        [self.allFriendsTableView reloadData];
    }
    
    // hiding found friends view:
    self.allFoundFriendView.hidden = YES;
    self.searchField.text = @"";
    
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
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
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

- (IBAction)closeButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}



@end
