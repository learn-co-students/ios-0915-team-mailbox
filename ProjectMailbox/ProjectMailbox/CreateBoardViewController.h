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
@property (nonatomic, strong) NSString *boardObjectId;
@property (weak, nonatomic) IBOutlet UILabel *boardNameLabel;
@property (nonatomic, strong) NSString *boardNameToDisplay;

@end
