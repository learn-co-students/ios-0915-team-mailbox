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

@interface TMBFirstPageViewController ()
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@end

@implementation TMBFirstPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([PFUser currentUser]) {
        self.welcomeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome, %@", nil), [[PFUser currentUser] username]];
    } else {
        self.welcomeLabel.text = NSLocalizedString(@"Not logged in", nil);
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (![PFUser currentUser]) {
        TMBSignInViewController *signInViewController = [[TMBSignInViewController alloc]init];
        
        
    }
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
            NSString *location = userData[@"location"][@"name"];
            NSString *gender = userData[@"gender"];
            NSString *birthday = userData[@"birthday"];
            NSString *relationship = userData[@"relationship_status"];
            
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
    
}

- (void)buildUserInterface {
    
}

- (void)facebookLoginErrorAlert {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Facebook login failed. Please try again" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:okAction];
}

@end
