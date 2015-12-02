//
//  SpotifyTrack.m
//  ProjectMailbox
//
//  Created by Jimena Almendares on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "SpotifyTrack.h"

@interface SpotifyTrack ()

@end


@implementation SpotifyTrack

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.trackID = @"3grxgV6Ot8KqtysApjYLs1";
        self.trackTitle = @"Sorry";
        self.albumCoverURL = @"https://upload.wikimedia.org/wikipedia/en/d/dc/Justin_Bieber_-_Sorry_%28Official_Single_Cover%29.png";
    }
    return self;
}

@end
