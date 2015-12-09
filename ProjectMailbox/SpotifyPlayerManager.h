
#import <Foundation/Foundation.h>

extern NSString * const SpotifyDidStartPlayingNotificationName;
extern NSString * const SpotifyNotificationTrackIDKey;

extern NSString * const SpotifyDidStopPlayingNotificationName;

extern NSString * const SpotifyDidTogglePausedNotificationName;
extern NSString * const SpotifyNotificationPausedStateKey;


@interface SpotifyPlayerManager : NSObject

+(instancetype)sharedManager;

@property (nonatomic, strong, readonly) NSString *currentTrackID;
@property (nonatomic, assign, readonly) BOOL isPlaying;

-(void)playTrackWithID:(NSString *)trackID;
-(void)togglePlayPause;
-(void)stop;

@end
