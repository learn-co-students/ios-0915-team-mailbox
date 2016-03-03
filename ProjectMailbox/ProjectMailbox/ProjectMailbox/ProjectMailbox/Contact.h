//
//  Contact.h
//  ProjectMailbox
//
//  Created by Flatiron on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <Contacts/Contacts.h>
#import <UIKit/UIKit.h>


@interface Contact : CNContact

@property (weak, nonatomic) NSString *firstName;
@property (weak, nonatomic) NSString *lastName;
@property (weak, nonatomic) NSString *email;
@property (weak, nonatomic) UIImage *image;
@property (nonatomic, strong) NSMutableArray *phones;

@end
