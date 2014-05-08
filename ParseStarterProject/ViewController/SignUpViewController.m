//
//  SignUpViewController.m
//  ParseStarterProject
//
//  Created by Q on 1/30/14.
//
//

#import "SignUpViewController.h"
#import "BZGFormFieldCell.h"
#import "BZGMailgunEmailValidator.h"
#import "ReactiveCocoa.h"
#import "EXTScope.h"
#import "ScannerViewController.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"
#import "ParseStarterProjectAppDelegate.h"
#import <AddressBook/AddressBook.h>

static NSString *const MAILGUN_PUBLIC_KEY = @"pubkey-1z1yy5aqi6ynejve9d6uq9y5xm0k8428";

@interface SignUpViewController ()
{
    M13ProgressHUD *HUD;
}
@property (strong, nonatomic) UITableViewCell *signupCell;
@end

@implementation SignUpViewController

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
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Sign Up";
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanBtn setFrame:CGRectMake(0, 0, 30, 26)];
    [scanBtn setImage:[UIImage imageNamed:@"nav_scan_button"] forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(scanTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:scanBtn];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelTapped:)];
    
    // Ask for permission
    CFErrorRef *error = nil;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    [self configureUsernameFieldCell];
    [self configureEmailFieldCell];
    [self configurePasswordFieldCell];

    self.formFieldCells = [NSMutableArray arrayWithArray:@[self.usernameFieldCell,
                                                           self.emailFieldCell,
                                                           self.passwordFieldCell]];
    self.formSection = 0;
    self.emailValidator = [BZGMailgunEmailValidator validatorWithPublicKey:MAILGUN_PUBLIC_KEY];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isScan)
    {
        self.usernameFieldCell.textField.text = self.scanDataDict[@"username"];
        self.usernameFieldCell.validationState = BZGValidationStateValid;
        self.emailFieldCell.textField.text = self.scanDataDict[@"email"];
        self.emailFieldCell.validationState = BZGValidationStateValid;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - config

- (void)configureUsernameFieldCell
{
    self.usernameFieldCell = [BZGFormFieldCell new];
    self.usernameFieldCell.label.text = @"Username";
    self.usernameFieldCell.textField.placeholder = NSLocalizedString(@"Username", nil);
    self.usernameFieldCell.textField.keyboardType = UIKeyboardTypeASCIICapable;
    self.usernameFieldCell.textField.delegate = self;
    self.usernameFieldCell.shouldChangeTextBlock = ^BOOL(BZGFormFieldCell *cell, NSString *newText) {
        if (newText.length < 5) {
            cell.validationState = BZGValidationStateInvalid;
            [cell.infoCell setText:@"Username must be at least 5 characters long."];
            cell.shouldShowInfoCell = YES;
        } else {
            cell.validationState = BZGValidationStateValid;
            cell.shouldShowInfoCell = NO;
        }
        return YES;
    };
}

- (void)configureEmailFieldCell
{
    self.emailFieldCell = [BZGFormFieldCell new];
    self.emailFieldCell.label.text = @"Email";
    self.emailFieldCell.textField.placeholder = NSLocalizedString(@"Email", nil);
    self.emailFieldCell.textField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailFieldCell.textField.delegate = self;
    @weakify(self)
    self.emailFieldCell.didEndEditingBlock = ^(BZGFormFieldCell *cell, NSString *text) {
        @strongify(self);
        if (text.length == 0) {
            cell.validationState = BZGValidationStateNone;
            cell.shouldShowInfoCell = NO;
            [self updateInfoCellBelowFormFieldCell:cell];
            return;
        }
        cell.validationState = BZGValidationStateValidating;
        [self.emailValidator validateEmailAddress:self.emailFieldCell.textField.text
                                          success:^(BOOL isValid, NSString *didYouMean) {
                                              if (isValid) {
                                                  cell.validationState = BZGValidationStateValid;
                                                  cell.shouldShowInfoCell = NO;
                                              } else {
                                                  cell.validationState = BZGValidationStateInvalid;
                                                  [cell.infoCell setText:@"Email address is invalid."];
                                                  cell.shouldShowInfoCell = YES;
                                              }
                                              if (didYouMean) {
                                                  [cell.infoCell setText:[NSString stringWithFormat:@"Did you mean %@?", didYouMean]];
//                                                  @weakify(cell);
//                                                  @weakify(self);
//                                                  [cell.infoCell setTapGestureBlock:^BOOL{
//                                                      @strongify(cell);
//                                                      @strongify(self);
//                                                      [cell.textField setText:didYouMean];
//                                                      [self textFieldDidEndEditing:cell.textField];
//                                                  }];
                                                  cell.shouldShowInfoCell = YES;
                                              } else {
                                                  [cell.infoCell setTapGestureBlock:nil];
                                              }
                                              [self updateInfoCellBelowFormFieldCell:cell];
                                          } failure:^(NSError *error) {
                                              cell.validationState = BZGValidationStateNone;
                                              cell.shouldShowInfoCell = NO;
                                              [self updateInfoCellBelowFormFieldCell:cell];
                                          }];
    };
}

- (void)configurePasswordFieldCell
{
    self.passwordFieldCell = [BZGFormFieldCell new];
    self.passwordFieldCell.label.text = @"Password";
    self.passwordFieldCell.textField.placeholder = NSLocalizedString(@"Password", nil);
    self.passwordFieldCell.textField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordFieldCell.textField.secureTextEntry = YES;
    self.passwordFieldCell.textField.delegate = self;
    self.passwordFieldCell.shouldChangeTextBlock = ^BOOL(BZGFormFieldCell *cell, NSString *text) {
        // because this is a secure text field, reset the validation state every time.
        cell.validationState = BZGValidationStateNone;
        if (text.length < 8) {
            cell.validationState = BZGValidationStateInvalid;
            [cell.infoCell setText:@"Password must be at least 8 characters long."];
            cell.shouldShowInfoCell = YES;
        } else {
            cell.validationState = BZGValidationStateValid;
            cell.shouldShowInfoCell = NO;
        }
        return YES;
    };
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == self.formSection) {
        return [super tableView:tableView numberOfRowsInSection:section];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.formSection) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        return self.signupCell;
    }
}

