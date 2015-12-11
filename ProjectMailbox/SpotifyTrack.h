
#import <Foundation/Foundation.h>

@interface SpotifyTrack : NSObject

@property (strong, nonatomic) NSString *trackID;
@property (strong, nonatomic) NSString *trackTitle;
@property (strong, nonatomic) NSString *albumCoverURL;

-(instancetype)initWithTrackID:(NSString *)trackID trackTitle:(NSString *)trackTitle albumCoverURL:(NSString *)albumCoverURL;

@end
