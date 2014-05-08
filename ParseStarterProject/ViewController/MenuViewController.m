//
//  MenuViewController.m
//  ParseStarterProject
//
//  Created by Q on 1/25/14.
//
//

#import "MenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "MeneCell.h"

@interface MenuViewController ()
@property (nonatomic, strong) UINavigationController *transitionsNavigationController;
@property (nonatomic, strong) NSArray *menuArray;
@end

@implementation MenuViewController

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.transitionsNavigationController = (UINavigationController *)self.slidingViewController.topViewController;
    _menuArray = @[@"Feeds", @"Notifications", @"Members", @"Profile", @"Settings"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _menuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    MeneCell *cell;
    if(cell == nil)
    {
        cell = [[MeneCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(MeneCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setupMenuCellWithText:_menuArray[indexPath.row]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *menuItem = _menuArray[indexPath.row];
    
    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);
    if ([menuItem isEqualToString:@"Feeds"])
    {
        self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedViewController"];
    }
    else if ([menuItem isEqualToString:@"Notifications"])
    {
        self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
    }
    else if ([menuItem isEqualToString:@"Members"])
    {
        self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MembersViewController"];
    }
    else if ([menuItem isEqualToString:@"Profile"])
    {
        self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    }
    else if ([menuItem isEqualToString:@"Settings"])
    {
        self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    }
    
    [self.slidingViewController resetTopViewAnimated:YES];
}

@end
