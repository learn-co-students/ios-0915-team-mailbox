
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
#import "TMBDoodleViewController.h"
#import <MMDrawerController/MMDrawerVisualState.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import <MMDrawerController/MMDrawerController.h>
#import <MMDrawerController/MMDrawerBarButtonItem.h>


static NSInteger const kNumberOfSections = 1;
static NSInteger const kItemsPerPage = 20;


@interface TMBBoardController () <TMBImageCardViewControllerDelegate, TMBDoodleViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *boardContent;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSString *queriedBoardID;
@property (nonatomic, strong) NSMutableArray *collection;
@property (nonatomic) NSUInteger queryCount;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIImage *imageSelectedForOtherView;
@property (nonatomic, strong) NSMutableArray *pfObjects;
@property (nonatomic, strong) NSString *boardName;
@property (nonatomic, strong) UINavigationBar *navigationBar;

@end


@implementation TMBBoardController

static NSString * const reuseIdentifier = @"MediaCell";


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSLog(@" I'M IN THE VIEW WILL APPEAR, BOARD CONTROLLER");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetButtonTappedInCreateBoardVC:) name:@"UserTappedResetBoardButton" object:nil];
}


- (void)viewDidLoad {

    NSLog(@" I'M IN THE VIEW DID LOAD, BOARD CONTROLLER");

    [super viewDidLoad];
    
    self.navigationBar = self.navigationController.navigationBar;
    [self.navigationBar setBarTintColor:[UIColor colorWithRed:40/255.0 green:58/255.0 blue:103/255.0 alpha:1.0]];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationBar.translucent = NO;
  
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                 NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:15.0]};
    [self.navigationBar setTitleTextAttributes:titleAttributes];
    [self.navigationBar setTitleVerticalPositionAdjustment:5.0 forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.topItem.title = @"";
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0);
    
    self.boardID = [TMBSharedBoardID sharedBoardID].boardID;
    
    [self setupLeftMenuButton];
    
    self.pfObjects = [NSMutableArray new];
    self.collection = [NSMutableArray new];
    self.boardContent = [NSMutableArray new];
    [self buildThemeColorsArray];
    [self buildEmptyCollection];
    
    [self queryParseForContent:self.boardID];
    
    [self queryAndSetBoardNameForNavigationTitle:self.boardID];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boardSelectedInSideMenu:) name:@"UserSelectedABoard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newBoardCretedInCreateBoardVC:) name:@"NewBoardCreatedInCreateBoardVC" object:nil];
    
}


- (void)newBoardCretedInCreateBoardVC:(NSNotification *)notification {
 
    if ([notification.object isKindOfClass:[PFObject class]]) {

    PFObject *newBoard = [notification object];
    NSString *boardID = [newBoard valueForKey:@"objectId"];
        
    [TMBSharedBoardID sharedBoardID].boardID = newBoard.objectId;
    [[TMBSharedBoardID sharedBoardID].boards setObject:newBoard forKey:boardID];
        
    [self.collection removeAllObjects];
    [self buildThemeColorsArray];
    [self buildEmptyCollection];

    [self queryParseForContent:newBoard.objectId];
        
    NSLog(@" WOO I GOT THE MESSAGE! SWITCHED OUT BOARD! BOARD OBJ ID IS: %@. BOARD NAME IS: %@", notification, newBoard[@"boardName"]);
    }
    
    else {
        NSLog(@"Error, object not recognised.");

    }

}

    
- (void)boardSelectedInSideMenu:(NSNotification *)notification {
    
    NSLog(@" WOO I GOT THE MESSAGE! I'M IN THE boardSelectedInSideMenu METHOD, BOARD CONTROLLER. NOTIFICATION: %@", notification);
    
    if ([notification.object isKindOfClass:[PFObject class]]) {
        PFObject *passedBoard = [notification object];
        NSString *boardID = [passedBoard valueForKey:@"objectId"];
        
        [TMBSharedBoardID sharedBoardID].boardID = passedBoard.objectId;
        [[TMBSharedBoardID sharedBoardID].boards setObject:passedBoard forKey:boardID];
        [self queryParseForContent:passedBoard.objectId];
        
        NSLog(@" WOO I GOT THE MESSAGE! SWITCHED OUT BOARD! BOARD OBJ ID IS: %@. BOARD NAME IS: %@", notification, passedBoard[@"boardName"]);
    }
    
    else {
        NSLog(@"Error, object not recognised.");
    }
    
}


- (void)resetButtonTappedInCreateBoardVC:(NSNotification *)notification {
    
    [self.collection removeAllObjects];
    [self buildThemeColorsArray];
    [self buildEmptyCollection];
    
    PFObject *resetBoard = [notification object];
    [self queryParseForContent:resetBoard.objectId];
    
    NSLog(@" I'M IN THE resetButtonTappedInCreateBoardVC, BOARD CONTROLLER. BOARD ID IS: %@", resetBoard.objectId);
}



