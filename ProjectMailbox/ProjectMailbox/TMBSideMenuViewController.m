//
//  TMBSideMenuViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBSideMenuViewController.h"
#import "TMBBoard.h"
#import "TMBSharedBoardID.h"
#import "TMBBoardTableViewCell.h"
#import "TMBBoardController.h"
#import "AppViewController.h"


@interface TMBSideMenuViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *findFriendsButton;
@property (weak, nonatomic) IBOutlet UIButton *createNewBoardButton;
@property (weak, nonatomic) IBOutlet UIButton *manageBoardsButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameField;
@property (nonatomic) NSInteger boardCount;
@property (strong, nonatomic) NSMutableArray *userBoards;
@property (strong, nonatomic) NSString *boardID;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *boardsTableView;
@property (weak, nonatomic) IBOutlet UILabel *internetConnectionLabel;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *boardsTableViewHeightConstraint;

@end


@implementation TMBSideMenuViewController



- (void)viewDidAppear:(BOOL)animated  {
    
    [super viewDidAppear:animated];
    
    NSLog(@" I'M IN THE VIEW DID APPEAR, SIDE MENU VIEW CONTROLLER");

    [self adjustHeightOfTableview];
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@" I'M IN THE VIEW DID LOAD, SIDE MENU VIEW CONTROLLER");

    [self prefersStatusBarHidden];
    
    self.internetConnectionLabel.hidden = YES;
    
    [self checkInternetConnection];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteButtonTappedInCreateBoardVC:) name:@"UserTappedDeleteBoardButton" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveButtonTappedInCreateBoardVC:) name:@"UserTappedSaveBoardButton" object:nil];
    
    self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    
    self.boardsTableView.delegate = self;
    self.boardsTableView.dataSource = self;
    [self.boardsTableView setBackgroundView:nil];
    [self.boardsTableView setBackgroundColor:[UIColor clearColor]];
    self.boardsTableView.separatorColor = [UIColor clearColor];

    NSString *userFirstName = [[PFUser currentUser] objectForKey:@"First_Name"];
    NSString *userLastName = [[PFUser currentUser] objectForKey:@"Last_Name"];    
    self.usernameField.text = [NSString stringWithFormat:@"%@ %@", userFirstName, userLastName];
    
    PFFile *profilePictureObject = [[PFUser currentUser] objectForKey:@"profileImage"];
    
    if (profilePictureObject !=nil) {
        [profilePictureObject getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (data != nil) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.profileImage.image = [UIImage imageWithData:data];
                }];
            }
        }];
    }
    
    self.userBoards = [NSMutableArray new];

    [self queryAllBoardsCreatedByUser:[PFUser currentUser] completion:^(NSArray *boardsCreatedByUser, NSError *error) {
        
        for (PFObject *object in boardsCreatedByUser) {
            
            [self.userBoards insertObject:object atIndex:0];
            NSLog(@" I'M IN THE VIEW DID LOAD, SIDE MENU VIEW CONTROLLER. ALL BOARDS CREATED BY CURRENT USER ARE: %@", self.userBoards);
            [self.boardsTableView reloadData];
            [self adjustHeightOfTableview];
            
//            NSString *boardName = object[@"boardName"];
//            NSDate *updatedAt = [object updatedAt];
//            NSLog(@"=========== BOARDS CREATED BY USER - BOARD NAMES ARE: %@ updated at %@", boardName, updatedAt);
        }
    }];
    
    [self queryAllBoardsContainingUser:[PFUser currentUser] completion:^(NSArray *boardsContainingUser, NSError *error) {
        
        for (PFObject *object in boardsContainingUser) {
            
            [self.userBoards addObject:object];
             NSLog(@" I'M IN THE VIEW DID LOAD, SIDE MENU VIEW CONTROLLER. ALL BOARDS CONTAINING CURRENT USER ARE: %@", self.userBoards);
            [self.boardsTableView reloadData];
            [self adjustHeightOfTableview];
        }
    }];

    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@" I'M IN THE TABLE VIEW NUMBER OF ROWS, SIDE MENU VIEW CONTROLLER. USER BOARDS COUNT IS %lu", self.userBoards.count);
    NSLog(@" I'M IN THE TABLE VIEW NUMBER OF ROWS, SIDE MENU VIEW CONTROLLER. USER BOARDS ARE: %@", self.userBoards);
    return self.userBoards.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TMBBoardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"boardMemberCell" forIndexPath:indexPath];
    
    PFObject *board = self.userBoards[indexPath.row];

    cell.boardNameLabel.text = [board[@"boardName"] uppercaseString];
    cell.backgroundColor = [UIColor clearColor];
    
    //self.boardID = board.objectId;
