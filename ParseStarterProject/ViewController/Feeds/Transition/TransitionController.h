//
//  TransitionController.h
//  ParseStarterProject
//
//  Created by Q on 3/22/14.
//
//

#import <Foundation/Foundation.h>

@protocol TransitionControllerDelegate <NSObject>
- (void)interactionBeganAtPoint:(CGPoint)point;
@end

@interface TransitionController : NSObject  <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIGestureRecognizerDelegate>

@property (nonatomic) id <TransitionControllerDelegate> delegate;
@property (nonatomic) BOOL hasActiveInteraction;
@property (nonatomic) UINavigationControllerOperation navigationOperation;
@property (nonatomic) UICollectionView *collectionView;

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView;

@end
