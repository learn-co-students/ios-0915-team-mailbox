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
    
    
    [self queryAllParseUsers];
    
    
    NSLog(@"IN VIEW DID LOAD.........");

    
    self.friendsTableView.delegate = self;
    self.friendsTableView.dataSource = self;
    
    self.allFriends = [NSMutableArray new];
    self.boardFriends = [NSMutableArray new];
    self.combinedFriends = [NSMutableArray new];


    
    // hiding found friends view:
    self.foundFriendView.hidden = YES;


    // loging in this app as Inga for now
    
    if (![PFUser currentUser]){
        [PFUser logInWithUsernameInBackground:@"ingakyt@gmail.com" password:@"test" block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            NSLog(@"logged in user: %@ \nwith error: %@", user, error);
                }];
    }
    
    
    
    
    
    // creating new board:
    self.myNewBoard = [PFObject objectWithClassName:@"Board"];
    
    [self.myNewBoard setObject:[PFUser currentUser] forKey:kTMBBoardFromUserKey];
//    [self.myNewBoard setObject:self.boardFriends forKey:kTMBBoardUsersKey];   // takes an array
    self.myNewBoard[@"boardName"] = @"My Board";

    
    [self.myNewBoard saveEventually];
    
    
    
    
 
    
    
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





- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender {
    
    // delete the board with that board id
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
    
    
    
    self.foundFriendView.hidden = NO;
    
    


}








- (IBAction)addFriendButtonTapped:(UIButton *)sender {
    
    // GOALS:
    
    // found Friend view is hidden by default in viewDidLoad
    
    // show found Friend view when found someone
    
    // ----->  show found Friend view when noone is found
    
    // hide found Friend view
    
    // ----->  reset the text view text to blank
    
    
    
    
    // pushes to Parse: makes the FOUND FRIEND a 'follower' of the board:
    // fromUser
    // toUser
    // type 'follow'
    
    PFUser *newBoardUser = self.allFriends.lastObject; // push to parse;
    PFObject *follow = [PFObject objectWithClassName:@"Activity"];
    [follow setObject:@"follow" forKey:@"type"];
    [follow setObject:self.myNewBoard forKey:@"board"];
    [follow setObject:[PFUser currentUser] forKey:kTMBActivityFromUserKey];
    [follow setObject:newBoardUser forKey:kTMBActivityToUserKey];
    [follow saveInBackground];

    
    // adding new board user to boardFriends array
    [self.boardFriends addObject:self.allFriends.lastObject];
    
    [self.myNewBoard setObject:self.boardFriends forKey:kTMBBoardUsersKey];   // takes an array
    [self.myNewBoard saveInBackground];

    
    self.foundFriendView.hidden = YES;
    


    
}









-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSUInteger numberOfFriends = self.allFriends.count;
    NSLog(@"numberOfRows getting called: %lu", self.allFriends.count);
    
    NSLog(@" ......... IM IN THE TABLEVIEW NUMBER OF ROWS METHOD ......... ");
    
    return numberOfFriends;
}








-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //TESTING HELPER METHODS:
    
//    PFUser *currentUser = PFUser.currentUser;
//    [self queryAllBoardsForUser:currentUser completion:^(NSArray *boards, NSError *error) {
//        if (!error) {
//            NSLog(@"************** %lu BOARD OBJECTS CAME BACK", boards.count);
//        }
//    }];
    
    
    
//    [self queryAllFriendsOnBoard:@"9pv7WduyJ0" completion:^(NSArray *friends, NSError *error) {
//        if (!error) {
//            NSLog(@"************** %lu BOARD OBJECTS CAME BACK", friends.count);
//            NSLog(@"**************  BOARD OBJECTS ARE: %@", friends);
//            
//            NSArray *test = [friends valueForKey:kTMBBoardUsersKey];
//            
//            NSLog(@"************** %lu BOARD FRIENDS CAME BACK", test.count);
//            NSLog(@"**************  BOARD FRIENDS ARRAY IS: %@",test);
//
//        }
//    }];
//    
    

    [self queryFriendsFollowingABoard:@"9pv7WduyJ0" completion:^(NSArray *friends, NSError *error) {
        if (!error) {
            NSLog(@"************** %lu BOARD OBJECTS CAME BACK", friends.count);
            NSLog(@"**************  BOARD OBJECTS ARE: %@", friends);
            
            NSArray *test = [friends valueForKey:kTMBBoardUsersKey];
            
            NSLog(@"************** %lu BOARD FRIENDS CAME BACK", test.count);
            NSLog(@"**************  BOARD FRIENDS ARRAY IS: %@",test);

        }
    }];
    
    
    
    
    
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







