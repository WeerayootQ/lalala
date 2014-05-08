//
//  MainCollectionViewController.m
//  ParseStarterProject
//
//  Created by Q on 3/22/14.
//
//

#import "MainCollectionViewController.h"
#import "TransitionLayout.h"
#import "SmallCollectionCell.h"
#import "LargeCollectionCell.h"
#import "CollectionViewLargeLayout.h"
#import "CollectionViewSmallLayout.h"
#import "SmallCollectionViewController.h"
#import "ParseStarterProjectAppDelegate.h"

#define MAX_COUNT 3
#define CELL_ID @"CELL_ID"
static NSString * const SmallCellIdentifier = @"SmallCell";
static NSString * const LargeCellIdentifier = @"LargeCell";

@interface MainCollectionViewController ()
{
    BOOL isLarge;
}
@end

@implementation MainCollectionViewController

- (id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    if (self = [super initWithCollectionViewLayout:layout])
    {
        [self.collectionView registerClass:[SmallCollectionCell class] forCellWithReuseIdentifier:CELL_ID];
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

#pragma mark - Hide StatusBar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"layout : %@", collectionView.collectionViewLayout);

    PFObject *obj = self.dataSourceArray[indexPath.row];
    SmallCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    cell.feedObj = obj;
//    cell.layer.cornerRadius = 4;
//    cell.clipsToBounds = YES;
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
//    [self configureCollectionCell:cell forRowAtIndexPath:indexPath];
    return cell;
}


//- (void)configureCollectionCell:(UICollectionViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    PFObject *obj = self.dataSourceArray[indexPath.row];
//    PFUser *user = obj[@"feed_by"];
//    PFFile *file = user[@"userImage"];
//
//
//    UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
//    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, cell.contentView.frame.size.width - 20, cell.contentView.frame.size.height - 55)];
//    UILabel *userContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, cell.contentView.frame.size.width - 20, cell.contentView.frame.size.height - 90)];
//    userImageView.contentMode = UIViewContentModeScaleAspectFill;
//    userImageView.clipsToBounds = YES;
//    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        if (!error)
//        {
//            UIImage *image = [UIImage imageWithData:data];
//            userImageView.image = image;
//        }
//    }];
//
//    usernameLabel.text = user.username;;
//    userContentLabel.text = obj[@"feed_msg"];
//    
//    [usernameLabel sizeToFit];
//    [userContentLabel sizeToFit];
//    [userImageView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//    [usernameLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//    [userContentLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//    
//    [cell.contentView addSubview:userImageView];
//    [cell.contentView addSubview:usernameLabel];
//    [cell.contentView addSubview:userContentLabel];
//    cell.backgroundColor = [UIColor whiteColor];
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (UICollectionViewController*)nextViewControllerAtPoint:(CGPoint)point
{
    return nil;
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView
                        transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout
                                           newLayout:(UICollectionViewLayout *)toLayout
{
    NSLog(@"FROM : %@", fromLayout);
    NSLog(@"TO : %@", toLayout);
    TransitionLayout *transitionLayout = [[TransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    return transitionLayout;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Adjust scrollView decelerationRate
    self.collectionView.decelerationRate = self.class != [MainCollectionViewController class] ? UIScrollViewDecelerationRateNormal : UIScrollViewDecelerationRateFast;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
