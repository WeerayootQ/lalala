//
//  ScannerViewController.m
//  ParseStarterProject
//
//  Created by Q on 2/18/14.
//
//

#import "ScannerViewController.h"
#import "SignUpViewController.h"
#import "WECodeScannerView.h"
#import "WESoundHelper.h"
#import <AddressBook/AddressBook.h>

@interface ScannerViewController () <WECodeScannerViewDelegate>

@property (nonatomic, strong) WECodeScannerView *codeScannerView;
@property (nonatomic, strong) UILabel *codeLabel;

@end

@implementation ScannerViewController

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
    
    CGFloat labelHeight = 60.0f;
    self.codeScannerView = [[WECodeScannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - labelHeight)];
 	self.codeScannerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
 	self.codeScannerView.delegate = self;
    
 	self.codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.codeScannerView.frame.size.height, self.view.bounds.size.width - 10, labelHeight)];
 	self.codeLabel.backgroundColor = [UIColor clearColor];
 	self.codeLabel.textColor = [UIColor blackColor];
 	self.codeLabel.font = [UIFont boldSystemFontOfSize:17.0];
 	self.codeLabel.numberOfLines = 2;
 	self.codeLabel.textAlignment = NSTextAlignmentCenter;
 	self.codeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.codeScannerView];
 	[self.view addSubview:self.codeLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
 	[super viewWillDisappear:animated];
 	[self.codeScannerView stop];
}

- (void)viewWillAppear:(BOOL)animated
{
 	[super viewWillAppear:animated];
 	[self.codeScannerView start];
}

#pragma mark - WEScanner Delegate

- (void)scannerView:(WECodeScannerView *)scannerView didReadCode:(NSString *)code
{
    NSLog(@"Scanned code: %@", code);
    
    self.codeLabel.text = @"Succeeded!!!";
    [self performSelector:@selector(beep) withObject:nil afterDelay:0.1];
    
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
    
    // This gets the vCard data from a file in the app bundle called vCard.vcf
    //NSURL *vCardURL = [[NSBundle bundleForClass:self.class] URLForResource:@"vCard" withExtension:@"vcf"];
    //CFDataRef vCardData = (CFDataRef)[NSData dataWithContentsOfURL:vCardURL];
    
    // This version simply uses a string. I'm assuming you'll get that from somewhere else.
    NSString *vCardString = code;
    // This line converts the string to a CFData object using a simple cast, which doesn't work under ARC
    //CFDataRef vCardData = (CFDataRef)[vCardString dataUsingEncoding:NSUTF8StringEncoding];
    // If you're using ARC, use this line instead:
    CFDataRef vCardData = (__bridge CFDataRef)[vCardString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (accessGranted)
    {
        
#ifdef DEBUG
        NSLog(@"Save to contact app");
#endif
        
        ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
        for (CFIndex index = 0; index < CFArrayGetCount(vCardPeople); index++)
        {
            ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, index);
            //ABAddressBookAddRecord(addressBook, person, NULL);
            NSString *firstNames = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *lastNames =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            NSString *company = (__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
            
            //get Phone Numbers
            NSMutableArray *numbers = [[NSMutableArray alloc] init];
            ABMultiValueRef multiplePhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i = 0; i < ABMultiValueGetCount(multiplePhones); i++)
            {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiplePhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                [numbers addObject:phoneNumber];
                NSLog(@"All numbers %@", numbers);
            }
            
            //get Emails
            NSMutableArray *emails = [[NSMutableArray alloc] init];
            ABMultiValueRef multipleEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            for(CFIndex i = 0; i < ABMultiValueGetCount(multipleEmails); i++)
            {
                CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multipleEmails, i);
                NSString *email = (__bridge NSString *)emailRef;
                [emails addObject:email];
                NSLog(@"All numbers %@", emails);
            }
            
            //get Emails
            NSMutableArray *addresses = [[NSMutableArray alloc] init];
            ABMultiValueRef multipleAddress = ABRecordCopyValue(person, kABPersonAddressProperty);
            for(CFIndex i = 0; i < ABMultiValueGetCount(multipleAddress); i++)
            {
                CFStringRef addressRef = ABMultiValueCopyValueAtIndex(multipleAddress, i);
                NSDictionary *addressDict = (__bridge NSDictionary *)addressRef;
                [addresses addObject:addressDict];
                NSLog(@"All numbers %@", addresses);
            }
            
            //get Emails
            NSMutableArray *urls = [[NSMutableArray alloc] init];
            ABMultiValueRef multipleURL = ABRecordCopyValue(person, kABPersonURLProperty);
            for(CFIndex i = 0; i < ABMultiValueGetCount(multipleURL); i++)
            {
                CFStringRef addressRef = ABMultiValueCopyValueAtIndex(multipleURL, i);
                NSString *email = (__bridge NSString *)addressRef;
                [urls addObject:email];
                NSLog(@"All numbers %@", urls);
            }
            
            CFRelease(person);
            
            NSLog(@"%@", self.navigationController.childViewControllers);
            // Back to ContactFormViewController
            SignUpViewController *signupVC = (SignUpViewController *)self.navigationController.childViewControllers[1];
            signupVC.scanDataDict = @{@"username" : firstNames, @"email" : emails[0]};
            signupVC.isScan = YES;
            [self.navigationController popToViewController:signupVC animated:YES];
        }
        
        // Incase of you need to add this contact to address book
        //ABAddressBookSave(addressBook, NULL);
    }
    else
    {
#ifdef DEBUG
        NSLog(@"Cannot fetch Contacts :( ");
#endif
    }

}

- (void)scannerViewDidStartScanning:(WECodeScannerView *)scannerView
{
    self.codeLabel.text = @"Scanning...";
}

- (void)scannerViewDidStopScanning:(WECodeScannerView *)scannerView
{

}

- (void)beep
{
    [WESoundHelper playSoundFromFile:@"BEEP.mp3" fromBundle:[NSBundle mainBundle] asAlert:YES];
}

@end
