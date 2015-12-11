//
//  TMBFriendsTableViewCell.h
//  ProjectMailbox
//
//  Created by Flatiron on 12/7/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMBFriendsTableViewCell  : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *friendProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *friendFollowUnfollowButton;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *fromUserNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkButtonTapped;

@end
