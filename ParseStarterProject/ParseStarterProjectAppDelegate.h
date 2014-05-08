@class ParseStarterProjectViewController;
#define AppDelegateAccessor ((ParseStarterProjectAppDelegate *)[[UIApplication sharedApplication] delegate])

@interface ParseStarterProjectAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet ParseStarterProjectViewController *viewController;
@property (nonatomic, assign) BOOL isLarge;
@property (nonatomic, assign) BOOL isFirstLarge;
@property (nonatomic, assign) BOOL isFromPost;

@end
