//
//  FeedCell.m
//  ParseStarterProject
//
//  Created by Q on 1/25/14.
//
//

#import "FeedCell.h"

@implementation FeedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    for (UIView *subviews in [self.contentView subviews])
    {
        [subviews removeFromSuperview];
    }
}

- (void)setupContentViewWithObj:(PFObject *)obj
{
    PFUser *user = obj[@"feed_by"];
    
    _feedUserImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10 + 5, 30, 30)];
    _feedUserImageView.backgroundColor = [UIColor clearColor];
    _feedUserImageView.image = [UIImage imageNamed:@"user_temp.jpeg"]; // TODO
    _feedUserImageView.layer.cornerRadius = 15;
    _feedUserImageView.layer.masksToBounds = YES;
    
    _feedUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 12 + 5, 200, 15)];
    _feedUserLabel.backgroundColor = [UIColor clearColor];
    _feedUserLabel.textColor = [UIColor darkGrayColor];
    _feedUserLabel.textAlignment = NSTextAlignmentLeft;
    _feedUserLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    _feedUserLabel.text = user.username; // TODO
    
    _feedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 27 + 5, 200, 15)];
    _feedTimeLabel.backgroundColor = [UIColor clearColor];
    _feedTimeLabel.textColor = [UIColor darkGrayColor];
    _feedTimeLabel.textAlignment = NSTextAlignmentLeft;
    _feedTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:9];
    _feedTimeLabel.text = @"Last 10 minutes ago"; // TODO
    
    _feedMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 42 + 5, 200, 60)];
    _feedMsgLabel.backgroundColor = [UIColor clearColor];
    _feedMsgLabel.textColor = [UIColor darkGrayColor];
    _feedMsgLabel.textAlignment = NSTextAlignmentLeft;
    _feedMsgLabel.numberOfLines = 0;
    _feedMsgLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    _feedMsgLabel.text = obj[@"feed_msg"];//@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla id eleifend sapien. Nulla venenatis luctus tellus in mollis turpis duis."; // TODO
    
    // Comment section
    _feedCommentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _feedCommentBtn.backgroundColor = [UIColor clearColor];
    _feedCommentBtn.frame = CGRectMake(260, 110, 25, 25);
    [_feedCommentBtn setImage:[UIImage imageNamed:@"comment_icon.png"] forState:UIControlStateNormal];
    
    _feedNumberCommentLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 110, 25, 25)];
    _feedNumberCommentLabel.backgroundColor = [UIColor clearColor];
    _feedNumberCommentLabel.textColor = [UIColor whiteColor];
    _feedNumberCommentLabel.textAlignment = NSTextAlignmentCenter;
    _feedNumberCommentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:8];
    _feedNumberCommentLabel.text = @""; // TODO
    
    // Thumbup section
    _feedThumbBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _feedThumbBtn.backgroundColor = [UIColor clearColor];
    _feedThumbBtn.frame = CGRectMake(285, 110, 25, 25);
    [_feedThumbBtn setImage:[UIImage imageNamed:@"thumbup_icon.png"] forState:UIControlStateNormal];
    
    _feedNumberThumbupLabel = [[UILabel alloc] initWithFrame:CGRectMake(285, 110, 25, 25)];
    _feedNumberThumbupLabel.backgroundColor = [UIColor clearColor];
    _feedNumberThumbupLabel.textColor = [UIColor whiteColor];
    _feedNumberThumbupLabel.textAlignment = NSTextAlignmentCenter;
    _feedNumberThumbupLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:8];
    _feedNumberThumbupLabel.text = @""; // TODO
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 250)];
    bgView.backgroundColor = [UIColor colorWithRed:226/255.0f green:226/255.0f blue:226/255.0f alpha:1.0f];
    bgView.layer.cornerRadius = 2;
    bgView.layer.masksToBounds = YES;
    
    // Add subviews
    [self.contentView addSubview:bgView];
    [self.contentView addSubview:_feedUserImageView];
    [self.contentView addSubview:_feedUserLabel];
    [self.contentView addSubview:_feedTimeLabel];
    [self.contentView addSubview:_feedMsgLabel];
//    [self.contentView addSubview:_feedCommentBtn];
//    [self.contentView addSubview:_feedNumberCommentLabel];
//    [self.contentView addSubview:_feedThumbBtn];
//    [self.contentView addSubview:_feedNumberThumbupLabel];
}

- (void)setFeedObj:(PFObject *)feedObj
{
    _feedObj = feedObj;
    
    [self setupContentViewWithObj:_feedObj];
}

@end
