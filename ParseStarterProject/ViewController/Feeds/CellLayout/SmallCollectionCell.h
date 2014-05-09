//
//  SmallCollectionCell.h
//  ParseStarterProject
//
//  Created by Q on 3/22/14.
//
//

#import <UIKit/UIKit.h>
@class FeedObj;

@interface SmallCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UITextView *usernameLabel;
@property (nonatomic, strong) UITextView *userContentLabel;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UILabel *numberOfCommentLabel;
@property (nonatomic, strong) UILabel *numberOfLikeLabel;
@property (nonatomic, strong) PFObject *feedObj;
@end
