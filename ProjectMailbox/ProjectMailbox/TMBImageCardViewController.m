//
//  TMBImageCardViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 11/18/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBImageCardViewController.h"

@interface TMBImageCardViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@end

@implementation TMBImageCardViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    
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



- (void)postImage {
    
    UIImage *aImage = self.imageView.image;
    
    NSData *imageData = UIImagePNGRepresentation(aImage);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            if (succeeded) {
                PFObject* newPhotoObject = [PFObject objectWithClassName:@"Boards"];
                [newPhotoObject setObject:imageFile forKey:@"profileImage"];
                [newPhotoObject saveInBackground];
            }
        } else {
            NSLog(@"ERROR UPLOADING PROFILE IMAGE");
        }
    }];
    
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    [self postImage];
    
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
