//
//  TMBDoodleViewController.h
//  ProjectMailbox
//
//  Created by Flatiron on 11/19/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleColorPickerView.h"
#import <Parse/Parse.h>

@class TMBDoodleViewController;

@protocol TMBDoodleViewControllerDelegate <NSObject>

@required

-(void)doodleViewController:(TMBDoodleViewController *)viewController passBoardIDforQuery:(NSString *)boardID;

@end 

@interface TMBDoodleViewController : UIViewController {

CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    
}

@property (nonatomic, weak) id<TMBDoodleViewControllerDelegate> delegate;

@end
