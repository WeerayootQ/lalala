//
//  FeedViewController.m
//  ParseStarterProject
//
//  Created by Q Buzzwoo on 1/13/2557 BE.
//
//

#import "FeedViewController.h"
#import "SignInViewController.h"
#import "UIImageView+LBBlurredImage.h"
#import "UIViewController+ECSlidingViewController.h"
#import "SAMTextView.h"
#import "FeedCell.h"
#import "SVPullToRefresh.h"
#import "GHWalkThroughView.h"
#import "SignUpViewController.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"
#import "ParseStarterProjectAppDelegate.h"
#import "AssetHelper.h"
#import "DoImagePickerController.h"
#import "UIViewController+ECSlidingViewController.h"


static NSString * const sampleDesc1 = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque tincidunt laoreet diam, id suscipit ipsum sagittis a. ";

static NSString * const sampleDesc2 = @" Suspendisse et ultricies sem. Morbi libero dolor, dictum eget aliquam quis, blandit accumsan neque. Vivamus lacus justo, viverra non dolor nec, lobortis luctus risus.";

static NSString * const sampleDesc3 = @"In interdum scelerisque sem a convallis. Quisque vehicula a mi eu egestas. Nam semper sagittis augue, in convallis metus";

static NSString * const sampleDesc4 = @"Praesent ornare consectetur elit, in fringilla ipsum blandit sed. Nam elementum, sem sit amet convallis dictum, risus metus faucibus augue, nec consectetur tortor mauris ac purus.";

static NSString * const sampleDesc5 = @"Sed rhoncus arcu nisl, in ultrices mi egestas eget. Etiam facilisis turpis eget ipsum tempus, nec ultricies dui sagittis. Quisque interdum ipsum vitae ante laoreet, id egestas ligula auctor";

#define FONT_SIZE 12.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 80.0f

@interface FeedViewController () <UITextViewDelegate, UIActionSheetDelegate, GHWalkThroughViewDataSource, DoImagePickerControllerDelegate>
{
    UILabel *_countLabel;
    int charCount;
    NSString *feedString;
    M13ProgressHUD *HUD;
}
@property (nonatomic, strong) NSMutableArray *feedArray;
@property (nonatomic, strong) UIView *addFeedOverlay;
@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;
@property (nonatomic, strong) UIImageView *postImageView;
// For intro view.
@property (nonatomic, strong) GHWalkThroughView *ghView;
@property (nonatomic, strong) NSArray *descStrings;
@property (nonatomic, strong) UILabel *welcomeLabel;
// For image picker
@property (nonatomic, strong) NSArray *aIVs;

@end

