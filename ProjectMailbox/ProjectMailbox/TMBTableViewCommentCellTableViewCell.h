//
//  TMBTableViewCommentCellTableViewCell.h
//  ProjectMailbox
//
//  Created by Flatiron on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMBTableViewCommentCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *fromUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCommentLabel;

@end
