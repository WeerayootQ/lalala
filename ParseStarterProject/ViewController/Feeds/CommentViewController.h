//
//  CommentViewController.h
//  ParseStarterProject
//
//  Created by Q on 5/7/14.
//
//

#import <UIKit/UIKit.h>

@interface CommentViewController : AMBubbleTableViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) PFObject *feedObj;

@end
