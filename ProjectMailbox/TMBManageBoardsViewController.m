//
//  TMBManageBoardsViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 1/5/16.
//  Copyright © 2016 Joseph Kiley. All rights reserved.
//

#import "TMBManageBoardsViewController.h"
#import "TMBBoardTableViewCell.h"
#import <Parse/Parse.h>
#import "CreateBoardViewController.h"


@interface TMBManageBoardsViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *internetConnectionLabel;
@property (strong, nonatomic) NSMutableArray *adminBoards;
@property (strong, nonatomic) NSMutableArray *adminBoardFriends;
@property (strong, nonatomic) NSMutableArray *memberBoards;
@property (weak, nonatomic) IBOutlet UITableView *adminTableView;
@property (weak, nonatomic) IBOutlet UITableView *memberTableView;
@property (strong, nonatomic) NSString *boardID;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *boardsYouManageLabel;
@property (weak, nonatomic) IBOutlet UILabel *boardsYoureInLabel;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminTableHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *memberTableHeightConstraint;

@end

@implementation TMBManageBoardsViewController



- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self adjustHeightOfTableview];
    
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self prefersStatusBarHidden];
    
    self.internetConnectionLabel.hidden = YES;
    
    [self checkInternetConnection];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteButtonTappedInCreateBoardVC:) name:@"UserTappedDeleteBoardButton" object:nil];
    
    self.adminTableView.delegate = self;
    self.adminTableView.dataSource = self;
    self.memberTableView.delegate = self;
    self.memberTableView.dataSource = self;
    
    self.adminBoards = [NSMutableArray new];
    self.adminBoardFriends = [NSMutableArray new];
    self.memberBoards = [NSMutableArray new];
    
    
    // loging in this app as Inga for now
    
//    if (![PFUser currentUser]){
//        [PFUser logInWithUsernameInBackground:@"ingakyt@yahoo.com" password:@"test" block:^(PFUser * _Nullable user, NSError * _Nullable error) {
//            NSLog(@"logged in user: %@ \nwith error: %@", user, error);
//        }];
//    }
    
    
    [self queryAllBoardsCreatedByUser:[PFUser currentUser] completion:^(NSArray *boardsCreatedByUser, NSError *error) {
        
        if (!error) {
            for (PFObject *object in boardsCreatedByUser) {
            [self.adminBoards insertObject:object atIndex:0];
            [self.adminTableView reloadData];
            [self adjustHeightOfTableview];
            }
        }

    }];
    
    
    [self queryAllBoardsContainingUser:[PFUser currentUser] completion:^(NSArray *boardsContainingUser, NSError *error) {
        
        for (PFObject *object in boardsContainingUser) {
            
            [self.memberBoards insertObject:object atIndex:0];
            [self.memberTableView reloadData];
            [self adjustHeightOfTableview];
        }
    }];
    
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}


-(void)deleteButtonTappedInCreateBoardVC:(NSNotification *)notification
{
    NSLog(@"WOO I GOT THE MESSAGE: %@", notification);
    
    NSIndexPath *selectedIndexPath = self.adminTableView.indexPathForSelectedRow;
    PFObject *selectedBoard = self.adminBoards[selectedIndexPath.row];

    [self.adminBoards removeObject:selectedBoard];
    
    [self.adminTableView reloadData];
    [self adjustHeightOfTableview];
    
}



- (void)checkInternetConnection {
    
    // if there is no internet...
    // hide some views
    // display alert
    
    // check connection to a very small, fast loading site:
    NSURL *scriptUrl = [NSURL URLWithString:@"http://apple.com/contact"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (!data) {
        self.internetConnectionLabel.hidden = NO;
        self.internetConnectionLabel.text = @"No Internet Connection";
        self.boardsYouManageLabel.hidden = YES;
        self.adminTableView.hidden = YES;
        self.boardsYoureInLabel.hidden = YES;
        self.memberTableView.hidden = YES;
        NSLog(@"Device is not connected to the internet");
        
    } else {
        NSLog(@"Device is connected to the internet");
    }
}



#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.adminTableView) {
        return self.adminBoards.count;
    } else {
        return self.memberBoards.count;
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TMBBoardTableViewCell *cell = [[TMBBoardTableViewCell alloc] init];
    
    
    if (tableView == self.adminTableView) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"boardAdminCell" forIndexPath:indexPath];
        
        PFObject *board = self.adminBoards[indexPath.row];
        
        cell.boardNameLabel.text = board[@"boardName"];
        
        } else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"boardMemberCell" forIndexPath:indexPath];
        
        PFObject *board = self.memberBoards[indexPath.row];
        
        cell.boardNameLabel.text = board[@"boardName"];
        
    }
    
    
    return cell;
    
}



