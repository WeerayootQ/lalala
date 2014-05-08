//
//  FeedObj.m
//  ParseStarterProject
//
//  Created by Q on 1/25/14.
//
//

#import "FeedObj.h"

@implementation FeedObj

static FeedObj *__sharedInstance = nil;

- (void)getFeeds
{
    PFQuery *query = [PFQuery queryWithClassName:@"Feed"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"count object : %d", objects.count);
    }];
}

@end
