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

#define COLOR_PICKER_MARGIN_TOP 190
#define COLOR_PICKER_MARGIN_RIGHT 0
#define COLOR_PICKER_WIDTH 36
#define COLOR_PICKER_HEIGHT 250

@interface TMBDoodleViewController () <UIImagePickerControllerDelegate>

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
    
    NSLog(@" I'M IN THE VIEW DID LOAD, DOODLE VIEW CONTROLLER");
    
    [self prefersStatusBarHidden];
    
    red = 0.0/255.0;
    green = 0.0/225.0;
    blue = 0.0/255.0;
    brush = 10.0;
    opacity = 1.0;
    
    [self setUpSimpleColorPicker];
    
    self.boardID = [TMBSharedBoardID sharedBoardID].boardID;
    self.board = [[TMBSharedBoardID sharedBoardID].boards objectForKey:self.boardID];
    
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)setUpSimpleColorPicker {
    
    CGRect simpleColorPickerRect = CGRectZero;
    simpleColorPickerRect.origin = CGPointMake(self.view.frame.size.width - COLOR_PICKER_WIDTH - COLOR_PICKER_MARGIN_RIGHT, COLOR_PICKER_MARGIN_TOP);
    simpleColorPickerRect.size = CGSizeMake(COLOR_PICKER_WIDTH, COLOR_PICKER_HEIGHT);
    
    self.simpleColorPickerView = [[SimpleColorPickerView alloc] initWithFrame:simpleColorPickerRect withDidPickColorBlock:^(UIColor *color) {
        NSLog(@"%@", color);
        self.chosenColor = color;
        
    }];
    
    NSLog(@" I'M IN THE setUpSimpleColorPicker, DOODLE VIEW CONTROLLER");
    
    [self.view addSubview:self.simpleColorPickerView];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    
    UITouch *touch = [touches anyObject];
    
    lastPoint = [touch locationInView:self.view];
    
    NSLog(@" I'M IN THE touchesBegan, DOODLE VIEW CONTROLLER");
    
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    
    [self.topImageView.image drawInRect:CGRectMake(0, 0, self.topImageView.image.size.width, self.topImageView.image.size.height)];
    
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [self.chosenColor CGColor]);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.topImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.topImageView setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
    
    NSLog(@" I'M IN THE touchesMoved, DOODLE VIEW CONTROLLER topImageView.image width:%f height:%f", self.topImageView.image.size.width, self.topImageView.image.size.height);
    
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
        
        NSLog(@" I'M IN THE touchesEnded !mouseSwiped, DOODLE VIEW CONTROLLER topImageView.image width:%f height:%f", self.view.frame.size.width, self.view.frame.size.height);
    }
    
    UIGraphicsBeginImageContext(self.bottomImageView.frame.size);
    
    [self.bottomImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    NSLog(@" I'M IN THE touchesEnded BOTTOM IMAGE WIDTH:%f HEIGHT:%f", self.view.frame.size.width, self.view.frame.size.height);
    
    [self.topImageView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    NSLog(@" I'M IN THE touchesEnded TOP IMAGE WIDTH:%f HEIGHT:%f", self.view.frame.size.width, self.view.frame.size.height);
    
    self.bottomImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    NSLog(@" I'M IN THE touchesEnded BOTTOM IMAGE VIEW IMAGE IS %@", self.bottomImageView.image);
    
    self.topImageView.image = nil;
    
    UIGraphicsEndImageContext();

}


- (IBAction)photoButtonPressed:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    NSLog(@" I'M IN THE photoButtonPressed, DOODLE VIEW CONTROLLER");
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.bottomImageView.image = chosenImage;
    
    NSLog(@" I'M IN THE imagePickerController, DOODLE VIEW CONTROLLER. self.bottomImageView.image / CHOSEN IMAGE WIDTH:%f HEIGHT:%f", chosenImage.size.width, chosenImage.size.height);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)activityLoadView {
    
    self.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.overlayView.center;
    [self.overlayView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.overlayView];
    
    NSLog(@" I'M IN THE activityLoadView, DOODLE VIEW CONTROLLER");
    
}


-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@" I'M IN THE imageWithImage scaledToSize, DOODLE VIEW CONTROLLER. newImage is %@", newImage);
    
    return newImage;
}


//- (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
//    
//    CGFloat oldWidth = image.size.width;
//    CGFloat oldHeight = image.size.height;
//    
////    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
////    CGFloat newHeight = oldHeight * scaleFactor;
////    CGFloat newWidth = oldWidth * scaleFactor;
//    CGFloat newHeight = oldHeight * 1;
//    CGFloat newWidth = oldWidth * 1;
//
//    CGSize newSize = CGSizeMake(newWidth, newHeight);
//    
//    NSLog(@" I'M IN THE imageWithImage scaledToMaxWidth, DOODLE VIEW CONTROLLER. newSize width: %f height:%f", newWidth, newHeight);
//    
//    return [self imageWithImage:image scaledToSize:newSize];
//    
//}


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
    [self.bottomImageView.image drawInRect:CGRectMake(0, 0, self.bottomImageView.image.size.width, self.bottomImageView.image.size.height)];
    
    UIImage *saveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    // Save the image to Parse
    
    [self activityLoadView];
    
    self.thumbnail = [self imageWithImage:self.bottomImageView.image scaledToMaxWidth:self.bottomImageView.image.size.width maxHeight:self.bottomImageView.image.size.height];
    
    [self shouldUploadImage:self.image];
    
    NSData *imageData = UIImagePNGRepresentation(self.bottomImageView.image);
    NSData *thumbData = UIImagePNGRepresentation(self.thumbnail);
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbFile = [PFFile fileWithData:thumbData];
    
    PFObject *photo = [PFObject objectWithClassName:kTMBPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:@"user"];
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
        
        UIAlertAction *error = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [errorAction addAction:error];
        
        [self presentViewController:errorAction animated:YES completion:nil];

    } else {
        
        UIAlertController *successAction = [UIAlertController alertControllerWithTitle:@"Success" message:@"Image was successfully saved in the photo album" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *success = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [successAction addAction:success];
        
        [self presentViewController:successAction animated:YES completion:nil];
    
    }
    
}



@end


