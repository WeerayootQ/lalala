//
//  SmallCollectionViewController.m
//  ParseStarterProject
//
//  Created by Q on 3/22/14.
//
//

#import "SmallCollectionViewController.h"
#import "CollectionViewLargeLayout.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"
#import "ParseStarterProjectAppDelegate.h"
#import "GHWalkThroughView.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "CreateFeedViewController.h"
#import "FRDLivelyButton.h"
#import "CalendarViewController.h"
#import "CALAgendaViewController.h"
#import "NSDate+Agenda.h"
#import "NSDate+ETI.h"
#import "CALAgenda.h"
#import "JMOEvent.h"
#import "PostViewController.h"
#import "CommentViewController.h"

#import <AddressBook/AddressBook.h>
#import <MapKit/MapKit.h>

static NSString * const sampleDesc1 = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque tincidunt laoreet diam, id suscipit ipsum sagittis a. ";
static NSString * const sampleDesc2 = @" Suspendisse et ultricies sem. Morbi libero dolor, dictum eget aliquam quis, blandit accumsan neque. Vivamus lacus justo, viverra non dolor nec, lobortis luctus risus.";
static NSString * const sampleDesc3 = @"In interdum scelerisque sem a convallis. Quisque vehicula a mi eu egestas. Nam semper sagittis augue, in convallis metus";
static NSString * const sampleDesc4 = @"Praesent ornare consectetur elit, in fringilla ipsum blandit sed. Nam elementum, sem sit amet convallis dictum, risus metus faucibus augue, nec consectetur tortor mauris ac purus.";
static NSString * const sampleDesc5 = @"Sed rhoncus arcu nisl, in ultrices mi egestas eget. Etiam facilisis turpis eget ipsum tempus, nec ultricies dui sagittis. Quisque interdum ipsum vitae ante laoreet, id egestas ligula auctor";

#define FONT_SIZE 12.0f

@interface SmallCollectionViewController () <GHWalkThroughViewDataSource, CALAgendaCollectionViewDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CLLocationManagerDelegate>
{
    M13ProgressHUD *HUD;
    UIView *menuView;
    UILabel *locationLabel;
    UILabel *weatherLabel;
    BOOL isMenuOn;
    BOOL isFromFullScreen;
}

@property (nonatomic, assign) NSInteger slide;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *topImage;
@property (nonatomic, strong) UIImageView *reflected;
@property (nonatomic, strong) NSArray *galleryImages;
@property (nonatomic, strong) NSMutableArray *feedArray;
@property (nonatomic, strong) FRDLivelyButton *addFeedBtn;
@property (nonatomic, strong) FRDLivelyButton *menuBtn;

// For intro view.
@property (nonatomic, strong) GHWalkThroughView *ghView;
@property (nonatomic, strong) NSArray *descStrings;
@property (nonatomic, strong) UILabel *welcomeLabel;

// Location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;

// Event
@property (nonatomic, strong) CALAgendaViewController *agendaVc;
@property (nonatomic, strong) JMOEvent *event;
@end

@implementation SmallCollectionViewController

