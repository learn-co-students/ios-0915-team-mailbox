//
//  AppViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "AppViewController.h"

@interface AppViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation AppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserDidLogOut:) name:@"UserDidLogOutNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserDidLogIn:) name:@"UserDidLogInNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowHamburgerMenu:) name:@"ShowHamburgerMenuNotification" object:nil];
    
    if ([PFUser currentUser]) {
        [self showMainPage];
    } else if (![PFUser currentUser]) {
        [self showFirstPage];
    }
    
}

-(void)showMainPage
{
    UIViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainPage"];
    
    [self setEmbeddedViewController:homeVC];
}

-(void)showFirstPage
{
    UIViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstPage"];
    
    [self setEmbeddedViewController:loginVC];
}

-(void)handleUserDidLogOut:(NSNotification *)notification
{
    [PFUser logOut];
    
    // switch back to the login VC
    [self showFirstPage];
}

-(void)handleUserDidLogIn:(NSNotification *)notification
{
    [PFUser currentUser];
    
    // switch to the home VC
    [self showMainPage];
}

-(void)handleShowHamburgerMenu:(NSNotification *)notification
{
    
}



-(void)setEmbeddedViewController:(UIViewController *)controller
{
    if([self.childViewControllers containsObject:controller]) {
        return;
    }
    
    for(UIViewController *vc in self.childViewControllers) {
        [vc willMoveToParentViewController:nil];
        
        if(vc.isViewLoaded) {
            [vc.view removeFromSuperview];
        }
        
        [vc removeFromParentViewController];
    }
    
    if(!controller) {
        return;
    }
    
    [self addChildViewController:controller];
    [self.containerView addSubview:controller.view];
    [controller.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    [controller didMoveToParentViewController:self];
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
