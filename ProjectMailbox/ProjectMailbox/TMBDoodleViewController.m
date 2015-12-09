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

- (IBAction)saveButtonPressed:(id)sender {
    
    UIGraphicsBeginImageContextWithOptions(self.bottomImageView.bounds.size, NO, 0.0);
    [self.bottomImageView.image drawInRect:CGRectMake(0, 0, self.bottomImageView.frame.size.width, self.bottomImageView.frame.size.height)];
    
    UIImage *saveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    NSData* data = UIImageJPEGRepresentation(self.bottomImageView.image, 0.5f);
    PFFile *imageFile = [PFFile fileWithData:data];
    
    // Save the image to Parse
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The image has now been uploaded to Parse. Associate it with a new object
            PFObject* newPhotoObject = [PFObject objectWithClassName:@"Doodle"];
            [newPhotoObject setObject:imageFile forKey:@"image"];
            [newPhotoObject setObject:[PFUser currentUser] forKey:@"user"];
            
            [newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Saved");
                }
                else{
                    // Error
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
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
