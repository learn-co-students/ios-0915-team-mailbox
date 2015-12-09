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

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSMutableArray *boardFriends;  // contains friends associated with a particular board
@property (nonatomic, strong) NSMutableArray *allFriends;  // contains ALL friends
@property (nonatomic, strong) NSMutableArray *combinedFriends;  // boardFriends + allFriends arrays

@end
