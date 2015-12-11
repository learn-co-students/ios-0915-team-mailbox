//
//  ShareTableViewController.h
//  ProjectMailbox
//
//  Created by Jimena Almendares on 12/10/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class ShareTableViewController;

@protocol ShareTableViewControllerDelegate <NSObject>

@required
-(void)shareTableViewController:(ShareTableViewController *)tableViewController didSelectBoard:(PFObject *)board;

@end


@interface ShareTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *boardsArray;
@property (nonatomic, strong) PFObject *currentBoard;

@property (nonatomic, weak) id<ShareTableViewControllerDelegate> delegate;

@end
