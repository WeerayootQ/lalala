//
//  PaperFeedViewController.m
//  ParseStarterProject
//
//  Created by Q on 3/22/14.
//
//

#import "PaperFeedViewController.h"
#import "CollectionViewSmallLayout.h"
#import "CollectionViewLargeLayout.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"
#import "ParseStarterProjectAppDelegate.h"
#import "GHWalkThroughView.h"

static NSString * const sampleDesc1 = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque tincidunt laoreet diam, id suscipit ipsum sagittis a. ";

static NSString * const sampleDesc2 = @" Suspendisse et ultricies sem. Morbi libero dolor, dictum eget aliquam quis, blandit accumsan neque. Vivamus lacus justo, viverra non dolor nec, lobortis luctus risus.";

static NSString * const sampleDesc3 = @"In interdum scelerisque sem a convallis. Quisque vehicula a mi eu egestas. Nam semper sagittis augue, in convallis metus";

static NSString * const sampleDesc4 = @"Praesent ornare consectetur elit, in fringilla ipsum blandit sed. Nam elementum, sem sit amet convallis dictum, risus metus faucibus augue, nec consectetur tortor mauris ac purus.";

static NSString * const sampleDesc5 = @"Sed rhoncus arcu nisl, in ultrices mi egestas eget. Etiam facilisis turpis eget ipsum tempus, nec ultricies dui sagittis. Quisque interdum ipsum vitae ante laoreet, id egestas ligula auctor";

#define FONT_SIZE 12.0f
#define kTransitionSpeed 0.02f
#define kLargeLayoutScale 2.5F

@interface PaperFeedViewController () <GHWalkThroughViewDataSource, UITableViewDelegate, UITableViewDataSource>
{
    M13ProgressHUD *HUD;
    UIView *menuView;
}
// For intro view.
@property (nonatomic, strong) GHWalkThroughView *ghView;
@property (nonatomic, strong) NSArray *descStrings;
@property (nonatomic, strong) UILabel *welcomeLabel;

@property (nonatomic, assign) NSInteger slide;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *topImage;
@property (nonatomic, strong) UIImageView *reflected;
@property (nonatomic, strong) CollectionViewLargeLayout *largeLayout;
@property (nonatomic, strong) CollectionViewSmallLayout *smallLayout;
@property (nonatomic, getter=isFullscreen) BOOL fullscreen;
@property (nonatomic, getter=isTransitioning) BOOL transitioning;
@property (nonatomic, assign) BOOL isZooming;
@property (nonatomic, assign) CGFloat lastScale;

//@property (strong, nonatomic) TLTransitionLayout *transitionLayout;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinch;
@property (nonatomic) CGFloat initialScale;


@end

