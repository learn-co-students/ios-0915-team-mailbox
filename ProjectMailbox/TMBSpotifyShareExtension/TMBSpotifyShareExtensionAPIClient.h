//
//  TMBSpotifyShareExtensionAPIClient.h
//  ProjectMailbox
//
//  Created by Jimena Almendares on 11/23/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMBSpotifyShareExtensionAPIClient : NSObject

+(void)getAlbumCoverUrl:(NSString *)trackID withCompletionBlock:(void (^)(NSString *albumCoverLink, NSString *trackTitle))completionBlock;
@end
