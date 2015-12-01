//
//  TMBMainPageContentViewController.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBMainPageContentViewController.h"

@interface TMBMainPageContentViewController ()
@property (weak, nonatomic) IBOutlet UIView *hamburgerMenuContainer;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *homeContentTapGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIView *homeContainer;

@end

@implementation TMBMainPageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowHamburgerMenu:) name:@"ShowHamburgerMenuNotification" object:nil];
}

-(void)handleShowHamburgerMenu:(NSNotification *)notification
{
    self.homeContentTapGestureRecognizer.enabled = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.hamburgerMenuContainer.alpha = 1;
        self.homeContainer.alpha = 0.5;
    }];
}

- (IBAction)homeContentTapped:(id)sender {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.hamburgerMenuContainer.alpha = 0;
        self.homeContainer.alpha = 1;
    }];
    
    self.homeContentTapGestureRecognizer.enabled = NO;
    
}





@end
