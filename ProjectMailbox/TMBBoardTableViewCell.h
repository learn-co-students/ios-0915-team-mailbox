//
//  TMBBoardTableViewCell.h
//  ProjectMailbox
//
//  Created by Flatiron on 12/15/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMBBoardTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *boardNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *unfollowButton;

@end
