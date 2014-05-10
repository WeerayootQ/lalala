//
//  NotificationViewController.m
//  ParseStarterProject
//
//  Created by Q on 5/9/14.
//
//

#import "NotificationViewController.h"
#import "FRDLivelyButton.h"
#import "CommentViewController.h"

@interface NotificationViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@end

@implementation NotificationViewController

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
    [self fetchUserNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
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
    PFObject *notiObj = (PFObject *)self.dataSourceArray[indexPath.row];
    PFUser *byUser = notiObj[@"noti_by"];
    if ([[notiObj objectForKey:@"noti_type"] isEqualToString:@"LIKE"])
    {
        UIImageView *userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 45, 45)];
        userAvatar.backgroundColor = [UIColor greenColor];
        userAvatar.image = [UIImage imageWithContentsOfFile:[[BuzzAppHelper sharedInstance] getAnswerFilePathWithName:byUser.username]];
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:userAvatar.bounds];
        userAvatar.layer.masksToBounds = NO;
        userAvatar.layer.shadowColor = [UIColor blackColor].CGColor;
        userAvatar.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        userAvatar.layer.shadowOpacity = 0.5f;
        userAvatar.layer.shadowPath = shadowPath.CGPath;
        
        UILabel *notiLabel = [[UILabel alloc] initWithFrame:CGRectMake(userAvatar.frame.origin.x + userAvatar.frame.size.width + 5, 5, self.view.frame.size.width, 30)];
        notiLabel.text = [NSString stringWithFormat:@"%@ commented on your post", byUser.username];
        notiLabel.font = FONT_LIGHT(16);
        NSString *darkText = byUser.username;
        NSString *lightText = @"commented on your post";
        NSString *text = [NSString stringWithFormat:@"%@ %@", darkText, lightText];
        
        // Define general attributes for the entire text
        NSDictionary *attribs = @{NSForegroundColorAttributeName:notiLabel.textColor,
                                  NSFontAttributeName:notiLabel.font};
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text
                                                                                           attributes:attribs];
        // Dark text attributes
        UIColor *darkColor = [UIColor blackColor];
        NSRange darkTextRange = [text rangeOfString:darkText];
        [attributedText setAttributes:@{NSForegroundColorAttributeName:darkColor,
                                        NSFontAttributeName:FONT_BOLD(16)}
                                range:darkTextRange];
        
        // Light text attributes
        UIColor *lightColor = [UIColor lightGrayColor];
        NSRange lightTextRange = [text rangeOfString:lightText];
        [attributedText setAttributes:@{NSForegroundColorAttributeName:lightColor}
                                range:lightTextRange];
        notiLabel.attributedText = attributedText;
        
        NSDate *createdAt = notiObj.createdAt;
        UILabel *timeStampLabel = [[UILabel alloc] initWithFrame:CGRectMake(userAvatar.frame.origin.x + userAvatar.frame.size.width + 5, 25, self.view.frame.size.width, 30)];
        timeStampLabel.text = [NSString stringWithFormat:@"%@", [self relativeDateStringForDate:createdAt]];
        timeStampLabel.font = FONT_LIGHT(14);
        timeStampLabel.textColor = [UIColor lightGrayColor];
        
        [cell.contentView addSubview:userAvatar];
        [cell.contentView addSubview:notiLabel];
        [cell.contentView addSubview:timeStampLabel];
    }
    else if ([[notiObj objectForKey:@"noti_type"] isEqualToString:@"COMMENT"])
    {
        UIImageView *userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 45, 45)];
        userAvatar.backgroundColor = [UIColor greenColor];
        userAvatar.image = [UIImage imageWithContentsOfFile:[[BuzzAppHelper sharedInstance] getAnswerFilePathWithName:byUser.username]];
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:userAvatar.bounds];
        userAvatar.layer.masksToBounds = NO;
        userAvatar.layer.shadowColor = [UIColor blackColor].CGColor;
        userAvatar.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        userAvatar.layer.shadowOpacity = 0.5f;
        userAvatar.layer.shadowPath = shadowPath.CGPath;
        
        UILabel *notiLabel = [[UILabel alloc] initWithFrame:CGRectMake(userAvatar.frame.origin.x + userAvatar.frame.size.width + 5, 5, self.view.frame.size.width, 30)];
        notiLabel.text = [NSString stringWithFormat:@"%@ commented on your post", byUser.username];
        notiLabel.font = FONT_LIGHT(16);
        NSString *darkText = byUser.username;
        NSString *lightText = @"commented on your post";
        NSString *text = [NSString stringWithFormat:@"%@ %@", darkText, lightText];
        
        // Define general attributes for the entire text
        NSDictionary *attribs = @{NSForegroundColorAttributeName:notiLabel.textColor,
                                  NSFontAttributeName:notiLabel.font};
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text
                                                                                           attributes:attribs];
        // Dark text attributes
        UIColor *darkColor = [UIColor blackColor];
        NSRange darkTextRange = [text rangeOfString:darkText];
        [attributedText setAttributes:@{NSForegroundColorAttributeName:darkColor,
                                        NSFontAttributeName:FONT_BOLD(16)}
                                range:darkTextRange];
            
        // Light text attributes
        UIColor *lightColor = [UIColor lightGrayColor];
        NSRange lightTextRange = [text rangeOfString:lightText];
        [attributedText setAttributes:@{NSForegroundColorAttributeName:lightColor}
                                range:lightTextRange];
        notiLabel.attributedText = attributedText;
        
        NSDate *createdAt = notiObj.createdAt;
        UILabel *timeStampLabel = [[UILabel alloc] initWithFrame:CGRectMake(userAvatar.frame.origin.x + userAvatar.frame.size.width + 5, 25, self.view.frame.size.width, 30)];
        timeStampLabel.text = [NSString stringWithFormat:@"%@", [self relativeDateStringForDate:createdAt]];
        timeStampLabel.font = FONT_LIGHT(14);
        timeStampLabel.textColor = [UIColor lightGrayColor];
        
        [cell.contentView addSubview:userAvatar];
        [cell.contentView addSubview:notiLabel];
        [cell.contentView addSubview:timeStampLabel];
    }
    else
    {
        UIImageView *userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 45, 45)];
        userAvatar.backgroundColor = [UIColor greenColor];
        userAvatar.image = [UIImage imageWithContentsOfFile:[[BuzzAppHelper sharedInstance] getAnswerFilePathWithName:byUser.username]];
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:userAvatar.bounds];
        userAvatar.layer.masksToBounds = NO;
        userAvatar.layer.shadowColor = [UIColor blackColor].CGColor;
        userAvatar.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        userAvatar.layer.shadowOpacity = 0.5f;
        userAvatar.layer.shadowPath = shadowPath.CGPath;
        
        UILabel *notiLabel = [[UILabel alloc] initWithFrame:CGRectMake(userAvatar.frame.origin.x + userAvatar.frame.size.width + 5, 5, self.view.frame.size.width, 30)];
        notiLabel.text = [NSString stringWithFormat:@"%@ commented on your post", byUser.username];
        notiLabel.font = FONT_LIGHT(16);
        NSString *darkText = byUser.username;
        NSString *lightText = @"commented on your post";
        NSString *text = [NSString stringWithFormat:@"%@ %@", darkText, lightText];
        
        // Define general attributes for the entire text
        NSDictionary *attribs = @{NSForegroundColorAttributeName:notiLabel.textColor,
                                  NSFontAttributeName:notiLabel.font};
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text
                                                                                           attributes:attribs];
        // Dark text attributes
        UIColor *darkColor = [UIColor blackColor];
        NSRange darkTextRange = [text rangeOfString:darkText];
        [attributedText setAttributes:@{NSForegroundColorAttributeName:darkColor,
                                        NSFontAttributeName:FONT_BOLD(16)}
                                range:darkTextRange];
        
        // Light text attributes
        UIColor *lightColor = [UIColor lightGrayColor];
        NSRange lightTextRange = [text rangeOfString:lightText];
        [attributedText setAttributes:@{NSForegroundColorAttributeName:lightColor}
                                range:lightTextRange];
        notiLabel.attributedText = attributedText;
        
        NSDate *createdAt = notiObj.createdAt;
        UILabel *timeStampLabel = [[UILabel alloc] initWithFrame:CGRectMake(userAvatar.frame.origin.x + userAvatar.frame.size.width + 5, 25, self.view.frame.size.width, 30)];
        timeStampLabel.text = [NSString stringWithFormat:@"%@", [self relativeDateStringForDate:createdAt]];
        timeStampLabel.font = FONT_LIGHT(14);
        timeStampLabel.textColor = [UIColor lightGrayColor];
        
        [cell.contentView addSubview:userAvatar];
        [cell.contentView addSubview:notiLabel];
        [cell.contentView addSubview:timeStampLabel];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *notiObj = (PFObject *)self.dataSourceArray[indexPath.row];
    PFObject *forFeedObject = [notiObj objectForKey:@"noti_for_feed"];
    
    NSLog(@"SELECTED");
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    CommentViewController *commtentVC = (CommentViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    commtentVC.feedObj = forFeedObject;
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:commtentVC];
    [self presentViewController:rootVC animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 150, 20)];
    headerLabel.font = FONT_BOLD(20);
    headerLabel.text = @"Notifications";
    
    // close button
    FRDLivelyButton *closeBtn = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 40, 10, 36, 28)];
    [closeBtn setOptions:@{ kFRDLivelyButtonLineWidth: @(2.0f),
                            kFRDLivelyButtonHighlightedColor: [UIColor blackColor],
                            kFRDLivelyButtonColor: [UIColor blackColor]
                                 }];
    [closeBtn setStyle:kFRDLivelyButtonStyleClose animated:NO];
    [closeBtn addTarget:self action:@selector(doneBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:headerLabel];
    [headerView addSubview:closeBtn];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0f;
}


