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
@property (strong, nonatomic) NSString *photoParseText;

//board ID
@property (nonatomic, strong) NSString *boardID;
@property (strong, nonatomic) PFObject *testing;


@end

@implementation TMBCommentViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.boardID = [TMBSharedBoardID sharedBoardID].boardID;
    
    self.commentedPhoto.image = self.selectedImage;
    self.photoParseText = [self.parseObjSelected valueForKey:@"objectId"];
    
    NSLog(@"What is this from viewDiDLoad: %@", self.parseObjSelected);
    
    self.commentsTableView.delegate = self;
    self.commentsTableView.dataSource = self;
    
    /*****************************
     *        PARSE QUERY        *
     *****************************/

    // goal: get comments related to that image & display them in a table view
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query includeKey:kTMBActivityPhotoKey];
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
        self.testing = anActivitysPhoto;
        PFFile *imageFile = anActivitysPhoto[@"image"];
        
        // test: user's first name set to label
        PFObject *aFromUser = anActivity[@"fromUser"];
        NSString *firstName = aFromUser[@"First_Name"];
        self.currentUserNameLabel.text = [NSString stringWithFormat:@"Posted by %@", firstName];
        
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

    
//    PFQuery *commentQuery = [PFQuery queryWithClassName:@"Activity"];
//    [commentQuery whereKey:@"photo" equalTo:self.photoParseText];
//    [commentQuery includeKey:@"fromUser"];
//    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//        if (error) {
//            
//        } else {
//            PFObject *commentActivity = [objects firstObject];
//            NSLog(@"here's the content for this photo %@", commentActivity[@"content"]);
//            
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                [self.activities addObject:[objects mutableCopy]];
//                [self.commentsTableView reloadData];
//            }];
//        }
//    }];
//    
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSUInteger numberOfComments = self.activities.count;
    NSLog(@"numberOfRows getting called: %lu", self.activities.count);
    
    return numberOfComments;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TMBTableViewCommentCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    
    NSUInteger rowOfIndexPath = indexPath.row;
    
    // setting table rows to display comments
    
    PFObject *anActivity = self.activities[rowOfIndexPath];
    cell.userCommentLabel.text = anActivity[@"content"];
    NSLog(@"anActivity is %@", anActivity);
    
    // user label displays fromUser name
    PFObject *aFromUser = anActivity[@"fromUser"];
    NSLog(@"aFromUser is %@", aFromUser);
    NSString *firstName = aFromUser[@"First_Name"];
    NSLog(@"first name is %@", firstName);
    cell.fromUserNameLabel.text = firstName;
    
    
    // set user profile photo next...

    return cell;
    
}

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
                self.commentField.text = @"";
 
            }
            else{
                // Error
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}


@end