//    [TMBSharedBoardID sharedBoardID].boardID = board.objectId;
//    [[TMBSharedBoardID sharedBoardID].boards objectForKey:board];
//    NSLog(@" I'M IN THE TABLE VIEW CELL FOR ROW, SIDE MENU VIEW CONTROLLER. SHARED BOARD OBJECT ID IS %@", [TMBSharedBoardID sharedBoardID].boardID);
//    
//    NSIndexPath *selectedIndexPath = tableView.indexPathForSelectedRow;
//    PFObject *selectedBoard = self.userBoards[selectedIndexPath.row];
//    
//    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    [center postNotificationName:@"UserSelectedABoard" object:selectedBoard];
//    
//    NSLog(@" I'M IN THE TABLE VIEW CELL FOR ROW, SIDE MENU VIEW CONTROLLER. CELL WAS TAPPED. SELECTED BOARD IS %@", selectedBoard);
    
    return cell;
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
//    AppViewController *destinationVC = segue.destinationViewController;
    
    // when you tap a row...
    NSIndexPath *selectedIndexPath = self.boardsTableView.indexPathForSelectedRow;
    PFObject *selectedBoard = self.userBoards[selectedIndexPath.row];
    NSString *selecedBoardObjectId = selectedBoard.objectId;
    
    NSLog(@" I'M IN THE PREPARE FOR SEGUE, SIDE MENU VIEW CONTROLLER. CELL WAS TAPPED. SELECTED BOARD IS: %@", selecedBoardObjectId);

    [TMBSharedBoardID sharedBoardID].boardID = selectedBoard.objectId;
    
    NSString *boardID = [selectedBoard valueForKey:@"objectId"];
    [[TMBSharedBoardID sharedBoardID].boards setObject:selectedBoard forKey:boardID];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"UserSelectedABoard" object:selectedBoard];

    //connects to destination VC. acts only as a link. the property is empty
//    destinationVC.boardID = selecedBoardObjectId;
    
}


- (void)deleteButtonTappedInCreateBoardVC:(NSNotification *)notification {
    
    NSLog(@" WOO I GOT THE MESSAGE, DELETED!: %@", notification);
    
    if ([notification.object isKindOfClass:[PFObject class]]) {
        
        PFObject *deletedBoard = [notification object];
        [self.userBoards removeObject:deletedBoard];
        [self.boardsTableView reloadData];
        [self adjustHeightOfTableview];
    }
    
    else {
        NSLog(@"Error, object not recognised.");
    }
    
}


- (void)saveButtonTappedInCreateBoardVC:(NSNotification *)notification {
    
    NSLog(@" WOO I GOT THE MESSAGE, SAVED!: %@", notification);
    
    if ([notification.object isKindOfClass:[PFObject class]]) {
        
        PFObject *savedBoard = [notification object];
        
        if (![self.userBoards containsObject:savedBoard]) {
            [self.userBoards insertObject:savedBoard atIndex:0];
        }
        
        [self.boardsTableView reloadData];
        [self adjustHeightOfTableview];
    }
    
    else {
        NSLog(@"Error, object not recognised.");
    }
    
}


- (IBAction)logoutButtonTapped:(id)sender {
    
    [TMBSharedBoardID sharedBoardID].boardID = @"";
    [[TMBSharedBoardID sharedBoardID].boards removeAllObjects];
    [PFUser logOut];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogOutNotification"
                                                        object:nil];
    NSLog(@" User has Logged Out");
    
}


- (void)checkInternetConnection {
    
    // check connection to a very small, fast loading site:
    NSURL *scriptUrl = [NSURL URLWithString:@"http://apple.com/contact"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (!data) {
        self.internetConnectionLabel.hidden = NO;
        self.internetConnectionLabel.text = @"No Internet Connection";
        self.usernameField.hidden = YES;
        self.profileImage.hidden = YES;
        self.editProfileButton.hidden = YES;
        self.boardsTableView.hidden = YES;
        self.findFriendsButton.hidden = YES;
        self.createNewBoardButton.hidden = YES;
        self.manageBoardsButton.hidden = YES;
        self.logoutButton.hidden = YES;
        
        NSLog(@" Device is not connected to the internet");
        
    } else {
        NSLog(@" Device is connected to the internet");
    }
    
}


- (void)adjustHeightOfTableview {
    
    CGFloat minHeight = 40;
    CGFloat height = self.boardsTableView.contentSize.height - 1;
    
    if (height < minHeight)
        height = minHeight;
    
    // set the height constraint
    
    CGFloat scrollViewHeight = height + 550;
    
//    NSLog(@"SCROLL VIEW HEIGHT %f", scrollViewHeight);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.boardsTableViewHeightConstraint.constant = height;
        self.scrollView.contentSize = CGSizeMake(280, scrollViewHeight) ;
        [self.view setNeedsUpdateConstraints];
    }];
    
}


- (void)queryAllBoardsCreatedByUser:(PFUser *)user completion:(void(^)(NSArray *boardsCreatedByUser, NSError *error))completionBlock {
    
    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"fromUser" equalTo:user];
    
    [boardQuery findObjectsInBackgroundWithBlock:^(NSArray *boardsCreatedByUser, NSError *error) {        
        completionBlock(boardsCreatedByUser, error);
    }];
}


- (void)queryAllBoardsContainingUser:(PFUser *)user completion:(void(^)(NSArray *boardsContainingUser, NSError *error))completionBlock {
    
    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"boardFriends" equalTo:PFUser.currentUser];
    
    [boardQuery findObjectsInBackgroundWithBlock:^(NSArray *boardsContainingUser, NSError *error) {
        completionBlock(boardsContainingUser, error);
    }];
}



@end


