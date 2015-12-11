
#import "SpotifyTrack.h"

@interface SpotifyTrack ()

@end


@implementation SpotifyTrack


-(instancetype)initWithTrackID:(NSString *)trackID trackTitle:(NSString *)trackTitle albumCoverURL:(NSString *)albumCoverURL
{
    self = [super init];
    
    if(self) {
        _trackID = trackID;
        _trackTitle = trackTitle;
        _albumCoverURL = albumCoverURL;
    }
    
    return self;
}


@end
