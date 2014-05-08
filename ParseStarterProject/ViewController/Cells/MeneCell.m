//
//  MeneCell.m
//  ParseStarterProject
//
//  Created by Q on 3/11/14.
//
//

#import "MeneCell.h"

@implementation MeneCell

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

- (void)setupMenuCellWithText:(NSString *)text
{
    _icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 50, 50)];
    _icon.backgroundColor = [UIColor clearColor];
    _icon.image = [UIImage imageNamed:@""];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 130, 50)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = text;
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    [self.contentView addSubview:_icon];
    [self.contentView addSubview:_titleLabel];
}

@end
