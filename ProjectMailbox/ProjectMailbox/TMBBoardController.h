//
//  RWTCollectionViewController.h
//  RWPinterest
//
//  Created by Joel Bell on 11/23/15.
//  Copyright © 2015 Joel Bell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMBBoardLayout.h"
#import "TMBCommentViewController.h"
#import "TMBBoardCell.h"
#import "Parse/Parse.h"
#import "TMBImageCardViewController.h"
#import "TMBSharedBoardID.h"
#import "TMBDoodleViewController.h"
#import <MMDrawerController/MMDrawerVisualState.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import <MMDrawerController/MMDrawerController.h>
#import <MMDrawerController/MMDrawerBarButtonItem.h>

@interface TMBBoardController : UICollectionViewController

@property (nonatomic, strong) NSString *boardID;
@property (nonatomic, strong) NSMutableArray *boardContent;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSString *queriedBoardID;
@property (nonatomic, strong) NSMutableArray *collection;
@property (nonatomic) NSUInteger queryCount;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIImage *imageSelectedForOtherView;
@property (nonatomic, strong) NSMutableArray *pfObjects;
@property (nonatomic, strong) NSString *boardName;
@property (nonatomic, strong) UINavigationBar *navigationBar;

- (void)buildEmptyCollection;
- (UIColor *)colorForDummyCellAtRow:(NSUInteger)row;
- (void)buildThemeColorsArray;
- (void)setupLeftMenuButton;
- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress;
- (void)boardWasDeletedInOtherView:(NSNotification *)notification;
- (void)boardWasUpdatedInOtherViews:(NSNotification *)notification;


@end
