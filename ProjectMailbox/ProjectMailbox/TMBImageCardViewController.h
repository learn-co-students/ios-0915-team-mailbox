//
//  TMBImageCardViewController.h
//  ProjectMailbox
//
//  Created by Flatiron on 11/18/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@interface TMBImageCardViewController : ViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (id)initWithImage:(UIImage *)aImage;

@end
