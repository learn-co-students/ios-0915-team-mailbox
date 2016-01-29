//
//  SpotifyPlayerManager.m
//  ProjectMailbox
//
//  Created by Jimena Almendares on 12/8/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "SpotifyPlayerManager.h"
#import <Spotify/Spotify.h>


NSString * const SpotifyDidStartPlayingNotificationName = @"SpotifyDidStartPlayingNotification";
NSString * const SpotifyNotificationTrackIDKey = @"trackID";

NSString * const SpotifyDidStopPlayingNotificationName = @"SpotifyDidStopPlayingNotification";

NSString * const SpotifyDidTogglePausedNotificationName = @"SpotifyDidTogglePausedNotification";
NSString * const SpotifyNotificationPausedStateKey = @"isPaused";


@interface SpotifyPlayerManager () <SPTAudioStreamingPlaybackDelegate>

@property (nonatomic, strong) SPTAudioStreamingController *player;

@property (nonatomic, strong, readwrite) NSString *currentTrackID;
@property (nonatomic, assign, readwrite) BOOL isPlaying;

@end


@implementation SpotifyPlayerManager

+(instancetype)sharedManager
{
    static SpotifyPlayerManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

-(void)ensurePlayerWithCompletion:(void (^)(void))completionBlock
{
    if(self.player && self.player.loggedIn) {
        completionBlock();
        return;
    }
    
    self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    self.player.playbackDelegate = self;
    
    [self.player loginWithSession:[SPTAuth defaultInstance].session callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Logging in got error: %@", error);
            completionBlock();
            return;
        }
        
        completionBlock();
    }];
}

-(NSURL *)URIForTrackID:(NSString *)trackID
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"spotify:track:%@", trackID]];
}

-(void)playTrackWithID:(NSString *)trackID
{
    if([self.currentTrackID isEqualToString:trackID]) {
        return;
    }
    
    self.currentTrackID = trackID;
    
    NSLog(@"Switching to track %@", trackID);
    [self ensurePlayerWithCompletion:^{
        [self.player stop:^(NSError *error) {
            self.isPlaying = NO;
            
            if(error) {
                NSLog(@"Error stopping track: %@", error);
            }
            
            if(!trackID) {
                return;
            }
            
            [self.player playURIs:@[[self URIForTrackID:trackID]] fromIndex:0 callback:^(NSError *error) {
                if(error) {
                    NSLog(@"Error playing track: %@", error);
                }
                else {
                    self.isPlaying = YES;
                }
            }];
        }];
    }];
    
    
    if(trackID) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyDidStartPlayingNotificationName object:self userInfo:@{ SpotifyNotificationTrackIDKey: trackID }];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyDidStopPlayingNotificationName object:self userInfo:nil];
    }
}

-(void)togglePlayPause
{
    BOOL newPauseState = !self.player.isPlaying;
    self.isPlaying = newPauseState;
    
    [self ensurePlayerWithCompletion:^{
        [self.player setIsPlaying:newPauseState callback:^(NSError *error) {
            if(error) {
                NSLog(@"Error toggling play/pause: %@", error);
            }
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyDidTogglePausedNotificationName object:self userInfo:@{ SpotifyNotificationPausedStateKey: @(newPauseState), SpotifyNotificationTrackIDKey: self.currentTrackID }];
}

-(void)stop
{
    [self playTrackWithID:nil];
}


#pragma mark SPTAudioStreamingPlaybackDelegate



@end
