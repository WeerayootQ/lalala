//
//  PostViewController.m
//  ParseStarterProject
//
//  Created by Q on 4/24/14.
//
//

#import "PostViewController.h"
#import "PopoverView.h"
#import "DoImagePickerController.h"
#import "AssetHelper.h"
#import "FRDLivelyButton.h"
#import "ParseStarterProjectAppDelegate.h"

#define kStringArray [NSArray arrayWithObjects:@"Public", @"Report", nil]
#define kImageArray [NSArray arrayWithObjects:[UIImage imageNamed:@"success"], [UIImage imageNamed:@"error"], nil]
@interface PostViewController () <PopoverViewDelegate, DoImagePickerControllerDelegate, UITextViewDelegate>
{
    PopoverView *pv;
    CGPoint point;
    UIToolbar *inputAccView;
    UIBarButtonItem *photoBtn;
    UIBarButtonItem *doneBtn;
    BOOL isKeyboardPresenting;
    int privacyValue;
}
// For image picker
@property (nonatomic, strong) NSArray *aIVs;
@property (nonatomic, strong) FRDLivelyButton *closeBtn;

@end

@implementation PostViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // User
    PFUser *currentUser = [PFUser currentUser];
    PFFile *file = currentUser[@"userImage"];
    
    // Layout
    self.mainScrollView.frame = CGRectMake(0, 0, 320, (iPhone5)? 568:480);
    self.mainScrollView.scrollEnabled = NO;
    self.mainScrollView.contentSize =  CGSizeMake(320, (iPhone5)? 568:568);
    self.mainScrollView.showsVerticalScrollIndicator = YES;
    
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.userImageView.clipsToBounds = YES;
    self.userImageView.image = [UIImage imageNamed:@"placeholder.png"];
    self.userImageView.backgroundColor = [UIColor redColor];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error)
        {
            UIImage *image = [UIImage imageWithData:data];                                                                                                                                                                                                                                                                                                                                                                                                          
            self.userImageView.image = image;
        }
        else
        {
            NSLog(@"IMAGE ERROR");
        }
    }];
    
    self.userName.text = currentUser.username;
    self.userName.font = FONT_BOLD(18);
    self.userName.textAlignment = NSTextAlignmentLeft;
    
    self.contentTextView.font = FONT_BOLD(26);
    self.contentTextView.delegate = self;
    self.contentTextView.text = @"Write something...";
    self.contentTextView.textColor = [UIColor lightGrayColor];
    self.contentTextView.frame = CGRectMake(self.contentTextView.frame.origin.x - 3,
                                            self.contentTextView.frame.origin.y,
                                            self.contentTextView.frame.size.width + 6,
                                            self.contentTextView.frame.size.height);
    [self.contentTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [self.contentTextView setInputAccessoryView:[self createInputAccessoryViewWithSuperView:self.contentTextView]];
    [self.view addSubview:[self createInputAccessoryViewWithSuperView:self.view]];
    
    // close button
    self.closeBtn = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 46, 20, 36, 28)];
    [self.closeBtn setOptions:@{ kFRDLivelyButtonLineWidth: @(2.0f),
                                 kFRDLivelyButtonHighlightedColor: [UIColor blackColor],
                                 kFRDLivelyButtonColor: [UIColor blackColor]
                               }];
    [self.closeBtn setStyle:kFRDLivelyButtonStyleClose animated:NO];
    [self.closeBtn addTarget:self action:@selector(closeTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    [self.contentTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
   UITextView *tv = object;
   //Center vertical alignment
   //CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
   //topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
   //tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
 
   //Bottom vertical alignment
   CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height);
    topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
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

#pragma mark - UIButton Action

- (IBAction)privacyBtnTapped:(id)sender
{
    pv = [PopoverView showPopoverAtPoint:CGPointMake(self.privacyBtn.frame.origin.x, self.privacyBtn.frame.origin.y + 50)
                                  inView:self.view
                               withTitle:@"Privacy"
                         withStringArray:kStringArray
                                delegate:self]; // Show string array defined at top of this file with title.
}

- (void)cameraTapped:(id)sender
{
    	for (UIImageView *iv in _aIVs)
		iv.image = nil;
	
    DoImagePickerController *cont = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
    cont.delegate = self;
    cont.nResultType = DO_PICKER_RESULT_UIIMAGE;
    cont.nMaxCount = 1;
    cont.nColumnCount = 3;
    [self presentViewController:cont animated:YES completion:nil];
}

- (void)donTapped:(id)sender
{
    if (isKeyboardPresenting)
    {
        [self.contentTextView resignFirstResponder];
        doneBtn.style = UIBarButtonItemStylePlain;
        doneBtn.title = @"Post";
        isKeyboardPresenting = NO;
    }
    else
    {
        [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
        [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
        [MMProgressHUD showWithTitle:@"NeightBor" status:@"Posting..."];
        [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeGradient];
    
        // Post
        NSData *imageData = UIImagePNGRepresentation(_postImageView.image);
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    
        PFObject *feed = [PFObject objectWithClassName:@"Feeds"];
        [feed setObject:[PFUser currentUser] forKey:@"feed_by"];
        [feed setObject:self.contentTextView.text forKey:@"feed_msg"];
        [feed setObject:imageFile forKey:@"feed_image"];
    
    
        // Photos are public, but may only be modified by the user who uploaded them
        PFACL *feedACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [feedACL setPublicReadAccess:YES];
        feed.ACL = feedACL;
    
        // Save the Photo PFObject
        [feed saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSLog(@"Feed already post");
                [MMProgressHUD dismissWithSuccess:@"Posted!!"];
                ParseStarterProjectAppDelegate *appDelegate = AppDelegateAccessor;
                appDelegate.isFromPost = YES;
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                NSLog(@"Error : %@", [error localizedDescription]);
                [MMProgressHUD dismissWithError:@"Failed!!"];
            }
        }];
    }
}

- (void)closeTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PopoverDelegate

- (void)popoverView:(PopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"%s item:%d", __PRETTY_FUNCTION__, index);
    
    // Figure out which string was selected, store in "string"
    NSString *string = [kStringArray objectAtIndex:index];
    [self setTitlePrivacyWithIndex:index];
    
    // Show a success image, with the string from the array
    [popoverView showImage:[UIImage imageNamed:@"success"] withMessage:string];
    
    // alternatively, you can use
    // [popoverView showSuccess];
    // or
    // [popoverView showError];
    
    // Dismiss the PopoverView after 0.5 seconds
    [popoverView performSelector:@selector(dismiss) withObject:nil afterDelay:0.5f];
}

- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    pv = nil;
}

