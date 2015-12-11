//
//  ShareViewController.m
//  TMBSpotifyShareExtension
//
//  Created by Jimena Almendares on 11/23/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

#import "ShareViewController.h"
#import "TMBSpotifyShareExtensionAPIClient.h"
#import "ShareTableViewController.h"
#import <Parse/Parse.h>


@interface ShareViewController () <ShareTableViewControllerDelegate>

@property(strong, nonatomic) NSString *trackID;
@property(strong, nonatomic) NSMutableArray *boardsArray;
@property(strong, nonatomic) PFObject *currentBoard;
@property(strong, nonatomic) PFUser *currentUser;

@property (nonatomic, weak) SLComposeSheetConfigurationItem *boardConfigItem;

@end

@implementation ShareViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize Parse.
    [Parse enableDataSharingWithApplicationGroupIdentifier:@"group.com.flatironschool.mosaic"
                                     containingApplication:@"com.flatironschool.mosaic"];
    
    [Parse enableLocalDatastore];
    
    [Parse setApplicationId:@"rQDnUltUD2fr1WN4XK1Dc8K3isG2ebpVeX1pLOF6"
                  clientKey:@"ivu9n1BAvIFtH9Kcu9s9aBuY7Tq3Ue8gNnjOGHq6"];
    
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    NSLog(@"Content: %@", self.contentText);

    
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
                        
                        self.trackID = trackId;
                        NSLog(@"Track ID: %@", trackId);
                      
                        
                        [TMBSpotifyShareExtensionAPIClient getAlbumCoverUrl:trackId withCompletionBlock:^(NSString *albumCoverLink, NSString *trackTitle) {

                        
                            PFObject *newSongPhoto = [PFObject objectWithClassName:@"Photo"];
                            NSLog(@"TrackID: %@",self.trackID);
                            newSongPhoto[@"TrackID"] = self.trackID;
                            
                            NSLog(@"TrackTitle: %@",trackTitle);
                            newSongPhoto[@"TrackTitle"] = trackTitle;
                            
                            NSLog(@"AlbumCoverURL: %@",albumCoverLink);
                            newSongPhoto[@"AlbumCoverURL"] = albumCoverLink;
                            
                            NSLog(@"currentBoard: %@", self.currentBoard);
                            newSongPhoto[@"board"] = self.currentBoard;
                            
                            NSLog(@"user: %@", self.currentUser);
                            newSongPhoto[@"user"] = self.currentUser;
                            
                            [newSongPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                NSLog(@"YAY!!!");
                            }];
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


- (void)queryAllBoardsForUser:(PFUser *)user completion:(void(^)(NSArray *boards, NSError *error))completionBlock
{
    // this query currently searches ONLY for boards CREATED BY USER!!! Update when users relatioships are finalized
   
    NSLog(@" ..... BEFORE PARSE CALL ..... ");
    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"fromUser" equalTo:user];
    
    [boardQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable boards, NSError * _Nullable error) {
        
        NSLog(@" ..... INSIDE PARSE CALL: %lu boards came back",boards.count);
    
    
        
        completionBlock(boards, error);
        
    }];
    
    NSLog(@" ..... AFTER PARSE CALL ..... ");
    
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    
    PFUser *user = [PFUser currentUser];
    self.currentUser = user;
    NSLog(@"%@", self.currentUser);
    
    SLComposeSheetConfigurationItem *boardItem = [[SLComposeSheetConfigurationItem alloc] init];
    
    boardItem.title = @"Loading boards...";
    boardItem.valuePending = YES;
    
    // query parse for boards belonging to the user
    // when that query comes back, set valuePending on the configuration item to NO
    // and then we'll have to make a baby VC or something for board selection
    // for now an option would be to just use the first board and make sure the posting stuff works.
    
    __weak SLComposeSheetConfigurationItem *weakConfigItem = boardItem;
    __weak ShareViewController *weakSelf = self;
    self.boardConfigItem = boardItem;
    
    [self queryAllBoardsForUser:user completion:^(NSArray *boards, NSError *error) {
        
        if (!error) {
            weakSelf.boardsArray = [boards mutableCopy];
            NSLog(@"Boards Array: %@", boards);
            
            weakConfigItem.valuePending = NO;
            weakConfigItem.title = boards.firstObject[@"boardName"];
            weakSelf.currentBoard = boards.firstObject;
        }
    }];

    
    boardItem.tapHandler = ^{
        
        if(!weakSelf.boardsArray) {
            return;
        }
        
        ShareTableViewController *boardsVC = [[ShareTableViewController alloc] init];
//        boardsVC.view.backgroundColor = [UIColor yellowColor];
        boardsVC.boardsArray = weakSelf.boardsArray;
        boardsVC.delegate = weakSelf;
        
        [weakSelf.navigationController pushViewController:boardsVC animated:YES];
        
        //        ShareTableViewController *dummyVC = [[ShareTableViewController alloc] init];
//        dummyVC.view.backgroundColor = [UIColor redColor];
//        [self.navigationController pushViewController:dummyVC animated:YES];
        

    };
    
    return @[ boardItem ];
}

-(void)shareTableViewController:(ShareTableViewController *)tableViewController didSelectBoard:(PFObject *)board
{
    self.currentBoard = board;
    [self.navigationController popViewControllerAnimated:YES];
    self.boardConfigItem.title = board[@"boardName"];
}

@end