#pragma mark - Fetch Notification

- (void)fetchUserNotification
{
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
    [query whereKey:@"noti_for_user" equalTo:currentUser];
    [query includeKey:@"noti_by"];
    [query includeKey:@"createdAt"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"count object : %d", objects.count);
        NSLog(@"object : %@", objects);
        if (self.dataSourceArray != nil)
        {
            self.dataSourceArray = nil;
            self.dataSourceArray = [NSMutableArray arrayWithArray:objects];
        }
        else
        {
            self.dataSourceArray = [NSMutableArray arrayWithArray:objects];
        }
        
        [self.tableView reloadData];
//        for (PFObject *commentObj in self.data)
//        {
//            [self.dataSourceArray addObject:@{ @"comment": commentObj,
//                                               @"type": @(AMBubbleCellReceived)}];
//        }
        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.dataSourceArray.count - 1) inSection:0];
//        NSLog(@"INDEX : %d", indexPath.row);
//        [self.tableView beginUpdates];
//        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//        [self.tableView endUpdates];
//        [super reloadTableScrollingToBottom:YES];
    }];

}

#pragma mark - Timestamp relative format

- (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setAMSymbol:@"am"];
    [dateFormatter setPMSymbol:@"pm"];
    
    NSString* timestamp;
    int timeIntervalInHours = (int)[[NSDate date] timeIntervalSinceDate:date] /3600;
    
    int timeIntervalInMinutes = [[NSDate date] timeIntervalSinceDate:date] /60;
    
    if (timeIntervalInMinutes <= 2){//less than 2 minutes old
        
        timestamp = @"Just Now";
        
    }else if(timeIntervalInMinutes < 15){//less than 15 minutes old
        
        timestamp = @"A few minutes ago";
        
    }else if(timeIntervalInHours < 24){//less than 1 day
        
        [dateFormatter setDateFormat:@"h:mm a"];
        timestamp = [NSString stringWithFormat:@"Today at %@",[dateFormatter stringFromDate:date]];
        
    }else if (timeIntervalInHours < 48){//less than 2 days
        
        [dateFormatter setDateFormat:@"h:mm a"];
        timestamp = [NSString stringWithFormat:@"Yesterday at %@",[dateFormatter stringFromDate:date]];
        
    }else if (timeIntervalInHours < 168){//less than  a week
        
        [dateFormatter setDateFormat:@"EEEE"];
        timestamp = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
        
    }else if (timeIntervalInHours < 8765){//less than a year
        
        [dateFormatter setDateFormat:@"d MMMM"];
        timestamp = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
        
    }else{//older than a year
        
        [dateFormatter setDateFormat:@"d MMMM yyyy"];
        timestamp = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
        
    }
    
    return timestamp;
}

#pragma mark - Button Action

- (void)doneBtnTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
