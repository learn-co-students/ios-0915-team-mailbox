
#import "TMBSpotifyViewController.h"
#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TMBSpotifyViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioRecorder *recorder;

@end


@implementation TMBSpotifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
// setup audio session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:nil];
  
    [audioSession setActive:YES error:nil];
   

// set up audio recorder
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVEncoderBitRateKey];
    [recordSetting setValue :[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    [recordSetting setValue :[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    // file path Desktop/recorderTrial.m4a
    
    NSArray *pathComponents = [NSArray arrayWithObjects: NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES), @"MyAudioMemo.m4a", nil];
    
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
//    NSURL *filePath = [[NSURL alloc] initWithString:@"Desktop/recorderTrial.m4a"];
    
    // what should
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc]initWithURL:outputFileURL
                                                           settings:recordSetting
                                                              error: nil];
    
    BOOL audioHWAvailable = audioSession.inputAvailable;
    
    NSLog(@"audioHWAvailable: %d", audioHWAvailable);

    [recorder setDelegate:self];
    
    self.recorder = recorder;
    
    


}


# pragma mark - audio play/record buttons

- (IBAction)recordButtonTapped:(UIButton *)sender {
    [self.recorder prepareToRecord];
    self.recorder.meteringEnabled = YES;
    
    [self.recorder record];
}

- (IBAction)playButtonTapped:(UIButton *)sender {
}

- (IBAction)stopButtonTapped:(UIButton *)sender {
    [self.recorder stop];
}



@end