@implementation PaperFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _galleryImages = @[@"Image", @"Image1", @"Image2", @"Image3", @"Image4"];
    _slide = 0;
    
    // Custom layouts
    _smallLayout = [[CollectionViewSmallLayout alloc] init];
    _largeLayout = [[CollectionViewLargeLayout alloc] init];
    
    _collectionView.collectionViewLayout = _smallLayout;
    _collectionView.clipsToBounds = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    
    // Init mainView
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mainView.clipsToBounds = YES;
    _mainView.layer.cornerRadius = 4;
    [self.view insertSubview:_mainView belowSubview:_collectionView];
    
    // ImageView on top
    _topImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    _reflected = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_topImage.bounds), 320, 320)];
    [_mainView addSubview:_topImage];
    [_mainView addSubview:_reflected];
    
    // Reflect imageView
    _reflected.transform = CGAffineTransformMakeScale(1.0, -1.0);
    
    
    // Gradient to top image
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _topImage.bounds;
    gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] CGColor],
                        (id)[[UIColor colorWithWhite:0 alpha:0] CGColor]];
    [_topImage.layer insertSublayer:gradient atIndex:0];
    
    
    // Gradient to reflected image
    CAGradientLayer *gradientReflected = [CAGradientLayer layer];
    gradientReflected.frame = _reflected.bounds;
    gradientReflected.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor],
                                 (id)[[UIColor colorWithWhite:0 alpha:0] CGColor]];
    [_reflected.layer insertSublayer:gradientReflected atIndex:0];
    
    
    // Content perfect pixel
    UIView *perfectPixelContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_topImage.bounds), 1)];
    perfectPixelContent.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    [_topImage addSubview:perfectPixelContent];
    
    
    // Label logo
    UILabel *logo = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 290, 0)];
    logo.backgroundColor = [UIColor clearColor];
    logo.textColor = [UIColor whiteColor];
    logo.font = [UIFont fontWithName:@"Helvetica-Bold" size:22];
    logo.text = @"Neightbor";
    [logo sizeToFit];
    // Label Shadow
    [logo setClipsToBounds:NO];
    [logo.layer setShadowOffset:CGSizeMake(0, 0)];
    [logo.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [logo.layer setShadowRadius:1.0];
    [logo.layer setShadowOpacity:0.6];
    [_mainView addSubview:logo];
    
    
    // Label Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, logo.frame.origin.y + CGRectGetHeight(logo.frame) + 8, 290, 0)];
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    title.text = @"Heberti Almeida";
    [title sizeToFit];
    // Label Shadow
    [title setClipsToBounds:NO];
    [title.layer setShadowOffset:CGSizeMake(0, 0)];
    [title.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [title.layer setShadowRadius:1.0];
    [title.layer setShadowOpacity:0.6];
    [_mainView addSubview:title];
    
    
    // Label SubTitle
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, title.frame.origin.y + CGRectGetHeight(title.frame), 290, 0)];
    subTitle.backgroundColor = [UIColor clearColor];
    subTitle.textColor = [UIColor whiteColor];
    subTitle.font = [UIFont fontWithName:@"Helvetica" size:13];
    subTitle.text = @"Lorem ipsum dolor sit amet, consectetuer adipiscing elit";
    subTitle.lineBreakMode = NSLineBreakByWordWrapping;
    subTitle.numberOfLines = 0;
    [subTitle sizeToFit];
    // Label Shadow
    [subTitle setClipsToBounds:NO];
    [subTitle.layer setShadowOffset:CGSizeMake(0, 0)];
    [subTitle.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [subTitle.layer setShadowRadius:1.0];
    [subTitle.layer setShadowOpacity:0.6];
    [_mainView addSubview:subTitle];
    
    
    // First Load
    [self changeSlide];
    
    // Loop gallery - fix loop: http://bynomial.com/blog/?p=67
    NSTimer *timer = [NSTimer timerWithTimeInterval:5.0f target:self selector:@selector(changeSlide) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    
    UISwipeGestureRecognizer *swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(handleSwipe:)];
    swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDownRecognizer];
    
    UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleSwipeUp:)];
    swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUpRecognizer];

    
    menuView = [[UIView alloc] initWithFrame:CGRectMake(0, -[[UIScreen mainScreen] bounds].size.height,
                                                        [[UIScreen mainScreen] bounds].size.width,
                                                        [[UIScreen mainScreen] bounds].size.height)];
    menuView.backgroundColor = [UIColor clearColor];
    
    UITableView *menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, menuView.frame.size.width, menuView.frame.size.height)
                                                              style:UITableViewStylePlain];
    menuTableView.delegate = self;
    menuTableView.dataSource = self;
    
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    postButton.backgroundColor = [UIColor clearColor];
    postButton.frame = CGRectMake(0, 178, [[UIScreen mainScreen] bounds].size.width, 114);
    [postButton addTarget:self action:@selector(addFeed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *dummy = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,
                                                                       [[UIScreen mainScreen] bounds].size.width,
                                                                       [[UIScreen mainScreen] bounds].size.height)];
    dummy.image = [UIImage imageNamed:@"IMG_4226.PNG"];
    dummy.userInteractionEnabled = YES;
    dummy.backgroundColor = [UIColor clearColor];
    [dummy addSubview:postButton];
    [dummy addSubview:menuTableView];
    [menuView addSubview:dummy];
    
    [self.view addSubview:menuView];
    [self.view bringSubviewToFront:menuView];
}


