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

@interface TMBImageCardViewController ()

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

//loading view
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;


@end

@implementation TMBImageCardViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.boardID = [TMBSharedBoardID sharedBoardID].boardID;
    self.board = [[TMBSharedBoardID sharedBoardID].boards objectForKey:self.boardID];
    
}

-(void)activityLoadView
{
    
    self.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.overlayView.center;
    [self.overlayView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.overlayView];
    
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


// this code saves our image and its comment to Parse
- (IBAction)postButtonTapped:(UIButton *)sender {
    
    [self activityLoadView];
    
    self.thumbnail = [self imageWithImage:self.imageView.image scaledToMaxWidth:204.0 maxHeight:176.0];
    
    //    [self shouldUploadImage:self.image];
    
    // Trim comment and save it in a dictionary for use later in our callback block
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    trimmedComment,
                    kTMBEditPhotoViewControllerUserInfoCommentKey,
                    nil];
    }
    
    NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
    NSData *thumbData = UIImagePNGRepresentation(self.thumbnail);
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbFile = [PFFile fileWithData:thumbData];
    
    PFObject *photo = [PFObject objectWithClassName:kTMBPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kTMBPhotoUserKey];
    [photo setObject:self.photoFile forKey:kTMBPhotoPictureKey];
    [photo setObject:self.thumbFile forKey:kTMBPhotoThumbnailKey];
    [photo setObject:self.board forKey:@"board"];
    
    // Photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    // Save the Photo PFObject
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            [self.delegate imageCardViewController:self passBoardIDforQuery:self.boardID];
            [self dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"Photo uploaded");
            
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
                }
            }
            
        }else {
            
            NSLog(@"Photo failed to save: %@", error);
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
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
