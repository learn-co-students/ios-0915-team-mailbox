//
//  TMBSelectedFriendViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 12/3/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBSelectedFriendViewController.h"

@interface TMBSelectedFriendViewController ()
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contactImageView;


@end

@implementation TMBSelectedFriendViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // passing names
    
    self.contactNameLabel.text = [NSString stringWithFormat:@"%@, %@",self.selectedContactPassed.firstName, self.selectedContactPassed.lastName];
    
    
    // passing phone number
    
    self.phoneNumberLabel.text = self.selectedContactPassed.phoneNumbers[0].value.stringValue;
    
    
    //passing email
    
    self.emailAddressLabel.text = self.selectedContactPassed.emailAddresses[0].value;
    
    
    // passing photo

    UIImage *image = [UIImage imageWithData:self.selectedContactPassed.imageData];
    self.contactImageView.image = image;


}


//



// get phone name, number & email from contacts picker

// when "send text" is tapped --> send hashed phone to Parse?

// when "send email" is tapped --> ???












/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
