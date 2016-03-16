//
//  TMBFirstPageViewController.h
//  ProjectMailbox
//
//  Created by Joseph Kiley on 11/17/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "TMBSignUpViewController.h"
#import "TMBMainPageViewController.h"

@interface TMBFirstPageViewController : ViewController 

//loading view
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (void)activityLoadView;
- (void)showErrorAlert;
- (void)showNoInternetErrorAlert;

@end
