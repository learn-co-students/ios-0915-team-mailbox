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

@interface CreateBoardViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *boardNameLabel;
@property (strong, nonatomic) PFObject *myNewBoard;
@property (weak, nonatomic) IBOutlet UITextField *searchFriendsTextField;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;

// Found a Friend View
@property (weak, nonatomic) IBOutlet UIImageView *foundFriendImage;
@property (weak, nonatomic) IBOutlet UILabel *foundFriendUsernameLabel;
@property (weak, nonatomic) IBOutlet UIView *foundFriendView;

@end


@implementation CreateBoardViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"IN VIEW DID LOAD.........");

    
    self.friendsTableView.delegate = self;
    self.friendsTableView.dataSource = self;
    
    self.allFriends = [NSMutableArray new];



    // loging in this app as Inga for now
    
    if (![PFUser currentUser]){
        [PFUser logInWithUsernameInBackground:@"ingakyt@gmail.com" password:@"test" block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            NSLog(@"logged in user: %@ \nwith error: %@", user, error);
                }];
    }
    
    
    
    
    // QUERY FOR BOARDS CONTAINING USERS
    
    PFQuery *query = [PFQuery queryWithClassName:@"Board"];
    [query whereKey:@"users" equalTo:PFUser.currentUser];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        
        for (PFObject *object in objects ) {
            
            NSDate *test = [object updatedAt];
            
            NSLog(@" ..... THE UPDATED DATE IS %@",test);
            
        }
        
        

    }];
    
    
    
    
}





- (IBAction)addFriendButtonTapped:(UIButton *)sender {

    
}




- (IBAction)createNewBoardTapped:(UIButton *)sender {

    // get all users (query)
    // get or create a board
    // set array of users to board[@"users"]
    // save board. see what it looks like in Parse!!!
        // THEN you can start working on querying/finding boards associated with a user
        // query forClass: @"board" whereKey:@"users" contains:PFUser.currentUser
        // see if you get back the baord you expected
    
    
    

    
    // QUERY FOR ALL USERS:
    
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        // set datastore to objects array
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            self.users = [objects mutableCopy];
            
            NSArray *differentUsers = @[objects[0], objects[1]];
            
            NSLog(@" ......... ALL USERS ARE : %@", self.users);
            
            
            
            
            // CREATING A BOARD WITH THE USERS ARRAY:
            
            NSString *boardName = self.boardNameLabel.text;
            
            self.myNewBoard = [PFObject objectWithClassName:@"Board"];
            
            
            self.myNewBoard[@"boardName"] = boardName;
            
    
            
            [self.myNewBoard setObject:[PFUser currentUser] forKey:kTMBBoardFromUserKey];
            [self.myNewBoard addUniqueObjectsFromArray:differentUsers forKey:kTMBBoardUsersKey];
            
            [self.myNewBoard saveInBackground];
            
            
            
        }];
    }];
    
    
    
    
    
    

}







- (IBAction)searchFriendsButtonTapped:(UIButton *)sender {
    
    
    
    // FIND ALL PARSE USERS WITH THAT USER NAME:
    
    
    PFQuery *friendQuery = [PFUser query];
    
    // setting the textfield.text to the user name
    NSString *friendUsername = self.searchFriendsTextField.text;
    
    [friendQuery whereKey:@"username" equalTo:friendUsername];
    
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable friendObjects, NSError * _Nullable error) {
        
        NSArray *foundFriends = [friendObjects mutableCopy];
        
        
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
                // adding found frinds to the ALL friends array
                [self.allFriends addObject:foundFriends[0]];
                NSLog(@" ......... ALL FRIENDS ARRAY IS: %@", self.allFriends);
            
            
            [self.friendsTableView reloadData];


            }];
        
        


        
        
        
        NSLog(@" ......... FOUND FRIENDS: %@", friendObjects);
        
        
        
        
        // setting foundFriends View to display a friend
        
        PFObject *aFriend = foundFriends[0];
        
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
        

        
        
        
        
    }];
    
    
    
    
    
    
    
    
    

}








-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSUInteger numberOfFriends = self.allFriends.count;
    NSLog(@"numberOfRows getting called: %lu", self.allFriends.count);
    
    NSLog(@" ......... IM IN THE TABLEVIEW NUMBER OF ROWS METHOD ......... ");
    
    return numberOfFriends;
}






-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"cellForRowAtIndexPath: has been called with an indexPath of %@", indexPath);
    
    TMBFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell" forIndexPath:indexPath];    
    NSUInteger rowOfIndexPath = indexPath.row;
    
    
    
    // setting table rows to display friends
    
    PFObject *aFriend = self.allFriends[rowOfIndexPath];
    
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
    
    
    
    NSLog(@" ......... IM IN THE TABLEVIEW CELL FOR ROW METHOD ......... ");
    
    return cell;
    
    
}






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
