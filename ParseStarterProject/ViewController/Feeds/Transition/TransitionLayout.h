//
//  TransitionLayout.h
//  ParseStarterProject
//
//  Created by Q on 3/22/14.
//
//

#import <UIKit/UIKit.h>

@interface TransitionLayout : UICollectionViewTransitionLayout
@property (nonatomic) UIOffset offset;
@property (nonatomic) CGFloat progress;
@property (nonatomic) CGSize itemSize;
@end
