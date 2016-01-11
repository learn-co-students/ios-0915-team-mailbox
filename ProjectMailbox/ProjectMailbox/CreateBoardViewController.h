//
//  CreateBoardViewController.h
//  ProjectMailbox
//
//  Created by Flatiron on 12/6/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface CreateBoardViewController : ViewController
@property (strong, nonatomic) PFObject *selectedBoard;
@property (nonatomic, strong) NSString *boardObjectIdFromSelectedBoard;
@property (nonatomic, strong) NSString *boardNameToDisplay;
@property (nonatomic, strong) NSMutableArray *boardFriendsToDisplay;
@property (nonatomic) BOOL shouldHideSaveBoardButton;
@property (nonatomic) BOOL shouldHideCancelButton;

@end
