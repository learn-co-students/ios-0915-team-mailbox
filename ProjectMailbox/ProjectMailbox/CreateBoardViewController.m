//
//  CreateBoardViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 12/6/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "CreateBoardViewController.h"
#import "TMBConstants.h"

@interface CreateBoardViewController ()
@property (weak, nonatomic) IBOutlet UITextField *boardNameLabel;

@end

@implementation CreateBoardViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];


    // loging in this app as Inga for now
    
    if (![PFUser currentUser]){
        [PFUser logInWithUsernameInBackground:@"ingakyt@gmail.com" password:@"test" block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            NSLog(@"logged in user: %@ \nwith error: %@", user, error);
                }];
    }

}




- (IBAction)createNewBoardTapped:(UIButton *)sender {

    
    NSString *boardName = self.boardNameLabel.text;
    
    //create a board object
    
    PFObject *boardNameObj = [PFObject objectWithClassName:@"Board"];
    boardNameObj[@"boardName"] = boardName;
    
    [boardNameObj setObject:[PFUser currentUser] forKey:kTMBBoardFromUserKey];

    
    [boardNameObj saveInBackground];
    

    
}




- (IBAction)addFriendButtonTapped:(UIButton *)sender {
    
    
    NSString *string = ...;
    NSURL *URL = ...;
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                      applicationActivities:nil];
    [navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         // ...
                                     }];
    
    
    
    
    if let streetName = "\(galleryObj["Street_name"]!)" as String?,
        let postalCode = "\(galleryObj["Postal_code"]!)" as String?,
        let state = "\(galleryObj["State"]!)" as String?,
        let galleryName = "\(galleryObj["Gallery_Name"])" as String? {
            
            let activityItem:String! = "\(galleryName)\n\(streetName), \(state), \(postalCode)"
            
            let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
            
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }

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
