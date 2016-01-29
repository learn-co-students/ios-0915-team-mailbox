//
//  SpotifyTrack.h
//  ProjectMailbox
//
//  Created by Jimena Almendares on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotifyTrack : NSObject

@property (strong, nonatomic) NSString *trackID;
@property (strong, nonatomic) NSString *trackTitle;
@property (strong, nonatomic) NSString *albumCoverURL;
@end
