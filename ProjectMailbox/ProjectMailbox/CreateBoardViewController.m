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
    self.boardFriends = [NSMutableArray new];
    self.combinedFriends = [NSMutableArray new];


    
    // hiding found friends view:
    self.foundFriendView.hidden = YES;


    // loging in this app as Inga for now
    
//    if (![PFUser currentUser]){
//        [PFUser logInWithUsernameInBackground:@"ingakyt@gmail.com" password:@"test" block:^(PFUser * _Nullable user, NSError * _Nullable error) {
//            NSLog(@"logged in user: %@ \nwith error: %@", user, error);
//                }];
//    }
    
    
    
    
    
    // CREATING NEW BOARD:
    
    self.myNewBoard = [PFObject objectWithClassName:@"Board"];
    [self.myNewBoard setObject:[PFUser currentUser] forKey:kTMBBoardFromUserKey];
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
    
    // pushes to Parse: makes the FOUND FRIEND a 'follower' of the board:
    // fromUser
    // toUser
    // type 'follow'
    
    
    // adding new board user to boardFriends array
    PFUser *newBoardUser = self.allFriends.lastObject; // push to parse;
    [self.boardFriends addObject:self.allFriends.lastObject];

    
    PFObject *follow = [PFObject objectWithClassName:@"Activity"];
//    [follow setObject:@"follow" forKey:@"type"];
//    [follow setObject:self.myNewBoard forKey:@"board"];
//    [follow setObject:[PFUser currentUser] forKey:kTMBActivityFromUserKey];
    [follow setObject:newBoardUser forKey:kTMBActivityToUserKey];
//    [follow saveInBackground];

    
    
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
    
    
    PFUser *currentUser = [PFUser currentUser];
    
    [self queryAllBoardsForUser:currentUser completion:^(NSArray *boards, NSError *error) {
        NSLog(@"************** %lu BOARD OBJECTS CAME BACK", boards.count);
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
    
    // check - adds friend to board
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
    

    
}






/*****************************
 *       HELPER METHODS      *
 *****************************/



- (void)queryAllUsersWithUsername:(NSString *)username completion:(void(^)(NSArray *allFriends, NSError *error))completionBlock {
    
    //   __block NSArray *allUsers = [[NSArray alloc] init];
    
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"username" equalTo:username];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSLog(@" ......... ALL USERS ARE : %@", objects);
        
        completionBlock(objects, error);
        
    }];
    
}



// passing a board, getting back board objects
- (void)queryAllFriendsOnBoard:(NSString *)boardID completion:(void(^)(NSArray *friends, NSError *error))completionBlock {
    
    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"objectId" equalTo:boardID];
    
    [boardQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable board, NSError * _Nullable error) {
        
        
        
        NSLog(@" ..... INSIDE PARSE CALL: %lu friends came back", board.count);
        
        // get the user (friend) array
        
        completionBlock(board, error);
        
    }];
    
}



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



@end
