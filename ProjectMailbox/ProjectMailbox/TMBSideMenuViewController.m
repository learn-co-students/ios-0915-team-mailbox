//
//  TMBSideMenuViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBSideMenuViewController.h"
#import "TMBBoard.h"

@interface TMBSideMenuViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameField;
@property (weak, nonatomic) IBOutlet UITableView *boardListingTableView;
@property (nonatomic) NSInteger boardCount;
@property (strong, nonatomic) NSMutableArray *userBoards;

@end

@implementation TMBSideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    
    self.usernameField.text = [[PFUser currentUser] objectForKey:@"First_Name"];
    
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
    
    [self queryForBoardsWithUser];
    
}

- (IBAction)logoutButtonTapped:(id)sender {
    
    [PFUser logOut];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogOutNotification" object:nil];
    
}

- (void)queryForBoardsWithUser {
    
    self.userBoards = [NSMutableArray new];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Board"];
    [query whereKey:@"users" equalTo:PFUser.currentUser];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        NSLog(@"The objects is : %@", objects);
        
        for (PFObject *thing in objects) {
            
            TMBBoard *newboard = [TMBBoard newTMBoardFromPFObject:thing];
            
            
            [self.userBoards addObject:newboard];
        
        }
        
        NSSortDescriptor *byDate = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES];
        [self.userBoards sortUsingDescriptors:@[byDate]];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.boardListingTableView reloadData];
        }];
        
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.userBoards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];
    
    TMBBoard *boards = self.userBoards[indexPath.row];
    
    cell.textLabel.text = boards.boardName;
    
    return cell;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
