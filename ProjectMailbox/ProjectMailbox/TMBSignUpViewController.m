//
//  TMBSignUpViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 11/17/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBSignUpViewController.h"
#import "TMBConstants.h"
#import "TMBSharedBoardID.h"

@interface TMBSignUpViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) PFObject *myNewBoard;
@property (nonatomic, strong) NSString *boardObjectId;

@end


@implementation TMBSignUpViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@" I'M IN THE VIEW DID LOAD, SIGN UP PAGE VIEW CONTROLLER");
    
    self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.image = [UIImage imageNamed:@"profilePlaceholder"];
    
    self.repeatPasswordField.returnKeyType = UIReturnKeyDone;
    
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.firstNameField) {
        [self.lastNameField becomeFirstResponder];
    } else if (textField == self.lastNameField) {
        [self.emailField becomeFirstResponder];
    } else if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self.repeatPasswordField becomeFirstResponder];
    } else if (textField == self.repeatPasswordField) {
        [self.repeatPasswordField resignFirstResponder];
        
    }
}


- (IBAction)choosePhotoButtonTapped:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];

}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profileImage.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (IBAction)signUpButtonTapped:(id)sender {
    
    NSLog(@" I'M IN THE signUpButtonTapped, FIRST PAGE VIEW CONTROLLER");

    [self.view endEditing:YES];
    
    if (self.usernameTextField.text.length == 0 || self.firstNameField.text.length == 0 || self.lastNameField.text.length == 0 || self.emailField.text.length == 0 || self.passwordField.text.length == 0 || self.repeatPasswordField.text.length == 0) {
        [self showBlankFieldAlert];
    }
    
    if (![self isConfirmedPassword]) {
        [self showPasswordErrorAlert];
    }
    
    if (![self isValidEmailAddress]) {
        [self showInvalidEmailAlert];
    }
    
    
    

    
    if ([self allFieldsAreValid]) {
        
        PFUser *newUser = [[PFUser alloc]init];
        newUser.username = self.usernameTextField.text;
        newUser.password = self.passwordField.text;
        newUser.email = self.emailField.text;
        
        [newUser setObject:self.firstNameField.text forKey:@"First_Name"];
        [newUser setObject:self.lastNameField.text forKey:@"Last_Name"];
        
        if (self.profileImage.image == nil) {
            
            NSData *profilePictureData = UIImageJPEGRepresentation([UIImage imageNamed:@"profilePlaceholder"], 0.6f);
            PFFile *profileFileObject = [PFFile fileWithData:profilePictureData];
            [newUser setObject:profileFileObject forKey:@"profileImage"];
        };
        
        if (self.profileImage.image != nil) {
            
            NSData *profilePictureData = UIImageJPEGRepresentation(self.profileImage.image, 0.6f);
            PFFile *profileFileObject = [PFFile fileWithData:profilePictureData];
            [newUser setObject:profileFileObject forKey:@"profileImage"];
        }

        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // code 125 invalid email address
            // code 200 missing username
            // code 202 username already exists
            
            if (error && error.code == 202) {
                [self showUsernameAlreadyExistsAlert];
            };
            
            if (succeeded) {
                NSLog(@" I'M IN SIGN UP BTN TAPPED, SIGN UP PAGE VIEW CONTROLLER. NEW USER IS CREATED. USER OBJECT ID IS %@", newUser.objectId);
                [self createNewBoardOnParseWithUser:newUser completion:^(NSString *objectId, NSError *error) {
                    
                    if (!error) {
                        // passing board ID and board object through singleton
                        [TMBSharedBoardID sharedBoardID].boardID = self.myNewBoard.objectId;
                        
                        // passing board object through singleton
                        NSString *boardID = [self.myNewBoard valueForKey:@"objectId"];
                        [[TMBSharedBoardID sharedBoardID].boards setObject:self.myNewBoard forKey:boardID];
                        
                        NSLog(@" I'M IN SIGN UP BTN TAPPED, SIGN UP PAGE VIEW CONTROLLER. NEW BOARD IS CREATED. NEW/SHARED BOARD ID IS %@", [TMBSharedBoardID sharedBoardID].boardID);
                        NSLog(@" I'M IN SIGN UP BTN TAPPED, SIGN UP PAGE VIEW CONTROLLER. NEW BOARD IS CREATED. NEW/SHARED BOARD DICTIONARY IS %@", [TMBSharedBoardID sharedBoardID].boards);
                    }
                }];
                
                [self showSuccessAlert];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidSignUpNotification" object:nil];
                
            } else {
                [self showErrorAlert];
            }
            
        }];
        
    };
    
    
}