#pragma mark <UICollectionViewDataSource>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    NSLog(@" I'M IN THE numberOfSectionsInCollectionView, BOARD CONTROLLER. NUMBER OF SECTIONS: %lu", kNumberOfSections);
    return kNumberOfSections;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSLog(@" I'M IN THE collectionView, BOARD CONTROLLER. COLLECTION COUNT: %lu", self.collection.count);
    return self.collection.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@" I'M IN THE collectionView cellForItemAtIndexPath, BOARD CONTROLLER.");

    TMBBoardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([self.collection[indexPath.row] isKindOfClass:[UIImage class]]) {
        
        cell.boardImageView.image = self.collection[indexPath.row];
        
    } else if ([self.collection[indexPath.row] isKindOfClass:[PFFile class]]) {
        
        cell.boardImageView.image = [UIImage imageNamed:@"placeholderForBoardCell"];
        cell.boardImageView.file = (PFFile *)self.collection[indexPath.row];
        [cell.boardImageView loadInBackground:^(UIImage *image, NSError *error) {
            
            if (!error) {
                cell.boardImageView.alpha = 0.0;
                [UIView beginAnimations:@"fade in" context:nil];
                [UIView setAnimationDuration:1.0];
                cell.boardImageView.alpha = 1.0;
                [UIView commitAnimations];
            }
            
        }];
        
    }
    
    cell.backgroundColor = [self colorForDummyCellAtRow:indexPath.row];
    
    return cell;
}


- (void)buildEmptyCollection {
    
    NSLog(@" I'M IN THE buildEmptyCollection, BOARD CONTROLLER.");

    if (self.collection.count == 0) {
        for (int i = 0; i < kItemsPerPage; i++) {
            [self.collection addObject:[UIImage imageNamed:@"placeholderForBoardCell"]];
        }
    }
    
}


- (UIColor *)colorForDummyCellAtRow:(NSUInteger)row {
    
    NSLog(@" I'M IN THE colorForDummyCellAtRow, BOARD CONTROLLER.");

    NSUInteger colorIndex = row % self.colors.count;
    return self.colors[colorIndex];
}


- (void)buildThemeColorsArray {
    
    NSLog(@" I'M IN THE buildThemeColorsArray, BOARD CONTROLLER.");
    
    UIColor *c1 = [UIColor colorWithRed:40/255.0 green:58/255.0 blue:103/255.0 alpha:0.03];
    UIColor *c2 = [UIColor colorWithRed:40/255.0 green:58/255.0 blue:103/255.0 alpha:0.06];
    UIColor *c3 = [UIColor colorWithRed:40/255.0 green:58/255.0 blue:103/255.0 alpha:0.12];
    UIColor *c4 = [UIColor colorWithRed:40/255.0 green:58/255.0 blue:103/255.0 alpha:0.18];
    UIColor *c5 = [UIColor colorWithRed:40/255.0 green:58/255.0 blue:103/255.0 alpha:0.21];
    
    self.colors = @[c1, c2, c3, c4, c5, c4, c3, c5, c1, c3];
    
}



#pragma mark - side menu selection


- (void)setupLeftMenuButton {
    
    NSLog(@" I'M IN THE setupLeftMenuButton, BOARD CONTROLLER.");

    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}


- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    
    NSLog(@" I'M IN THE leftDrawerButtonPress, BOARD CONTROLLER.");

    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}



#pragma mark - alert and segue


