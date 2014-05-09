//
//  AMBubbleTableViewController.m
//  AMBubbleTableViewController
//
//  Created by Andrea Mazzini on 30/06/13.
//  Copyright (c) 2013 Andrea Mazzini. All rights reserved.
//

#import "AMBubbleTableViewController.h"
#import "AMBubbleTableCell.h"

#define kInputHeight 40.0f
#define kLineHeight 30.0f
#define kButtonWidth 78.0f


@interface AMBubbleTableViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSMutableDictionary*	options;
@property (nonatomic, strong) UIImageView*	imageInput;
@property (nonatomic, strong) UITextView*	textView;
@property (nonatomic, strong) UIImageView*	imageInputBack;
@property (nonatomic, strong) UIButton*		buttonSend;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) UITextView*	tempTextView;
@property (nonatomic, assign) float			previousTextFieldHeight;

@end

@implementation AMBubbleTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setupView];
}

- (void)setBubbleTableOptions:(NSDictionary *)options
{
	[self.options addEntriesFromDictionary:options];
}

- (NSMutableDictionary*)options
{
	if (_options == nil) {
		_options = [[AMBubbleGlobals defaultOptions] mutableCopy];
	}
	return _options;
}

- (void)setTableStyle:(AMBubbleTableStyle)style
{
	switch (style) {
		case AMBubbleTableStyleDefault:
			[self.options addEntriesFromDictionary:[AMBubbleGlobals defaultStyleDefault]];
			break;
		case AMBubbleTableStyleSquare:
			[self.options addEntriesFromDictionary:[AMBubbleGlobals defaultStyleSquare]];
			break;
		case AMBubbleTableStyleFlat:
			[self.options addEntriesFromDictionary:[AMBubbleGlobals defaultStyleFlat]];
			break;
		default:
			break;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleKeyboardWillShow:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleKeyboardWillHide:)
												 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupView
{
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																						action:@selector(handleTapGesture:)];
    // Like View
    self.likeView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 90)];
    self.likeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.likeView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 150, 20)];
    headerLabel.font = FONT_BOLD(20);
    headerLabel.text = @"Likes";
    [self.likeView addSubview:headerLabel];
    
	// Table View
    CGRect tableFrame = CGRectMake(0.0f, self.likeView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - kInputHeight - 50);
	self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
	[self.tableView addGestureRecognizer:gestureRecognizer];
	[self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self.tableView setDataSource:self];
	[self.tableView setDelegate:self];
	[self.tableView setBackgroundColor:[UIColor whiteColor]];//self.options[AMOptionsBubbleTableBackground]];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.view addSubview:self.tableView];
	
    // Input background
    CGRect inputFrame = CGRectMake(0.0f, self.view.frame.size.height - kInputHeight, self.view.frame.size.width, kInputHeight);
	self.imageInput = [[UIImageView alloc] initWithImage:self.options[AMOptionsImageBar]];
	[self.imageInput setFrame:inputFrame];
	[self.imageInput setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin)];
	[self.imageInput setUserInteractionEnabled:YES];
	
	[self.view addSubview:self.imageInput];
	
	// Input field
	CGFloat width = self.imageInput.frame.size.width - kButtonWidth;
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(6.0f, 3.0f, width, kLineHeight)];
    [self.textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.textView setScrollIndicatorInsets:UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 8.0f)];
    [self.textView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [self.textView setScrollsToTop:NO];
    [self.textView setUserInteractionEnabled:YES];
    [self.textView setFont:self.options[AMOptionsTextFieldFont]];
    [self.textView setTextColor:self.options[AMOptionsTextFieldFontColor]];
    [self.textView setBackgroundColor:self.options[AMOptionsTextFieldBackground]];
    [self.textView setKeyboardAppearance:UIKeyboardAppearanceDefault];
    [self.textView setKeyboardType:UIKeyboardTypeDefault];
    [self.textView setReturnKeyType:UIReturnKeyDefault];
	
	[self.textView setDelegate:self];
    [self.imageInput addSubview:self.textView];
	
	// This text view is used to get the content size
	self.tempTextView = [[UITextView alloc] init];
    self.tempTextView.font = self.textView.font;
    self.tempTextView.text = @"";
    CGSize size = [self.tempTextView sizeThatFits:CGSizeMake(self.textView.frame.size.width, FLT_MAX)];
    self.previousTextFieldHeight = size.height;
    
	// Input field's background
    self.imageInputBack = [[UIImageView alloc] initWithFrame:CGRectMake(self.textView.frame.origin.x - 1.0f,
																		0.0f,
																		self.textView.frame.size.width + 2.0f,
																		self.imageInput.frame.size.height)];
    [self.imageInputBack setImage:self.options[AMOptionsImageInput]];
    [self.imageInputBack setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.imageInputBack setBackgroundColor:[UIColor clearColor]];
	[self.imageInputBack setUserInteractionEnabled:NO];
    [self.imageInput addSubview:self.imageInputBack];

	// Send button
    self.buttonSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonSend setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin)];
    
    UIImage *sendBack = self.options[AMOptionsImageButton];
    UIImage *sendBackHighLighted = self.options[AMOptionsImageButtonHighlight];
    [self.buttonSend setBackgroundImage:sendBack forState:UIControlStateNormal];
    [self.buttonSend setBackgroundImage:sendBack forState:UIControlStateDisabled];
    [self.buttonSend setBackgroundImage:sendBackHighLighted forState:UIControlStateHighlighted];
	[self.buttonSend.titleLabel setFont:self.options[AMOptionsButtonFont]];

    NSString *title = NSLocalizedString(@"Send",);
    [self.buttonSend setTitle:title forState:UIControlStateNormal];
    [self.buttonSend setTitle:title forState:UIControlStateHighlighted];
    [self.buttonSend setTitle:title forState:UIControlStateDisabled];
    self.buttonSend.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    
    UIColor *titleShadow = [UIColor colorWithRed:0.325f green:0.463f blue:0.675f alpha:1.0f];
    [self.buttonSend setTitleShadowColor:titleShadow forState:UIControlStateNormal];
    [self.buttonSend setTitleShadowColor:titleShadow forState:UIControlStateHighlighted];
    self.buttonSend.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);

    [self.buttonSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonSend setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.buttonSend setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
    
    [self.buttonSend setEnabled:NO];
    [self.buttonSend setFrame:CGRectMake(self.imageInput.frame.size.width - 65.0f, [self.options[AMOptionsButtonOffset] floatValue], 59.0f, 26.0f)];
    [self.buttonSend addTarget:self	action:@selector(sendPressed:) forControlEvents:UIControlEventTouchUpInside];
	
    [self.imageInput addSubview:self.buttonSend];
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.dataSource numberOfRows];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	AMBubbleCellType type = [self.dataSource cellTypeForRowAtIndexPath:indexPath];
	NSString* cellID = [NSString stringWithFormat:@"cell_%d", type];
	NSString* text = [self.dataSource textForRowAtIndexPath:indexPath];
	NSDate* date = [self.dataSource timestampForRowAtIndexPath:indexPath];
	AMBubbleTableCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	
	UIImage* avatar;
	UIColor* color;
	
	if ([self.dataSource respondsToSelector:@selector(usernameColorForRowAtIndexPath:)]) {
		color = [self.dataSource usernameColorForRowAtIndexPath:indexPath];
	}
	if ([self.dataSource respondsToSelector:@selector(avatarForRowAtIndexPath:)]) {
		avatar = [self.dataSource avatarForRowAtIndexPath:indexPath];
	}

	
	if (cell == nil) {
		cell = [[AMBubbleTableCell alloc] initWithOptions:self.options
										  reuseIdentifier:cellID];
		
		// iPad cells are set by default to 320 pixels, this fixes the quirk
		cell.contentView.frame = CGRectMake(cell.contentView.frame.origin.x,
											cell.contentView.frame.origin.y,
											self.tableView.frame.size.width,
											cell.contentView.frame.size.height);

		if ([self.options[AMOptionsBubbleSwipeEnabled] boolValue]) {
			UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
			swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionRight;
			[cell addGestureRecognizer:swipeGesture];
		}
		if ([self.options[AMOptionsBubblePressEnabled] boolValue]) {
			UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
			[cell addGestureRecognizer:longPressGesture];
		}
	}
	
	// Used by the gesture recognizer
	cell.tag = indexPath.row;
	
	NSString* stringDate;
	if (type == AMBubbleCellTimestamp) {
		[self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];	// Jan 1, 2000
		[self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];	// 1:23 PM
		stringDate = [self.dateFormatter stringFromDate:date];
		[cell setupCellWithType:type
					  withWidth:self.tableView.frame.size.width
					  andParams:@{ @"date": stringDate }];
	} else {
		[self.dateFormatter setDateFormat:@"HH:mm"];					// 13:23
		NSString* username;
		if ([self.dataSource respondsToSelector:@selector(usernameForRowAtIndexPath:)]) {
			username = [self.dataSource usernameForRowAtIndexPath:indexPath];
		}
		stringDate = [self.dateFormatter stringFromDate:date];
		[cell setupCellWithType:type
					  withWidth:self.tableView.frame.size.width
					  andParams:@{
		 @"text": text,
		 @"date": stringDate,
		 @"index": @(indexPath.row),
		 @"username": (username ? username : @""),
		 @"avatar": (avatar ? avatar: @""),
		 @"color": (color ? color: @"")
		 }];
	}
	
	return cell;
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)sender
{
	if ([self.delegate respondsToSelector:@selector(swipedCellAtIndexPath:withFrame:andDirection:)]) {
		[self.delegate swipedCellAtIndexPath:[NSIndexPath indexPathForRow:sender.view.tag inSection:0] withFrame:sender.view.frame andDirection:sender.direction];
	}
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender
{
	if ([self.delegate respondsToSelector:@selector(longPressedCellAtIndexPath:withFrame:)]) {
		if (sender.state == UIGestureRecognizerStateBegan) {
			[self.delegate longPressedCellAtIndexPath:[NSIndexPath indexPathForRow:sender.view.tag inSection:0] withFrame:sender.view.frame];
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	AMBubbleCellType type = [self.dataSource cellTypeForRowAtIndexPath:indexPath];
	NSString* text = [self.dataSource textForRowAtIndexPath:indexPath];
	NSString* username = @"";
	
	if ([self.dataSource respondsToSelector:@selector(usernameForRowAtIndexPath:)]) {
		username = [self.dataSource usernameForRowAtIndexPath:indexPath];
	}
	
	if (type == AMBubbleCellTimestamp) {
		return [self.options[AMOptionsTimestampHeight] floatValue];
	}
    
    // Set MessageCell height.
    CGSize size = [text sizeWithFont:self.options[AMOptionsBubbleTextFont]
				   constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
					   lineBreakMode:NSLineBreakByWordWrapping];
	
	CGSize usernameSize = CGSizeZero;
	
	if (![username isEqualToString:@""] && type == AMBubbleCellReceived) {
		usernameSize = [username sizeWithFont:self.options[AMOptionsTimestampFont]
							constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
								lineBreakMode:NSLineBreakByWordWrapping];
	}
	
	// Account for either the bubble or accessory size
    return MAX(size.height + 17.0f + usernameSize.height,
			   [self.options[AMOptionsAccessorySize] floatValue] + [self.options[AMOptionsAccessoryMargin] floatValue]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 150, 20)];
    headerLabel.font = FONT_BOLD(20);
    headerLabel.text = @"Comments";
    [headerView addSubview:headerLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

#pragma mark - Keyboard Handlers

- (void)handleKeyboardWillShow:(NSNotification *)notification
{
	[self resizeView:notification];
	[self scrollToBottomAnimated:YES];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification
{
	[self resizeView:notification];	
}

- (void)resizeView:(NSNotification*)notification
{
	CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	CGFloat viewHeight = (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? MIN(self.view.frame.size.width,self.view.frame.size.height) : MAX(self.view.frame.size.width,self.view.frame.size.height));
	CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
	CGFloat diff = keyboardY - viewHeight;
	
	// This check prevents an issue when the view is inside a UITabBarController
	if (diff > 0) {
		double fraction = diff/keyboardY;
		duration *= (1-fraction);
		keyboardY = viewHeight;
	}
	
	// Thanks to Raja Baz (@raja-baz) for the delay's animation fix.	
	CGFloat delay = 0.0f;
	CGRect beginRect = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	diff = beginRect.origin.y - viewHeight;
	if (diff > 0) {
		double fraction = diff/beginRect.origin.y;
		delay = duration * fraction;
		duration -= delay;
	}
	
	void (^completition)(void) = ^{
		CGFloat inputViewFrameY = keyboardY - self.imageInput.frame.size.height;
		
		self.imageInput.frame = CGRectMake(self.imageInput.frame.origin.x,
										   inputViewFrameY,
										   self.imageInput.frame.size.width,
										   self.imageInput.frame.size.height);
		
		UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
											   0.0f,
											   viewHeight - self.imageInput.frame.origin.y - kInputHeight,
											   0.0f);
		
		
		
		self.tableView.contentInset = insets;
		self.tableView.scrollIndicatorInsets = insets;
	};
	
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		[UIView animateWithDuration:0.5
							  delay:0
			 usingSpringWithDamping:500.0f
			  initialSpringVelocity:0.0f
							options:UIViewAnimationOptionCurveLinear
						 animations:completition
						 completion:nil];
	} else {
		[UIView animateWithDuration:duration
							  delay:delay
							options:[AMBubbleGlobals animationOptionsForCurve:curve]
						 animations:completition
						 completion:nil];
	}
}

- (void)resizeTextViewByHeight:(CGFloat)delta
{
	int numLines = self.textView.contentSize.height / self.textView.font.lineHeight;

	self.textView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f,
                                                  (numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f);
	
    	//self.textView.scrollEnabled = (numLines >= 4);
	
	// Adjust table view's insets
	CGFloat viewHeight = (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) ? self.view.frame.size.width : self.view.frame.size.height;
	UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
										   0.0f,
										   viewHeight - self.imageInput.frame.origin.y - kInputHeight,
										   0.0f);

	self.tableView.contentInset = insets;
	self.tableView.scrollIndicatorInsets = insets;

	// Slightly scroll the table
	[self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + delta) animated:YES];

}

- (void)handleTapGesture:(UIGestureRecognizer*)gesture
{
	[self.textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
	[self.buttonSend setEnabled:([textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)];

	CGFloat maxHeight = self.textView.font.lineHeight * 5;
	CGFloat textViewContentHeight = self.textView.contentSize.height;
	
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		// Fixes the wrong content size computed by iOS7
		if (textView.text.UTF8String[textView.text.length-1] == '\n') {
			textViewContentHeight += textView.font.lineHeight;
		}
	}
	
    if ([@"" isEqualToString:textView.text]) {
    	self.tempTextView = [[UITextView alloc] init];
    	self.tempTextView.font = self.textView.font;
    	self.tempTextView.text = self.textView.text;
		
    	CGSize size = [self.tempTextView sizeThatFits:CGSizeMake(self.textView.frame.size.width, FLT_MAX)];
        textViewContentHeight  = size.height;
    }

	CGFloat delta = textViewContentHeight - self.previousTextFieldHeight;
	BOOL isShrinking = textViewContentHeight < self.previousTextFieldHeight;

	delta = (textViewContentHeight + delta >= maxHeight) ? 0.0f : delta;
	
	if(!isShrinking)
        [self resizeTextViewByHeight:delta];
    
    if(delta != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, self.tableView.contentInset.bottom + delta, 0.0f);
                             self.tableView.contentInset = insets;
                             self.tableView.scrollIndicatorInsets = insets;
							 
                             [self scrollToBottomAnimated:NO];
							 
                             self.imageInput.frame = CGRectMake(0.0f,
                                                               self.imageInput.frame.origin.y - delta,
                                                               self.imageInput.frame.size.width,
                                                               self.imageInput.frame.size.height + delta);
                         }
                         completion:^(BOOL finished) {
                             if(isShrinking)
                                 [self resizeTextViewByHeight:delta];
                         }];
        
        self.previousTextFieldHeight = MIN(textViewContentHeight, maxHeight);
    }
	
	// This is a workaround for an iOS7 bug:
	// http://stackoverflow.com/questions/18070537/how-to-make-a-textview-scroll-while-editing
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		if([textView.text hasSuffix:@"\n"]) {
			double delayInSeconds = 0.2;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				CGPoint bottomOffset = CGPointMake(0, self.textView.contentSize.height - self.textView.bounds.size.height);
				[self.textView setContentOffset:bottomOffset animated:YES];
			});
		}
	}
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger bottomRow = [self.dataSource numberOfRows] - 1;
    if (bottomRow >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
							  atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)sendPressed:(id)sender
{
	[self.delegate didSendText:self.textView.text];
	[self.textView setText:@""];
	[self textViewDidChange:self.textView];
	[self resizeTextViewByHeight:self.textView.contentSize.height - self.previousTextFieldHeight];
    [self.buttonSend setEnabled:NO];
	[self scrollToBottomAnimated:YES];
}

