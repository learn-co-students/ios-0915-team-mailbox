//
//  TMBSignInViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 11/17/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBSignInViewController.h"
#import "TMBSharedBoardID.h"

@interface TMBSignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;


@end

@implementation TMBSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    
    CGRect finalFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        finalFrame = CGRectZero;
    }
    
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:curve];
        self.bottomViewBottomConstraint.constant = finalFrame.size.height + 0;
        [self.view layoutIfNeeded];
    }];
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
            
//          PFUser currentUser
            NSUserDefaults *usernameDefault = [NSUserDefaults standardUserDefaults];
            
            [usernameDefault setValue:userName forKey:@"user_name"];
            
            [usernameDefault synchronize];
            
            NSLog(@"User has Logged in");
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogInNotification" object:nil];
            
            [self showSuccessAlert];
            
            //get all boardIDs for current user
            PFQuery *boardQueryFromPhotoClass = [PFQuery queryWithClassName:@"Photo"];
            [boardQueryFromPhotoClass whereKey:@"user" equalTo:PFUser.currentUser];
            [boardQueryFromPhotoClass selectKeys:@[@"board"]];
            [boardQueryFromPhotoClass orderByDescending:@"updatedAt"];
            [boardQueryFromPhotoClass getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                if (!error) {
                    
                    // set boardID singleton for board with most recent photo
                    PFObject *boardObject = object[@"board"];
                    NSString *boardID = [boardObject valueForKey:@"objectId"];
                    [TMBSharedBoardID sharedBoardID].boardID = boardID;
                    NSLog(@"\n\n\n\nboardID: %@\n\n\n\n",boardID);
                    
                    // get all boards for user and add to board dict singleton
                    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
                    [boardQuery whereKey:@"fromUser" equalTo:PFUser.currentUser];
                    [boardQuery selectKeys:@[@"objectId",@"boardName"]];
                    [boardQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                        
                        if (!error) {
                            
                            for (PFObject *object in objects) {
                                
                                NSString *boardID = [object valueForKey:@"objectId"];
                                NSString *boardName = [object valueForKey:@"boardName"];
                                [[TMBSharedBoardID sharedBoardID].boards setObject:boardName forKey:boardID];
                                
                            }
                            
                        } else {
                            
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                        
                    }];
                    
                } else {
                    
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
                
            }];
            
            
        } else {
            
            [self showErrorAlert];
        }
        
    }];
    
}

- (IBAction)backButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
