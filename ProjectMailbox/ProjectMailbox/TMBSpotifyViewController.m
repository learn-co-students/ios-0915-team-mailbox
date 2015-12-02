//
//  TMBSpotifyViewController.m
//  ProjectMailbox
//
//  Created by Jimena Almendares on 11/23/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "TMBSpotifyViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Spotify/Spotify.h>

@interface TMBSpotifyViewController ()

//@property (nonatomic, strong) SPTSession *session;
//@property (nonatomic, strong) SPTAudioStreamingController *player;


@end

@implementation TMBSpotifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyLoggedInWithNotification:) name:@"SpotifyLoggedIn" object:nil];
}

//-(void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SpotifyLoggedIn" object:nil];
//}
//
//
//-(void) spotifyLoggedInWithNotification:(NSNotification*)notification{
//    NSLog(@"i have received a notification that spotify has logged in");
//    NSLog(@"i may now do stuff with spotify");
//        // trackID:@"7fEGUogfVroN6IQL6Q7atH"];
//}
//
//- (IBAction)playButtonTapped:(UIButton *)sender {
//    SPTSession *session = [[SPTAuth defaultInstance] session];
//    [self playUsingSession:session withTrackID:@"7fEGUogfVroN6IQL6Q7atH"];
//}
//
- (IBAction)spotifyLogInButtonTapped:(id)sender {
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    [[UIApplication sharedApplication] openURL:loginURL];
}
//
//
//
//
//-(void)playUsingSession:(SPTSession *)session withTrackID:(NSString *)trackID {
//    
//    // Create a new player if needed
//    if (self.player == nil) {
//        self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
//    }
//    
//    [self.player loginWithSession:session callback:^(NSError *error) {
//        if (error != nil) {
//            NSLog(@"*** Logging in got error: %@", error);
//            return;
//        }
//        // spotify:track:3grxgV6Ot8KqtysApjYLs1
//        NSString *trackIDString = [NSString stringWithFormat:@"spotify:track:%@", trackID];
//        //        NSURL *trackURI = [NSURL URLWithString:@"spotify:track:7fEGUogfVroN6IQL6Q7atH"];
//        NSURL *trackURI = [NSURL URLWithString:trackIDString];
//        [self.player playURIs:@[ trackURI ] fromIndex:0 callback:^(NSError *error) {
//            
//            NSLog(@"%@", trackURI);
//            
//            if (error != nil) {
//                NSLog(@"*** Starting playback got error: %@", error);
//                return;
//            }
//        }];
//    }];
//}



@end