#pragma mark - UICollection Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    isFromFullScreen = YES;
    UIViewController *vc = [self nextViewControllerAtPoint:CGPointZero];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UICollectionViewController *)nextViewControllerAtPoint:(CGPoint)point
{
    // We could have multiple section stacks and find the right one,
    CollectionViewLargeLayout *largeLayout = [[CollectionViewLargeLayout alloc] init];
    MainCollectionViewController *nextCollectionViewController = [[MainCollectionViewController alloc] initWithCollectionViewLayout:largeLayout];
    nextCollectionViewController.useLayoutToLayoutNavigationTransitions = YES;
    return nextCollectionViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSignUpWithNotification:) name:@"SHOW_SIGNUP" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSignInWithNotification:) name:@"SHOW_SIGNIN" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActionSheetWihtNotification:) name:@"SHOW_ACTIONSHEET" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCommentWithNotification:) name:@"SHOW_COMMENT" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLikeWithNotification:) name:@"SHOW_LIKE" object:nil];
    
    //Gallery
    _galleryImages = @[@"feed8.png", @"feed9.png", @"feed10.png", @"feed11.png"];
    _slide = 0;
    
    
    // Init mainView
    _mainView = [[UIView alloc] initWithFrame:self.view.bounds];
    _mainView.clipsToBounds = YES;
    _mainView.layer.cornerRadius = 4;
    [self.view insertSubview:_mainView belowSubview:self.collectionView];
    
    // ImageView on top
    _topImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
    [_mainView addSubview:_topImage];
    
    // Gradient to top image
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _topImage.bounds;
    gradient.colors = @[(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] CGColor],
                        (id)[[UIColor colorWithWhite:0 alpha:0] CGColor]];
    [_topImage.layer insertSublayer:gradient atIndex:0];
    
    // Content perfect pixel
    UIView *perfectPixelContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_topImage.bounds), 1)];
    perfectPixelContent.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    [_topImage addSubview:perfectPixelContent];
    
    // First Load
    [self changeSlide];
    
    // Loop gallery - fix loop: http://bynomial.com/blog/?p=67
    NSTimer *timer = [NSTimer timerWithTimeInterval:5.0f target:self selector:@selector(changeSlide) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    menuView = [[UIView alloc] initWithFrame:CGRectMake(0, -[[UIScreen mainScreen] bounds].size.height,
                                                        [[UIScreen mainScreen] bounds].size.width,
                                                        [[UIScreen mainScreen] bounds].size.height)];
    menuView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.95];
    
    UILabel *menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, menuView.frame.size.width, 64)];
    menuLabel.text = @"MENU";
    menuLabel.textColor = [UIColor whiteColor];
    menuLabel.backgroundColor = [UIColor blackColor];
    menuLabel.textAlignment = NSTextAlignmentCenter;
    menuLabel.font = FONT_BOLD(22);
    [menuView addSubview:menuLabel];
    [menuView bringSubviewToFront:menuLabel];
    
    _menuBtn = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 46, 15, 36, 28)];
    [_menuBtn setOptions:@{ kFRDLivelyButtonLineWidth: @(2.0f),
                            kFRDLivelyButtonHighlightedColor: [UIColor blackColor],
                            kFRDLivelyButtonColor: [UIColor whiteColor]
                          }];
    [_menuBtn setStyle:kFRDLivelyButtonStyleClose animated:NO];
    [_menuBtn addTarget:self action:@selector(menuTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UITableView *menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, menuView.frame.size.width, menuView.frame.size.height - 64) style:UITableViewStylePlain];
    menuTableView.delegate = self;
    menuTableView.dataSource = self;
    menuTableView.backgroundColor = [UIColor clearColor];
    [menuView addSubview:menuTableView];
    [menuView addSubview:_menuBtn];
    [self.collectionView addSubview:menuView];
//    [self.view insertSubview:menuView aboveSubview:self.collectionView];

    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.collectionView addGestureRecognizer:swipeDown];
    
    [self checkUserLogin];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    _startLocation = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self checkUserLogin];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    ParseStarterProjectAppDelegate *appDelegate = AppDelegateAccessor;
    if (appDelegate.isFromPost)
    {
        [self handleSwipeUp:nil];
        isMenuOn = NO;
        self.collectionView.scrollEnabled = YES;
    }

    if (isFromFullScreen)
    {
        NSLog(@"XPOS : %f", self.collectionView.contentOffset.x);
        isFromFullScreen = NO;
        menuView.frame = CGRectMake(self.collectionView.contentOffset.x, -[[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    }
    
    // do stuff with the user
    PFQuery *query = [PFQuery queryWithClassName:@"Feeds"];
    [query includeKey:@"feed_by"];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSLog(@"count object : %d", objects.count);
        
        //            NSLog(@"data : %@", objects);
        
        if (_feedArray == nil)
        {
            _feedArray = [NSMutableArray arrayWithArray:objects];
        }
        
        _feedArray = [objects mutableCopy];
        self.dataSourceArray = _feedArray;
        [self.collectionView reloadData];
        
        //            [HUD performAction:M13ProgressViewActionNone animated:YES];
        //            [self performSelector:@selector(reset) withObject:nil afterDelay:1.5];
    }];
}

