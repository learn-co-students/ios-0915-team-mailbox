//
//  TMBImageCardViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 11/18/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBImageCardViewController.h"
#import "TMBConstants.h"
#import "TMBSharedBoardID.h"

@interface TMBImageCardViewController () <UITextFieldDelegate>

//photo handling
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumb;
@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, strong) PFFile *thumbFile;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;

//board ID
@property (nonatomic, strong) NSString *boardID;
@property (nonatomic, strong) PFObject *board;

//loading view
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end



@implementation TMBImageCardViewController



#pragma mark - views


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.textField.delegate = self;
    
    self.boardID = [TMBSharedBoardID sharedBoardID].boardID;
    self.board = [[TMBSharedBoardID sharedBoardID].boards objectForKey:self.boardID];
    
    NSLog(@" I'M IN THE VIEW DID LOAD, IMAGE CARD VIEW CONTROLLER. SHARED BOARD ID IS %@", self.boardID);
    NSLog(@" I'M IN THE VIEW DID LOAD, IMAGE CARD VIEW CONTROLLER. SHARED BOARD OBJECT IS %@", self.board);
    
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)activityLoadView {
    
    self.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.overlayView.center;
    [self.overlayView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.overlayView];
    
}



#pragma mark - misc end / exit


- (IBAction)closeButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)backgroundTapped:(id)sender {
    
    [self.textField endEditing:YES];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // done key was pressed - dismiss keyboard
    [textField resignFirstResponder];
    
    return YES;
}



#pragma mark - choose or take photo


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


- (IBAction)choseImageButtonTapped:(UIButton *)sender {
    
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



#pragma mark - save to parse


- (IBAction)postButtonTapped:(UIButton *)sender {
    
    // overlay activity indicator
    [self activityLoadView];
    
    // scale image for view in board
    self.thumb = [self imageWithImage:self.imageView.image scaledToMaxWidth:930.0 maxHeight:396.0];
    self.image = [self imageWithImage:self.imageView.image scaledToMaxWidth:1224.0 maxHeight:1056.0];
    
    // capture text comment
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:trimmedComment,
                    kTMBEditPhotoViewControllerUserInfoCommentKey,
                    nil];
    }
    
    NSData *imageData = UIImageJPEGRepresentation(self.image, 0.8f);
    NSData *thumbData = UIImagePNGRepresentation(self.thumb);
    
    self.imageFile = [PFFile fileWithData:imageData];
    self.thumbFile = [PFFile fileWithData:thumbData];
    
    PFObject *photo = [PFObject objectWithClassName:kTMBPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kTMBPhotoUserKey];
    [photo setObject:self.imageFile forKey:kTMBPhotoPictureKey];
    [photo setObject:self.thumbFile forKey:kTMBPhotoThumbnailKey];
    NSLog(@" I'M IN THE POST IMAGE METHOD, IMAGE CARD VIEW CONTROLLER. BOARD OBJECT FOR KEY 'BOARD' IS %@", self.board);
    [photo setObject:self.board forKey:@"board"];
    
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.delegate imageCardViewController:self passBoardIDforQuery:self.boardID];
            
            if (userInfo) {
                NSString *commentText = [userInfo objectForKey:kTMBEditPhotoViewControllerUserInfoCommentKey];
                
                if (commentText && commentText.length != 0) {
                    PFObject *comment = [PFObject objectWithClassName:kTMBActivityClassKey];
                    [comment setObject:kTMBActivityTypeComment forKey:kTMBActivityTypeKey];
                    [comment setObject:photo forKey:kTMBActivityPhotoKey];
                    [comment setObject:[PFUser currentUser] forKey:kTMBActivityFromUserKey];
                    [comment setObject:[PFUser currentUser] forKey:kTMBActivityToUserKey];
                    [comment setObject:commentText forKey:kTMBActivityContentKey];
                    [comment setObject:self.board forKey:@"board"];
                    
                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                    [ACL setPublicReadAccess:YES];
                    comment.ACL = ACL;
                    
                    [comment saveEventually];
                }
            }
            
            
            [self.overlayView removeFromSuperview];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            
            NSLog(@"Photo failed to save: %@", error);
            [self.overlayView removeFromSuperview];
            [self uploadingErrorAlert];
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        
    }];
    
}



#pragma mark - image scaling


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    
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



#pragma mark - alert


- (void)uploadingErrorAlert {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Network error"
                                message:@"Unable to upload photo"
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];

    [alert addAction:ok];

    [self presentViewController:alert animated:YES completion:nil];
    
}



@end


