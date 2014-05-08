//
//  SignUpViewController.h
//  ParseStarterProject
//
//  Created by Q on 1/30/14.
//
//

#import <UIKit/UIKit.h>
#import "BZGFormViewController.h"

@class BZGMailgunEmailValidator;

@interface SignUpViewController : BZGFormViewController
@property (nonatomic, strong) BZGFormFieldCell *usernameFieldCell;
@property (nonatomic, strong) BZGFormFieldCell *emailFieldCell;
@property (nonatomic, strong) BZGFormFieldCell *passwordFieldCell;
@property (nonatomic, strong) BZGMailgunEmailValidator *emailValidator;
@property (nonatomic, strong) NSDictionary *scanDataDict;
@property (nonatomic, assign) BOOL isScan;
@end