#pragma mark - Change slider
- (void)changeSlide
{
    //    if (_fullscreen == NO && _transitioning == NO) {
    if(_slide > _galleryImages.count-1) _slide = 0;
    
    UIImage *toImage = [UIImage imageNamed:_galleryImages[_slide]];
    [UIView transitionWithView:_mainView
                      duration:0.6f
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationCurveEaseInOut
                    animations:^{
                        _topImage.image = toImage;
//                        _reflected.image = toImage;
                    } completion:nil];
    _slide++;
    //    }
}

#pragma mark - Feed

- (void)addFeedTapped:(FRDLivelyButton *)sender
{
    [sender setStyle:kFRDLivelyButtonStyleClose animated:YES];
}

- (void)fetchFeedData
{
    PFQuery *query = [PFQuery queryWithClassName:@"Feeds"];
    [query includeKey:@"feed_by"];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    NSLog(@"count object : %d", objects.count);
//        NSLog(@"data : %@", objects);
    
        if (_feedArray == nil)
        {
            _feedArray = [NSMutableArray arrayWithArray:objects];
        }
    
        _feedArray = [objects mutableCopy];
        self.dataSourceArray = _feedArray;
        [self.collectionView reloadData];
    }];
}

- (void)checkUserLogin
{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser)
    {
        // Create ProgressHUD
//        HUD = [[M13ProgressHUD alloc] initWithProgressView:[[M13ProgressViewRing alloc] init]];
//        HUD.progressViewSize = CGSizeMake(45.0, 45.0);
//        HUD.indeterminate = YES;
//        [HUD performAction:M13ProgressViewActionNone animated:YES];
//        UIWindow *window = ((ParseStarterProjectAppDelegate *)[UIApplication sharedApplication].delegate).window;
//        [window addSubview:HUD];
//        HUD.status = @"Loading...";
//        [HUD show:YES];
        
        // do stuff with the user
        NSLog(@"Current loged user : %@", currentUser.username);
        PFQuery *query = [PFQuery queryWithClassName:@"Feeds"];
        [query includeKey:@"feed_by"];
        [query orderByDescending:@"updatedAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            NSLog(@"count object : %d", objects.count);

//            NSLog(@"data : %@", objects);
            
            if (_feedArray == nil)
            {
                _feedArray = [NSMutableArray arrayWithArray:objects];
            }
            
            _feedArray = [objects mutableCopy];
            self.dataSourceArray = _feedArray;
            [self.collectionView reloadData];
            
//            [HUD performAction:M13ProgressViewActionNone animated:YES];
//            [self performSelector:@selector(reset) withObject:nil afterDelay:1.5];
        }];
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
        
        
        
        _ghView = [[GHWalkThroughView alloc] initWithFrame:(iPhone5)?CGRectMake(0, 0, 320, 586):CGRectMake(0, 0, 320, 480)];
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
        [self.ghView showInView:self.view animateDuration:0.3];
        
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
    SignUpViewController *signUpVC = (SignUpViewController *)[[SignUpViewController alloc] init];
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:signUpVC];
    [self presentViewController:rootVC animated:YES completion:nil];
}

- (void)showSignInWithNotification:(NSNotification *)notification
{
    SignInViewController *signInVC = (SignInViewController *)[[SignInViewController alloc] init];
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:signInVC];
    [self presentViewController:rootVC animated:YES completion:nil];
}

- (void)showCommentWithNotification:(NSNotification *)notification
{
    NSLog(@"OBJECT : %@", notification.object);
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    CommentViewController *commtentVC = (CommentViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commtentVC.feedObj = (PFObject *)notification.object;
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:commtentVC];
    [self presentViewController:rootVC animated:YES completion:nil];
}

