//
//  AddFeedViewController.m
//  ParseStarterProject
//
//  Created by Q Buzzwoo on 1/14/2557 BE.
//
//

#import "AddFeedViewController.h"
#import "UIImageView+LBBlurredImage.h"

@interface AddFeedViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *bgImageView;

@end

@implementation AddFeedViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_bgImageView setImageToBlur:[UIImage imageNamed:@"example.png"]
                      blurRadius:kLBBlurredImageDefaultBlurRadius
                 completionBlock:^(NSError *error){
                       NSLog(@"The blurred image has been setted");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
