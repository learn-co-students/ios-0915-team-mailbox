//
//  SpotifyTrackView.m
//  ProjectMailbox
//
//  Created by Jimena Almendares on 12/1/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "SpotifyTrackView.h"
#import "SpotifyTrack.h"
#import "TMBSpotifyViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Spotify/Spotify.h>

@interface SpotifyTrackView ()

@property (strong, nonatomic) SpotifyTrack *spotifyTrack;
@property (strong, nonatomic) UIImageView *coverArtImageView;
@property (strong, nonatomic) UILabel *spotifyTrackTitle;

@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@end

@implementation SpotifyTrackView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitWithSpotifyTrack];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitWithSpotifyTrack];
    }
    return self;
}

-(void)commonInitWithSpotifyTrack {
    
    SpotifyTrack *track = [[SpotifyTrack alloc] init];
    self.spotifyTrack = track;
    
    self.backgroundColor = [UIColor blackColor];
    
    //initialize image view
    CGRect imageViewRect = CGRectMake(0, 0, 207, 184);
    self.coverArtImageView = [[UIImageView alloc] initWithFrame:imageViewRect];
    [self addSubview:self.coverArtImageView];
    
    // set image from url for album art.
    NSURL *coverURL = [NSURL URLWithString: self.spotifyTrack.albumCoverURL];
    NSData *coverImageData = [NSData dataWithContentsOfURL:coverURL];
    UIImage *coverImage = [UIImage imageWithData:coverImageData];
    self.coverArtImageView.image = coverImage;
    
    // add spotify play/pause button
    UIButton *playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [playPauseButton.centerXAnchor constraintEqualToAnchor: self.centerXAnchor];
    [playPauseButton.centerYAnchor constraintEqualToAnchor: self.centerYAnchor];
    [playPauseButton.heightAnchor constraintEqualToConstant:50];
    [playPauseButton.widthAnchor constraintEqualToConstant:50];
    [playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    [playPauseButton addTarget: self  action:@selector(playSpotifyTrackWithTrackId:) forControlEvents:UIControlEventTouchUpInside];
    playPauseButton.frame = CGRectMake(0, 0, 50, 40);
    [playPauseButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self addSubview:playPauseButton];
    [self bringSubviewToFront: playPauseButton];
    
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyLoggedInWithNotification:) name:@"SpotifyLoggedIn" object:nil];
    NSLog(@"In initialization method.");
}

//view life cycle methods to initialize spotify session
-(void)didMoveToSuperview {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyLoggedInWithNotification:) name:@"SpotifyLoggedIn" object:nil];
    NSLog(@"In didMoveToSuperview method.");
}


-(void)removeFromSuperview {
    [super removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SpotifyLoggedIn" object:nil];
}

-(void) spotifyLoggedInWithNotification:(NSNotification*)notification{
    NSLog(@"i have received a notification that spotify has logged in");
    NSLog(@"i may now do stuff with spotify");
    //    SPTSession *session = [[SPTAuth defaultInstance] session];
    //    [self playUsingSession:session withTrackID:@"7fEGUogfVroN6IQL6Q7atH"];
}


-(void)playSpotifyTrackWithTrackId:(NSString *) trackID {
    SPTSession *session = [[SPTAuth defaultInstance] session];
    [self playUsingSession:session withTrackID: self.spotifyTrack.trackID];
}

-(void)playUsingSession:(SPTSession *)session withTrackID:(NSString *)trackID {
    
    // Create a new player if needed
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    }
    
    [self.player loginWithSession:session callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Logging in got error: %@", error);
            return;
        }
        // spotify:track:3grxgV6Ot8KqtysApjYLs1
        NSString *trackIDString = [NSString stringWithFormat:@"spotify:track:%@", trackID];

        NSURL *trackURI = [NSURL URLWithString:trackIDString];
        [self.player playURIs:@[ trackURI ] fromIndex:0 callback:^(NSError *error) {
            
            NSLog(@"%@", trackURI);
            
            if (error != nil) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
        }];
    }];
}

@end
