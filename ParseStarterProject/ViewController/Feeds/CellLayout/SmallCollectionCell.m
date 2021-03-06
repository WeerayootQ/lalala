//
//  SmallCollectionCell.m
//  ParseStarterProject
//
//  Created by Q on 3/22/14.
//
//

#import "SmallCollectionCell.h"

@implementation SmallCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
    [self setLayoutWithFrameSize:self.frame.size];
}

- (void)setFeedObj:(PFObject *)feedObj
{
    _feedObj = feedObj;
    PFUser *user = _feedObj[@"feed_by"];
    PFFile *file = user[@"userImage"];
    NSLog(@"ID : %@", _feedObj.objectId);

    self.backgroundColor = [UIColor whiteColor];
    self.userImageView = [[UIImageView alloc] init];//WithFrame:CGRectMake(8, 8, self.contentView.frame.size.width * 0.35, self.contentView.frame.size.width * 0.35)];
    self.usernameLabel = [[UITextView alloc] init];//WithFrame:CGRectMake(8, 60, self.contentView.frame.size.width - 16, 30)];
    self.userContentLabel = [[UITextView alloc] init];//WithFrame:CGRectMake(8, 80, self.contentView.frame.size.width - 16, 30)];
    self.usernameLabel.font = FONT_REG(12);
    self.usernameLabel.backgroundColor = [UIColor clearColor];
    self.usernameLabel.textAlignment = NSTextAlignmentLeft;
    self.usernameLabel.userInteractionEnabled = NO;
    self.userContentLabel.userInteractionEnabled = NO;
    self.userContentLabel.font = FONT_LIGHT(10);
    self.userContentLabel.backgroundColor = [UIColor clearColor];
    self.userContentLabel.textAlignment = NSTextAlignmentLeft;
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.userImageView.clipsToBounds = YES;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error)
        {
            UIImage *image = [UIImage imageWithData:data];
            self.userImageView.image = image;
        }
    }];

    self.usernameLabel.text = user.username;;
    self.userContentLabel.text = _feedObj[@"feed_msg"];
    
    [[self userImageView] setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self usernameLabel] setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self userContentLabel] setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    self.separator = [[UIView alloc] initWithFrame:CGRectMake(15, self.contentView.frame.size.height - 50, 290, 1)];
    self.separator.backgroundColor = [UIColor blackColor];
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.likeButton.frame = CGRectMake(50, 50, 32, 29);
    self.likeButton.backgroundColor = [UIColor clearColor];
    [self.likeButton addTarget:self action:@selector(likeBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.likeButton setImage:[UIImage imageNamed:@"like-icon.png"] forState:UIControlStateNormal];
    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButton.frame = CGRectMake(100, 50, 32, 29);
    self.commentButton.backgroundColor = [UIColor clearColor];
    [self.commentButton addTarget:self action:@selector(commentBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentButton setImage:[UIImage imageNamed:@"comment-icon.png"] forState:UIControlStateNormal];
    
    self.numberOfLikeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - 150, 50, 75, 29)];
    self.numberOfLikeLabel.backgroundColor = [UIColor clearColor];
    self.numberOfLikeLabel.textAlignment = NSTextAlignmentRight;
    self.numberOfLikeLabel.font = FONT_LIGHT(10);
    self.numberOfLikeLabel.text = @"30 Likes 100 Comments";
    
    [self.contentView addSubview:self.userImageView];
    [self.contentView addSubview:self.usernameLabel];
    [self.contentView addSubview:self.userContentLabel];
    [self.contentView addSubview:self.separator];
    [self.contentView addSubview:self.likeButton];
    [self.contentView addSubview:self.commentButton];
    [self.contentView addSubview:self.numberOfLikeLabel];
    [self setLayoutWithFrameSize:self.frame.size];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    for (UIView *sub in self.contentView.subviews)
    {
        [sub removeFromSuperview];
    }
}

