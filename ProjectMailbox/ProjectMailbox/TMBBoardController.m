//
//  RWTCollectionViewController.m
//  RWPinterest
//
//  Created by Joel Bell on 11/23/15.
//  Copyright © 2015 Joel Bell. All rights reserved.
//

#import "TMBBoardController.h"
#import "TMBBoardCell.h"
#import "Parse/Parse.h"
#import "TMBImageCardViewController.h"
#import "TMBSharedBoardID.h"
#import "SpotifyTrack.h"
#import "SpotifyTrackView.h"

//#import "TMBSharedBoard.h" joel copy over - singleton not set up

// drawer controller
#import <MMDrawerController/MMDrawerVisualState.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import <MMDrawerController/MMDrawerController.h>
#import <MMDrawerController/MMDrawerBarButtonItem.h>


static NSInteger const kNumberOfSections = 1;
static NSInteger const kItemsPerPage = 20;

@interface TMBBoardController () <TMBImageCardViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *boardContent;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSString *queriedBoardID;
@property (nonatomic, strong) NSMutableArray *collection;
@property (nonatomic) NSUInteger queryCount;

@property (nonatomic, strong) NSString *boardID;
@property (nonatomic, strong) NSMutableArray *boardIDs;

@end

@implementation TMBBoardController

static NSString * const reuseIdentifier = @"MediaCell";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.boardID = [TMBSharedBoardID sharedBoardID].boardID;
    self.boardIDs = [TMBSharedBoardID sharedBoardID].boardIDs;
    
    NSLog(@"\n\nself.boardID: %@\nself.boardIDs:\n%@\n\n",self.boardID,self.boardIDs);
    
    [self setupLeftMenuButton];

    
    self.collection = [NSMutableArray new];
    self.boardContent = [NSMutableArray new];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5);
    
    [self buildThemeColorsArray];
    [self prepareAndExecuteParseQuery];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)imageCardViewController:(TMBImageCardViewController *)viewController didScaleThumbImage:(UIImage *)image
{
    [self.collection addObject:image];
    [self.collectionView reloadData];
}

-(void)prepareAndExecuteParseQuery
{
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
        [boardQuery whereKey:@"fromUser" equalTo:PFUser.currentUser];
        [boardQuery selectKeys:@[@"objectId"]];
        [boardQuery orderByDescending:@"lastViewed"];
        // if board selected from drawer menu
        
            // query board based on drawer menu choice
            // [self queryParseToUpdateCollection];
        
        // else //
        
        
            [boardQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                self.queriedBoardID = [object valueForKey:@"objectId"];
                NSLog(@"\n\nself.queriedBoardID: %@\n\n",self.queriedBoardID);
                [self queryParseToUpdateCollection];
                
            }];
        
        //
        
    } else {
        // if user is not logged in, need to go back to login screen
        NSLog(@"\n\nnot current user\ngo back to login screen\n\n");
    }
}



-(void)queryParseToUpdateCollection
{
    
    if ([self.queriedBoardID length] == 0) {
        
        return;
        
    } else {
        
        PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
        [boardQuery whereKey:@"objectId" equalTo:self.queriedBoardID];
        
        PFQuery *contentQuery = [PFQuery queryWithClassName:@"Photo"];
        [contentQuery whereKey:@"board" matchesQuery:boardQuery];
        [contentQuery orderByDescending:@"updatedAt"];
        
        [contentQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
            if (number == 0) {
                return;
            } else {
                [contentQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

                    if (!error) {
                        for (PFObject *object in objects) {
                            if(object[@"trackTitle"]) {
                                //initialize custom spotify cell
                            }
                            
                            PFFile *imageFile = object[@"thumbnail"];
                            [self.boardContent addObject:imageFile];
                        
                        }
                        
                        NSOperationQueue *dataQueue = [[NSOperationQueue alloc] init];
                        [dataQueue addOperationWithBlock:^{
                            
                            for (PFFile *imageFile in self.boardContent) {
                                
                                NSData *data = [imageFile getData];
                                UIImage *image = [UIImage imageWithData:data];
                                NSLog(@"image: %@",image);
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                    
                                    [self.collection addObject:image];
                                    NSUInteger imageFileIndex = [self.collection indexOfObject:image];
                                    
                                    if (imageFileIndex < kItemsPerPage){
                                        NSIndexPath *ip = [NSIndexPath indexPathForItem:imageFileIndex inSection:0];
                                        [self.collectionView reloadItemsAtIndexPaths:@[ip]];
                                    }else{
                                        [self.collectionView reloadData];
                                    }
                                    
                                }];
                            }
                            [self.boardContent removeAllObjects];
                            
                        }];
                        
                    } else {
                        
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                    }
                }];
            }
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return kNumberOfSections;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSUInteger neededColorCells = kItemsPerPage - (self.collection.count % kItemsPerPage);
    
    if(self.collection.count != 0 && neededColorCells == kItemsPerPage) {
        neededColorCells = 0;
    }
    
    return self.collection.count + neededColorCells;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TMBBoardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if(indexPath.row < self.collection.count) {
        cell.imageView.image = self.collection[indexPath.row];
        cell.backgroundColor = nil;
        
        
    }
    else {
        cell.imageView.image = nil;
        cell.backgroundColor = [self colorForDummyCellAtRow:indexPath.row];
    }
    
    return cell;
}


-(UIColor *)colorForDummyCellAtRow:(NSUInteger)row
{
    NSUInteger colorIndex = row % self.colors.count;
    return self.colors[colorIndex];
}


-(void)buildThemeColorsArray
{
    
    UIColor *c1 = [UIColor colorWithRed:0.349 green:0.573 blue:0.784 alpha:1]; /*#5992c8*/
    UIColor *c2 = [UIColor colorWithRed:0.565 green:0.725 blue:0.835 alpha:1]; /*#90b9d5*/
    UIColor *c3 = [UIColor colorWithRed:0.945 green:0.443 blue:0.475 alpha:1]; /*#f17179*/
    UIColor *c4 = [UIColor colorWithRed:0.78 green:0.451 blue:0.243 alpha:1]; /*#c7733e*/
    UIColor *c5 = [UIColor colorWithRed:0.863 green:0.341 blue:0.2 alpha:1]; /*#dc5733*/
    
    self.colors = @[c1, c2, c3, c4, c5];
    
}

// added by Tim - necessary ? ? ?
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TMBImageCardViewController *destinationVC = segue.destinationViewController;
    destinationVC.delegate = self;
}

- (IBAction)addButtonTapped:(id)sender {
    
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"Add to your Mosaic"
                                 message:@"Select your choice"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* picture = [UIAlertAction
                              actionWithTitle:@"Picture"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  UIViewController *pictureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TMBImageCardViewController"];
                                  
                                  [self presentViewController:pictureVC animated:YES completion:nil];
                                  
                                  [view dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];
    
    UIAlertAction* text = [UIAlertAction
                           actionWithTitle:@"Text"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               UIViewController *textVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TMBTextCardViewController"];
                               
                               [self presentViewController:textVC animated:YES completion:nil];
                               
                               [view dismissViewControllerAnimated:YES completion:nil];
                               
                           }];
    
    UIAlertAction* doodle = [UIAlertAction
                             actionWithTitle:@"Doodle"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 UIViewController *doodleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TMBDoodleViewController"];
                                 
                                 [self presentViewController:doodleVC animated:YES completion:nil];
                                 
                                        [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
       NSLogPageSize()      4[k
    f]p2l4tUIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    //maybe add a Spotify link or an option to open the Spotify
    
    [view addAction:picture];
    [view addAction:text];
    [view addAction:doodle];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
    
}




@end