- (void)showLikeWithNotification:(NSNotification *)notification
{
    NSLog(@"OBJECT : %@", notification.object);
}

- (void)showActionSheetWihtNotification:(NSNotification *)notification
{
    // Ask for permission
    CFErrorRef *error = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else
    { // we're on iOS 5 or older
        accessGranted = YES;
    }
    [self displayActionSheet];
}

#pragma mark - Progress HUD

- (void)reset
{
    [HUD hide:YES];
    [HUD performAction:M13ProgressViewActionNone animated:NO];
}

#pragma mark - ActionSheet
- (void)displayActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"NeighborAPP"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Sign In", @"Sign Up", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault; [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self showSignInWithNotification:nil];
            break;
        case 1:
            [self showSignUpWithNotification:nil];
            break;
    }
}

#pragma mark - swipe

- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    menuView.frame = CGRectMake(self.collectionView.contentOffset.x, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    [UIView commitAnimations];
}

- (void)handleSwipeUp:(UISwipeGestureRecognizer *)recognizer
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    menuView.frame = CGRectMake(self.collectionView.contentOffset.x, -[[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    [UIView commitAnimations];
}

- (void)addFeed:(id)sender
{
    CreateFeedViewController *postVC = [[CreateFeedViewController alloc] init];
    [self.navigationController pushViewController:postVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 5;
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0)
    {
        // User's cell
        PFUser *currentUser = [PFUser currentUser];
        PFFile *file = currentUser[@"userImage"];
        
        UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 24, 62, 62)];
        userImageView.contentMode = UIViewContentModeScaleAspectFill;
        userImageView.clipsToBounds = YES;
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error)
            {
                UIImage *image = [UIImage imageWithData:data];
                userImageView.image = image;
            }
        }];
        
        UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(77, 24, 250, 62)];
        userLabel.text = currentUser.username;
        userLabel.textColor = [UIColor whiteColor];
        userLabel.font = FONT_BOLD(22);
        userLabel.backgroundColor = [UIColor clearColor];
        userLabel.textAlignment = NSTextAlignmentCenter;
        userLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [cell.contentView addSubview:userImageView];
        [cell.contentView addSubview:userLabel];
    }
    else if (indexPath.row == 1)
    {
        // Menu cell
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 24, 62, 62)];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.image = [UIImage imageNamed:@"post-icon.png"];
        [cell.contentView addSubview:icon];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(77, 24, 250, 62)];
        label.text = @"Create Post/Report";
        label.textColor = [UIColor whiteColor];
        label.font = FONT_THIN(22);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell.contentView addSubview:label];
    }
    else if (indexPath.row == 2)
    {
        // Menu cell
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 24, 62, 62)];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.image = [UIImage imageNamed:@"alert-icon.png"];
        [cell.contentView addSubview:icon];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(77, 24, 250, 62)];
        label.text = @"Message";
        label.textColor = [UIColor whiteColor];
        label.font = FONT_THIN(22);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell.contentView addSubview:label];
    }
    else if (indexPath.row == 3)
    {
        // Menu cell
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 24, 62, 62)];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.image = [UIImage imageNamed:@"calendar-icon.png"];
        [cell.contentView addSubview:icon];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(77, 24, 250, 62)];
        label.text = @"Events";
        label.textColor = [UIColor whiteColor];
        label.font = FONT_THIN(22);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell.contentView addSubview:label];
    }
    else if (indexPath.row == 4)
    {
        // Menu cell
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 24, 62, 62)];
        icon.image = [UIImage imageNamed:@"setting-icon.png"];
        [cell.contentView addSubview:icon];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(77, 24, 250, 62)];
        label.text = @"Settings";
        label.textColor = [UIColor whiteColor];
        label.font = FONT_THIN(22);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell.contentView addSubview:label];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        // User's profile
        
    }
    else if (indexPath.row == 1)
    {
        // Post
        [self openPostController];
    }
    else if (indexPath.row == 2)
    {
        // Notifications
    }
    else if (indexPath.row == 3)
    {
        // Events
        [self openEventController];
    }
    else
    {
        // Settings
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView)
    {
        menuView.frame = CGRectMake(self.collectionView.contentOffset.x, -[[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    }
}

#pragma mark - Helper Method

- (double)celsiusConverter:(double)fahrenheit
{
    double celsius = (fahrenheit - 32)*((double)5/9);
    return celsius;
}

#pragma mark - Setup View

- (void)setupCoverLabelWithDict:(NSDictionary *)dict andPlaceMark:(NSArray *)placemark
{
    double fahrenheit = [dict[@"temperature"] doubleValue];
    double celsius = [self celsiusConverter:fahrenheit];
    
    // Location icon
    UILabel *locationIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 50, 0)];
    locationIconLabel.backgroundColor = [UIColor clearColor];
    locationIconLabel.textColor = [UIColor whiteColor];
    locationIconLabel.font = FONT_CLIPMACON(50);
    locationIconLabel.text = [NSString stringWithFormat:@"%c", ClimaconCompass];
    [locationIconLabel sizeToFit];
    [_mainView addSubview:locationIconLabel];
    
    // Label for current location
    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + locationIconLabel.frame.size.width + 10, 12, 290, locationIconLabel.frame.size.height + 5)];
    locationLabel.backgroundColor = [UIColor clearColor];
    locationLabel.textColor = [UIColor whiteColor];
    locationLabel.font = FONT_REG(24);
    locationLabel.text = [NSString stringWithFormat:@"%@, %@", [placemark[0] administrativeArea], [placemark[0] country]];
    [locationLabel setClipsToBounds:NO];
    [locationLabel.layer setShadowOffset:CGSizeMake(0, 0)];
    [locationLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [locationLabel.layer setShadowRadius:1.0];
    [locationLabel.layer setShadowOpacity:0.6];
    [_mainView addSubview:locationLabel];
    
    // Weather icon
    UILabel *weatherIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, locationLabel.frame.origin.y + CGRectGetHeight(locationLabel.frame) - 13, 50, 0)];
    weatherIconLabel.backgroundColor = [UIColor clearColor];
    weatherIconLabel.textColor = [UIColor whiteColor];
    weatherIconLabel.font = FONT_CLIPMACON(30);
    weatherIconLabel.text = [NSString stringWithFormat:@"%c", ClimaconDrizzle];
    [weatherIconLabel sizeToFit];
    [_mainView addSubview:weatherIconLabel];
    
    // Label SubTitle
    weatherLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + weatherIconLabel.frame.size.width + 10, locationLabel.frame.origin.y + CGRectGetHeight(locationLabel.frame) - 5, 290, 0)];
    weatherLabel.backgroundColor = [UIColor clearColor];
    weatherLabel.textColor = [UIColor whiteColor];
    weatherLabel.font = FONT_LIGHT(18);
    weatherLabel.text = [NSString stringWithFormat:@"%@, %.2f ºC", dict[@"summary"], celsius];
    weatherLabel.lineBreakMode = NSLineBreakByWordWrapping;
    weatherLabel.numberOfLines = 0;
    [weatherLabel sizeToFit];
    [weatherLabel setClipsToBounds:NO];
    [weatherLabel.layer setShadowOffset:CGSizeMake(0, 0)];
    [weatherLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [weatherLabel.layer setShadowRadius:1.0];
    [weatherLabel.layer setShadowOpacity:0.6];
    [_mainView addSubview:weatherLabel];
}


