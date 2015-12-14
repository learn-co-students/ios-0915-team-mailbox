//
//  TMBFriendsTableViewCell.m
//  ProjectMailbox
//
//  Created by Flatiron on 12/7/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBFriendsTableViewCell.h"

@implementation TMBFriendsTableViewCell


- (void)viewDidLoad {
    self.friendProfileImage.contentMode = UIViewContentModeScaleAspectFill;
    self.friendProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2;
    self.friendProfileImage.clipsToBounds = YES;

    //self.userProfileImage.image = [UIImage imageNamed:@"default-profile-image.jpg"];
    self.userProfileImage.contentMode = UIViewContentModeScaleAspectFill;
    self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.size.width / 2;
    self.userProfileImage.clipsToBounds = YES;
}

@end
