//
//  SignInViewController.m
//  ParseStarterProject
//
//  Created by Q Buzzwoo on 1/13/2557 BE.
//
//

#import "SignInViewController.h"
#import "BZGFormFieldCell.h"
#import "BZGMailgunEmailValidator.h"
#import "ReactiveCocoa.h"
#import "EXTScope.h"
#import "ScannerViewController.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"
#import "ParseStarterProjectAppDelegate.h"
#import <AddressBook/AddressBook.h>
#import "FBShimmeringView.h"
#import "FBShimmering.h"
#import "FBShimmeringLayer.h"

static NSString *const MAILGUN_PUBLIC_KEY = @"pubkey-1z1yy5aqi6ynejve9d6uq9y5xm0k8428";

@interface SignInViewController () <UITextFieldDelegate>
{
    M13ProgressHUD *HUD;
    FBShimmeringView *shimmeringView;
    UILabel *logoLabel;
}
//@property (strong, nonatomic) UITableViewCell *signupCell;
@property (nonatomic, strong) UITextField *userField;
@property (nonatomic, strong) UITextField *passField;

@end

@implementation SignInViewController

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
    self.title = @"Sign In";
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped:)];
    self.navigationController.navigationBarHidden = YES;
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgView.backgroundColor = [UIColor clearColor];
    bgView.image = [UIImage imageNamed:@"main-bg.png"];
    bgView.userInteractionEnabled = YES;
    
    shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0, 0, 320, iPhone5 ? 568 : 480)];
    shimmeringView.shimmering = YES;
    shimmeringView.shimmeringBeginFadeDuration = 0.3;
    shimmeringView.shimmeringOpacity = 0.3;
    logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    logoLabel.text = @"Neighbor";
    logoLabel.font = FONT_LIGHT(60);//[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:60.0];
    logoLabel.textColor = [UIColor whiteColor];
    logoLabel.textAlignment = NSTextAlignmentCenter;
    logoLabel.backgroundColor = [UIColor clearColor];
    shimmeringView.contentView = logoLabel;
    logoLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/3.5);
    
    
    UIColor *placeholderColor = [UIColor colorWithWhite:1 alpha:0.8];
    UIColor *txtColor = [UIColor whiteColor];
    
    self.userField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, 45)];
    self.userField.backgroundColor = [UIColor clearColor];
    self.userField.delegate = self;
    self.userField.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2.2);
    self.userField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName:placeholderColor}];
    self.userField.textColor = txtColor;
    self.userField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.userField.returnKeyType = UIReturnKeyNext;
    self.userField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(self.userField.frame.origin.x, self.userField.frame.origin.y + 50, 250, 1)];
    separator.backgroundColor = [UIColor whiteColor];
    
    self.passField = [[UITextField alloc] initWithFrame:CGRectMake(self.userField.frame.origin.x, self.userField.frame.origin.y + 56, 250, 45)];
    self.passField.backgroundColor = [UIColor clearColor];
    self.passField.delegate = self;
    self.passField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:placeholderColor}];
    self.passField.textColor = txtColor;
    self.passField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.passField.returnKeyType = UIReturnKeyGo;
    self.passField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passField.secureTextEntry = YES;

    [self.view addSubview:bgView];
    [self.view addSubview:shimmeringView];
    [self.view addSubview:self.userField];
    [self.view addSubview:separator];
    [self.view addSubview:self.passField];
