//
//  TMBCommentViewController.h
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/11/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TMBCommentViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbFile;

/// The class of the PFObject this table will use as a datasource
@property (nonatomic, retain) NSString *className;

/// The array of PFObjects that is the UITableView data source
@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic, strong) PFObject *photo;
@property (strong, nonatomic) PFFile *selectedFile;
@property (strong, nonatomic) PFObject *parseObjSelected;


- (void)loadDataFromParse;
- (void)keyboardWillShowOrHide:(NSNotification *)notification;
- (void)adjustHeightOfTableview;

@end
