//
//  MeneCell.h
//  ParseStarterProject
//
//  Created by Q on 3/11/14.
//
//

#import <UIKit/UIKit.h>

@interface MeneCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *icon;
- (void)setupMenuCellWithText:(NSString *)text;
@end
