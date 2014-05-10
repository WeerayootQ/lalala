//
//  ProfileViewController.m
//  ParseStarterProject
//
//  Created by Q on 5/10/14.
//
//

#import "ProfileViewController.h"
#import "FRDLivelyButton.h"

@interface ProfileViewController ()
@property (nonatomic, strong) FRDLivelyButton *backBtn;
@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"IMG_4674.PNG"]];
    
    PFUser *currentUser = [PFUser currentUser];
    
    self.backBtn = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(10, 28, 36, 28)];
    [self.backBtn setOptions:@{ kFRDLivelyButtonLineWidth: @(2.0f),
                                 kFRDLivelyButtonHighlightedColor: [UIColor blackColor],
                                 kFRDLivelyButtonColor: [UIColor blackColor]
                                 }];
    [self.backBtn setStyle:kFRDLivelyButtonStyleCaretLeft animated:NO];
    [self.backBtn addTarget:self action:@selector(backTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    UIImageView *userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    userAvatar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    userAvatar.image = [UIImage imageWithContentsOfFile:[[BuzzAppHelper sharedInstance] getAnswerFilePathWithName:currentUser.username]];
    userAvatar.center = CGPointMake(320/2, 100);
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:userAvatar.bounds];
    userAvatar.layer.masksToBounds = NO;
    userAvatar.layer.shadowColor = [UIColor blackColor].CGColor;
    userAvatar.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    userAvatar.layer.shadowOpacity = 0.5f;
    userAvatar.layer.shadowPath = shadowPath.CGPath;
    [self.view addSubview:userAvatar];
    
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
    userLabel.backgroundColor = [UIColor clearColor];
    userLabel.textAlignment = NSTextAlignmentCenter;
    userLabel.font = FONT_BOLD(26);
    userLabel.text = currentUser.username;
    userLabel.center = CGPointMake(320/2, 200);
    [self.view addSubview:userLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Action

- (void)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
