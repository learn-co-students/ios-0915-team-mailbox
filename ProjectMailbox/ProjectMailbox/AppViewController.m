//
//  AppViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "AppViewController.h"
#import "TMBSharedBoardID.h"


@interface AppViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation AppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserDidLogOut:) name:@"UserDidLogOutNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserDidSignUp:) name:@"UserDidSignUpNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserDidLogInWithBoards:) name:@"UserDidLogInWithBoardsNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserDidLogInWithoutBoards:) name:@"UserDidLogInWithoutBoardsNotification" object:nil];
    
    
    
    if ([PFUser currentUser]) {
        [self showMainPage];
    } else if (![PFUser currentUser]) {
        [self showFirstPage];
    }
    
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)showMainPage
{
    UINavigationController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mainPageNav"];
    
    // create / Set Up MMDrawer
    
    UIViewController *leftMenuVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TMBSideMenuViewController"];
    
    MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:homeVC leftDrawerViewController:leftMenuVC];
    [drawerController setMaximumRightDrawerWidth:150.0];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    //[drawerController setDrawerVisualStateBlock:[MMDrawerVisualState swingingDoorVisualStateBlock]];
    
    [drawerController setShowsShadow:NO];
    [drawerController setStatusBarViewBackgroundColor: [UIColor clearColor]];

    
    [self setEmbeddedViewController:drawerController];
    
}

-(void)showFirstPage
{
    UIViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstPage"];
    
    [self setEmbeddedViewController:loginVC];
}

-(void)showCreateBoardPage
{
    
    UIViewController *createBoardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"createBoard"];
    
    [self setEmbeddedViewController:createBoardVC];
    
}

-(void)handleUserDidLogOut:(NSNotification *)notification
{
    [PFUser logOut];
    
    // switch back to the login VC
    [TMBSharedBoardID sharedBoardID].boardID = @"";
    [[TMBSharedBoardID sharedBoardID].boards removeAllObjects];
    [self showFirstPage];
}

-(void)handleUserDidLogInWithBoards:(NSNotification *)notification
{
    [PFUser currentUser];
    
    // switch to the home VC
    [self showMainPage];
}

-(void)handleUserDidLogInWithoutBoards:(NSNotification *)notification
{
    [PFUser currentUser];
    
    // switch to the home VC
    [self showCreateBoardPage];
}

- (void)handleUserDidSignUp:(NSNotification *)notification {
    
    [PFUser currentUser];
    
    [self showMainPage];
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

@end
