//
//  CommentViewController.m
//  ParseStarterProject
//
//  Created by Q on 5/7/14.
//
//

#import "CommentViewController.h"

@interface CommentViewController () <AMBubbleTableDataSource, AMBubbleTableDelegate>

@property (nonatomic, strong) NSMutableArray* data;

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
    self.tableView.frame = CGRectMake(0, 60, 320, self.view.bounds.size.height - 60);
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self setDataSource:self]; // Weird, uh?
	[self setDelegate:self];
    
    // Dummy data
	self.data = [[NSMutableArray alloc] initWithArray:@[
                                                        @{
                                                            @"text": @"He felt that his whole life was some kind of dream and he sometimes wondered whose it was and whether they were enjoying it.",
                                                            @"date": [NSDate date],
                                                            @"type": @(AMBubbleCellReceived),
                                                            @"username": @"Stevie",
                                                            @"color": [UIColor redColor]
                                                            },
                                                        @{
                                                            @"text": @"My dad isn’t famous. My dad plays jazz. You can’t get famous playing jazz",
                                                            @"date": [NSDate date],
                                                            @"type": @(AMBubbleCellSent)
                                                            },
                                                        @{
                                                            @"date": [NSDate date],
                                                            @"type": @(AMBubbleCellTimestamp)
                                                            },
                                                        @{
                                                            @"text": @"I'd far rather be happy than right any day.",
                                                            @"date": [NSDate date],
                                                            @"type": @(AMBubbleCellReceived),
                                                            @"username": @"John",
                                                            @"color": [UIColor orangeColor]
                                                            },
                                                        @{
                                                            @"text": @"The only reason for walking into the jaws of Death is so's you can steal His gold teeth.",
                                                            @"date": [NSDate date],
                                                            @"type": @(AMBubbleCellSent)
                                                            },
                                                        @{
                                                            @"text": @"The gods had a habit of going round to atheists' houses and smashing their windows.",
                                                            @"date": [NSDate date],
                                                            @"type": @(AMBubbleCellReceived),
                                                            @"username": @"Jimi",
                                                            @"color": [UIColor blueColor]
                                                            },
                                                        @{
                                                            @"text": @"you are lucky. Your friend is going to meet Bel-Shamharoth. You will only die.",
                                                            @"date": [NSDate date],
                                                            @"type": @(AMBubbleCellSent)
                                                            },
                                                        @{
                                                            @"text": @"Guess the quotes!",
                                                            @"date": [NSDate date],
                                                            @"type": @(AMBubbleCellSent)
                                                            },
                                                        ]
				 ];
    
	// Set a style
	[self setTableStyle:AMBubbleTableStyleFlat];
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

//#pragma mark - UITableViewDataSource
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView
// numberOfRowsInSection:(NSInteger)section
//{
//    return 20;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView
//         cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *cellIdentifier = @"Cell";
//    UITableViewCell *cell;
//    if(cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
//    }
//    
//    [self configureCell:cell forRowAtIndexPath:indexPath];
//    
//    return cell;
//}
//
//- (void)configureCell:(UITableViewCell *)cell
//    forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.textLabel.text = @"Comemememememy sdfposdfksdfk";
//}
//
//#pragma mark - UITableViewDelegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"test");
//}

#pragma mark - AMBubbleTableDataSource

- (NSInteger)numberOfRows
{
	return self.data.count;
}

- (AMBubbleCellType)cellTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self.data[indexPath.row][@"type"] intValue];
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.data[indexPath.row][@"text"];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [NSDate date];
}

- (UIImage*)avatarForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [UIImage imageNamed:@"avatar"];
}

#pragma mark - AMBubbleTableDelegate

- (void)didSendText:(NSString*)text
{
	NSLog(@"User wrote: %@", text);
	
	[self.data addObject:@{ @"text": text,
                            @"date": [NSDate date],
                            @"type": @(AMBubbleCellSent)
                            }];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.data.count - 1) inSection:0];
	[self.tableView beginUpdates];
	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
	[self.tableView endUpdates];
	// [super reloadTableScrollingToBottom:YES];
}

- (NSString*)usernameForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.data[indexPath.row][@"username"];
}

- (UIColor*)usernameColorForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.data[indexPath.row][@"color"];
}

@end
