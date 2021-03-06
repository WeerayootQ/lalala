//
//  CommentViewController.m
//  ParseStarterProject
//
//  Created by Q on 5/7/14.
//
//

#import "CommentViewController.h"
#import "FRDLivelyButton.h"

@interface CommentViewController () <AMBubbleTableDataSource, AMBubbleTableDelegate>

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) FRDLivelyButton *closeBtn;

@end

@implementation CommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // close button
    self.closeBtn = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 40, 10, 36, 28)];
    [self.closeBtn setOptions:@{ kFRDLivelyButtonLineWidth: @(2.0f),
                                 kFRDLivelyButtonHighlightedColor: [UIColor blackColor],
                                 kFRDLivelyButtonColor: [UIColor blackColor]
                               }];
    [self.closeBtn setStyle:kFRDLivelyButtonStyleClose animated:NO];
    [self.closeBtn addTarget:self action:@selector(doneBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeBtn];
    // Fetch Data
    [self fetchCommentData];

    // Set a style
    [self setDataSource:self]; // Weird, uh?
	[self setDelegate:self];
    [self setTableStyle:AMBubbleTableStyleFlat];
    [super setFeedObject:self.feedObj];
    [super fetchLikeUsers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AMBubbleTableDataSource

- (NSInteger)numberOfRows
{
	return self.dataSourceArray.count;
}

- (AMBubbleCellType)cellTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self.dataSourceArray[indexPath.row][@"type"] intValue];
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *obj = (PFObject *)self.dataSourceArray[indexPath.row][@"comment"];
	return [obj objectForKey:@"comment_msg"];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [NSDate date];
}

- (UIImage *)avatarForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *obj = (PFObject *)self.dataSourceArray[indexPath.row][@"comment"];
    PFUser *user = obj[@"comment_by"];
	return [UIImage imageWithContentsOfFile:[[BuzzAppHelper sharedInstance] getAnswerFilePathWithName:[user objectForKey:@"username"]]];
}

#pragma mark - AMBubbleTableDelegate

- (void)didSendText:(NSString*)text
{
	NSLog(@"User wrote: %@", text);
    PFUser *currentUser = [PFUser currentUser];
    PFObject *myComment = [PFObject objectWithClassName:@"Comments"];
    myComment[@"comment_msg"] = text;
    myComment[@"comment_feed_id"] = self.feedObj;
    myComment[@"comment_by"] = currentUser;
    [myComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [self fetchCommentDataAfterSend];
            // Subscribing Comment Chanel
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation addUniqueObject:[NSString stringWithFormat:@"COMMENT%@", self.feedObj.objectId] forKey:@"channels"];
            [currentInstallation saveInBackground];
            
            NSDictionary *payload = @{@"alert" : [NSString stringWithFormat:@"%@ commented on your post.", currentUser.username],
                                      @"Increment" : @"badge"};
            
            PFPush *push = [[PFPush alloc] init];
            [push setChannel:[NSString stringWithFormat:@"COMMENT%@", self.feedObj.objectId]];
            [push setData:payload];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    PFUser *feedOwener = self.feedObj[@"feed_by"];
                    PFObject *notiRecord = [PFObject objectWithClassName:@"Notification"];
                    notiRecord[@"noti_for_user"] = feedOwener;
                    notiRecord[@"noti_by"] = currentUser;
                    notiRecord[@"noti_type"] = @"COMMENT";
                    notiRecord[@"noti_for_feed"] = self.feedObj;
                    [notiRecord saveInBackground];
                }
            }];
        }
    }];
}

- (NSString*)usernameForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.data[indexPath.row][@"username"];
}

- (UIColor*)usernameColorForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.data[indexPath.row][@"color"];
}

- (void)fetchCommentDataAfterSend
{
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    [query whereKey:@"comment_feed_id" equalTo:self.feedObj];
    [query includeKey:@"comment_by"];
    [query includeKey:@"createdAt"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"count object : %d", objects.count);
        NSLog(@"object : %@", objects);
        if (self.data != nil)
        {
            self.data = nil;
            self.dataSourceArray = nil;
            self.data = [NSMutableArray arrayWithArray:objects];
            self.dataSourceArray = [NSMutableArray array];
        }
        
        for (PFObject *commentObj in self.data)
        {
            [self.dataSourceArray addObject:@{ @"comment": commentObj,
                                               @"type": @(AMBubbleCellReceived)}];
        }

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.dataSourceArray.count - 1) inSection:0];
        NSLog(@"INDEX : %d", indexPath.row);
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        [super reloadTableScrollingToBottom:YES];
    }];
}

- (void)fetchCommentData
{
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    [query whereKey:@"comment_feed_id" equalTo:self.feedObj];
    [query includeKey:@"comment_by"];
    [query includeKey:@"createdAt"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"count object : %d", objects.count);
        NSLog(@"object : %@", objects);
        if (self.data == nil)
        {
            self.data = [NSMutableArray arrayWithArray:objects];
            self.dataSourceArray = [NSMutableArray array];
        }
        self.data = [objects mutableCopy];
        
        for (PFObject *commentObj in self.data)
        {
            [self.dataSourceArray addObject:@{ @"comment": commentObj,
                                               @"type": @(AMBubbleCellReceived)}];
            
            PFUser *user = commentObj[@"comment_by"];
            PFFile *file = user[@"userImage"];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error)
                {
                    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"UserAvatar/%@.png", [user objectForKey:@"username"]]];
                    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                    if (!fileExists)
                    {
                        [data writeToFile:[[BuzzAppHelper sharedInstance] getAnswerFilePathWithName:[user objectForKey:@"username"]] atomically:YES];
                        NSLog(@"Download to Cache");
                    }
                    else
                    {
                        NSLog(@"Not Cache");
                    }
                }
            }];
        }
        
        [self.tableView reloadData];
    }];
}

#pragma mark - Button Action

- (void)doneBtnTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