- (UITableViewCell *)signupCell
{
    UITableViewCell *cell = _signupCell;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"Sign Up";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        RAC(cell, selectionStyle) =
        [RACSignal combineLatest:@[[RACObserve(self.usernameFieldCell,validationState) skip:1],
                                   [RACObserve(self.emailFieldCell, validationState) skip:1],
                                   [RACObserve(self.passwordFieldCell, validationState) skip:1]]
                          reduce:^NSNumber *(NSNumber *u, NSNumber *e, NSNumber *p){
                              if (u.integerValue == BZGValidationStateValid
                                  && e.integerValue == BZGValidationStateValid
                                  && p.integerValue == BZGValidationStateValid) {
                                  return @(UITableViewCellSelectionStyleDefault);
                              } else {
                                  return @(UITableViewCellSelectionStyleNone);
                              }
                          }];
        
        RAC(cell.textLabel, textColor) =
        [RACSignal combineLatest:@[[RACObserve(self.usernameFieldCell,validationState) skip:1],
                                   [RACObserve(self.emailFieldCell, validationState) skip:1],
                                   [RACObserve(self.passwordFieldCell, validationState) skip:1]]
                          reduce:^UIColor *(NSNumber *u, NSNumber *e, NSNumber *p){
                              if (u.integerValue == BZGValidationStateValid
                                  && e.integerValue == BZGValidationStateValid
                                  && p.integerValue == BZGValidationStateValid) {
                                  return [UIColor colorWithRed:19/255.0 green:144/255.0 blue:255/255.0 alpha:1.0];
                              } else {
                                  return [UIColor lightGrayColor];
                              }
                          }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        if (_usernameFieldCell.validationState == BZGValidationStateValid && _passwordFieldCell.validationState == BZGValidationStateValid && _emailFieldCell.validationState == BZGValidationStateValid)
        {
            // Create ProgressHUD
            [self createHUDWithText:kLoading];
            
            PFUser *user = [PFUser user];
            user.username = _usernameFieldCell.textField.text;
            user.password = _passwordFieldCell.textField.text;
            user.email = _emailFieldCell.textField.text;
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    // Hooray! Let them use the app now.
                    NSLog(@"SignUp Secceded!");
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_INTRO_SIGNIN" object:nil];
                        [HUD performAction:M13ProgressViewActionNone animated:YES];
                        [self performSelector:@selector(resetHUD) withObject:nil afterDelay:1.5];
                    }];
                }
                else
                {
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"SignUp Error : %@", errorString);
                    // Show the errorString somewhere and let the user try again.
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Neightbor"
                                                                    message:[error localizedDescription]
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.formSection) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    } else {
        return 44;
    }
}


#pragma mark - QRCode Scan Mehtod

- (void)scanTapped:(id)sender
{
    ScannerViewController *scanVC = [[ScannerViewController alloc] init];
 	[self presentViewController:scanVC animated:YES completion:^{
        // TODO
    }];
}

#pragma mark - Navigation Button Action

- (void)cancelTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HUD Method

- (void)createHUDWithText:(NSString *)text
{
    // Create ProgressHUD
    HUD = [[M13ProgressHUD alloc] initWithProgressView:[[M13ProgressViewRing alloc] init]];
    HUD.progressViewSize = CGSizeMake(60.0, 60.0);
    HUD.indeterminate = YES;
    HUD.status = text;
    [HUD performAction:M13ProgressViewActionNone animated:YES];
    [HUD show:YES];
    UIWindow *window = ((ParseStarterProjectAppDelegate *)[UIApplication sharedApplication].delegate).window;
    [window addSubview:HUD];
}

- (void)resetHUD
{
    [HUD hide:YES];
    [HUD performAction:M13ProgressViewActionNone animated:NO];
}


@end