- (void)reloadTableScrollingToBottom:(BOOL)scroll
{
	[self.tableView reloadData];
	if (scroll) {
		[self scrollToBottomAnimated:YES];
	}
}

- (NSDateFormatter*)dateFormatter
{
	if (_dateFormatter == nil) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]]];
	}
	return _dateFormatter;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadData];
}

#pragma mark - Like

- (void)fetchLikeUsers
{
    PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
    [query whereKey:@"like_feed_id" equalTo:self.feedObject];
    [query includeKey:@"like_by"];
    [query includeKey:@"createdAt"];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"count object : %d", objects.count);
        NSLog(@"object : %@", objects);
        
        __block float xPOS = 5.0;
        for (int i = 0; i < objects.count; i++)
        {
            PFObject *likeObj = objects[i];
            PFUser *user = likeObj[@"like_by"];
            PFFile *file = user[@"userImage"];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error)
                {
                    if (i < 4)
                    {
                        UIImageView *likedUser = [[UIImageView alloc] initWithFrame:CGRectMake(xPOS, 30, 50, 50)];
                        likedUser.image = [UIImage imageWithData:data];
                        [self.likeView addSubview:likedUser];
                        xPOS = xPOS + 52.0;
                    }
                    else if (i > 3 && i < 5)
                    {
                        UIImageView *likedUser = [[UIImageView alloc] initWithFrame:CGRectMake(xPOS, 30, 50, 50)];
                        [self.likeView addSubview:likedUser];
                    }
                
                    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"UserAvatar/%@.png", [user objectForKey:@"username"]]];
                    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                    if (!fileExists)
                    {
                        [data writeToFile:[[BuzzAppHelper sharedInstance] getAnswerFilePathWithName:[user objectForKey:@"username"]] atomically:YES];
                        NSLog(@"Download to Cache");
                    }
                    else
                    {
                        NSLog(@"Not Cache");
                    }
                }
            }];
        }
    }];
}

@end
