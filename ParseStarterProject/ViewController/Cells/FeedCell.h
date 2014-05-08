//
//  FeedCell.h
//  ParseStarterProject
//
//  Created by Q on 1/25/14.
//
//

#import <UIKit/UIKit.h>

@interface FeedCell : UITableViewCell

@property (nonatomic, strong) UILabel *feedUserLabel;
@property (nonatomic, strong) UILabel *feedTimeLabel;
@property (nonatomic, strong) UILabel *feedMsgLabel;
@property (nonatomic, strong) UILabel *feedNumberCommentLabel;
@property (nonatomic, strong) UILabel *feedNumberThumbupLabel;
@property (nonatomic, strong) UIImageView *feedUserImageView;
@property (nonatomic, strong) UIButton *feedThumbBtn;
@property (nonatomic, strong) UIButton *feedCommentBtn;
@property (nonatomic, strong) PFObject *feedObj;

@end
