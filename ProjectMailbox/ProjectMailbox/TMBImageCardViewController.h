//
//  TMBImageCardViewController.h
//  ProjectMailbox
//
//  Created by Flatiron on 11/18/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@class TMBImageCardViewController;

@protocol TMBImageCardViewControllerDelegate <NSObject>

@required

-(void)imageCardViewController:(TMBImageCardViewController *)viewController passBoardIDforQuery:(NSString *)boardID;

@end


@interface TMBImageCardViewController : ViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumb;
@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, strong) PFFile *thumbFile;
@property (nonatomic, weak) id<TMBImageCardViewControllerDelegate> delegate;

//board ID
@property (nonatomic, strong) NSString *boardID;
@property (nonatomic, strong) PFObject *board;

//loading view
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (BOOL)prefersStatusBarHidden;
- (void)activityLoadView;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size;
- (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;
- (void)uploadingErrorAlert;

@end

