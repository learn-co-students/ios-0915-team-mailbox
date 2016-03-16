//
//  TMBSignUpViewController.h
//  ProjectMailbox
//
//  Created by Joseph Kiley on 11/17/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@interface TMBSignUpViewController : ViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) PFObject *myNewBoard;
@property (nonatomic, strong) NSString *boardObjectId;

- (BOOL)prefersStatusBarHidden;
- (IBAction)choosePhotoButtonTapped:(id)sender;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;

- (void)showUsernameAlreadyExistsAlert;
- (void)showBlankFieldAlert;
- (void)showInvalidEmailAlert;
- (void)showPasswordErrorAlert;
- (void)showSuccessAlert;

@end
