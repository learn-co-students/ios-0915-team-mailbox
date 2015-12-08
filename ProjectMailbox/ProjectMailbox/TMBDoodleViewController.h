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

@interface TMBDoodleViewController : UIViewController {
    
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    
}

@end
