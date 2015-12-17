//
//  TMBDoodleViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 11/19/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBDoodleViewController.h"
#import "PAPCache.h"
#import "TMBConstants.h"
#import "TMBSharedBoardID.h"

#define FEEDBACK_VIEW_WIDTH 200
#define FEEDBACK_VIEW_HEIGHT 200

#define COLOR_PICKER_MARGIN_TOP 20
#define COLOR_PICKER_MARGIN_RIGHT 10
#define COLOR_PICKER_WIDTH 20
#define COLOR_PICKER_HEIGHT 150

@interface TMBDoodleViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (strong, nonatomic) UIView *feedbackView;
@property (strong, nonatomic) SimpleColorPickerView *simpleColorPickerView;
@property (strong, nonatomic) UIColor *chosenColor;
@property (nonatomic, assign) UIBackgroundTaskIdentifier doodlePostBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (strong, nonatomic) UIImage *thumbnail;
@property (strong, nonatomic) PFFile *imageData;
@property (strong, nonatomic) PFFile *thumbData;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbFile;
@property (nonatomic, strong) UIImage *image;

//board ID
@property (nonatomic, strong) NSString *boardID;
@property (nonatomic, strong) PFObject *board;

//loading view
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;


@end

@implementation TMBDoodleViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    red = 0.0/255.0;
    green = 0.0/225.0;
    blue = 0.0/255.0;
    brush = 10.0;
    opacity = 1.0;
    
    [self setUpSimpleColorPicker];
    
    self.boardID = [TMBSharedBoardID sharedBoardID].boardID;
    self.board = [[TMBSharedBoardID sharedBoardID].boards objectForKey:self.boardID];
    
}

- (void)setUpSimpleColorPicker {
    
    CGRect simpleColorPickerRect = CGRectZero;
    simpleColorPickerRect.origin = CGPointMake(self.view.frame.size.width - COLOR_PICKER_WIDTH - COLOR_PICKER_MARGIN_RIGHT, COLOR_PICKER_MARGIN_TOP);
    simpleColorPickerRect.size = CGSizeMake(COLOR_PICKER_WIDTH, COLOR_PICKER_HEIGHT);
    
    self.simpleColorPickerView = [[SimpleColorPickerView alloc] initWithFrame:simpleColorPickerRect withDidPickColorBlock:^(UIColor *color) {
//        [self.topImageView setBackgroundColor:color];
        NSLog(@"%@", color);
        self.chosenColor = color;
        
    }];
    
    [self.view addSubview:self.simpleColorPickerView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    
    UITouch *touch = [touches anyObject];
    
    lastPoint = [touch locationInView:self.view];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.topImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [self.chosenColor CGColor]);
//    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.topImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.topImageView setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.topImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.topImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.bottomImageView.frame.size);
    [self.bottomImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.topImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.bottomImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.topImageView.image = nil;
    UIGraphicsEndImageContext();

}

- (IBAction)photoButtonPressed:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.bottomImageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
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

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    // passing a UIImage and setting it to our library/camera image
    anImage = self.bottomImageView.image;
    
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


- (IBAction)saveButtonPressed:(id)sender {
    
    UIGraphicsBeginImageContextWithOptions(self.bottomImageView.bounds.size, NO, 0.0);
    [self.bottomImageView.image drawInRect:CGRectMake(0, 0, 204.0, 176.0)];
    
//    [self.bottomImageView.image drawInRect:CGRectMake(0, 0, self.bottomImageView.frame.size.width, self.bottomImageView.frame.size.height)];
    
    UIImage *saveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    NSData* data = UIImageJPEGRepresentation(self.bottomImageView.image, 0.5f);
    PFFile *imageFile = [PFFile fileWithData:data];
    
    // Save the image to Parse
    
    [self activityLoadView];
    
    self.thumbnail = [self imageWithImage:self.bottomImageView.image scaledToMaxWidth:204.0 maxHeight:176.0];
    
    [self shouldUploadImage:self.image];
    
//    NSDictionary *userInfo = [NSDictionary dictionary];
//    NSString *trimmedComment = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    if (trimmedComment.length != 0) {
//        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                    trimmedComment,
//                    kTMBEditPhotoViewControllerUserInfoCommentKey,
//                    nil];
//    }
    
    NSData *imageData = UIImagePNGRepresentation(self.bottomImageView.image);
    NSData *thumbData = UIImagePNGRepresentation(self.thumbnail);
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbFile = [PFFile fileWithData:thumbData];
    
    PFObject *photo = [PFObject objectWithClassName:kTMBPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kTMBPhotoUserKey];
    [photo setObject:self.photoFile forKey:kTMBPhotoPictureKey];
    [photo setObject:self.thumbFile forKey:kTMBPhotoThumbnailKey];
    [photo setObject:self.board forKey:@"board"];
    NSLog(@"%@", photo);
    
    // Photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    // Save the Photo PFObject
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            [self.delegate doodleViewController:self passBoardIDforQuery:self.boardID];
            [self dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"Doodle uploaded");
            
            [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            
            // userInfo might contain any caption which might have been posted by the uploader
//            if (userInfo) {
//                NSString *commentText = [userInfo objectForKey:kTMBEditPhotoViewControllerUserInfoCommentKey];
//                
//                if (commentText && commentText.length != 0) {
//                    // create and save photo caption
//                    PFObject *comment = [PFObject objectWithClassName:kTMBActivityClassKey];
//                    [comment setObject:kTMBActivityTypeComment forKey:kTMBActivityTypeKey];
//                    [comment setObject:photo forKey:kTMBActivityPhotoKey];
//                    [comment setObject:[PFUser currentUser] forKey:kTMBActivityFromUserKey];
//                    [comment setObject:[PFUser currentUser] forKey:kTMBActivityToUserKey];
//                    [comment setObject:commentText forKey:kTMBActivityContentKey];
//                    
//                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
//                    [ACL setPublicReadAccess:YES];
//                    comment.ACL = ACL;
//                    
//                    [comment saveEventually];
//                    [[PAPCache sharedCache] incrementCommentCountForPhoto:photo];
//                }
//            }
            
        } else {
            
            NSLog(@"Photo failed to save: %@", error);
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }];
            
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)resetButtonPressed:(id)sender {
    
    self.bottomImageView.image = nil;
    
}

- (IBAction)backButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error != NULL) {
        
        UIAlertController *errorAction = [UIAlertController alertControllerWithTitle:@"Error" message:@"Image could not be saved. Please try again" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *error = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [errorAction addAction:error];
        
        [self presentViewController:errorAction animated:YES completion:nil];

    } else {
        
        UIAlertController *successAction = [UIAlertController alertControllerWithTitle:@"Success" message:@"Image was successfully saved in the photo album" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *success = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [successAction addAction:success];
        
        [self presentViewController:successAction animated:YES completion:nil];
    
    }
}

@end
