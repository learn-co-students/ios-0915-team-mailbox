//
//  TMBPhoneContactsViewController.h
//  ProjectMailbox
//
//  Created by Flatiron on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface TMBPhoneContactsViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;

- (IBAction)showPicker:(UIButton *)sender;


@end