- (IBAction)addButtonTapped:(id)sender {
    
    UIAlertController *view = [UIAlertController
                               alertControllerWithTitle:@"Add to your Mosaic"
                               message:@"Select your choice"
                               preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *picture = [UIAlertAction
                              actionWithTitle:@"Picture"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  TMBImageCardViewController *pictureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TMBImageCardViewController"];
                                  pictureVC.delegate = self;
                                  [self presentViewController:pictureVC animated:YES completion:nil];
                                  [view dismissViewControllerAnimated:YES completion:nil];
                              }];
    
    UIAlertAction *doodle = [UIAlertAction
                             actionWithTitle:@"Doodle"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 TMBDoodleViewController *doodleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TMBDoodleViewController"];
                                 doodleVC.delegate = self;
                                 [self presentViewController:doodleVC animated:YES completion:nil];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [view addAction:picture];
    [view addAction:doodle];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
    
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{

    NSLog(@" I'M IN THE shouldPerformSegueWithIdentifier, BOARD CONTROLLER.");

    NSArray *indexPathsOfSelectedCell = self.collectionView.indexPathsForSelectedItems;
    NSIndexPath *selectedIndexPath = indexPathsOfSelectedCell.firstObject;
    self.imageSelectedForOtherView = self.collection[selectedIndexPath.row];
    
    if (selectedIndexPath.row < self.pfObjects.count){
        return YES;
        
    } else {
        return NO;
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    TMBCommentViewController *destVC = segue.destinationViewController;
    NSArray *indexPathsOfSelectedCell = self.collectionView.indexPathsForSelectedItems;
    NSIndexPath *selectedIndexPath = indexPathsOfSelectedCell.firstObject;
    PFObject *selectedOBJ = self.pfObjects[selectedIndexPath.row];
    
    destVC.parseObjSelected = selectedOBJ;
    destVC.selectedFile = self.collection[selectedIndexPath.row];
    
    NSLog(@" I'M IN THE prepareForSegue, BOARD CONTROLLER. SELECTED OBJECT IS: %@", selectedOBJ);
    NSLog(@" I'M IN THE prepareForSegue, BOARD CONTROLLER. SELECTED FILE IS: %@", self.collection[selectedIndexPath.row]);
    
}



#pragma mark - queries


- (void)imageCardViewController:(TMBImageCardViewController *)viewController passBoardIDforQuery:(NSString *)boardID {
    
    NSLog(@" I'M IN THE imageCardViewController, BOARD CONTROLLER.");

    NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    [self queryParseForContent:boardID];
}


- (void)doodleViewController:(TMBDoodleViewController *)viewController passBoardIDforQuery:(NSString *)boardID {
    
    NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    [self queryParseForContent:boardID];
}


- (void)queryAndSetBoardNameForNavigationTitle:(NSString *)boardID {
    
    NSLog(@" I'M IN THE queryAndSetBoardNameWithID");
    
    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"objectId" equalTo:boardID];
    [boardQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@" I'M IN THE queryAndSetBoardNameWithID findObjectsInBackgroundWithBlock, ERROR: %@", error);
        }
        
        if (!objects) {
            NSLog(@" I'M IN THE queryAndSetBoardNameWithID findObjectsInBackgroundWithBlock NO OBJECTS CAME BACK");
        }
        
        if (objects) {
            NSLog(@" I'M IN THE queryAndSetBoardNameWithID findObjectsInBackgroundWithBlock OBJECTS CAME BACK: %@", objects);
            for (PFObject *board in objects) {
                NSString *returnedBoardName = [board valueForKey:@"boardName"];
                self.navigationBar.topItem.title = returnedBoardName;
                
                NSLog(@" I'M IN THE queryAndSetBoardNameWithID findObjectsInBackgroundWithBlock, BOARD CONTROLLER. BOARD OBJ: %@", board);
                NSLog(@" I'M IN THE queryAndSetBoardNameWithID findObjectsInBackgroundWithBlock, BOARD CONTROLLER. BOARD TITLE: %@", returnedBoardName);
                NSLog(@" I'M IN THE queryAndSetBoardNameWithID findObjectsInBackgroundWithBlock, BOARD CONTROLLER. NAV TITLE: %@", self.navigationBar.topItem.title);
            }
        }
    }];
    
}


- (void)queryParseForContent:(NSString *)boardID {
    
    NSLog(@" I'M IN THE QUERY PARSE FOR CONTENT METHOD, BOARD CONTROLLER");

    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"objectId" equalTo:boardID];
    [boardQuery includeKey:@"boardName"];
    
    PFQuery *contentQuery = [PFQuery queryWithClassName:@"Photo"];
    [contentQuery whereKey:@"board" matchesQuery:boardQuery];
    [contentQuery orderByDescending:@"updatedAt"];
    [contentQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (self.pfObjects.count > 0) {
            [self.pfObjects removeAllObjects];
        }
        
        if (objects.count > kItemsPerPage) {
            
            NSUInteger totalItems;
            NSUInteger numberOfDummyItemsForUpdate;
            
            if ((objects.count % 20) == 0) {
                totalItems = objects.count;
            } else {
                totalItems = objects.count + (kItemsPerPage - (objects.count % kItemsPerPage));
            }
            numberOfDummyItemsForUpdate = totalItems - self.collection.count;
            
            for (int i = 0; i < numberOfDummyItemsForUpdate; i++) {
                [self.collection addObject:[UIImage imageNamed:@"placeholderForBoardCell"]];
            }
            
        }
        
        NSUInteger objectIndex = 0;
        for (PFObject *object in objects) {
            
            PFFile *imageFile = object[@"thumbnail"];
            
            if (imageFile) {
                [self.collection replaceObjectAtIndex:objectIndex withObject:imageFile];
                [self.pfObjects addObject:object];
            }
            objectIndex++;
        }
        
        [self.collectionView reloadData];
        
    }];
    
    
}




@end


