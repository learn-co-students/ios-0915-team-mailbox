//
//  TMBImageCardViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 11/18/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBImageCardViewController.h"
#import "TMBConstants.h"
#import "PAPCache.h"
#import "TMBTableViewCommentCellTableViewCell.h"


@interface TMBImageCardViewController () <UITableViewDelegate, UITableViewDataSource>

//add photo view
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

//detail view
@property (weak, nonatomic) IBOutlet UILabel *currentUserNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentedPhoto;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;


@end


@implementation TMBImageCardViewController


- (id)initWithImage:(UIImage *)aImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aImage) {
            return nil;
        }
        
        self.image = aImage;
        self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
        self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"IN VIEW DID LOAD.........");
    
    self.commentsTableView.delegate = self;
    self.commentsTableView.dataSource = self;
    
    

    // loging in this app as Inga for now
    
    if (![PFUser currentUser]){
        [PFUser logInWithUsernameInBackground:@"ingakyt@gmail.com" password:@"test" block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            NSLog(@"logged in user: %@ \nwith error: %@", user, error);
        }];
    }
    
    
    
    /*****************************
     *        PARSE QUERY        *
     *****************************/

    // goal: query for an image, set the image to the view
    // goal: get comments related to that image & display them in a small table view
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query includeKey:kTMBActivityPhotoKey];
    [query includeKey:kTMBActivityFromUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            // handle error in the future
        }

        PFObject *anActivity = [objects firstObject];
        NSLog(@"anActivities comment: %@", anActivity[@"content"]);
        
        // set datastore to objects array
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            self.activities = [objects mutableCopy];
            [self.commentsTableView reloadData];
        }];
        
        // test: getting photo obj
        PFObject *anActivitysPhoto = anActivity[@"photo"];
        PFFile *imageFile = anActivitysPhoto[@"image"];
        
        // test: user's first name set to label
        PFObject *aFromUser = anActivity[@"fromUser"];
        NSString *firstName = aFromUser[@"First_Name"];
        self.currentUserNameLabel.text = firstName;

        // setting the image view to photo obj above
        [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:result];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.commentedPhoto.image = image;
                }];
            }
        }];
    }];
    
    
}



     
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSUInteger numberOfComments = self.activities.count;
    NSLog(@"numberOfRows getting called: %lu", self.activities.count);
    
    return numberOfComments;
}





-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"cellForRowAtIndexPath: has been called with an indexPath of %@", indexPath);
    
    TMBTableViewCommentCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];

    NSUInteger rowOfIndexPath = indexPath.row;
    
    // setting table rows to display comments
    PFObject *anActivity = self.activities[rowOfIndexPath];
//    cell.textLabel.text = anActivity[@"content"];
    cell.userCommentLabel.text = anActivity[@"content"];
    
    
    // user label displays fromUser name
    PFObject *aFromUser = anActivity[@"fromUser"];
    NSString *firstName = aFromUser[@"First_Name"];
    cell.fromUserNameLabel.text = firstName;
    
    // set user profile photo next...

    
    return cell;
    
}





- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}






- (IBAction)takePhotoButtonTapped:(UIButton *)sender {
    
    
    // simulators don't have a camera
    
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        NSLog(@"NO CAMERA FOUND");
        // make an alert later
        
    } else {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
    
}





- (IBAction)chosePhotoButtonTapped:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}





/*****************************
 *      SAVING TO PARSE      *
 *****************************/

// this code saves the image selected from photo library or camera
- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    // passing a UIImage and setting it to our library/camera image
    anImage = self.imageView.image;
    
    NSData *imageData = UIImagePNGRepresentation(anImage);
    self.photoFile = [PFFile fileWithData:imageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    NSLog(@"IN SHOULD UPLOAD IMAGE BOOL .........");
    
    return YES;
}



// this code saves our image and its comment to Parse
- (IBAction)postButtonTapped:(UIButton *)sender {
    
    [self shouldUploadImage:self.image];
    
    // Trim comment and save it in a dictionary for use later in our callback block
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    trimmedComment,
                    kTMBEditPhotoViewControllerUserInfoCommentKey,
                    nil];
    }
    
    
    // Create a Photo object
    PFObject *photo = [PFObject objectWithClassName:kTMBPhotoClassKey];
    PFUser *currentUser = [PFUser currentUser];
    [photo setObject:[PFUser currentUser] forKey:kTMBPhotoUserKey];  // the user is nil??
    [photo setObject:self.photoFile forKey:kTMBPhotoPictureKey];
    
    // Photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading
    // the photo even if the app is sent to the background
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // Save the Photo PFObject
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded");
            
            [[PAPCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            
            // userInfo might contain any caption which might have been posted by the uploader
            if (userInfo) {
                NSString *commentText = [userInfo objectForKey:kTMBEditPhotoViewControllerUserInfoCommentKey];
                
                if (commentText && commentText.length != 0) {
                    // create and save photo caption
                    PFObject *comment = [PFObject objectWithClassName:kTMBActivityClassKey];
                    [comment setObject:kTMBActivityTypeComment forKey:kTMBActivityTypeKey];
                    [comment setObject:photo forKey:kTMBActivityPhotoKey];
                    [comment setObject:[PFUser currentUser] forKey:kTMBActivityFromUserKey];
                    [comment setObject:[PFUser currentUser] forKey:kTMBActivityToUserKey];
                    [comment setObject:commentText forKey:kTMBActivityContentKey];
                    
                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                    [ACL setPublicReadAccess:YES];
                    comment.ACL = ACL;
                    
                    [comment saveEventually];
                    [[PAPCache sharedCache] incrementCommentCountForPhoto:photo];
                }
            }
            //
            //            [[NSNotificationCenter defaultCenter] postNotificationName:TMBTabBarControllerDidFinishEditingPhotoNotification object:photo];
        }else {
            NSLog(@"Photo failed to save: %@", error);
            // re-write this alert to newer syntax
            
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            //            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        
    }];
    
    
    // Dismiss this screen
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    
}





- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}




- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}







/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */




@end