@implementation FeedViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refreshButtonHandler:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                          target:self
                                                                                          action:@selector(addPostButtonHandler:)];
    self.title = @"Feeds";
    self.view.backgroundColor = [UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:1.0f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSignUpWithNotification:) name:@"SHOW_SIGNUP" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSignInWithNotification:) name:@"SHOW_SIGNIN" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActionSheetWihtNotification:) name:@"SHOW_ACTIONSHEET" object:nil];
    
    // Check current user
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
        
        // do stuff with the user
        NSLog(@"Current loged user : %@", currentUser.username);
        PFQuery *query = [PFQuery queryWithClassName:@"Feeds"];
        [query includeKey:@"feed_by"];
        [query orderByDescending:@"updatedAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"count object : %d", objects.count);
            NSLog(@"data : %@", objects);
            
            if (_feedArray == nil)
            {
                _feedArray = [NSMutableArray arrayWithArray:objects];
            }
    
            _feedArray = [objects mutableCopy];
            [self.tableView reloadData];
            
            [HUD performAction:M13ProgressViewActionSuccess animated:YES];
            [self performSelector:@selector(reset) withObject:nil afterDelay:1.5];
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
    
    // setup pull-refresh scroll
    [self.tableView addPullToRefreshWithActionHandler:^{
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            PFQuery *query = [PFQuery queryWithClassName:@"Feeds"];
            [query includeKey:@"feed_by"];
            [query orderByDescending:@"updatedAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSLog(@"count object : %d", objects.count);
                NSLog(@"data : %@", objects);
                
                if (_feedArray == nil)
                {
                    _feedArray = [NSMutableArray arrayWithArray:objects];
                }
                
                _feedArray = [objects mutableCopy];
                [self.tableView reloadData];
                [self.tableView.pullToRefreshView stopAnimating];
            }];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    if ([(NSObject *)self.slidingViewController.delegate isKindOfClass:[MEDynamicTransition class]]) {
//        MEDynamicTransition *dynamicTransition = (MEDynamicTransition *)self.slidingViewController.delegate;
//        if (!self.dynamicTransitionPanGesture) {
//            self.dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:dynamicTransition action:@selector(handlePanGesture:)];
//        }
//    
//        [self.navigationController.view removeGestureRecognizer:self.slidingViewController.panGesture];
//        [self.navigationController.view addGestureRecognizer:self.dynamicTransitionPanGesture];
//    } else {
//        [self.navigationController.view removeGestureRecognizer:self.dynamicTransitionPanGesture];
//        [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _feedArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    PFObject *feedObj = (PFObject *)_feedArray[indexPath.row];
    cell.feedObj = feedObj;
    // Configure the cell...
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *feedObj = (PFObject *)_feedArray[indexPath.row];
    NSString *text = feedObj[@"feed_msg"];
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    CGSize size = [text boundingRectWithSize:constraint
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes: @{ NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:FONT_SIZE]}
                                     context: nil].size;
    CGFloat height = MAX(size.height, 44.0f);
    NSLog(@"height : %f", height);
    return height + (CELL_CONTENT_MARGIN /* * 2*/);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

 #pragma mark UINavigation Button Action
- (void)refreshButtonHandler:(id)sender
{
////    [PFUser logOut];
//
//    PFUser *currentUser = [PFUser currentUser];
//
//    // Create the post
//    PFObject *feed = [PFObject objectWithClassName:@"Feeds"];
//    feed[@"feed_msg"] = @"I'm like";
//    feed[@"feed_by"] = currentUser;
// 
//    // Create the comment
//    PFObject *myComment = [PFObject objectWithClassName:@"Comments"];
//    myComment[@"comment_msg"] = @"Let's do Sushirrito.";
// 
//    // Add a relation between the Post and Comment
//    myComment[@"comment_feed_id"] = feed;
//    myComment[@"comment_by"] = currentUser;
//    
//    // This will save both myPost and myComment
//    [myComment saveInBackground];
//    
//    // Create  like
//    PFObject *like = [PFObject objectWithClassName:@"Likes"];
//    // Add a relation between the Post and Comment
//    like[@"like_feed_id"] = feed;
//    like[@"like_by"] = currentUser;
//    
//    // This will save both myPost and myComment
//    [like saveInBackground];
    
//    [PFUser logOut];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Feeds"];
    [query includeKey:@"feed_by"];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"count object : %d", objects.count);
        NSLog(@"data : %@", objects);
        
        if (_feedArray == nil)
        {
            _feedArray = [NSMutableArray arrayWithArray:objects];
        }
        
        _feedArray = [objects mutableCopy];
        [self.tableView reloadData];
    }];
}

- (void)addPostButtonHandler:(id)sender
{
//    // Create the post
//    PFObject *resident = [PFObject objectWithClassName:@"Residental"];
//    resident[@"res_id"] = @"1";
//    resident[@"res_name"] = @"KKN1";
//    resident[@"res_address"] = @"Chiang Mai";
// 
//    // Create the comment
//    PFObject *admin = [PFObject objectWithClassName:@"Admin"];
//    admin[@"admin_id"] = @"1";
//    admin[@"admin_name"] = @"ilikeIT";
//    admin[@"admin_username"] = @"admin";
//    admin[@"admin_password"] = @"pass";
// 
//    // Add a relation between the Post and Comment
//    admin[@"admin_resident_id"] = resident;
//    
//    // This will save both myPost and myComment
//    [admin saveInBackground];
    [self showAddFeedOverlay];
}

- (void)addFeedCancelTapped:(id)sender
{
    [self hideAddFeedOverlay];
}

- (void)onShowImagePicker:(id)sender
{
	for (UIImageView *iv in _aIVs)
		iv.image = nil;
	
    DoImagePickerController *cont = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
    cont.delegate = self;
    cont.nResultType = DO_PICKER_RESULT_UIIMAGE;
//    if (_sgMaxCount.selectedSegmentIndex == 0)
        cont.nMaxCount = 1;
//    else if (_sgMaxCount.selectedSegmentIndex == 1)
//        cont.nMaxCount = 4;
//    else if (_sgMaxCount.selectedSegmentIndex == 2)
//    {
//        cont.nMaxCount = DO_NO_LIMIT_SELECT;
//        cont.nResultType = DO_PICKER_RESULT_ASSET;  // if you want to get lots photos, you'd better use this mode for memory!!!
//    }
    
    cont.nColumnCount = 3;
    
    [self presentViewController:cont animated:YES completion:nil];
}

