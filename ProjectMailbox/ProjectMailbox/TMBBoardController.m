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
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIImage *imageSelectedForOtherView;
@property (nonatomic, strong) NSMutableArray *pfObjects;

@end

@implementation TMBBoardController

static NSString * const reuseIdentifier = @"MediaCell";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.pfObjects = [NSMutableArray new];
    
    //    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@""]];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    self.boardID = [TMBSharedBoardID sharedBoardID].boardID;
    
    [self setupLeftMenuButton];
    
    self.collection = [NSMutableArray new];
    self.boardContent = [NSMutableArray new];
    
    [self buildThemeColorsArray];
    
    [self queryParseToUpdateCollection:self.boardID successBlock:^(BOOL success){
        
        if (success)  {
            
            NSLog(@"\n\n EVERYTHING IS COOL! \n\n");
        }
        
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -110 && ![self.refreshControl isRefreshing]) {
        [self.refreshControl beginRefreshing];
        [self.collection removeAllObjects];
        [self refresh];
        
    }
}

- (void)refresh
{
    NSLog(@"entered refresh");
    
    [self queryParseToUpdateCollection:self.boardID successBlock:^(BOOL success) {
        
        if (success) {
            
            [self.refreshControl endRefreshing];
        }
        
    }];
    
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)imageCardViewController:(TMBImageCardViewController *)viewController thumbForInstantView:(UIImage *)image {

    NSLog(@"\n\n\n\nimageCard delegate method called\n\n\n\n");
    [self.collection addObject:image];
    [self.collectionView reloadData];
}

-(void)queryParseToUpdateCollection:(NSString *)boardID successBlock:(void (^)(BOOL success))completionBlock
{
    
    NSLog(@"Query parse started \n\n\n");
    
    if ([self.boardID length] == 0) {
        
        // user does not have any boards
        // or need to query for board again
        completionBlock(NO);
        return;
        
    } else {
        
        PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
        [boardQuery whereKey:@"objectId" equalTo:self.boardID];
        
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
                            
                            PFFile *imageFile = object[@"thumbnail"];
                            [self.boardContent addObject:imageFile];
                            [self.pfObjects addObject:object];
                            
                        }
                        
                        NSOperationQueue *dataQueue = [[NSOperationQueue alloc] init];
                        [dataQueue addOperationWithBlock:^{
                            
                            [self.collection removeAllObjects];
                            
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
                            completionBlock(YES);
                        }];
                        
                    } else {
                        
                        completionBlock(NO);
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
    
    UIColor *c1 = [UIColor colorWithRed:121/255.0 green:92/255.0 blue:150/255.0 alpha:1.0];
    UIColor *c2 = [UIColor colorWithRed:85/255.0 green:56/255.0 blue:106/255.0 alpha:1.0];
    UIColor *c3 = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    UIColor *c4 = [UIColor colorWithRed:189/255.0 green:170/255.0 blue:208/255.0 alpha:1.0];
    UIColor *c5 = [UIColor colorWithRed:188/255.0 green:103/255.0 blue:105/255.0 alpha:1.0];
    UIColor *c6 = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    UIColor *c7 = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    UIColor *c8 = [UIColor colorWithRed:85/255.0 green:56/255.0 blue:106/255.0 alpha:1.0];
    UIColor *c9 = [UIColor colorWithRed:188/255.0 green:103/255.0 blue:105/255.0 alpha:1.0];
    UIColor *c10 = [UIColor colorWithRed:85/255.0 green:56/255.0 blue:106/255.0 alpha:1.0];
    
    self.colors = @[c1, c2, c3, c4, c5, c6, c7, c8, c9, c10];
    
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
                                  TMBImageCardViewController *pictureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TMBImageCardViewController"];
                                  pictureVC.delegate = self;
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
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    
    [view addAction:picture];
    [view addAction:text];
    [view addAction:doodle];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        
    TMBCommentViewController *destVC = segue.destinationViewController;
//    TMBBoardCell *selectedCell = (TMBBoardCell *)sender;
    NSArray *indexPathsOfSelectedCell = self.collectionView.indexPathsForSelectedItems;
    NSIndexPath *selectedIndexPath = indexPathsOfSelectedCell.firstObject;
    self.imageSelectedForOtherView = self.collection[selectedIndexPath.row];
    PFObject *selectedOBJ = self.pfObjects[selectedIndexPath.row];
    
    destVC.parseObjSelected = selectedOBJ;
    
    destVC.selectedImage = self.imageSelectedForOtherView;
}

@end