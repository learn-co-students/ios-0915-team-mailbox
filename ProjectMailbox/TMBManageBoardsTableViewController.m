//
//  TMBManageBoardsTableViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 12/15/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBManageBoardsTableViewController.h"
#import "TMBBoardTableViewCell.h"
#import <Parse/Parse.h>

@interface TMBManageBoardsTableViewController ()
@property (strong, nonatomic) NSMutableArray *userBoards;
@property (strong, nonatomic) NSString *boardID;

@end

@implementation TMBManageBoardsTableViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.userBoards = [NSMutableArray new];
    
    [self queryAllBoardsCreatedByUser:[PFUser currentUser] completion:^(NSArray *boardsCreatedByUser, NSError *error) {
        
        for (PFObject *object in boardsCreatedByUser) {
            
            [self.userBoards addObject:object];
            [self.tableView reloadData];
            
            NSString *boardName = object[@"boardName"];
            NSDate *updatedAt = [object updatedAt];
            //            self.boardID = object.objectId;
            //
            //            NSLog(@"========== BOARD OBJECT IS: %@", object);
            //            NSLog(@"========== BOARD OBJECT IDs ARE: %@", self.boardID);
            NSLog(@"=========== 1st CREATED BY USER - BOARD NAMES ARE: %@ updated at %@", boardName, updatedAt);
        }
    }];
    
    [self queryAllBoardsContainingUser:[PFUser currentUser] completion:^(NSArray *boardsContainingUser, NSError *error) {
        
        for (PFObject *object in boardsContainingUser) {
            
            [self.userBoards addObject:object];
            [self.tableView reloadData];
            
            NSString *boardName = object[@"boardName"];
            NSDate *updatedAt = [object updatedAt];
            //            self.boardID = object.objectId;
            //
            //            NSLog(@"========== BOARD OBJECT IDs ARE: %@", self.boardID);
            NSLog(@"=========== 2nd CONTAINS USER - BOARD NAMES ARE: %@ updated at %@", boardName, updatedAt);
        }
    }];
    

}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.userBoards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMBBoardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"boardCell" forIndexPath:indexPath];
    
    PFObject *board = self.userBoards[indexPath.row];
    
    cell.boardNameLabel.text = board[@"boardName"];
//    cell.backgroundColor = [UIColor clearColor];
    
    self.boardID = board.objectId;
    NSLog(@"OOOOOOOOOOOOOOBJECT IDS %@", self.boardID);
    
    return cell;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
