//
//  TMBPhoneContactsViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBPhoneContactsViewController.h"
#import "Contact.h"
#import <UIKit/UIKit.h>


@interface TMBPhoneContactsViewController ()
@property (strong) CNContactStore *store;
@property (strong)  CNContactViewController *controller;
@property(nonatomic, copy) NSString *contactIdentifier;

@end

@implementation TMBPhoneContactsViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.store = [[CNContactStore alloc] init];
    
    NSLog(@"IN THE VIEW DID LOAD METHOD ..................");
    
    
    
    
    [self.store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            
            NSLog(@"IN THE VIEW DID LOAD METHOD REQUEST GRANTED  ..................");
            
            //keys with fetching properties
            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
            NSString *containerId = self.store.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContacts = [self.store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            if (error) {
                NSLog(@"error fetching contacts %@", error);
            } else {
                for (CNContact *contact in cnContacts) {
                    // copy data to my custom Contacts class.
                    Contact *newContact = [[Contact alloc] init];
                    newContact.phones = [NSMutableArray new];
                    newContact.firstName = contact.givenName;
                    newContact.lastName = contact.familyName;
                    UIImage *image = [UIImage imageWithData:contact.imageData];
                    newContact.image = image;
                    for (CNLabeledValue *label in contact.phoneNumbers) {
                        CNPhoneNumber *labelValue = label.value;
                        
                        NSString *phone = [label.value stringValue];
                        
                        if ([phone length] > 0) {
                            self.phoneNumber.text = phone;
                            NSLog(@"PHONE NUMBER IS : %@", phone);
                            
                            [newContact.phones addObject:phone];
                            NSLog(@"PHONES ARRAY IS : %@", newContact.phones);

                        }
                    }
                }
            }
        }
    }];

    
    
    
}





// woohoo works!
- (IBAction)showPicker:(UIButton *)sender
{
    CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}



// woohoo works!
- (void)peoplePickerNavigationControllerDidCancel:(CNContactPickerViewController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}





- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    
    NSLog(@"IN THE CONTACT PICKER DID SELECT CONTACT METHOD...........");
    
    
    
    // access the first name
    
    self.firstName.text = contact.givenName;

    
    // add a check for phone numbers
        // if 0, alert like "no phone numbers!" or maybe check for email?
        // if theres more than one number, popup to ask them to select one?
    self.phoneNumber.text = contact.phoneNumbers[0].value.stringValue;
    

    
    
    // create hash of the phone number stored on the server
    // text or email use --> share sheet,
    
    
   
    
}






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
