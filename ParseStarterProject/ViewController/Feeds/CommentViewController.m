//
//  CommentViewController.m
//  ParseStarterProject
//
//  Created by Q on 5/7/14.
//
//

#import "CommentViewController.h"

@interface CommentViewController () <AMBubbleTableDataSource, AMBubbleTableDelegate>

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

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
    // Fetch Data
    [self fetchCommentData];

    // Set a style
	[self setTableStyle:AMBubbleTableStyleFlat];
    [self setDataSource:self]; // Weird, uh?
	[self setDelegate:self];
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
    PFUser *user = _feedObj[@"feed_by"];
    PFFile *file = user[@"userImage"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error)
        {
            UIImage *image = [UIImage imageWithData:data];
        }
    }];

	return [UIImage imageNamed:@"avatar"];
}

#pragma mark - AMBubbleTableDelegate

- (void)didSendText:(NSString*)text
{
	NSLog(@"User wrote: %@", text);
	
    PFUser *currentUser = [PFUser currentUser];
    
    // Create the comment
    PFObject *myComment = [PFObject objectWithClassName:@"Comments"];
    myComment[@"comment_msg"] = text;//@"Let's do Sushirrito.";
 
    // Add a relation between the Post and Comment
    myComment[@"comment_feed_id"] = self.feedObj;
    myComment[@"comment_by"] = currentUser;
    
    // This will save both myPost and myComment
    [myComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [self fetchCommentDataAfterSend];
        }
    }];
    
//    // Create  like
//    PFObject *like = [PFObject objectWithClassName:@"Likes"];
//    // Add a relation between the Post and Comment
//    like[@"like_feed_id"] = self.feedObj;
//    like[@"like_by"] = currentUser;
//    
//    // This will save both myPost and myComment
//    [like saveInBackground];
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
        }
        
        [self.tableView reloadData];
    }];
}

@end
