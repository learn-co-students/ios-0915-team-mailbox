//
//  TMBSideMenuViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBSideMenuViewController.h"
#import "TMBBoard.h"
#import "TMBSideMenuTableViewCell.h"
#import "TMBSharedBoardID.h"


@interface TMBSideMenuViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UITableView *boardListingTableView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameField;
@property (nonatomic) NSInteger boardCount;
@property (strong, nonatomic) NSMutableArray *userBoards;
@property (strong, nonatomic) NSString *boardID;

@end

@implementation TMBSideMenuViewController



-(void) viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];
    [self.boardListingTableView reloadData];
    NSLog(@"viewDidAppear");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prefersStatusBarHidden];
    
    self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.boardListingTableView.delegate = self;
    self.boardListingTableView.dataSource = self;
    self.usernameField.text = [[PFUser currentUser] objectForKey:@"First_Name"];
    
    [self.boardListingTableView setBackgroundView:nil];
    [self.boardListingTableView setBackgroundColor:[UIColor clearColor]];
    
    PFFile *profilePictureObject = [[PFUser currentUser] objectForKey:@"profileImage"];
    
    if (profilePictureObject !=nil) {
        [profilePictureObject getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (data != nil) {
                
                NSLog(@"WEEEEE OK??!!");
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.profileImage.image = [UIImage imageWithData:data];
                }];
            }
        }];
    }
    
    self.userBoards = [NSMutableArray new];

    [self queryAllBoardsCreatedByUser:[PFUser currentUser] completion:^(NSArray *boardsCreatedByUser, NSError *error) {
        
        for (PFObject *object in boardsCreatedByUser) {
            
            [self.userBoards addObject:object];
            [self.boardListingTableView reloadData];
            
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
            [self.boardListingTableView reloadData];

            NSString *boardName = object[@"boardName"];
            NSDate *updatedAt = [object updatedAt];
//            self.boardID = object.objectId;
//            
//            NSLog(@"========== BOARD OBJECT IDs ARE: %@", self.boardID);
            NSLog(@"=========== 2nd CONTAINS USER - BOARD NAMES ARE: %@ updated at %@", boardName, updatedAt);
        }
    }];

    
}


- (IBAction)logoutButtonTapped:(id)sender {
    
    [TMBSharedBoardID sharedBoardID].boardID = @"";
    [[TMBSharedBoardID sharedBoardID].boards removeAllObjects];
    [PFUser logOut];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogOutNotification" object:nil];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.userBoards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMBSideMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    
    PFObject *board = self.userBoards[indexPath.row];
    
    //cell.textLabel.text = board[@"boardName"];
    cell.boardNameLabel.text = board[@"boardName"];
    cell.backgroundColor = [UIColor clearColor];
    
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



@end