#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"selectedBoard"]) {
        
    CreateBoardViewController *destinationVC = segue.destinationViewController;        
        
    NSIndexPath *selectedIndexPath = self.adminTableView.indexPathForSelectedRow;
    PFObject *selectedBoard = self.adminBoards[selectedIndexPath.row];
        
        for (PFUser *eachFriend in selectedBoard[@"boardFriends"]) {
            [self.adminBoardFriends addObject:eachFriend];
        }
    
    self.boardID = selectedBoard.objectId;
    
    destinationVC.selectedBoard = selectedBoard;
    destinationVC.boardObjectIdFromSelectedBoard = self.boardID;
    destinationVC.boardNameToDisplay = selectedBoard[@"boardName"];
    destinationVC.shouldHideCancelButton = YES;
    destinationVC.boardFriendsToDisplay = self.adminBoardFriends;
        
    }
    
}



- (IBAction)unfollowButtonTapped:(UIButton *)sender {
    
    TMBBoardTableViewCell *tappedCell = (TMBBoardTableViewCell*)[[sender superview] superview];
    
    NSIndexPath *selectedIP = [self.memberTableView indexPathForCell:tappedCell];
    
    NSInteger index = selectedIP.row;
    
    PFObject *selectedBoard = self.memberBoards[index];
    
    [self removeUser:[PFUser currentUser] fromBoard:selectedBoard];
    [self.memberBoards removeObject:selectedBoard]; // removing locally
    [self.memberTableView reloadData];
    [self adjustHeightOfTableview];
    
}



- (void)adjustHeightOfTableview {
    
    CGFloat minHeight = 60;
    CGFloat adminTableHeight = self.adminTableView.contentSize.height - 1;
    
    CGFloat memberTableHeight = self.memberTableView.contentSize.height - 1;
    
    if (adminTableHeight < minHeight)
        adminTableHeight = minHeight;
    
    if (memberTableHeight < minHeight)
        memberTableHeight = minHeight;
    
    // set the height constraint
    
    CGFloat scrollViewHeight =
    self.adminTableHeightConstraint.constant +
    self.memberTableHeightConstraint.constant + 280;
    
//    NSLog(@"SCROLL VIEW HEIGHT %f", scrollViewHeight);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.adminTableHeightConstraint.constant = adminTableHeight;
        self.memberTableHeightConstraint.constant = memberTableHeight;
        self.scrollView.contentSize = CGSizeMake(320, scrollViewHeight);
        [self.view setNeedsUpdateConstraints];
    }];
    
}


- (IBAction)closeButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}


/*****************************
 *         PARSE CALLS       *
 *****************************/


- (void)queryAllBoardsCreatedByUser:(PFUser *)user completion:(void(^)(NSArray *boardsCreatedByUser, NSError *error))completionBlock {
    
    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"fromUser" equalTo:user];
    [boardQuery includeKey:@"boardFriends"];
    
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



- (void)removeUser:(PFObject *)user fromBoard:(PFObject *)board {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Board"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:board.objectId
                                 block:^(PFObject *aBoard, NSError *error) {
                                     // Now let's update it with some new data. In this case, only cheatMode and score
                                     // will get sent to the cloud. playerName hasn't changed.
                                     [aBoard removeObject:user forKey:@"boardFriends"];
                                     [aBoard saveInBackground];
                                 }];
    
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


@end