-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Swipe received.");
    if (isFromFullScreen)
    {
        return;
    }
    else
    {
        [self handleSwipe:nil];
        isMenuOn = YES;
        self.collectionView.scrollEnabled = NO;
    }
}

- (IBAction)menuTapped:(FRDLivelyButton *)sender
{
    if (isMenuOn)
    {
//        [sender setStyle:kFRDLivelyButtonStyleHamburger animated:YES];
        [self handleSwipeUp:nil];
        isMenuOn = NO;
        self.collectionView.scrollEnabled = YES;
    }
    else
    {
//        [sender setStyle:kFRDLivelyButtonStyleClose animated:YES];
        [self handleSwipe:nil];
        isMenuOn = YES;
        self.collectionView.scrollEnabled = NO;
    }
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
                  fromLocation:(CLLocation *)oldLocation
{
     if (_startLocation == nil)
     {
        _startLocation = newLocation;
        [[APIClient sharedInstance] getForecastWithDict:@{@"LATITUDE" : @(_startLocation.coordinate.latitude), @"LONGITUDE" : @(_startLocation.coordinate.longitude)}
                                          withBlock:^(NSDictionary *forecastDict, BOOL succeeded, NSError *error) {
                                              // TODO
                                              if (succeeded)
                                              {
                                                    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                                                    [geocoder reverseGeocodeLocation:_startLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                                                        if (placemarks.count > 0)
                                                        {
                                                            NSLog(@"Placemark : %@, %@", [placemarks[0] administrativeArea], [placemarks[0] country]);
                                                            [self setupCoverLabelWithDict:forecastDict andPlaceMark:placemarks];
                                                        }
                                                    }];
                                                    [_locationManager stopUpdatingLocation];
                                              }
                                              else
                                              {
                                                  // Do something.
                                              }
                                          }];
     }
}