- (void)setLayoutForSmallLayoutWithDestinationSize:(CGSize)size
{
    self.userImageView.frame = CGRectMake(8, 8, 45, 45);
    self.usernameLabel.frame = CGRectMake(8, 60, 180, self.frame.size.height - 70);
    self.usernameLabel.font = FONT_REG(12);
    self.userContentLabel.frame = CGRectMake(8, 80, 130, self.frame.size.height - 90);
    self.userContentLabel.font = FONT_LIGHT(10);
    self.separator.hidden = YES;
    self.likeButton.hidden = YES;
    self.commentButton.hidden = YES;
    self.numberOfLikeLabel.hidden = YES;
    self.numberOfCommentLabel.hidden = YES;
}

- (void)setLayoutForLargeLayoutWithDestinationSize:(CGSize)size
{
    self.userImageView.frame = CGRectMake(15, 15, 80, 80);
    self.usernameLabel.frame = CGRectMake(15, 105, 290, self.frame.size.height - 115);
    self.usernameLabel.font = FONT_REG(24);
    self.userContentLabel.frame = CGRectMake(15, 144, 290, self.frame.size.height - 154);
    self.userContentLabel.font = FONT_LIGHT(20);
    self.separator.hidden = NO;
    self.separator.frame = CGRectMake(15, self.frame.size.height - 55, 290, 1);
    self.likeButton.hidden = NO;
    self.likeButton.frame = CGRectMake(15, self.frame.size.height - 40, 32, 29);
    self.commentButton.hidden = NO;
    self.commentButton.frame = CGRectMake(15 + 15 + 32, self.frame.size.height - 40, 32, 29);
    self.numberOfLikeLabel.hidden = NO;
    self.numberOfLikeLabel.frame = CGRectMake(15, self.frame.size.height - 35, 290, 29);
}

- (void)setLayoutWithFrameSize:(CGSize)size
{
    if (size.width >= 320.0)
    {
        [self setLayoutForLargeLayoutWithDestinationSize:size];
    }
    else
    {
        [self setLayoutForSmallLayoutWithDestinationSize:size];
    }
}

- (void)likeBtnTapped:(id)sender
{
    NSLog(@"Like");
    
    // Check current user already liked
    PFUser *currentUser = [PFUser currentUser];

    if ([self checkUserAlreadyLiked:currentUser] == NO)
    {
        // Create  like
        PFObject *like = [PFObject objectWithClassName:@"Likes"];
        like[@"like_feed_id"] = _feedObj;
        like[@"like_by"] = currentUser;
        [like saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            // Subscribing Comment Chanel
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation addUniqueObject:[NSString stringWithFormat:@"LIKE%@", _feedObj.objectId] forKey:@"channels"];
            [currentInstallation saveInBackground];
            
            NSDictionary *payload = @{@"alert" : [NSString stringWithFormat:@"%@ liked your post.", currentUser.username],
                                      @"Increment" : @"badge"};
            
            PFPush *push = [[PFPush alloc] init];
            [push setChannel:[NSString stringWithFormat:@"LIKE%@", _feedObj.objectId]];
            [push setData:payload];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    PFUser *feedOwener = _feedObj[@"feed_by"];
                    PFObject *notiRecord = [PFObject objectWithClassName:@"Notification"];
                    notiRecord[@"noti_for_user"] = feedOwener;
                    notiRecord[@"noti_by"] = currentUser;
                    notiRecord[@"noti_type"] = @"LIKE";
                    notiRecord[@"noti_for_feed"] = self.feedObj;
                    [notiRecord saveInBackground];
                }
            }];
        }];
    }
    else
    {
        NSLog(@"This user already liked");
    }
}

- (void)commentBtnTapped:(id)sender
{
    NSLog(@"Comment");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_COMMENT" object:_feedObj];
}

- (BOOL)checkUserAlreadyLiked:(PFUser *)currentUser
{
    __block BOOL isLiked;
    PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
    [query whereKey:@"like_feed_id" equalTo:_feedObj];
    [query includeKey:@"like_by"];
    [query includeKey:@"createdAt"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"count object : %d", objects.count);
        NSLog(@"object : %@", objects);
        
        for (int i = 0; i < objects.count; i++)
        {
            PFUser *likedUser = objects[i][@"like_by"];
            if (![currentUser.username isEqualToString:likedUser.username])
            {
                isLiked = NO;
            }
            else
            {
                isLiked = YES;
            }
        }
    }];
    
    return isLiked;
}

@end
