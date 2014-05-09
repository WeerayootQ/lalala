//
//  NotificationViewController.m
//  ParseStarterProject
//
//  Created by Q on 5/9/14.
//
//

#import "NotificationViewController.h"

@interface NotificationViewController () <UITableViewDataSource, UITableViewDelegate>

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
    return 30;
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
    cell.textLabel.text = @"NOTIFICATION";
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
//        if (self.data != nil)
//        {
//            self.data = nil;
//            self.dataSourceArray = nil;
//            self.data = [NSMutableArray arrayWithArray:objects];
//            self.dataSourceArray = [NSMutableArray array];
//        }
//        
//        for (PFObject *commentObj in self.data)
//        {
//            [self.dataSourceArray addObject:@{ @"comment": commentObj,
//                                               @"type": @(AMBubbleCellReceived)}];
//        }
//        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.dataSourceArray.count - 1) inSection:0];
//        NSLog(@"INDEX : %d", indexPath.row);
//        [self.tableView beginUpdates];
//        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//        [self.tableView endUpdates];
//        [super reloadTableScrollingToBottom:YES];
    }];

}

@end
