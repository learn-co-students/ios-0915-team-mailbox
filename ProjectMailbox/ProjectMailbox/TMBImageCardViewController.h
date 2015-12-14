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

@property (nonatomic, weak) id<TMBImageCardViewControllerDelegate> delegate;

/// The class of the PFObject this table will use as a datasource
@property (nonatomic, retain) NSString *className;
/// The array of PFObjects that is the UITableView data source
@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic, strong) PFObject *photo;

- (id)initWithImage:(UIImage *)aImage;
-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size;
-(UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;


@end

