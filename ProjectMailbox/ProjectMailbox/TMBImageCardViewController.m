//
//  TMBImageCardViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 11/18/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBImageCardViewController.h"
#import "TMBConstants.h"
#import "PAPCache.h"
#import "TMBTableViewCommentCellTableViewCell.h"
#import "TMBSharedBoardID.h"

@interface TMBImageCardViewController () <UITableViewDelegate, UITableViewDataSource>

//add photo view
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnail;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier commentPostBackgroundTaskId;
//@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewBottomConstraint;

//detail view
@property (weak, nonatomic) IBOutlet UILabel *currentUserNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentedPhoto;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;


//board ID
@property (nonatomic, strong) NSString *boardID;
@property (nonatomic, strong) PFObject *board;
@property (strong, nonatomic) PFObject *testing;


@end

@implementation TMBImageCardViewController

- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
        self.commentPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"IN VIEW DID LOAD.........");
    
    self.commentsTableView.delegate = self;
    self.commentsTableView.dataSource = self;
    
    self.boardID = [TMBSharedBoardID sharedBoardID].boardID;
    self.board = [[TMBSharedBoardID sharedBoardID].boards objectForKey:self.boardID];
    
    if (![PFUser currentUser]){
        NSLog(@"Not currently logged in");
    }
  
    /*****************************
     *        PARSE QUERY        *
     *****************************/

    // goal: query for an image, set the image to the view
    // goal: get comments related to that image & display them in a small table view
    
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
    
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)closeButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePhotoButtonTapped:(UIButton *)sender {

    // simulators don't have a camera
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        NSLog(@"NO CAMERA FOUND");
        // make an alert later
        
    } else {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
    
}

- (IBAction)chosePhotoButtonTapped:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"\n\n\nimagePickerController\n\n\n");
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.clipsToBounds = YES;
    [self.imageView setImage:chosenImage];
    
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



/*****************************
 *      SAVING TO PARSE      *
 *****************************/

// this code saves the image selected from photo library or camera
- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    // passing a UIImage and setting it to our library/camera image
    anImage = self.imageView.image;
    
    NSData *imageData = UIImagePNGRepresentation(anImage);
    NSData *thumbData = UIImagePNGRepresentation(self.thumbnail);
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbFile = [PFFile fileWithData:thumbData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.thumbFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                NSLog(@"\n\nsaved thumbFile\n\n");
                
                if (error) {
                    NSLog(@"self.thumbnailFile saveInBackgroundWithBlock: %@", error);
                }
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];

    
    NSLog(@"IN SHOULD UPLOAD IMAGE BOOL .........");
    
    return YES;
}

// this code saves our image and its comment to Parse
- (IBAction)postButtonTapped:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.thumbnail = [self imageWithImage:self.imageView.image scaledToMaxWidth:410.0 maxHeight:352.0];
    
    [self shouldUploadImage:self.image];
    
    // Trim comment and save it in a dictionary for use later in our callback block
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    trimmedComment,
                    kTMBEditPhotoViewControllerUserInfoCommentKey,
                    nil];
    }
    
    PFObject *photo = [PFObject objectWithClassName:kTMBPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kTMBPhotoUserKey];  // the user is nil??
    [photo setObject:self.photoFile forKey:kTMBPhotoPictureKey];
    [photo setObject:self.thumbFile forKey:kTMBPhotoThumbnailKey];
    [photo setObject:self.board forKey:@"board"];
    
    // Photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading
    // the photo even if the app is sent to the background
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // Save the Photo PFObject
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            [self.delegate imageCardViewController:self passBoardIDforQuery:self.boardID];
            
            NSLog(@"Photo uploaded");
            
            // run query
            
            
            
            [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            
            // userInfo might contain any caption which might have been posted by the uploader
            if (userInfo) {
                NSString *commentText = [userInfo objectForKey:kTMBEditPhotoViewControllerUserInfoCommentKey];
                
                if (commentText && commentText.length != 0) {
                    // create and save photo caption
                    PFObject *comment = [PFObject objectWithClassName:kTMBActivityClassKey];
                    [comment setObject:kTMBActivityTypeComment forKey:kTMBActivityTypeKey];
                    [comment setObject:photo forKey:kTMBActivityPhotoKey];
                    [comment setObject:[PFUser currentUser] forKey:kTMBActivityFromUserKey];
                    [comment setObject:[PFUser currentUser] forKey:kTMBActivityToUserKey];
                    [comment setObject:commentText forKey:kTMBActivityContentKey];
                    
                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                    [ACL setPublicReadAccess:YES];
                    comment.ACL = ACL;
                    
                    [comment saveEventually];
                    [[PAPCache sharedCache] incrementCommentCountForPhoto:photo];
                }
            }
            //
            //            [[NSNotificationCenter defaultCenter] postNotificationName:TMBTabBarControllerDidFinishEditingPhotoNotification object:photo];
        }else {
            NSLog(@"Photo failed to save: %@", error);
            // re-write this alert to newer syntax
            
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            //            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        
    }];

    
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {

    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return [self imageWithImage:image scaledToSize:newSize];
}

- (IBAction)imageTapped:(id)sender {
    
    [self.textView endEditing:YES];
    
}


@end