#pragma mark - Hide StatusBar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark - UIPinchGestureRecognizer
- (void)didReceivePinchGesture:(UIPinchGestureRecognizer*)gesture
{
    NSLog(@"scale %f", gesture.scale);
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 4;
    
    //    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleFingerTap:)];
    //    twoFingerTap.numberOfTouchesRequired = 2;
    //    [cell addGestureRecognizer:twoFingerTap];
    
    UIImageView *backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Cell"]];
    cell.backgroundView = backgroundView;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Start transition
    _transitioning = YES;
    
    if (_fullscreen) {
        _fullscreen = NO;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
        
        [_collectionView snapshotViewAfterScreenUpdates:YES];
        
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            // Change flow layout
            [_collectionView setCollectionViewLayout:_smallLayout animated:YES];
            _collectionView.backgroundColor = [UIColor clearColor];
            
            // Reset scale
            _mainView.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            _transitioning = NO;
        }];
    }
    else {
        _fullscreen = YES;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            // Change flow layout
            [_collectionView setCollectionViewLayout:_largeLayout animated:YES];
            _collectionView.backgroundColor = [UIColor blackColor];
            
            // Transform to zoom in effect
            _mainView.transform = CGAffineTransformScale(_mainView.transform, 0.96, 0.96);
        } completion:^(BOOL finished) {
            _transitioning = NO;
        }];
    }
}


#pragma mark - Change slider
- (void)changeSlide
{
    if (_fullscreen == NO && _transitioning == NO) {
        if(_slide > _galleryImages.count-1) _slide = 0;
        
        UIImage *toImage = [UIImage imageNamed:_galleryImages[_slide]];
        [UIView transitionWithView:_mainView
                          duration:0.6f
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationCurveEaseInOut
                        animations:^{
                            _topImage.image = toImage;
                            _reflected.image = toImage;
                        } completion:nil];
        _slide++;
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout

#pragma mark - Gesture Interactions
- (void)doubleFingerTap:(UITapGestureRecognizer *)pinchGestureRecognizer
{
    NSLog(@"tap 2 fingers");
    
    if ([pinchGestureRecognizer state] == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // Transform to zoom in effect
            _mainView.transform = CGAffineTransformScale(_mainView.transform, 0.96, 0.96);
        } completion:^(BOOL finished) {
            _transitioning = NO;
        }];
    } else if ([pinchGestureRecognizer state] == UIGestureRecognizerStateEnded) {
        // Reset scale
        _mainView.transform = CGAffineTransformMakeScale(1, 1);
    }
}


