//
//  TMBPhoneContactsViewController.h
//  ProjectMailbox
//
//  Created by Flatiron on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ContactsUI/ContactsUI.h>

@interface TMBPhoneContactsViewController : UIViewController <CNContactPickerDelegate>

- (IBAction)showPicker:(UIButton *)sender;

@end