#pragma mark - Events

- (void)openEventController
{
    self.agendaVc = [CALAgendaViewController new];
    self.agendaVc.calendarScrollDirection = UICollectionViewScrollDirectionVertical;
    self.agendaVc.agendaDelegate = self;
    NSDateComponents *components = [NSDateComponents new];
    components.month = 1;
    components.day = 1;
    components.year = 2014;
    NSDate *fromDate = [[NSDate gregorianCalendar] dateFromComponents:components];
    components.month = 3;
    components.day = 1;
    NSDate *toDate = [[NSDate gregorianCalendar] dateFromComponents:components];
    [self.agendaVc setFromDate:fromDate];
    [self.agendaVc setToDate:toDate];
    
    self.agendaVc.events = [self fakeEvents];
    self.agendaVc.dayStyle = CALDayCollectionViewCellDayUIStyleIOS7;
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [self.navigationController pushViewController:self.agendaVc animated:YES];
}

- (NSArray *)fakeEvents
{
    NSDate *now = [[NSDate gregorianCalendar] dateFromComponents:[[NSDate gregorianCalendar]  components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]]];
    NSDateComponents *components = [NSDateComponents new];
    components.month = -3;
    
    JMOEvent *event1 = [JMOEvent new];
    components.day = 3;
    components.month = 0;
    components.hour = 11;
    event1.startDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    components.month = 0;
    components.day = 3;
    components.hour = 12;
    event1.endDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    
    JMOEvent *event2 = [JMOEvent new];
    components.day = 2;
    components.month = 1;
    components.hour = 11;
    event2.startDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    components.month = 1;
    components.day = 2;
    components.hour = 12;
    event2.endDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    
    JMOEvent *event3 = [JMOEvent new];
    components.day = 1;
    components.month = -3;
    components.hour = 11;
    event3.startDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    components.day = 1;
    components.month = -3;
    components.hour = 12;
    event3.endDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    
    JMOEvent *event4 = [JMOEvent new];
    components.day = 2;
    components.month = -3;
    components.hour = 11;
    event4.startDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    components.day = 2;
    components.month = -3;
    components.hour = 19;
    event4.endDate = [[NSDate gregorianCalendar] dateByAddingComponents:components toDate:now options:0];
    return @[event1, event2,event3, event4];
}

#pragma mark - Post

- (void)openPostController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    PostViewController *postVC = (PostViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"PostViewController"];
    [self.navigationController pushViewController:postVC animated:YES];
}

@end
