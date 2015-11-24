//
//  TMBSignInViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 11/17/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBSignInViewController.h"

@interface TMBSignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation TMBSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSAttributedString *usernameString = [[NSAttributedString alloc] init];
//    NSAttributedString *passwordString = [[NSAttributedString alloc] init];
//    [usernameString initWithString:@"Email Address" attributes:NSForegroundColorAttributeName];
//    [passwordString initWithString:@"Password" attributes:NSForegroundColorAttributeName];
    
    // Do any additional setup after loading the view.
}

- (IBAction)signInButtonTapped:(id)sender {
    
    [self.view endEditing:YES];
    
    NSString *userName = self.usernameTextField.text;
    
    NSString *password = self.passwordTextField.text;
    
    if (self.usernameTextField.text.length == 0 || self.passwordTextField.text.length == 0) {
        return;
    }
    
    [PFUser logInWithUsernameInBackground:userName password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (userName != nil) {
            NSUserDefaults *usernameDefault = [NSUserDefaults standardUserDefaults];
            
            [usernameDefault setValue:userName forKey:@"user_name"];
            
            [usernameDefault synchronize];
            
            [self showSuccessAlert];
            
        } else {
            
            [self showErrorAlert];
        }
        
    }];

    
//    NSOperationQueue *backgroundThread = [NSOperationQueue new];
//    
//    [backgroundThread addOperationWithBlock:^{
    
        
        
//        [PFUser logInWithUsername:userName password:password];
//        
//        if (userName != nil) {
//            NSUserDefaults *usernameDefault = [NSUserDefaults standardUserDefaults];
//            
//            [usernameDefault setValue:userName forKey:@"user_name"];
//            
//            [usernameDefault synchronize];
//            
//        } else {
//            
//            [self showErrorAlert];
//        }
    
    
//    
//    [PFUser logInWithUsername:userName password:password];
//    
//    if (userName != nil) {
//        NSUserDefaults *usernameDefault = [NSUserDefaults standardUserDefaults];
//        
//        [usernameDefault setValue:userName forKey:@"user_name"];
//        
//        [usernameDefault synchronize];
//    
//    } else {
//        
//        [self showErrorAlert];
//    }
    
}

- (void)showErrorAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Invalid login. Please log in again" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:okAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)showSuccessAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Alert" message:@"You've Logged in!!!!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:okAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

//- (void)textFieldShouldReturn:(UITextField *)textField {
//    
//    if (textField == self.usernameTextField) {
//        [self.usernameTextField becomeFirstResponder];
//    } else if (textField == self.passwordTextField) {
//        [self.usernameTextField resignFirstResponder];
//    }
//
//}

@end