- (void)setTitlePrivacyWithIndex:(int)index
{
    if (index == 0)
    {
        [self.privacyBtn setTitle:@"Public" forState:UIControlStateNormal];
    }
    else if (index == 1)
    {
        [self.privacyBtn setTitle:@"Report" forState:UIControlStateNormal];
    }
    else
    {
        [self.privacyBtn setTitle:@"Emergency" forState:UIControlStateNormal];
    }
}

#pragma mark - UITextViewDelegate

- (void)keyboardWillShow:(NSNotification *)notification
{
    isKeyboardPresenting = YES;
    
    if (iPhone5)
    {
        // Move up screen element.
        CGRect rect = CGRectMake(0, 20, 320, (iPhone5)? 568 : 480);
        [self.mainScrollView scrollRectToVisible:rect animated:YES];
    }
    else
    {
        // Move up screen element.
        CGRect rect = CGRectMake(0, 80, 320, (iPhone5)? 568 : 480);
        [self.mainScrollView scrollRectToVisible:rect animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    isKeyboardPresenting = NO;
    
    // Move up screen element.
    CGRect rect = CGRectMake(0, 0, 320, (iPhone5)? 568 : 480);
    [self.mainScrollView scrollRectToVisible:rect animated:YES];
}

- (UIView *)createInputAccessoryViewWithSuperView:(UIView *)superView
{
    inputAccView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, ([superView isKindOfClass:[UITextView class]])? 0.0 : self.view.bounds.size.height - 40.0, 320.0, 40.0)];
    [inputAccView setBackgroundColor:[UIColor grayColor]];
    [inputAccView setAlpha: 0.8];

    photoBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraTapped:)];
    photoBtn.tintColor = [UIColor lightGrayColor];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donTapped:)];
    doneBtn.tintColor = [UIColor grayColor];
 
    NSArray *buttonItems = [NSArray arrayWithObjects:photoBtn, flexibleSpace, doneBtn, nil];
	[inputAccView setItems:buttonItems];
    
    return inputAccView;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{

    if ([textView.text isEqualToString:@"Write something..."])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
        textView.font = FONT_BOLD(22);
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        textView.text = @"Write something...";
        textView.textColor = [UIColor lightGrayColor]; //optional
        textView.font = FONT_BOLD(26);
    }
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    int len = textView.text.length;
    NSLog(@"Charactor count : %d", len);
    if (len >= 100)
    {
        textView.font = FONT_BOLD(20);
    }
    else if (len >= 120)
    {
        textView.font = FONT_BOLD(18);
    }
    else if (len >= 140)
    {
        textView.font = FONT_BOLD(16);
    }
    else
    {
        textView.font = FONT_BOLD(22);
    }
//    charCount.text = [NSString stringWithFormat:@"%@: %i",  NSLocalizedString(@"CHARCOUNT", nil),len];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

#pragma mark - DoImagePickerControllerDelegate
- (void)didCancelDoImagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectPhotosFromDoImagePickerController:(DoImagePickerController *)picker result:(NSArray *)aSelected
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (picker.nResultType == DO_PICKER_RESULT_UIIMAGE)
    {
        for (int i = 0; i < MIN(4, aSelected.count); i++)
        {
//            UIImageView *iv = _aIVs[i];
//            iv.image = aSelected[i];
            self.postImageView.image = aSelected[i];
        }
    }
    else if (picker.nResultType == DO_PICKER_RESULT_ASSET)
    {
        for (int i = 0; i < MIN(4, aSelected.count); i++)
        {
//            UIImageView *iv = _aIVs[i];
//            iv.image = [ASSETHELPER getImageFromAsset:aSelected[i] type:ASSET_PHOTO_SCREEN_SIZE];
            self.postImageView.image = [ASSETHELPER getImageFromAsset:aSelected[i] type:ASSET_PHOTO_SCREEN_SIZE];
        }
        
        [ASSETHELPER clearData];
    }
    
    _postImageView.alpha = 1;
    
    // Enable main scrollView scroll
    self.mainScrollView.scrollEnabled = YES;
}

@end