//- (void)handlePinch:(UIPinchGestureRecognizer *)pinch
//{
//    if (pinch.state == UIGestureRecognizerStateBegan && !_transitionLayout) {
//        NSLog(@"UIGestureRecognizerStateBegan");
//
//        // remember initial scale factor for progress calculation
//        _initialScale = pinch.scale;
//
//        UICollectionViewLayout *toLayout = _smallLayout == _collectionView.collectionViewLayout ? _largeLayout : _smallLayout;
//
//        if (toLayout == _smallLayout) {
//            _collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
//        } else {
//            _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
//        }
//
//        _transitionLayout = (TLTransitionLayout *)[_collectionView startInteractiveTransitionToCollectionViewLayout:toLayout completion:^(BOOL completed, BOOL finish) {
//            if (finish) {
//                _collectionView.contentOffset = _transitionLayout.toContentOffset;
//            } else {
//                _collectionView.contentOffset = _transitionLayout.fromContentOffset;
//            }
//            self.transitionLayout = nil;
//        }];
//
////        NSArray *visibleIndexPaths = [_collectionView indexPathsForVisibleItems];
//        NSArray *visiblePoses = [_collectionView.collectionViewLayout layoutAttributesForElementsInRect:_collectionView.bounds];
//        NSMutableArray *visibleIndexPaths = [NSMutableArray arrayWithCapacity:visiblePoses.count];
//        for (UICollectionViewLayoutAttributes *pose in visiblePoses) {
//            [visibleIndexPaths addObject:pose.indexPath];
//        }
//        _transitionLayout.toContentOffset = [_collectionView toContentOffsetForLayout:_transitionLayout indexPaths:visibleIndexPaths placement:TLTransitionLayoutIndexPathPlacementCenter];
//
//    }
//
//    else if (pinch.state == UIGestureRecognizerStateChanged && _transitionLayout && pinch.numberOfTouches > 1) {
//        NSLog(@"UIGestureRecognizerStateChanged");
//        CGFloat finalScale = _transitionLayout.nextLayout == _largeLayout ? kLargeLayoutScale : 1 / kLargeLayoutScale;
//        _transitionLayout.transitionProgress = transitionProgress(_initialScale, pinch.scale, finalScale, TLTransitioningEasingLinear);
//    }
////    else if (pinch.state == UIGestureRecognizerStateEnded) {
////    else {
//    else if (pinch.state == UIGestureRecognizerStateEnded && _transitionLayout) {
//        NSLog(@"UIGestureRecognizerStateEnded");
//        if (_transitionLayout.transitionProgress > 0.3) {
//            [_collectionView finishInteractiveTransition];
//        } else {
//            [_collectionView cancelInteractiveTransition];
//        }
//
//    }
//
//    else {
//        NSLog(@"UIGestureRecognizerStateCancelled");
//        return;
//    }
//}
//
//- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
//{
//    return [[TLTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
//}


//- (CGFloat)transitionRange:(CGFloat)range
//{
//    return MAX(MIN((range), 1.0), 0.0);
//}


#pragma mark - UIViewControllerTransitioningDelegate
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}


- (void)checkUserLogin
{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser)
    {
        // Create ProgressHUD
        HUD = [[M13ProgressHUD alloc] initWithProgressView:[[M13ProgressViewRing alloc] init]];
        HUD.progressViewSize = CGSizeMake(60.0, 60.0);
        HUD.indeterminate = YES;
        [HUD performAction:M13ProgressViewActionNone animated:YES];
        UIWindow *window = ((ParseStarterProjectAppDelegate *)[UIApplication sharedApplication].delegate).window;
        [window addSubview:HUD];
        HUD.status = @"Loading...";
        [HUD show:YES];
        
//        // do stuff with the user
//        NSLog(@"Current loged user : %@", currentUser.username);
//        PFQuery *query = [PFQuery queryWithClassName:@"Feeds"];
//        [query includeKey:@"feed_by"];
//        [query orderByDescending:@"updatedAt"];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            NSLog(@"count object : %d", objects.count);
//            NSLog(@"data : %@", objects);
//            
//            if (_feedArray == nil)
//            {
//                _feedArray = [NSMutableArray arrayWithArray:objects];
//            }
//            
//            _feedArray = [objects mutableCopy];
//            self.dataSourceArray = _feedArray;
//            [self.collectionView reloadData];
//            
//            [HUD performAction:M13ProgressViewActionSuccess animated:YES];
//            [self performSelector:@selector(reset) withObject:nil afterDelay:1.5];
//        }];
    }
    else
    {
        // show the signup or login screen
        //        SignInViewController *signInVC = (SignInViewController *)[[self storyboard] instantiateViewControllerWithIdentifier:@"SignInViewController"];
        //        [self presentViewController:signInVC animated:NO completion:^{
        //            // TODO
        //        }];
        
        /*
         [PFUser logInWithUsernameInBackground:@"QWeerayoot" password:@"Buzzi4me"
         block:^(PFUser *user, NSError *error) {
         if (user) {
         // Do stuff after successful login.
         NSLog(@"Login success");
         } else {
         // The login failed. Check error to see why.
         NSLog(@"Login Fail");
         }
         }];
         */
        
//        __weak PaperFeedViewController *weakSelf = self;
    
        _ghView = [[GHWalkThroughView alloc] initWithFrame:self.navigationController.view.bounds];
        [_ghView setDataSource:self];
        [_ghView setWalkThroughDirection:GHWalkThroughViewDirectionVertical];
        UILabel* welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
        welcomeLabel.text = @"Neightbor";
        welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40];
        welcomeLabel.textColor = [UIColor whiteColor];
        welcomeLabel.textAlignment = NSTextAlignmentCenter;
        self.welcomeLabel = welcomeLabel;
        
        self.descStrings = @[sampleDesc1,sampleDesc2, sampleDesc3, sampleDesc4, sampleDesc5];
        // Show intro
        [_ghView setFloatingHeaderView:self.welcomeLabel];
        self.ghView.isfixedBackground = YES;
        self.ghView.bgImage = [UIImage imageNamed:@"intro_slide_1"];
        [self.ghView setWalkThroughDirection:GHWalkThroughViewDirectionHorizontal];
        [self.ghView showInView:self.navigationController.view animateDuration:0.3];
    }
}

