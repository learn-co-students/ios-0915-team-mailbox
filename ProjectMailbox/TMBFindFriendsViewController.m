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
@property (nonatomic, strong) NSMutableArray *allFriendsLocal;
@property (nonatomic, strong) NSMutableArray *friendsForCurrentUser;


@end




@implementation TMBFindFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSLog(@"IN VIEW DID LOAD of FIND FREINDS VC.........");
    
    self.allFriendsLocal = [NSMutableArray new];
    self.friendsForCurrentUser = [NSMutableArray new];
    
    self.allFriendsTableView.delegate = self;
    self.allFriendsTableView.dataSource = self;

    
    // hiding found friends view:
    self.allFoundFriendView.hidden = YES;
    

    [[PFUser currentUser] fetchInBackground];
    
    
    [self queryCurrentUserFriendsWithCompletion:^(NSMutableArray *users, NSError *error) {
        NSLog(@"DID IT WORK??? %@", users);
    }];
    
    
    
}





- (IBAction)searchFriendButtonTapped:(UIButton *)sender {
    
    
    // setting the textfield.text to the user name
    NSString *username = self.searchField.text;

    
    [self queryAllUsersWithUsername:username completion:^(NSArray *allFriends, NSError *error) {
    
        if (!error) {
            
            self.allFoundFriendView.hidden = NO;
            
            // setting foundFriends View to display a friend
            
            PFUser *aFriend = [allFriends firstObject];
            self.foundFriend = aFriend;
            
            NSString *firstName = aFriend[@"First_Name"];
            NSString *lastName = aFriend[@"Last_Name"];
            
            self.foundFriendUsernameLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            
            // setting user profile photo
            
            PFFile *imageFile = aFriend[@"profileImage"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *profileImage = [UIImage imageWithData:data];
                    self.foundFriendImage.image = profileImage;
                }
            }];
            

            }
        
        
        
    }];
    
  
  
    
}







- (IBAction)addFriendToAllFriendsButtonTapped:(UIButton *)sender {
    
    if (self.foundFriend) {
        [self addingUserToAllFriendsOnParse:self.foundFriend completion:^(NSArray *allFriends, NSError *error) {
            NSLog(@"complete!");
            NSLog(@"%@", allFriends);
            
        }];
        
        [self.allFriendsLocal addObject:self.foundFriend];
    }
    
    // hiding found friends view:
    self.allFoundFriendView.hidden = YES;
}




-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSUInteger numberOfFriends = self.allFriendsLocal.count;
    NSLog(@"numberOfRows getting called: %lu", self.allFriendsLocal.count);
    
    NSLog(@" ......... IM IN THE TABLEVIEW NUMBER OF ROWS METHOD ......... ");
    
    return numberOfFriends;
}




-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSLog(@"cellForRowAtIndexPath: has been called with an indexPath of %@", indexPath);
    
    TMBFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allFriendsCell" forIndexPath:indexPath];
    NSUInteger rowOfIndexPath = indexPath.row;
 
    
    // setting table rows to display friends
    
    PFObject *aFriend = self.allFriendsLocal[rowOfIndexPath];
    
    NSString *firstName = aFriend[@"First_Name"];
    NSString *lastName = aFriend[@"Last_Name"];
    
    cell.fromUserNameLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    
    // setting user profile photo
    
    PFFile *imageFile = aFriend[@"profileImage"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *profileImage = [UIImage imageWithData:data];
            cell.userProfileImage.image = profileImage;
        }

    }];
    
    
    return cell;
}



/*****************************
 *       HELPER METHODS      *
 *****************************/


- (void)queryCurrentUserFriendsWithCompletion:(void(^)(NSMutableArray *users, NSError *error))completionBlock {
    
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    [query includeKey:@"allFriends"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        if (!error) {
            
            for (PFUser *eachUser in [object objectForKey:@"allFriends"]) {
                [self.friendsForCurrentUser addObject:eachUser];
                
                NSString *testString = eachUser[@"Last_Name"];
                NSLog(@"**************  TEST STRING is: %@", testString);
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


- (void)addingUserToAllFriendsOnParse:(PFUser *)user completion:(void(^)(NSArray *allFriends, NSError *error))completionBlock {
    
    PFObject *newFriend = user;
    PFUser *currentUser = [PFUser currentUser];
    [currentUser addUniqueObject: newFriend forKey:@"allFriends"];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        completionBlock([currentUser objectForKey:@"allFriends"], error);
    }];
    
}



@end
