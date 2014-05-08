//
//  SignInViewController.h
//  ParseStarterProject
//
//  Created by Q Buzzwoo on 1/13/2557 BE.
//
//

#import <UIKit/UIKit.h>
#import "BZGFormViewController.h"

@class BZGMailgunEmailValidator;

@interface SignInViewController : UIViewController

@property (nonatomic, strong) BZGFormFieldCell *usernameFieldCell;
@property (nonatomic, strong) BZGFormFieldCell *emailFieldCell;
@property (nonatomic, strong) BZGFormFieldCell *passwordFieldCell;
@property (nonatomic, strong) BZGMailgunEmailValidator *emailValidator;
@property (nonatomic, strong) NSDictionary *scanDataDict;
@property (nonatomic, assign) BOOL isScan;

@end
