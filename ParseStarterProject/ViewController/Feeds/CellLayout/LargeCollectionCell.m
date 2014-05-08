//
//  LargeCollectionCell.m
//  ParseStarterProject
//
//  Created by Q on 3/22/14.
//
//

#import "LargeCollectionCell.h"

@implementation LargeCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fake-cell"]];
        self.backgroundView = backgroundView;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 80, 80)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.image = [UIImage imageNamed:@"user_temp.jpeg"];
        
        UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 60, 180, 30)];
        userLabel.backgroundColor = [UIColor redColor];
        userLabel.text = @"Weerayoot Ngandee";
        userLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:8];
        userLabel.textAlignment = NSTextAlignmentLeft;
        [userLabel sizeToFit];
        
        UILabel *userContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 75, 130, 30)];
        userContentLabel.backgroundColor = [UIColor grayColor];
        userContentLabel.text = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure";
        userContentLabel.font = [UIFont fontWithName:@"Helvetica" size:8];
        userContentLabel.textAlignment = NSTextAlignmentLeft;
        userContentLabel.numberOfLines = 0;
        [userContentLabel sizeToFit];
        
        
        [self.contentView addSubview:imageView];
        [self.contentView addSubview:userLabel];
        [self.contentView addSubview:userContentLabel];
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

@end
