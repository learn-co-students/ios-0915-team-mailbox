//
//  TMBTextCardViewController.m
//  ProjectMailbox
//
//  Created by Flatiron on 11/19/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBTextCardViewController.h"

@interface TMBTextCardViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation TMBTextCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)sendButtonTapped:(UIButton *)sender {
    
    NSString *commentText = self.textField.text;
    PFObject *comment = [PFObject objectWithClassName:@"Boards"];
    comment[@"Text_Content"] = commentText;
    [comment saveInBackground];
    
    
}

- (IBAction)backButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
