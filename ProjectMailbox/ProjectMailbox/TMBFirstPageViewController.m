//
//  TMBFirstPageViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 11/17/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBFirstPageViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "TMBSharedBoardID.h"

@interface TMBFirstPageViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;


//loading view
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;


@end

@implementation TMBFirstPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)presentMainPage {
    
    UIViewController *mainPage = [self.storyboard instantiateViewControllerWithIdentifier:@"MainPage"];
    
    mainPage.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:mainPage animated:YES completion:nil];
    
}


-(void)activityLoadView
{
    
    self.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlayView.backgroundColor = [UIColor colorWithRed:28/255.0 green:78/255.0 blue:157/255.0 alpha:0.7];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.overlayView.center;
    [self.overlayView addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.overlayView];
    
}




- (IBAction)signInButtonTapped:(id)sender {
    
    [self.view endEditing:YES];
    
    [self activityLoadView];
    
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
            
            NSLog(@"\n\n\nUser has Logged in\n\n\n");
            
            // get all boards for user and add to board dict singleton
            PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
            [boardQuery whereKey:@"fromUser" equalTo:PFUser.currentUser];
            [boardQuery selectKeys:@[@"objectId",@"boardName"]];
            [boardQuery orderByDescending:@"updatedAt"];
            [boardQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                
                NSLog(@"\n\n\nlogin board query\n\n\n");
                
                if (!error) {
                    
                    NSLog(@"\n\n\nobjects: %@\n\n\n",objects);
                    
                    if (objects.count == 0) {
                        [self.overlayView removeFromSuperview];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogInWithoutBoardsNotification" object:nil];
                        
                    } else {
                        
                        NSUInteger count = 0;
                        for (PFObject *object in objects) {
                            
                            NSString *boardID = [object valueForKey:@"objectId"];
                            NSString *boardName = [object valueForKey:@"boardName"];
                            if (count == 0) {
                                [TMBSharedBoardID sharedBoardID].boardID = boardID;
                            }
                            [[TMBSharedBoardID sharedBoardID].boards setObject:object forKey:boardID];
                            count++;
                        }
                        
                        PFQuery *boardQueryFromPhotoClass = [PFQuery queryWithClassName:@"Photo"];
                        [boardQueryFromPhotoClass whereKey:@"user" equalTo:PFUser.currentUser];
                        [boardQueryFromPhotoClass selectKeys:@[@"board"]];
                        [boardQueryFromPhotoClass orderByDescending:@"updatedAt"];
                        [boardQueryFromPhotoClass getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                            
                            if (!error) {
                                
                                // set boardID singleton from board with most recent photo
                                PFObject *boardObject = object[@"board"];
                                NSString *boardID = [boardObject valueForKey:@"objectId"];
                                [TMBSharedBoardID sharedBoardID].boardID = boardID;
                                NSLog(@"\n\n\n\nboardID: %@\n\n\n\n",boardID);
                                [self.overlayView removeFromSuperview];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogInWithBoardsNotification" object:nil];
                                
                            } else {
                                
                                if (error.code == 101) {
                                    NSLog(@"\n\n\n\nboardqueryphotoclass error.code: %li\n\n\n",error.code);
                                    [self.overlayView removeFromSuperview];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogInWithBoardsNotification" object:nil];
                                }
                                [self.overlayView removeFromSuperview];
                                NSLog(@"Error: %@ %@", error, [error userInfo]);
                            }
                            
                        }];
                        
                    }
                
                    
                } else {
                    
                    [self.overlayView removeFromSuperview];
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
                
                
            }];
            
            
        } else {
            
            [self.overlayView removeFromSuperview];
            [self showErrorAlert];
        }
        
    }];
    
}

- (void)showErrorAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Invalid login. Please try again" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:okAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)loginWithFacebook {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"public_profile", @"email", @"user_friends"];
        
    // Login PFUser using Facebook
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray
                                                    block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                                                     
                                                        if (!user) {
                                                            [self facebookLoginErrorAlert];
                                                            NSLog(@"Uh oh. The user cancelled the Facebook login.");
                                                        } else if (user.isNew) {
                                                            [self loadFacebookUserDetails];
                                                            
                                                            NSLog(@"User signed up and logged in through Facebook!");
                                                        } else {
                                                            [self loadFacebookUserDetails];
                                                            
                                                            NSLog(@"User logged in through Facebook!");
                                                        }
                                                        
                                                    }];
    
}

- (IBAction)facebookButtonTapped:(id)sender {
    
    [self loginWithFacebook];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogInNotification" object:nil];
    
}

- (void)loadFacebookUserDetails {
    
    NSDictionary *requestParameters = @{ @"fields": @"id, email, first_name, last_name, name" };
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:requestParameters];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *userEmail = userData[@"email"];
            NSString *userFirstName = userData[@"first_name"];
            NSString *userLastName = userData[@"last_name"];
//            NSString *location = userData[@"location"][@"name"];
//            NSString *gender = userData[@"gender"];
//            NSString *birthday = userData[@"birthday"];
//            NSString *relationship = userData[@"relationship_status"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
            
            NSURLSession *newSession = [NSURLSession sharedSession];
            
            // Run network request asynchronously
            NSURLSessionDataTask *newTask = [newSession dataTaskWithURL:pictureURL
                                                      completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                          
                                                          NSData *profilePictureData = [NSData dataWithContentsOfURL:pictureURL];
                                                          // set up PFUser
                                                          if (profilePictureData != nil) {
                                                              PFFile *profileFileObject = [PFFile fileWithData:profilePictureData];
                                                              
                                                              PFUser *currentUser = [PFUser currentUser];
                                                              [currentUser setObject:profileFileObject forKey:@"profileImage"];
                                                              [currentUser setObject:userFirstName forKey:@"First_Name"];
                                                              [currentUser setObject:userLastName forKey:@"Last_Name"];
                                                              [currentUser setObject:userEmail forKey:@"email"];
                                                              [currentUser setObject:userEmail forKey:@"username"];
                                                              
                                                              [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                                  if (error != nil) {
                                                                      [self facebookLoginErrorAlert];
                                                                      [PFUser logOut];
                                                                      return;
                                                                  }
                                                                  
                                                                  if (succeeded) {
                                                                      if (facebookID.length != 0) {
                                                                          NSUserDefaults *facebookLoginDefault = [[NSUserDefaults alloc]init];
                                                                          [facebookLoginDefault setObject:facebookID forKey:@"user_name"];
                                                                          [facebookLoginDefault synchronize];
                                                                          
                                                                  }
                                                                  }
                                                              }];
                                                          }
                                                          
                                                      }];
            
            [newTask resume];
            
  
                 }
             }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLogInNotification" object:nil];
    
}

- (void)facebookLoginErrorAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Facebook login failed. Please try again" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:okAction];
}

@end
