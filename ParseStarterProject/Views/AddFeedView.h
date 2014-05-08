//
//  AddFeedView.h
//  ParseStarterProject
//
//  Created by Q Buzzwoo on 1/14/2557 BE.
//
//

#import <UIKit/UIKit.h>

@interface AddFeedView : UIView

@property (nonatomic, strong) IBOutlet UIView *addOverlay;
@property (nonatomic, strong) IBOutlet UITextField *addField;
@property (nonatomic, strong) IBOutlet UIButton *addImageBtn;
@property (nonatomic, strong) IBOutlet UIButton *postFeedBtn;
@property (nonatomic, strong) IBOutlet UIButton *cancelBtn;

- (id)initWithFrame:(CGRect)frame andParentView:(UIView *)parent;

@end
