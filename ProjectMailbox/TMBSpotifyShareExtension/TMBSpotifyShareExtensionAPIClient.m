//
//  TMBSpotifyShareExtensionAPIClient.m
//  ProjectMailbox
//
//  Created by Jimena Almendares on 11/23/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBSpotifyShareExtensionAPIClient.h"

@implementation TMBSpotifyShareExtensionAPIClient

+(void)getAlbumCoverUrl:(NSString *)trackID withCompletionBlock:(void (^)(NSString *albumCoverLink))completionBlock {
    
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.spotify.com/v1/tracks/%@", trackID];
    
    NSURL *albumCoverURL = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *albumCoverDataTask = [session dataTaskWithURL:albumCoverURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSLog(@"Respose Dictionary: %@", responseDictionary);
        
        NSDictionary *albumDictionary = responseDictionary[@"album"];
        NSLog(@"albumDictionary: %@", albumDictionary);
        
        NSArray *imagesArray =albumDictionary[@"images"];
        NSLog(@"imagesArray: %@", imagesArray);
        
        NSDictionary *imageDictionary = imagesArray[1];
        NSLog(@"imageDictionary: %@", imageDictionary);
        
        NSString *albumCoverLink = imageDictionary[@"url"];
        NSLog(@"albumCoverLink: %@", albumCoverLink);
        
        
        completionBlock(albumCoverLink);
    }];
    
    [albumCoverDataTask resume];
}

@end