-(BOOL)isValidFirstName {
    
    NSString *empty = @"";
    if (self.firstNameField.text != empty) {
        return YES;
    }
    return NO;
}


-(BOOL)isValidLastName {
    
    NSString *empty = @"";
    if (self.lastNameField.text != empty) {
        return YES;
    }
    return NO;
}


-(BOOL)isValidUsername {
    
    NSString *empty = @"";
    if (self.usernameTextField.text != empty) {
        return YES;
    }
    return NO;
}


-(BOOL)isValidPassword {
    
    NSString *empty = @"";
    if (self.passwordField.text != empty) {
        return YES;
    }
    return NO;
}


-(BOOL)isConfirmedPassword {
    
    NSString *empty = @"";
    if ([self.repeatPasswordField.text isEqualToString:self.passwordField.text] && self.repeatPasswordField.text != empty) {
        return YES;
    }
    
    return NO;
}


-(BOOL)isValidEmailAddress {
    
    NSString *empty = @"";
    if ([self.emailField.text containsString:@"."] && [self.emailField.text containsString:@"@"] && self.emailField.text != empty) {
        return YES;
    }
    return NO;
}


-(BOOL)allFieldsAreValid {
    
    if ([self isValidFirstName] && [self isValidLastName] && [self isValidUsername] && [self isValidPassword] && [self isConfirmedPassword] && [self isValidEmailAddress]) {
        return YES;
    }
    
    return NO;
}


- (void)queryUsernames:(NSString *)username completion:(void(^)(NSArray *users, NSError *error))completionBlock {

    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        completionBlock(objects, error);
        
    }];
    
}


- (void)createNewBoardOnParseWithUser:(PFUser *)user completion:(void(^)(NSString *objectId, NSError *error))completionBlock {
    
    self.myNewBoard = [PFObject objectWithClassName:@"Board"];
    [self.myNewBoard setObject:user forKey:kTMBBoardFromUserKey];
    self.myNewBoard[@"boardName"] = @"My Board";
    [self.myNewBoard saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            completionBlock(self.myNewBoard.objectId, error);
        }
    }];
    
}


- (IBAction)backButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)showUsernameAlreadyExistsAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"This username already exists." message:@"Please choose a different username." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:okAction];
    
    [self presentViewController:controller animated:YES completion:nil];
    
}


- (void)showBlankFieldAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Oh-oh!" message:@"Failed to sign up. All fields are required." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:okAction];
    
    [self presentViewController:controller animated:YES completion:nil];
    
}


- (void)showInvalidEmailAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Oh-oh!" message:@"Failed to sign up. The email is invalid." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:okAction];
    
    [self presentViewController:controller animated:YES completion:nil];
    
}


- (void)showErrorAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Oh-oh!" message:@"Failed to sign up. Please try again" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:okAction];
    
    [self presentViewController:controller animated:YES completion:nil];
    
}


- (void)showPasswordErrorAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Oh-oh!" message:@"Failed to sign up. Password fields do not match." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:okAction];
    
    [self presentViewController:controller animated:YES completion:nil];
    
}


- (void)showSuccessAlert {
    
    UIAlertController *successAction = [UIAlertController alertControllerWithTitle:@"Success!"
                                                                           message:@"You've successfully signed up!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *success = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                    }];
    
    [successAction addAction:success];
    
    [self presentViewController:successAction animated:YES completion:nil];
    
}



@end