//    [self configureUsernameFieldCell];
//    [self configurePasswordFieldCell];
//    
//    self.formFieldCells = [NSMutableArray arrayWithArray:@[self.usernameFieldCell, self.passwordFieldCell]];
//    self.formSection = 0;
//    self.emailValidator = [BZGMailgunEmailValidator validatorWithPublicKey:MAILGUN_PUBLIC_KEY];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if (_isScan)
//    {
//        self.usernameFieldCell.textField.text = self.scanDataDict[@"username"];
//        self.usernameFieldCell.validationState = BZGValidationStateValid;
//        self.emailFieldCell.textField.text = self.scanDataDict[@"email"];
//        self.emailFieldCell.validationState = BZGValidationStateValid;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - config
//
//- (void)configureUsernameFieldCell
//{
//    self.usernameFieldCell = [BZGFormFieldCell new];
//    self.usernameFieldCell.label.text = @"Username";
//    self.usernameFieldCell.textField.placeholder = NSLocalizedString(@"Username", nil);
//    self.usernameFieldCell.textField.keyboardType = UIKeyboardTypeASCIICapable;
//    self.usernameFieldCell.textField.delegate = self;
//    self.usernameFieldCell.shouldChangeTextBlock = ^BOOL(BZGFormFieldCell *cell, NSString *newText) {
//        if (newText.length < 5) {
//            cell.validationState = BZGValidationStateInvalid;
//            [cell.infoCell setText:@"Username must be at least 5 characters long."];
//            cell.shouldShowInfoCell = YES;
//        } else {
//            cell.validationState = BZGValidationStateValid;
//            cell.shouldShowInfoCell = NO;
//        }
//        return YES;
//    };
//}
//
//- (void)configureEmailFieldCell
//{
//    self.emailFieldCell = [BZGFormFieldCell new];
//    self.emailFieldCell.label.text = @"Email";
//    self.emailFieldCell.textField.placeholder = NSLocalizedString(@"Email", nil);
//    self.emailFieldCell.textField.keyboardType = UIKeyboardTypeEmailAddress;
//    self.emailFieldCell.textField.delegate = self;
//    @weakify(self)
//    self.emailFieldCell.didEndEditingBlock = ^(BZGFormFieldCell *cell, NSString *text) {
//        @strongify(self);
//        if (text.length == 0) {
//            cell.validationState = BZGValidationStateNone;
//            cell.shouldShowInfoCell = NO;
//            [self updateInfoCellBelowFormFieldCell:cell];
//            return;
//        }
//        cell.validationState = BZGValidationStateValidating;
//        [self.emailValidator validateEmailAddress:self.emailFieldCell.textField.text
//                                          success:^(BOOL isValid, NSString *didYouMean) {
//                                              if (isValid) {
//                                                  cell.validationState = BZGValidationStateValid;
//                                                  cell.shouldShowInfoCell = NO;
//                                              } else {
//                                                  cell.validationState = BZGValidationStateInvalid;
//                                                  [cell.infoCell setText:@"Email address is invalid."];
//                                                  cell.shouldShowInfoCell = YES;
//                                              }
//                                              if (didYouMean) {
//                                                  [cell.infoCell setText:[NSString stringWithFormat:@"Did you mean %@?", didYouMean]];
//                                                  //                                                  @weakify(cell);
//                                                  //                                                  @weakify(self);
//                                                  //                                                  [cell.infoCell setTapGestureBlock:^BOOL{
//                                                  //                                                      @strongify(cell);
//                                                  //                                                      @strongify(self);
//                                                  //                                                      [cell.textField setText:didYouMean];
//                                                  //                                                      [self textFieldDidEndEditing:cell.textField];
//                                                  //                                                  }];
//                                                  cell.shouldShowInfoCell = YES;
//                                              } else {
//                                                  [cell.infoCell setTapGestureBlock:nil];
//                                              }
//                                              [self updateInfoCellBelowFormFieldCell:cell];
//                                          } failure:^(NSError *error) {
//                                              cell.validationState = BZGValidationStateNone;
//                                              cell.shouldShowInfoCell = NO;
//                                              [self updateInfoCellBelowFormFieldCell:cell];
//                                          }];
//    };
//}
//
//- (void)configurePasswordFieldCell
//{
//    self.passwordFieldCell = [BZGFormFieldCell new];
//    self.passwordFieldCell.label.text = @"Password";
//    self.passwordFieldCell.textField.placeholder = NSLocalizedString(@"Password", nil);
//    self.passwordFieldCell.textField.keyboardType = UIKeyboardTypeASCIICapable;
//    self.passwordFieldCell.textField.secureTextEntry = YES;
//    self.passwordFieldCell.textField.delegate = self;
//    self.passwordFieldCell.shouldChangeTextBlock = ^BOOL(BZGFormFieldCell *cell, NSString *text) {
//        // because this is a secure text field, reset the validation state every time.
//        cell.validationState = BZGValidationStateNone;
//        if (text.length < 8) {
//            cell.validationState = BZGValidationStateInvalid;
//            [cell.infoCell setText:@"Password must be at least 8 characters long."];
//            cell.shouldShowInfoCell = YES;
//        } else {
//            cell.validationState = BZGValidationStateValid;
//            cell.shouldShowInfoCell = NO;
//        }
//        return YES;
//    };
//}
//
//#pragma mark - UITableViewDataSource
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 2;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    if (section == self.formSection) {
//        return [super tableView:tableView numberOfRowsInSection:section];
//    } else {
//        return 1;
//    }
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == self.formSection) {
//        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
//    } else {
//        return self.signupCell;
//    }
//}
//
//- (UITableViewCell *)signupCell
//{
//    UITableViewCell *cell = _signupCell;
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//        cell.textLabel.text = @"Sign In";
//        cell.textLabel.textAlignment = NSTextAlignmentCenter;
//        RAC(cell, selectionStyle) =
//        [RACSignal combineLatest:@[[RACObserve(self.usernameFieldCell,validationState) skip:1],
//                                   [RACObserve(self.passwordFieldCell, validationState) skip:1]]
//                          reduce:^NSNumber *(NSNumber *u, NSNumber *p){
//                              if (u.integerValue == BZGValidationStateValid
//                                  && p.integerValue == BZGValidationStateValid) {
//                                  return @(UITableViewCellSelectionStyleDefault);
//                              } else {
//                                  return @(UITableViewCellSelectionStyleNone);
//                              }
//                          }];
//        
//        RAC(cell.textLabel, textColor) =
//        [RACSignal combineLatest:@[[RACObserve(self.usernameFieldCell,validationState) skip:1],
//                                   [RACObserve(self.passwordFieldCell, validationState) skip:1]]
//                          reduce:^UIColor *(NSNumber *u, NSNumber *p){
//                              if (u.integerValue == BZGValidationStateValid
//                                  && p.integerValue == BZGValidationStateValid) {
//                                  return [UIColor colorWithRed:19/255.0 green:144/255.0 blue:255/255.0 alpha:1.0];
//                              } else {
//                                  return [UIColor lightGrayColor];
//                              }
//                          }];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.textLabel.textColor = [UIColor lightGrayColor];
//    }
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0)
//    {
//        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
//    else
//    {
//        if (_usernameFieldCell.validationState == BZGValidationStateValid && _passwordFieldCell.validationState == BZGValidationStateValid)
//        {
//
//            [self createHUDWithText:kLoading];
//            
//            [PFUser logInWithUsernameInBackground:_usernameFieldCell.textField.text password:_passwordFieldCell.textField.text
//            block:^(PFUser *user, NSError *error) {
//                if (user)
//                {
//                    // Do stuff after successful login.
//                    [self dismissViewControllerAnimated:YES completion:^{
//                        NSLog(@"Sign-in success and dissmiss sign-in");
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_INTRO_SIGNIN" object:nil];
//                        [HUD performAction:M13ProgressViewActionNone animated:YES];
//                        [self performSelector:@selector(resetHUD) withObject:nil afterDelay:1.5];
//                    }];
//                }
//                else
//                {
//                    // The login failed. Check error to see why.
//                    NSLog(@"Login Fail");
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Neightbor" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                    [alert show];
//                }
//             }];
//             
//            
////            PFUser *user = [PFUser user];
////            user.username = _usernameFieldCell.textField.text;
////            user.password = _passwordFieldCell.textField.text;
////            user.email = _emailFieldCell.textField.text;
////            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
////                if (!error)
////                {
////                    // Hooray! Let them use the app now.
////                    NSLog(@"SignUp Secceded!");
////                    [self.navigationController popViewControllerAnimated:YES];
////                }
////                else
////                {
////                    NSString *errorString = [error userInfo][@"error"];
////                    NSLog(@"SignUp Error : %@", errorString);
////                    // Show the errorString somewhere and let the user try again.
////                }
////            }];
//        }
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == self.formSection) {
//        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
//    } else {
//        return 44;
//    }
//}


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

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userField)
    {
        [textField resignFirstResponder];
        [self.passField becomeFirstResponder];
        return NO;
    }
    else
    {
        if (![self.userField.text isEqualToString:@""] && ![self.passField.text isEqualToString:@""])
        {
            [self signIn];
            return YES;
        }
        else
        {
            return NO;
        }
    }
}

//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    textField.placeholder = textField.text;
//    textField.text = @"";
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    if (textField.text.length == 0) {
//        textField.text = textField.placeholder;
//    }
//    textField.placeholder = @"";
//}

#pragma mark - Sign-In Method

- (void)signIn
{
    [MMProgressHUD setDisplayStyle:MMProgressHUDDisplayStylePlain];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithTitle:@"Neighbor" status:@"Signing in"];
    [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeGradient];
    
    [PFUser logInWithUsernameInBackground:self.userField.text
                                 password:self.passField.text
                                    block:^(PFUser *user, NSError *error) {
        if (user)
        {
            // Do stuff after successful login.
            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"Sign-in success and dissmiss sign-in");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_INTRO_SIGNIN" object:nil];
                [MMProgressHUD dismissWithSuccess:@"Welcome"];
                [self performSelector:@selector(resetHUD) withObject:nil afterDelay:1.5];
            }];
        }
        else
        {
            // The login failed. Check error to see why.
            NSLog(@"Login Fail");
            [MMProgressHUD dismissWithError:@"Failed!!"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Neightbor"
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

@end