#pragma mark - Add Feed Overlay Handler
- (void)setupAddFeedOverlay
{
    charCount = 140;
    UIImageView *blurOverlay = [[UIImageView alloc] initWithFrame:self.navigationController.view.bounds];
    blurOverlay.backgroundColor = [UIColor clearColor];
    [blurOverlay setImageToBlur:[UIImage imageNamed:@"blur.png"]
                     blurRadius:kLBBlurredImageDefaultBlurRadius
                completionBlock:^(NSError *error){
                       NSLog(@"The blurred image has been setted");
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.5];
                    _addFeedOverlay.alpha = 1.0;
                    [UIView commitAnimations];
    }];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 25, 300, 210)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 3.0;
    bgView.layer.masksToBounds = YES;
    
    UIView *topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    topBarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"add_feed_topbar.png"]];
    [bgView addSubview:topBarView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    titleLabel.text = @"Update Feed";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20.0f];
    [bgView addSubview:titleLabel];
    
    // Create Share Button
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(265, 7, 28, 28);
    [shareBtn setImage:[UIImage imageNamed:@"share_btn.png"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareFeedTapped:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:shareBtn];
    
    // Create UserAvatar Image
    UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 55, 32, 32)];
    userImageView.image = [UIImage imageNamed:@"user_temp.jpeg"];
    userImageView.backgroundColor = [UIColor clearColor];
    userImageView.layer.cornerRadius = 16;
    userImageView.layer.masksToBounds = YES;
    [bgView addSubview:userImageView];
    
    // Cratee User Label
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, 55, 200, 15)];
    userLabel.backgroundColor = [UIColor clearColor];
    userLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
    userLabel.text = @"Weerayoot Ngandee";
    userLabel.textAlignment = NSTextAlignmentLeft;
    userLabel.textColor = [UIColor colorWithRed:100/255.0f green:100/255.0f blue:100/255.0f alpha:1.0f];
    [bgView addSubview:userLabel];
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, 70, 200, 15)];
    locationLabel.backgroundColor = [UIColor clearColor];
    locationLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:10.0];
    locationLabel.text = @"Near Ban Saraphi, Chiang Mai";
    locationLabel.textAlignment = NSTextAlignmentLeft;
    locationLabel.textColor = [UIColor colorWithRed:100/255.0f green:100/255.0f blue:100/255.0f alpha:1.0f];
    [bgView addSubview:locationLabel];
    
    // Create Separator
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(10, 95, 290, 0.5)];
    separatorView.backgroundColor = [UIColor lightGrayColor];
    [bgView addSubview:separatorView];
    
    // Create textView
    CGRect textViewFrame = CGRectMake(20.0, 133.0f, 200.0f, 90.0f);
    SAMTextView *textView = [[SAMTextView alloc] initWithFrame:textViewFrame];
    textView.backgroundColor = [UIColor whiteColor];
    textView.returnKeyType = UIReturnKeyDone;
    textView.keyboardAppearance = UIKeyboardAppearanceDark;
    textView.delegate = self;
    textView.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:11.0];
    textView.placeholder = @"Type for share you mentioned in 140 charactors";
    [textView becomeFirstResponder];
    
    // Create image button.
    UIButton *addImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addImageBtn.backgroundColor = [UIColor redColor];
    addImageBtn.frame = CGRectMake(230, 133, 70, 70);
    [addImageBtn setImage:[UIImage imageNamed:@"placeholder.png"] forState:UIControlStateNormal];
    [addImageBtn addTarget:self action:@selector(onShowImagePicker:) forControlEvents:UIControlEventTouchUpInside];
    
    _postImageView = [[UIImageView alloc] initWithFrame:addImageBtn.frame];
    _postImageView.backgroundColor = [UIColor clearColor];
    _postImageView.alpha = 0;
    
    // Create counter label
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 210, 200, 15)];
    _countLabel.text = @"Charactor left : 140";
    _countLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:10.0];
    _countLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
    _countLabel.textAlignment =NSTextAlignmentLeft;
    
    // Add subview to overlay
    _addFeedOverlay = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    _addFeedOverlay.alpha = 0.0;
    _addFeedOverlay.backgroundColor = [UIColor clearColor];
    [_addFeedOverlay addSubview:blurOverlay];
    [_addFeedOverlay addSubview:bgView];
    [_addFeedOverlay addSubview:textView];
    [_addFeedOverlay addSubview:addImageBtn];
    [_addFeedOverlay addSubview:_postImageView];
    [_addFeedOverlay addSubview:_countLabel];
    [self.navigationController.view addSubview:_addFeedOverlay];
}

