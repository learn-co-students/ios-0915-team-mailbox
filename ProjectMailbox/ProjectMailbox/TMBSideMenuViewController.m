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



-(void) viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];
    [self adjustHeightOfTableview];
    NSLog(@"viewDidAppear");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prefersStatusBarHidden];
    
    self.internetConnectionLabel.hidden = YES;
    
    [self checkInternetConnection];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteButtonTappedInCreateBoardVC:) name:@"UserTappedDeleteBoardButton" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveButtonTappedInCreateBoardVC:) name:@"UserTappedSaveBoardButton" object:nil];

    
    // loging in this app as Inga for now
    
    if (![PFUser currentUser]){
        [PFUser logInWithUsernameInBackground:@"ingakyt@yahoo.com" password:@"test" block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            NSLog(@"logged in user: %@ \nwith error: %@", user, error);
        }];
    }
    
    
    self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    
    self.boardsTableView.delegate = self;
    self.boardsTableView.dataSource = self;
    [self.boardsTableView setBackgroundView:nil];
    [self.boardsTableView setBackgroundColor:[UIColor clearColor]];

    NSString *userFirstName = [[PFUser currentUser] objectForKey:@"First_Name"];
    NSString *userLastName = [[PFUser currentUser] objectForKey:@"Last_Name"];    
    self.usernameField.text = [NSString stringWithFormat:@"%@ %@", userFirstName, userLastName];
    
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
            
            [self.userBoards insertObject:object atIndex:0];
            [self.boardsTableView reloadData];
            [self adjustHeightOfTableview];
            
            NSString *boardName = object[@"boardName"];
            NSDate *updatedAt = [object updatedAt];
//            self.boardID = object.objectId;            
//            NSLog(@"========== BOARD OBJECT IS: %@", object);
//            NSLog(@"========== BOARD OBJECT IDs ARE: %@", self.boardID);
            NSLog(@"=========== 1st CREATED BY USER - BOARD NAMES ARE: %@ updated at %@", boardName, updatedAt);
        }
    }];
    
    [self queryAllBoardsContainingUser:[PFUser currentUser] completion:^(NSArray *boardsContainingUser, NSError *error) {
        
        for (PFObject *object in boardsContainingUser) {
            
            [self.userBoards addObject:object];
            [self.boardsTableView reloadData];
            [self adjustHeightOfTableview];
            
            NSString *boardName = object[@"boardName"];
            NSDate *updatedAt = [object updatedAt];
//            self.boardID = object.objectId;
//            NSLog(@"========== BOARD OBJECT IDs ARE: %@", self.boardID);
            NSLog(@"=========== 2nd CONTAINS USER - BOARD NAMES ARE: %@ updated at %@", boardName, updatedAt);
        }
    }];

    
}


- (IBAction)logoutButtonTapped:(id)sender {
    
    [TMBSharedBoardID sharedBoardID].boardID = @"";
    [[TMBSharedBoardID sharedBoardID].boards removeAllObjects];
    [PFUser logOut];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogOutNotification"
                                                        object:nil];
    NSLog(@"User has Logged Out");
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.userBoards.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMBBoardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"boardMemberCell" forIndexPath:indexPath];
    
    PFObject *board = self.userBoards[indexPath.row];

    cell.boardNameLabel.text = [board[@"boardName"] uppercaseString];
    cell.backgroundColor = [UIColor clearColor];
    
    self.boardID = board.objectId;
    NSLog(@"OOOOOOOOOOOOOOBJECT IDS %@", self.boardID);
    
    return cell;

}


-(void)deleteButtonTappedInCreateBoardVC:(NSNotification *)notification {
    
    NSLog(@"WOO I GOT THE MESSAGE, DELETED!: %@", notification);
    
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


-(void)saveButtonTappedInCreateBoardVC:(NSNotification *)notification {
    
    NSLog(@"WOO I GOT THE MESSAGE, SAVED!: %@", notification);
    
    if ([notification.object isKindOfClass:[PFObject class]]) {
        
        PFObject *savedBoard = [notification object];
        [self.userBoards insertObject:savedBoard atIndex:0];
        [self.boardsTableView reloadData];
        [self adjustHeightOfTableview];
    }
    
    else {
        NSLog(@"Error, object not recognised.");
    }
    
}


- (void)checkInternetConnection {
    
    // if there is no internet...
    // hide some views
    // display "YOU ARE NOT CONNECTED TO THE INTERNET"
    
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
        
        NSLog(@"Device is not connected to the internet");
        
    } else {
        NSLog(@"Device is connected to the internet");
    }
}


- (void)adjustHeightOfTableview {
    
    CGFloat minHeight = 60;
    CGFloat height = self.boardsTableView.contentSize.height - 1;
    
    if (height < minHeight)
        height = minHeight;
    
    // set the height constraint
    
    CGFloat scrollViewHeight = height + 550;
    
    NSLog(@"SCROLL VIEW HEIGHT %f", scrollViewHeight);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.boardsTableViewHeightConstraint.constant = height;
        self.scrollView.contentSize = CGSizeMake(280, scrollViewHeight) ;
        [self.view setNeedsUpdateConstraints];
    }];
    
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
