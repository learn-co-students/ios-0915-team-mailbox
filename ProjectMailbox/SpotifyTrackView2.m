
#import "SpotifyTrackView2.h"
#import "SpotifyTrack2.h"
#import "TMBSpotifyViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Spotify/Spotify.h>
#import "SpotifyPlayerManager.h"

@interface SpotifyTrackView2 () <SPTAudioStreamingPlaybackDelegate>

@property (strong, nonatomic) UIImageView *coverArtImageView;
@property (strong, nonatomic) UILabel *spotifyTrackTitle;
@property (weak, nonatomic) UIButton *playPauseButton;

@property (strong, nonatomic) SpotifyTrack2 *spotifyTrack;

@end

@implementation SpotifyTrackView2

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
    
    SpotifyTrack2 *track2 = [[SpotifyTrack2 alloc] init];
    self.spotifyTrack = track2;
    
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
    UIImage * playPauseImage = [UIImage imageNamed:@"Play Icon"];
    [playPauseButton setImage:playPauseImage forState:UIControlStateNormal];
    [playPauseButton addTarget: self  action:@selector(playPauseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    playPauseButton.frame = CGRectMake(0, 0, 50, 50);
    [self addSubview:playPauseButton];
    [self bringSubviewToFront: playPauseButton];
    
    self.playPauseButton = playPauseButton;
    NSLog(@"In initialization method.");

// notification observer for login
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyLoggedInWithNotification:) name:@"SpotifyLoggedIn" object:nil];
   
// notification observers for player actions
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidStartPlaying:) name:SpotifyDidStartPlayingNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidStopPlaying:) name:SpotifyDidStopPlayingNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyDidTogglePaused:) name:SpotifyDidTogglePausedNotificationName object:nil];
}

-(void)spotifyDidStartPlaying:(NSNotification *)notification
{
    NSString *trackID = notification.userInfo[SpotifyNotificationTrackIDKey];
    if([self.spotifyTrack.trackID isEqualToString:trackID]) {
        // our track is playing!
        [self updateUIForWhenOurTrackIsPlaying];
    }
    else {
        // our track is not.
        [self updateUIForWhenOurTrackIsNotPlaying];
    }
}

-(void)spotifyDidStopPlaying:(NSNotification *)notification
{
    // we're not playing.
    [self updateUIForWhenOurTrackIsNotPlaying];
}

-(void)spotifyDidTogglePaused:(NSNotification *)notification
{
    BOOL isNowPaused = [notification.userInfo[SpotifyNotificationPausedStateKey] boolValue];
    NSLog(@"In View- isNowPaused: %d", isNowPaused);
    
    NSString *trackID = notification.userInfo[SpotifyNotificationTrackIDKey];
    
    if(![trackID isEqualToString:self.spotifyTrack.trackID]) {
        return;
    }
    
    // it's about us!
    if(!isNowPaused) {
        [self updateUIForWhenOurTrackIsPlaying];
    }
    else {
        [self updateUIForWhenOurTrackIsNotPlaying];
    }
}

-(void)updateUIForWhenOurTrackIsPlaying
{
    UIImage *pauseIcon = [UIImage imageNamed:@"Pause Icon"];
    [self.playPauseButton setImage:pauseIcon forState:UIControlStateNormal];
}

-(void)updateUIForWhenOurTrackIsNotPlaying
{
    UIImage *playIcon = [UIImage imageNamed:@"Play Icon"];
    [self.playPauseButton setImage:playIcon forState:UIControlStateNormal];
}


//view life cycle method to remove observer spotify session
-(void)removeFromSuperview {
    [super removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SpotifyLoggedIn" object:nil];
}

-(void) spotifyLoggedInWithNotification:(NSNotification*)notification{
    NSLog(@"i have received a notification that spotify has logged in");
    NSLog(@"i may now do stuff with spotify");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyDidStopPlayingNotificationName object:self userInfo:nil];
}

-(void)playPauseButtonTapped:(id)sender
{
    SpotifyPlayerManager *playerManager = [SpotifyPlayerManager sharedManager];
    if([playerManager.currentTrackID isEqualToString:self.spotifyTrack.trackID]) {
        [playerManager togglePlayPause];
    }
    else {
        [playerManager playTrackWithID: self.spotifyTrack.trackID];
    }
}

@end