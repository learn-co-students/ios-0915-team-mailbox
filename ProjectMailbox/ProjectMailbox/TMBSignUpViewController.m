//
//  TMBSignUpViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 11/17/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBSignUpViewController.h"

@interface TMBSignUpViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation TMBSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.repeatPasswordField.returnKeyType = UIReturnKeyDone;
    
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

- (IBAction)signUpButtonTapped:(id)sender {
    
    [self.view endEditing:YES];
    
    NSString *firstName = self.firstNameField.text;
    NSString *lastName = self.lastNameField.text;
    NSString *userName = self.emailField.text;
    NSString *password = self.passwordField.text;
    NSString *passwordRepeat = self.repeatPasswordField.text;
    
    if (self.firstNameField.text.length == 0 || self.lastNameField.text.length == 0 || self.emailField.text.length == 0 || self.passwordField.text.length == 0 || self.repeatPasswordField.text.length == 0) {
        
        [self showErrorAlert];
    }
    
    if (self.passwordField.text != self.repeatPasswordField.text) {
        
        [self showPasswordErrorAlert];
    }
    
    PFUser *newUser = [[PFUser alloc]init];
    
    newUser.username = userName;
    newUser.password = password;
    newUser.email = userName;
    [newUser setObject:firstName forKey:@"First_Name"];
    [newUser setObject:lastName forKey:@"Last_Name"];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self showSuccessAlert];
        } 
    }];
    
}

- (IBAction)backButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showErrorAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Alert" message:@"All fields are required" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:okAction];
}

- (void)showPasswordErrorAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Password fields do not match" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:okAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)showSuccessAlert {
    
    UIAlertController *successAction = [UIAlertController alertControllerWithTitle:@"Success!" message:@"You've successfully signed up!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *success = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [successAction addAction:success];
    
    [self presentViewController:successAction animated:YES completion:nil];
}


@end
