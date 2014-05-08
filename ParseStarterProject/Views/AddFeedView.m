//
//  AddFeedView.m
//  ParseStarterProject
//
//  Created by Q Buzzwoo on 1/14/2557 BE.
//
//

#import "AddFeedView.h"
#import "UIImageView+LBBlurredImage.h"

@implementation AddFeedView

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

- (id)initWithFrame:(CGRect)frame andParentView:(UIView *)parent
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        [self setupAddFeedOverlayFrame:frame andParentView:parent];
    }
    
    return self;
}

- (void)setupAddFeedOverlayFrame:(CGRect)frame andParentView:(UIView *)parent
{
    UIImageView *blurOverlay = [[UIImageView alloc] initWithFrame:frame];
    blurOverlay.backgroundColor = [UIColor clearColor];
    [blurOverlay setImageToBlur:[UIImage imageNamed:@"blur_bg@2x.png"]
                     blurRadius:kLBBlurredImageDefaultBlurRadius
                completionBlock:^(NSError *error){
                       NSLog(@"The blurred image has been setted");
    }];
    
//    _addField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, <#CGFloat width#>, <#CGFloat height#>)]
    
    _addOverlay = [[UIView alloc] initWithFrame:frame];
    _addOverlay.alpha = 1.0;
    _addOverlay.backgroundColor = [UIColor clearColor];
    [_addOverlay addSubview:blurOverlay];
    [parent addSubview:_addOverlay];
}


@end
