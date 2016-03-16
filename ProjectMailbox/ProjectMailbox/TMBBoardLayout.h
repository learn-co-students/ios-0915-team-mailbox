//
//  RWTCollectionViewLayout.h
//  RWPinterest
//
//  Created by Joel Bell on 11/23/15.
//  Copyright © 2015 Joel Bell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMBBoardLayout : UICollectionViewLayout

@property (nonatomic) CGFloat cellPadding;
@property (nonatomic, strong) NSMutableDictionary *offsets;
@property (nonatomic, strong) NSMutableDictionary *layoutInformation;
@property (nonatomic) CGFloat contentWidth;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic) CGFloat xOffset;
@property (nonatomic) CGFloat yOffset;
@property (nonatomic) CGFloat smallCellSizeWidth;
@property (nonatomic) CGFloat smallCellSizeHeight;
@property (nonatomic) CGFloat largeCellSizeWidth;
@property (nonatomic) CGFloat largeCellSizeHeight;
@property (nonatomic) UIEdgeInsets insets;

-(CGFloat)width;
-(CGFloat)height;
-(UIEdgeInsets)insets;
-(CGSize)collectionViewContentSize;
-(void)prepareLayout;
-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect;
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds;
-(void)generateLayoutInfo:(NSInteger)item indexPath:(NSIndexPath *)path;
-(void)calculateOffsets:(NSInteger)item;
-(CGRect)buildFrame:(NSInteger)item;

@end
