//
//  TMBCommentViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/11/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBCommentViewController.h"
#import "TMBConstants.h"
#import "PAPCache.h"
#import "TMBTableViewCommentCellTableViewCell.h"
#import "TMBSharedBoardID.h"
#import "ParseUI/ParseUI.h"


@interface TMBCommentViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier commentPostBackgroundTaskId;
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//detail view
@property (weak, nonatomic) IBOutlet UILabel *currentUserNameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *commentedPhoto;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentsTableViewHeight;
@property (strong, nonatomic) PFFile *userPhotoFile;

//board ID
@property (nonatomic, strong) NSString *boardID;
@property (strong, nonatomic) PFObject *board;

@end


@implementation TMBCommentViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@" I'M IN THE VIEW DID LOAD, COMMENT VIEW CONTROLLER");
    
    self.boardID = [TMBSharedBoardID sharedBoardID].boardID;
    
    self.commentedPhoto.image = [UIImage imageNamed:@"placeholderForBoardCell"];
    self.commentedPhoto.file = (PFFile *)self.selectedFile;
    [self.commentedPhoto loadInBackground];
    
    self.commentField.delegate = self;
    self.commentsTableView.delegate = self;
    self.commentsTableView.dataSource = self;
    
    [self loadDataFromParse];
    
    self.commentsTableView.allowsSelection = NO;
    self.commentsTableView.estimatedRowHeight = 75;
    self.commentsTableView.rowHeight = UITableViewAutomaticDimension;
    
    PFUser *fromUser = self.parseObjSelected[@"user"];
    NSString *fromUserFirstName = fromUser[@"First_Name"];
    self.currentUserNameLabel.text = [NSString stringWithFormat:@"Posted by %@", fromUserFirstName];
    
}


-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.commentsTableView reloadData];
    [self adjustHeightOfTableview];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)loadDataFromParse {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query includeKey:@"photo"];
    [query whereKey:@"photo" equalTo:self.parseObjSelected]; 
    [query includeKey:@"fromUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            // handle error in the future
        }
        
        PFObject *anActivity = [objects firstObject];
        NSLog(@"anActivities comment: %@", anActivity[@"content"]);
        
        // set datastore to objects array
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.activities = [objects mutableCopy];
            [self.commentsTableView reloadData];
            [self adjustHeightOfTableview];
        }];
        
        // getting photo object
        PFObject *anActivitysPhoto = anActivity[@"photo"];
        PFFile *imageFile = anActivitysPhoto[@"image"];
        
        PFObject *aFromUser = anActivity[@"fromUser"];
        PFObject *fromUserProfilePhoto = aFromUser[@"fromUser"];
        
        // setting user profile photo
        self.userPhotoFile = fromUserProfilePhoto[@"profileImage"];
        
        // setting the image view to photo object above
        [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:result];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.commentedPhoto.image = image;
                }];
            }
        }];
    }];

}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
    
}


- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    
    CGRect finalFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        finalFrame = CGRectZero;
    }
    
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:curve];
        self.commentViewBottomConstraint.constant = finalFrame.size.height + 0;
        [self.view layoutIfNeeded];
    }];
    
}


- (IBAction)closeButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger numberOfComments = self.activities.count;
    NSLog(@"numberOfRows getting called: %lu", self.activities.count);
    
    return numberOfComments;
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TMBTableViewCommentCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    
    NSUInteger rowOfIndexPath = indexPath.row;
    
    // setting table rows to display comments
    
    PFObject *anActivity = self.activities[rowOfIndexPath];
    cell.userCommentLabel.text = anActivity[@"content"];
    NSLog(@"anActivity is %@", anActivity);
    
    // user label displays fromUser name
    PFObject *aFromUser = anActivity[@"fromUser"];
    NSString *firstName = aFromUser[@"First_Name"];
    cell.fromUserNameLabel.text = firstName;
    
    // get profile image
    cell.userProfileImage.layer.cornerRadius = cell.userProfileImage.frame.size.width / 2;
    PFObject *commentDataAtRow = self.activities[rowOfIndexPath];
    PFObject *userDetails = commentDataAtRow[@"fromUser"];
    PFFile *newUserPhotoFile = userDetails[@"profileImage"];
    
    [newUserPhotoFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                cell.userProfileImage.image = image;
                cell.userProfileImage.layer.cornerRadius = cell.userProfileImage.frame.size.width / 2;
    }];
        }
        
    }];

    return cell;
    
}


- (IBAction)sendButtonTapped:(id)sender {
    
//    NSData *imageData = UIImagePNGRepresentation(self.commentedPhoto.image);

    if (self.commentField.text != 0) {
        PFObject* newCommentObject = [PFObject objectWithClassName:@"Activity"];
        
        [newCommentObject setObject:self.commentField.text forKey:@"content"];
        [newCommentObject setObject:[PFUser currentUser] forKey:@"fromUser"];
        [newCommentObject setObject:self.parseObjSelected forKey:@"photo"];
        [newCommentObject setObject:[self.parseObjSelected valueForKey:@"user"] forKey:@"toUser"];
        [newCommentObject setObject:[self.parseObjSelected valueForKey:@"board"] forKey:@"board"];
        [newCommentObject setObject:@"comment" forKey:@"type"];
        
        [newCommentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Saved");
                [self loadDataFromParse];
                self.commentField.text = @"";
                [self.view endEditing:YES];
 
            }
            else{
                // Error
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}


- (void)adjustHeightOfTableview {
    
    CGFloat minHeight = 60;
    CGFloat height = self.commentsTableView.contentSize.height - 1;
    
    if (height < minHeight)
        height = minHeight;
    
    // set the height constraint
    
    CGFloat scrollViewHeight = 500 + height;
    
    NSLog(@"SCROLL VIEW HEIGHT %f", scrollViewHeight);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.commentsTableViewHeight.constant = height;
        self.scrollView.contentSize = CGSizeMake(320, scrollViewHeight) ;
        [self.view setNeedsUpdateConstraints];
    }];
    
}


- (IBAction)backgroundTapped:(id)sender {
    
    [self.commentField endEditing:YES];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // done key was pressed - dismiss keyboard
    [textField resignFirstResponder];
    
    return YES;
}



@end



