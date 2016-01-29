//
//  TMBBoard.h
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/8/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PFObject;

@interface TMBBoard : NSObject

@property (strong, nonatomic) NSDate *updatedAt;
@property (strong, nonatomic) NSString *boardName;
@property (strong, nonatomic) NSString *userName;

+ (TMBBoard *)newTMBoardFromPFObject:(PFObject *)parseObject;

@end
