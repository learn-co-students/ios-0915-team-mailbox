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
#import "TMBSelectedFriendViewController.h"


@interface TMBPhoneContactsViewController ()
@property (strong) CNContactStore *store;
@property (strong) CNContactPickerViewController *contactPicker;
@property (strong) CNContact *selectedContact;
@property(nonatomic, copy) NSString *contactIdentifier;

@end

@implementation TMBPhoneContactsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.store = [[CNContactStore alloc] init];   // do i need this store?
    
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
                        
                        NSString *phone = [label.value stringValue];
                        
                        if ([phone length] > 0) {
                            NSLog(@"PHONE NUMBER IS : %@", phone);
                            
                            [newContact.phones addObject:phone];  // just testing, not actually using it
                            NSLog(@"PHONES ARRAY IS : %@", newContact.phones);

                        }
                    }
                }
            }
        }
    }];

    
}





- (IBAction)showPicker:(UIButton *)sender
{
    CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)peoplePickerNavigationControllerDidCancel:(CNContactPickerViewController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    
    self.selectedContact = contact;
    
    // either perform segue or (create new VC and push on nav controller)
    [self performSegueWithIdentifier:@"selectedFriendVC" sender:nil];
    
    NSLog(@"IN THE CONTACT PICKER DID SELECT CONTACT METHOD...........");
    
}

- (IBAction)cancelButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSString *identifierOfSegue = segue.identifier;

    if ([identifierOfSegue isEqualToString:@"selectedFriendVC"]) {

        TMBSelectedFriendViewController *friendDVC = segue.destinationViewController;
        friendDVC.selectedContactPassed = (Contact *)self.selectedContact;
        
    }
    
    
    NSLog(@"IN THE PREPARE FOR SEGUE METHOD ..................");
   
}

@end
