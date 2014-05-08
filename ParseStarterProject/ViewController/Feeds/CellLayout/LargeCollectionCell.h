//
//  LargeCollectionCell.h
//  ParseStarterProject
//
//  Created by Q on 3/22/14.
//
//

#import <UIKit/UIKit.h>
@class FeedObj;

@interface LargeCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *userContentLbel;
@property (nonatomic, strong) FeedObj *feedObj;
@end