- (void)showAddFeedOverlay
{
    [self setupAddFeedOverlay];
}

- (void)hideAddFeedOverlay
{
    _addFeedOverlay.alpha = 0.0;
    [_addFeedOverlay removeFromSuperview];
}

#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewShouldBeginEditing:");
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewDidBeginEditing:");
//    textView.backgroundColor = [UIColor greenColor];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    if (textView.text.length + text.length > 139)
    {
        if (location != NSNotFound)
        {
            [textView resignFirstResponder];
            NSLog(@"1");
        }
        NSLog(@"2");
        return NO;
    }
    else if (location != NSNotFound)
    {
        NSLog(@"3");
        [textView resignFirstResponder];
        return NO;
    }
    
    if (charCount > 0)
    {
        charCount--;
    }
    _countLabel.text = [NSString stringWithFormat:@"Charactor left : %d", charCount];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    feedString = textView.text;
    NSLog(@"text : %@", feedString);
//    [self hideAddFeedOverlay];
}

#pragma mark - Post Feed

- (void)shareFeedTapped:(id)sender
{
    if ([feedString isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NeighborAPP"
                                                        message:@"Not allow to send the blank feed content. Please try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"Try Again"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    // Create the post
    NSData *imageData = UIImagePNGRepresentation(_postImageView.image);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    
    PFObject *feed = [PFObject objectWithClassName:@"Feeds"];
    [feed setObject:[PFUser currentUser] forKey:@"feed_by"];
    [feed setObject:feedString forKey:@"feed_msg"];
    [feed setObject:imageFile forKey:@"feed_image"];
    
    
    // Photos are public, but may only be modified by the user who uploaded them
    PFACL *feedACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [feedACL setPublicReadAccess:YES];
    feed.ACL = feedACL;
    
    // Save the Photo PFObject
    [feed saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"Feed already post");
            [self hideAddFeedOverlay];
        }
        else
        {
            NSLog(@"Error : %@", [error localizedDescription]);
        }
    }];
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
    SignUpViewController *signupVC = (SignUpViewController *)[[self storyboard] instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self.navigationController pushViewController:signupVC animated:NO];
}

- (void)showSignInWithNotification:(NSNotification *)notification
{
    SignInViewController *signupVC = (SignInViewController *)[[self storyboard] instantiateViewControllerWithIdentifier:@"SignInViewController"];
    [self.navigationController pushViewController:signupVC animated:NO];
}

- (void)showActionSheetWihtNotification:(NSNotification *)notification
{
    [self displayActionSheet];
}

#pragma mark - Progress HUD

- (void)reset
{
    [HUD hide:YES];
    [HUD performAction:M13ProgressViewActionNone animated:NO];
}

#pragma mark - DoImagePickerControllerDelegate
- (void)didCancelDoImagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectPhotosFromDoImagePickerController:(DoImagePickerController *)picker result:(NSArray *)aSelected
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (picker.nResultType == DO_PICKER_RESULT_UIIMAGE)
    {
        for (int i = 0; i < MIN(4, aSelected.count); i++)
        {
//            UIImageView *iv = _aIVs[i];
//            iv.image = aSelected[i];
            _postImageView.image = aSelected[i];
        }
    }
    else if (picker.nResultType == DO_PICKER_RESULT_ASSET)
    {
        for (int i = 0; i < MIN(4, aSelected.count); i++)
        {
//            UIImageView *iv = _aIVs[i];
//            iv.image = [ASSETHELPER getImageFromAsset:aSelected[i] type:ASSET_PHOTO_SCREEN_SIZE];
            _postImageView.image = [ASSETHELPER getImageFromAsset:aSelected[i] type:ASSET_PHOTO_SCREEN_SIZE];
        }
        
        [ASSETHELPER clearData];
    }
    
    _postImageView.alpha = 1;
}

#pragma mark - ActionSheet
- (void)displayActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"NeighborAPP" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Sign In", @"Sign Up", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault; [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_INTRO_SIGNIN" object:nil];
            break;
        case 1:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_INTRO_SIGNUP" object:nil];
            break;
    }
}


@end