- (IBAction)checkButtonTapped:(UIButton *)sender {
    
    // check - adds friend to board, so sets 'follow' to an empty string
    // uncheck - removes friend from board
    
    // if user is a follower - display check
    // if user is not a follower - display blank circle
    
    
    
}








- (IBAction)saveNewBoardTapped:(UIButton *)sender {
    
    
    // THIS METHOD REALLY UPDATES THE BOARD CREATED IN THE VIEWDIDLOAD
    
    
    // if they named the board this updates the name
    NSString *boardName = self.boardNameLabel.text;
    self.myNewBoard[@"boardName"] = boardName;
    
    [self.myNewBoard saveEventually];
    
 
    
    
    
    
    // TOM'S NOTES:
    // get all users (query)
    // get or create a board
    // set array of users to board[@"users"]
    // save board. see what it looks like in Parse!!!
    // THEN you can start working on querying/finding boards associated with a user
    // query forClass: @"board" whereKey:@"users" contains:PFUser.currentUser
    // see if you get back the baord you expected
    
    
   

    
}






/*****************************
 *       HELPER METHODS      *
 *****************************/



// rewrite with completion block:
-(NSArray *)queryAllParseUsers {
    
   __block NSArray *allUsers = [[NSArray alloc] init];
    
        PFQuery *query = [PFUser query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    
            // putting it on the main thread:
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                allUsers = [objects mutableCopy];
                NSLog(@" ......... ALL USERS ARE : %@", allUsers);
            }];
        }];
    
    return allUsers;
}






// write methods:
// need to add some friends to users first
// (NSArray *)queryAllFriendsOnUser:(PFUser *)user {





// let's try querying the users array first:
// passing a board, getting back board objects
- (void)queryAllFriendsOnBoard:(NSString *)boardID completion:(void(^)(NSArray *friends, NSError *error))completionBlock {
    
    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"objectId" equalTo:boardID];
    
    [boardQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable boards, NSError * _Nullable error) {
        
        NSLog(@" ..... INSIDE PARSE CALL: %lu friends came back", boards.count);
        
        // get the user (friend) array
        
        completionBlock(boards, error);
        
    }];
    
}



// let's try 'follow' type
// doesn't work yet....

- (void)queryFriendsFollowingABoard:(NSString *)boardID completion:(void(^)(NSArray *friends, NSError *error))completionBlock {
    
    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"type" equalTo:@"follow"];
    [activityQuery whereKey:@"objectId" equalTo:boardID];
    
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        NSLog(@" ..... INSIDE PARSE CALL: %lu friends came back", objects.count);
        
        completionBlock(objects, error);
        
    }];
    
}








//-(void) getAllBoardsForCurrentUserWithCompletion:( (NSArray *boards)completion  // Tom's example

- (void)queryAllBoardsForUser:(PFUser *)user completion:(void(^)(NSArray *boards, NSError *error))completionBlock {
    
    NSLog(@" ..... BEFORE PARSE CALL ..... ");
    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"users" equalTo:user];
    
    [boardQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable boards, NSError * _Nullable error) {
        
        NSLog(@" ..... INSIDE PARSE CALL: %lu boards came back",boards.count);

//        for (PFObject *object in objects ) {
        
//            NSDate *lastUpdated = [object updatedAt];
//            NSLog(@" ..... THE UPDATED DATE IS %@",lastUpdated);
//        }
        
        completionBlock(boards, error);

    }];
    
        NSLog(@" ..... AFTER PARSE CALL ..... ");
    
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
