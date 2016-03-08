//
//  TMBCustomNavigationBar.m
//  ProjectMailbox
//
//  Created by Joel Bell on 12/10/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBCustomNavigationBar.h"

@implementation TMBCustomNavigationBar

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (CGSize)sizeThatFits:(CGSize)size {
    
    CGRect rec = self.frame;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    rec.size.width = screenRect.size.width;
    rec.size.height = 32;
    return rec.size;
}


-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    // Make items on navigation bar vertically centered.
    int i = 0;
    for (UIView *view in self.subviews) {
        i++;
        if (i == 0)
            continue;
        float centerY = self.bounds.size.height / 2.0f;
        CGPoint center = view.center;
        center.y = centerY;
        view.center = center;
    }
}

@end
