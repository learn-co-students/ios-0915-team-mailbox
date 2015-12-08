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

@property (weak, nonatomic) IBOutlet UIButton *sendTextButton;
@property (weak, nonatomic) IBOutlet UIButton *sendEmailButton;


@end

@implementation TMBSelectedFriendViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // passing names
    
    self.contactNameLabel.text = [NSString stringWithFormat:@"%@, %@",self.selectedContactPassed.firstName, self.selectedContactPassed.lastName];
    
    
    
    // adding a check for phone numbers
    
    if (self.selectedContactPassed.phoneNumbers.count == 0) {
        self.phoneNumberLabel.text = nil;
        self.sendTextButton.hidden = YES;
    } else {
        
        // passing phone number
        
        self.phoneNumberLabel.text = self.selectedContactPassed.phoneNumbers[0].value.stringValue;
        // if theres more than one number, popup to ask them to select one?

    }
    
    
    // checking for email
    
    if (self.selectedContactPassed.emailAddresses.count == 0) {
        self.emailAddressLabel.text = nil;
        self.sendEmailButton.hidden = YES;
    }   else {
        
        // passing email
        
        self.emailAddressLabel.text = self.selectedContactPassed.emailAddresses[0].value;

    }
   
    
    // passing photo

    UIImage *image = [UIImage imageWithData:self.selectedContactPassed.imageData];
    self.contactImageView.image = image;
    
    // if there is no photo, make a default icon

}





- (IBAction)sendTextButtonTapped:(UIButton *)sender {
    
    NSURL *phone = [NSURL URLWithString:@"sms:9175930409"]; // test with a real phone, no simulator ability
    [[UIApplication sharedApplication] openURL:phone];
    
    // messenger app launches
    // dismiss the view to go back to selecting a friend via FB/email/Contacts
    // switch to pending friend talbe view
    // create a 'pending' user on Parse with hashed First, Last names
    // when your friend registers with the app
    
    // include object id in your text message
    // when you're registering, you can ask for friend's 'referral code' --> board object id
    
    
    
    // or use a share sheet, it's a LOT less code
}






- (IBAction)sendEmailButtonTapped:(UIButton *)sender {
    
    
}





// get phone name, number & email from contacts picker

// when "send text" is tapped --> send hashed phone to Parse?

// when "send email" is tapped --> ???








// create hash of the phone number stored on the server

// text or email --> use share sheet. i don't wanna use share sheet.







/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
