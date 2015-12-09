//
//  TMBBoardID.m
//  TeamMailboxAddParse
//
//  Created by Joel Bell on 12/7/15.
//  Copyright © 2015 Joel Bell. All rights reserved.
//

#import "TMBSharedBoardID.h"

@implementation TMBSharedBoardID

+ (instancetype)sharedBoardID
{
    NSLog(@"shared board instance");
    static id sharedBoardID = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBoardID = [[self alloc] init];
    });
    return sharedBoardID;
}

-(NSString *)boardID
{
    NSLog(@"shared board ID: %@",_boardID);
    return _boardID;
}
-(NSMutableArray *)boardIDs
{
    if (!_boardIDs) {
        _boardIDs = [NSMutableArray new];
    }
    return _boardIDs;
}

@end
