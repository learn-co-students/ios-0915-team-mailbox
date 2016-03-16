//
//  TMBCustomNavigationBar.h
//  ProjectMailbox
//
//  Created by Joel Bell on 12/10/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMBCustomNavigationBar : UINavigationBar

- (CGSize)sizeThatFits:(CGSize)size;
- (void)layoutSubviews;

@end