//
//  PostViewController.h
//  ParseStarterProject
//
//  Created by Q on 4/24/14.
//
//

#import <UIKit/UIKit.h>

@interface PostViewController : UIViewController
@property (nonatomic, strong) IBOutlet UILabel *userName;
@property (nonatomic, strong) IBOutlet UIImageView *userImageView;
@property (nonatomic, strong) IBOutlet UIImageView *postImageView;
@property (nonatomic, strong) IBOutlet UITextView *contentTextView;
@property (nonatomic, strong) IBOutlet UIButton *privacyBtn;
@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;

@end
