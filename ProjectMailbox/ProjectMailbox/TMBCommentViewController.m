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

@interface TMBCommentViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnail;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier commentPostBackgroundTaskId;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewBottomConstraint;

//detail view
@property (weak, nonatomic) IBOutlet UILabel *currentUserNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentedPhoto;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (strong, nonatomic) PFFile *userPhotoFile;

//board ID
@property (nonatomic, strong) NSString *boardID;
@property (strong, nonatomic) PFObject *testing;


@end

@implementation TMBCommentViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.boardID = [TMBSharedBoardID sharedBoardID].boardID;
    
    self.commentedPhoto.image = self.selectedImage;
    
    NSLog(@"What is this from viewDiDLoad: %@", self.parseObjSelected);
    
    self.commentsTableView.delegate = self;
    self.commentsTableView.dataSource = self;
    
    [self loadDataFromParse];
    
    self.commentsTableView.estimatedRowHeight = 75;
    self.commentsTableView.rowHeight = UITableViewAutomaticDimension;

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.commentsTableView reloadData];
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)loadDataFromParse {
    
    /*****************************
     *        PARSE QUERY        *
     *****************************/
    
    // goal: get comments related to that image & display them in a table view
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query includeKey:kTMBActivityPhotoKey];
    [query whereKey:kTMBActivityPhotoKey equalTo:self.parseObjSelected];
    [query includeKey:kTMBActivityFromUserKey];
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
        }];
        
        // getting photo obj
        PFObject *anActivitysPhoto = anActivity[@"photo"];
        PFFile *imageFile = anActivitysPhoto[@"image"];
        
        // test: user's first name set to label
        PFObject *aFromUser = anActivity[@"fromUser"];
        NSString *firstName = aFromUser[@"First_Name"];
        self.currentUserNameLabel.text = [NSString stringWithFormat:@"Posted by %@", firstName];
        PFObject *fromUserProfilePhoto = aFromUser[@"fromUser"];
        self.userPhotoFile = fromUserProfilePhoto[@"profileImage"];
        
        
        // setting the image view to photo obj above
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

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSUInteger numberOfComments = self.activities.count;
    NSLog(@"numberOfRows getting called: %lu", self.activities.count);
    
    return numberOfComments;
}

- (NSString *)getText
{
    return @"This is some long text that should wrap. It is multiple long sentences that may or may not have spelling and grammatical errors. Yep it should wrap quite nicely and serve as a nice example!";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create a reusable cell
    TMBTableViewCommentCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    if(cell == nil) {
        cell = [[TMBTableViewCommentCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commentCell"];
//        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        cell.textLabel.numberOfLines = 0;
    }
    
    // Configure the cell for this indexPath
    cell.userCommentLabel.text = [self getText];
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    TMBTableViewCommentCellTableViewCell *cell = [[TMBTableViewCommentCellTableViewCell alloc] init];
//    cell.userCommentLabel.text = [self getText];
//    
//    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
//    // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
//    // in the UITableViewCell subclass
//    [cell setNeedsLayout];
//    [cell layoutIfNeeded];
//    
//    // Get the actual height required for the cell
//    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//    
//    // Add an extra point to the height to account for the cell separator, which is added between the bottom
//    // of the cell's contentView and the bottom of the table view cell.
//    height += 1;
//    
//    return height;
//}

//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    TMBTableViewCommentCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
//    
//    NSUInteger rowOfIndexPath = indexPath.row;
//    
//    // setting table rows to display comments
//    
//    PFObject *anActivity = self.activities[rowOfIndexPath];
//    cell.userCommentLabel.text = anActivity[@"content"];
//    NSLog(@"anActivity is %@", anActivity);
//    
//    // user label displays fromUser name
//    PFObject *aFromUser = anActivity[@"fromUser"];
//    NSString *firstName = aFromUser[@"First_Name"];
//    cell.fromUserNameLabel.text = firstName;
//    
//    // get profile image
//    cell.userProfileImage.layer.cornerRadius = cell.userProfileImage.frame.size.width / 2;
//    cell.userProfileImage.clipsToBounds = YES;
//    PFObject *commentDataAtRow = self.activities[rowOfIndexPath];
//    PFObject *userDetails = commentDataAtRow[@"fromUser"];
//    PFFile *newUserPhotoFile = userDetails[@"profileImage"];
//    [newUserPhotoFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
//        if (!error) {
//            UIImage *image = [UIImage imageWithData:data];
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                cell.userProfileImage.image = image;
//    }];
//        }
//        
//    }];
//    
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//
//    return cell;
//    
//}

- (IBAction)sendButtonTapped:(id)sender {
    
    NSData *imageData = UIImagePNGRepresentation(self.commentedPhoto.image);
    
    PFFile *test = [PFFile fileWithData:imageData];
    
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

- (IBAction)topViewTapped:(id)sender {
    
    [self.commentField resignFirstResponder];
}




@end
