//
//  RWTCollectionViewLayout.m
//  RWPinterest
//
//  Created by Joel Bell on 11/23/15.
//  Copyright © 2015 Joel Bell. All rights reserved.
//

#import "TMBBoardLayout.h"

static NSInteger const kSectionNumber = 0;
static NSInteger const kItemsPerPage = 20;
static NSInteger const kItemsPerPattern = 10;

@interface TMBBoardLayout()

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


@end


@implementation TMBBoardLayout

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    NSLog(@"\n\ninit TMBBoardLayout\n\n");
    self = [super initWithCoder:aDecoder];
    if (self)  {
        _contentWidth = 0;
        _cellPadding = 1;
        _layoutInformation = [NSMutableDictionary dictionary];
        _offsets = [NSMutableDictionary dictionaryWithDictionary:@{
                       @"xOffset" : [NSNumber numberWithFloat:0.0],
                       @"yOffset" : [NSNumber numberWithFloat:0.0]
                   }];
        
        
    }
    return self;
}

// getter convenience methods
-(CGFloat)width
{
    return self.collectionView.bounds.size.width - (self.insets.left + self.insets.right);
}

-(CGFloat)height
{
    return self.collectionView.bounds.size.height - (self.insets.top + self.insets.bottom);
}

-(UIEdgeInsets)insets
{
    return self.collectionView.contentInset;
}

-(CGSize)collectionViewContentSize
{
    return CGSizeMake(self.contentWidth, self.height);
}

-(void)prepareLayout
{

    NSInteger itemsCount = [self.collectionView numberOfItemsInSection:kSectionNumber];
    
    self.smallCellSizeWidth = self.width / 4;
    self.smallCellSizeHeight = self.height / 8;
    self.largeCellSizeWidth = self.width / 2;
    self.largeCellSizeHeight = self.height / 4;

    if (self.layoutInformation.count == 0) {

        for (NSInteger item = 0; item < itemsCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:kSectionNumber];
            
            [self generateLayoutInfo:item indexPath:indexPath];
            
        }
        
    } else {

        NSInteger itemIndex = self.layoutInformation.count;
        
        for (NSInteger item = itemIndex; item < itemsCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:kSectionNumber];
            
            [self generateLayoutInfo:item indexPath:indexPath];
            
        }
        
    }
    
}



-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{

    NSMutableArray *layoutAttributes = [NSMutableArray arrayWithCapacity:self.layoutInformation.count];
    
    for (NSIndexPath *path in self.layoutInformation) {
    
        UICollectionViewLayoutAttributes *attributes = [self.layoutInformation objectForKey:path];
        
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [layoutAttributes addObject:attributes];
        }
        
        
    }
    
    return layoutAttributes;
    
    
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    attr.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.2, 0.2), M_PI);
    attr.center = CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMaxY(self.collectionView.bounds));
    
    return attr;
}

-(void)generateLayoutInfo:(NSInteger)item indexPath:(NSIndexPath *)path
{
    [self calculateOffsets:item];
    CGRect frame = [self buildFrame:item];
    CGRect insetFrame = CGRectInset(frame, self.cellPadding, self.cellPadding);
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    attributes.frame = insetFrame;
    [self.layoutInformation setObject:attributes forKey:path];
    if (item % kItemsPerPage < 3) {
        self.contentWidth = CGRectGetMaxX(frame);
    }
    
}

-(void)calculateOffsets:(NSInteger)item
{
    
    self.xOffset = [[self.offsets objectForKey:@"xOffset"] floatValue];
    self.yOffset = [[self.offsets objectForKey:@"yOffset"] floatValue];
    
    NSInteger patternItem = item % kItemsPerPattern;
    NSInteger pageItem = item % kItemsPerPage;
    
    if (item == 0)
    {
        self.xOffset = 0;
        self.yOffset = 0;
    }
    else if (pageItem == 0 && item > 1)
    {
        self.xOffset = self.xOffset + self.smallCellSizeWidth;
        self.yOffset = 0;
    }
    else
    {
        switch (patternItem) {
            case 0 :
                self.xOffset = self.xOffset - (self.largeCellSizeWidth + self.smallCellSizeWidth);
                self.yOffset = self.yOffset + self.smallCellSizeHeight;
                break;
            case 1 :
                self.xOffset = self.xOffset + self.largeCellSizeWidth;
                // yOffset remains at current value
                break;
            case 2 :
                self.xOffset = self.xOffset + self.smallCellSizeWidth;
                // yOffset remains at current value
                break;
            case 3 :
                self.xOffset = self.xOffset - self.smallCellSizeWidth;
                self.yOffset = self.yOffset + self.smallCellSizeHeight;
                break;
            case 4 :
                self.xOffset = self.xOffset - self.largeCellSizeWidth;
                self.yOffset = self.yOffset + self.smallCellSizeHeight;
                break;
            case 5 :
                self.xOffset = self.xOffset + self.smallCellSizeWidth;
                // yOffset remains at current value
                break;
            case 6 :
                self.xOffset = self.xOffset - self.smallCellSizeWidth;
                self.yOffset = self.yOffset + self.smallCellSizeHeight;
                break;
            case 7 :
                self.xOffset = self.xOffset + self.smallCellSizeWidth;
                // yOffset remains at current value
                break;
            case 8 :
                self.xOffset = self.xOffset + self.smallCellSizeWidth;
                // yOffset remains at current value
                break;
            case 9 :
                self.xOffset = self.xOffset + self.smallCellSizeWidth;
                // yOffset remains at current value
                break;
            default :
                break;
        }
        
    }
    
    [self.offsets setObject:[NSNumber numberWithFloat:self.xOffset] forKey:@"xOffset"];
    [self.offsets setObject:[NSNumber numberWithFloat:self.yOffset] forKey:@"yOffset"];
}

-(CGRect)buildFrame:(NSInteger)item
{
    NSInteger patternItem = item % kItemsPerPattern;
    CGRect frame;
    
    if (patternItem == 0 || patternItem == 3) {
        frame = CGRectMake(self.xOffset, self.yOffset, self.largeCellSizeWidth, self.largeCellSizeHeight);
    } else {
        frame = CGRectMake(self.xOffset, self.yOffset, self.smallCellSizeWidth, self.smallCellSizeHeight);
    }

    return frame;
}





@end
