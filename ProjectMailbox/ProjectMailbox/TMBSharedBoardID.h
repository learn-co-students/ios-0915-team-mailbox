//
//  TMBBoardID.h
//  TeamMailboxAddParse
//
//  Created by Joel Bell on 12/7/15.
//  Copyright © 2015 Joel Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface TMBSharedBoardID : NSObject

@property (nonatomic, copy) NSString *boardID;
@property (nonatomic, copy) NSMutableDictionary *boards;

+ (instancetype)sharedBoardID;

@end
