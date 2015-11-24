//
//  ShareViewController.m
//  TMBSpotifyShareExtension
//
//  Created by Jimena Almendares on 11/23/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "ShareViewController.h"
#import "TMBSpotifyShareExtensionAPIClient.h"

@interface ShareViewController ()

@property(strong, nonatomic) NSString *trackID;

@end

@implementation ShareViewController



- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    NSLog(@"Content: %@", self.contentText);
    
    //    NSLog(@"Extension Context Description: %@", self.extensionContext.description);
    
    //    NSLog(@"self.extensionContext.inputItems[0]: %@", self.extensionContext.inputItems[0]);
    
    for(NSExtensionItem *item in self.extensionContext.inputItems) {
        NSLog(@"%@", item.attributedContentText);
        for(NSItemProvider *attachment in item.attachments) {
            for(NSString *typeID in attachment.registeredTypeIdentifiers) {
                [attachment loadItemForTypeIdentifier:typeID options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    NSLog(@"\t%@: %@", typeID, item);
                    
                    if([typeID isEqualToString: @"public.url"] == YES)
                    {
                        NSLog(@"public.url Item: %@", item);
                        NSString *itemString = [NSString stringWithFormat:@"%@", item];
                        NSString *trackId = [itemString stringByReplacingOccurrencesOfString:@"https://open.spotify.com/track/" withString:@""];
                        NSLog(@"Track ID: %@", trackId);
                        self.trackID = trackId;
                        
                        [TMBSpotifyShareExtensionAPIClient getAlbumCoverUrl:trackId withCompletionBlock:^(NSString *albumCoverLink) {
                            NSLog(@"ALBUMN COVER LINK: %@", albumCoverLink);
                        }];
                    }
                }];
            }
        }
    }
    
    
    
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    
    //    self.extensionContext.inputItems
    //
    //    UIWebView *wv = [UIWebView new];
    //    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"rar-spotify-test://"]];
    //    [wv loadRequest:req];
    //
    //    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}
@end
