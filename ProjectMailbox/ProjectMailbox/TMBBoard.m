//
//  TMBBoard.m
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/8/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBBoard.h"
#import <Parse/Parse.h>

@implementation TMBBoard

+ (TMBBoard *)newTMBoardFromPFObject:(PFObject *)parseObject {

    TMBBoard *newBoard = [[TMBBoard alloc] init];
    
    newBoard.boardName = parseObject[@"boardName"];
    newBoard.userName = parseObject[@"userName"];
    newBoard.updatedAt = [parseObject updatedAt];
    
    return newBoard;
    
}

@end