#pragma mark - GHDataSource

- (NSInteger)numberOfPages
{
    return _descStrings.count;
}

- (void)configurePage:(GHWalkThroughPageCell *)cell atIndex:(NSInteger)index
{
    cell.title = [NSString stringWithFormat:@"This is page %d", index + 1];
    cell.titleImage = [UIImage imageNamed:[NSString stringWithFormat:@"title%d", index + 1]];
    cell.desc = _descStrings[index];
}

- (UIImage *)bgImageforPage:(NSInteger)index
{
    NSString *imageName =[NSString stringWithFormat:@"bg_0%d.jpg", index + 1];
    UIImage *image = [UIImage imageNamed:imageName];
    return image;
}

- (void)showSignUpWithNotification:(NSNotification *)notification
{
//    SignUpViewController *signupVC = (SignUpViewController *)[[self storyboard] instantiateViewControllerWithIdentifier:@"SignUpViewController"];
//    [self.navigationController pushViewController:signupVC animated:NO];
}

- (void)showSignInWithNotification:(NSNotification *)notification
{
//    SignInViewController *signupVC = (SignInViewController *)[[self storyboard] instantiateViewControllerWithIdentifier:@"SignInViewController"];
//    [self.navigationController pushViewController:signupVC animated:NO];
}

- (void)showActionSheetWihtNotification:(NSNotification *)notification
{
//    [self displayActionSheet];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MenuCell";
    UITableViewCell *cell;
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row == 0)
    {
        // User's cell
        UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 45, 45)];
        userImageView.backgroundColor = [UIColor redColor];
        
        UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 15, 250, 50)];
        userLabel.text = @"Weerayoot Ngandee";
        userLabel.font = [UIFont systemFontOfSize:18.0f];
        userLabel.backgroundColor = [UIColor greenColor];
        
        [cell.contentView addSubview:userImageView];
        [cell.contentView addSubview:userLabel];
    }
    else
    {
        // Menu cell
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"HELLO");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


#pragma mark - swipe

- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    menuView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    [UIView commitAnimations];
}

- (void)handleSwipeUp:(UISwipeGestureRecognizer *)recognizer
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    menuView.frame = CGRectMake(0, -[[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    [UIView commitAnimations];
}

- (void)addFeed:(id)sender
{
//    CreateFeedViewController *postVC = [[CreateFeedViewController alloc] init];
//    [self.navigationController pushViewController:postVC animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y >= 432.0)
    {
        [self handleSwipeUp:nil];
    }
}



@end
