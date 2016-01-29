//
//  TMBImageCardViewController.h
//  ProjectMailbox
//
//  Created by Flatiron on 11/18/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@class TMBImageCardViewController;

@protocol TMBImageCardViewControllerDelegate <NSObject>

@required

-(void)imageCardViewController:(TMBImageCardViewController *)viewController passBoardIDforQuery:(NSString *)boardID;

@end

@interface TMBImageCardViewController : ViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) id<TMBImageCardViewControllerDelegate> delegate;


@end

