//
//  PaperFeedViewController.h
//  ParseStarterProject
//
//  Created by Q on 3/22/14.
//
//

#import <UIKit/UIKit.h>

@interface PaperFeedViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *galleryImages;
@property (nonatomic, readonly, getter=isFullscreen) BOOL fullscreen;
@property (nonatomic, readonly, getter=isTransitioning) BOOL transitioning;


@end
