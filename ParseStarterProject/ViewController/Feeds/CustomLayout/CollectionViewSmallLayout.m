//
//  CollectionViewSmallLayout.m
//  ParseStarterProject
//
//  Created by Q on 3/22/14.
//
//

#import "CollectionViewSmallLayout.h"

@implementation CollectionViewSmallLayout

- (id)init
{
    if (!(self = [super init])) return nil;
    
    self.itemSize = CGSizeMake(146, 254);
    self.sectionInset = UIEdgeInsetsMake((iPhone5 ? 314 : 224), 2, 0, 2);
    self.minimumInteritemSpacing = 10.0f;
    self.minimumLineSpacing = 2.0f;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return NO;
}

@end
