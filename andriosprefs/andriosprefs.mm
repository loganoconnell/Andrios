#import <Preferences/Preferences.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "UIView+Shimmer.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MobileGestalt/MobileGestalt.h>
#import <Twitter/TWTweetComposeViewController.h>
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
int width = [[UIScreen mainScreen] bounds].size.width;

@protocol PreferencesTableCustomView
//- (id)initWithSpecifier:(id)arg1;

@optional
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1;
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 inTableView:(id)arg2;
@end

@interface PSTableCell (Andrios)
- (id)initWithStyle:(long long)style reuseIdentifier:(id)arg2;
@end

@interface PSSwitchTableCell : PSControlTableCell
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 ;
@end

@interface andriosprefsListController: PSListController {
     UIWindow *settingsView;
}
@end

@implementation andriosprefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"andriosprefs" target:self] retain];
	}
	return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIImage* customImg = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/twitterbutton.png"];
    UIBarButtonItem *_customButton = [[[UIBarButtonItem alloc] initWithImage:customImg style:UIBarButtonItemStyleDone target:self action:@selector(share:)] autorelease];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:_customButton, nil];
    
    
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {

    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = image;

    [super viewDidAppear:animated];
}

- (void)share:(UIBarButtonItem *)sender
{
    TWTweetComposeViewController *tweetComposeViewController =
    [[TWTweetComposeViewController alloc] init];
    [tweetComposeViewController setInitialText:@"Add Android-inspired features and style to your iOS Device with #Andrios in Cydia! Developed by @ImBrandDev & @logandev22"];
    [tweetComposeViewController addImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/twitterpic.png"]];
    [self.navigationController presentViewController:tweetComposeViewController
                                            animated:YES
                                          completion:^{ }];
}

- (void)support
{
    NSString *url = @"mailto:orcadevteam@gmail.com?&subject=Andrios";
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:url]];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}
@end

@interface customSwitch : PSSwitchTableCell
@end

@implementation customSwitch

- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
    
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
    
    if (self) {
        
        [((UISwitch *)[self control]) setOnTintColor:[UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0]];
        
    }
    
    return self;
}

@end

@interface AndriosHeaderCell : PSTableCell{
	UILabel *_label;
    UILabel *underLabel;
    UILabel *tweakName;
@public
    UILabel *randLabel;
}
@end

@implementation AndriosHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        CGRect frame = CGRectMake(0, 20, 320, 60);
        if (IS_IPHONE_6_PLUS) {
            frame = CGRectMake(50, 20, 320, 60);
        }
        CGRect botFrame = CGRectMake(0, 50, 320, 60);
        if (IS_IPHONE_6_PLUS) {
            botFrame = CGRectMake(50, 50, 320, 60);
        }
        
        CGRect randFrame = CGRectMake(0, 70, 320, 60);
        if (IS_IPHONE_6_PLUS) {
            randFrame = CGRectMake(50, 70, 320, 60);
        }
        
        _label = [[UILabel alloc] initWithFrame:frame];
        [_label setNumberOfLines:1];
        _label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:43];
        [_label setText:@"Andrios"];
        [_label setBackgroundColor:[UIColor clearColor]];
        _label.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        _label.textAlignment = NSTextAlignmentCenter;
        [_label startShimmering];
        
        underLabel = [[UILabel alloc] initWithFrame:botFrame];
        [underLabel setNumberOfLines:1];
        underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        [underLabel setText:@"By BrandDev & Logan O'Connell"];
        [underLabel setBackgroundColor:[UIColor clearColor]];
        underLabel.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        underLabel.textAlignment = NSTextAlignmentCenter;
        
        randLabel = [[UILabel alloc] initWithFrame:randFrame];
        [randLabel setNumberOfLines:1];
        randLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        [randLabel setText:@"An Android-inspired experience, for iOS."];
        [randLabel setBackgroundColor:[UIColor clearColor]];
        randLabel.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        randLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_label];
        //[self addSubview:tweakName];
        [self addSubview:underLabel];
        [self addSubview:randLabel];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
    return 100.f;
}
@end

@interface AndriosSupportController : PSListController<MFMailComposeViewControllerDelegate> {
    MFMailComposeViewController *mailViewController;
}
@end

@implementation AndriosSupportController

+ (NSString *) Andrios_supportEmailAddress {
    return @"Orca Dev Team <orcadevteam@gmail.com>";
}

-(id) specifiers {
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"No mail accounts are set up." message:@"Use the Mail settings to add a new account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alertView show];
        return nil;
    }
    
    MFMailComposeViewController *viewController = [[[MFMailComposeViewController alloc] init] autorelease];
    viewController.mailComposeDelegate = self;
    viewController.toRecipients = @[ [self.class Andrios_supportEmailAddress] ];
    viewController.subject = [NSString stringWithFormat:@"Andrios Support"];
    [viewController addAttachmentData:[[NSFileManager defaultManager] contentsAtPath:@"/var/tmp/dpkgl.log"] mimeType:@"text/plain" fileName:@"dpkgl.log"];
    
    NSString *product = nil, *version = nil, *build = nil, *udid = nil;
    
    
    product = (NSString *)MGCopyAnswer(kMGProductType);
    version = (NSString *)MGCopyAnswer(kMGProductVersion);
    build = (NSString *)MGCopyAnswer(kMGBuildVersion);
    udid = (NSString *)MGCopyAnswer(kMGUniqueDeviceID);
    
    
    [viewController setMessageBody:[NSString stringWithFormat:@"\n\nDevice information: %@, iOS %@ (%@), %@", product, version, build, udid] isHTML:NO];
    
    [self.navigationController presentViewController:viewController animated:YES completion:nil];
    return nil;
}

- (void)mailComposeController:(MFMailComposeViewController *)viewController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [viewController dismissViewControllerAnimated:YES completion:nil];
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:YES];
}

@end

@interface CreditsController: PSListController {
    UIWindow *settingsView;
}
@end

@implementation CreditsController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Credits" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImage* customImg = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/twitterbutton.png"];
    UIBarButtonItem *_customButton = [[[UIBarButtonItem alloc] initWithImage:customImg style:UIBarButtonItemStyleDone target:self action:@selector(share:)] autorelease];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:_customButton, nil];
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}
- (void)share:(UIBarButtonItem *)sender
{
    TWTweetComposeViewController *tweetComposeViewController =
    [[TWTweetComposeViewController alloc] init];
    [tweetComposeViewController setInitialText:@"Add Android inspired Features and Style to your iOS Device with #Andrios in Cydia! Developed by @ImBrandDev & @logandev22"];
    [tweetComposeViewController addImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefsprefs.bundle/twitterpic.png"]];
    [self.navigationController presentViewController:tweetComposeViewController
                                            animated:YES
                                          completion:^{ }];
}

@end

@interface CreditsHeaderCell : PSTableCell <PreferencesTableCustomView> {
    UILabel *_label;
    UILabel* underLabel;
}
@end

@implementation CreditsHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    if (self) {
        CGRect frame = CGRectMake(0, -12.5, width, 60);
        CGRect botFrame = CGRectMake(0, 20, width, 60);
        
        _label = [[UILabel alloc] initWithFrame:frame];
        [_label setNumberOfLines:1];
        _label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
        [_label setText:@"Creators"];
        [_label setBackgroundColor:[UIColor clearColor]];
        _label.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        _label.textAlignment = NSTextAlignmentCenter;
        [_label startShimmering];
        
        underLabel = [[UILabel alloc] initWithFrame:botFrame];
        [underLabel setNumberOfLines:1];
        underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        [underLabel setText:@"The People Behind Andrios"];
        [underLabel setBackgroundColor:[UIColor clearColor]];
        underLabel.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        underLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_label];
        [self addSubview:underLabel];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
    CGFloat prefHeight = 75.0;
    return prefHeight;
}
@end

@interface AndriosMakerCell1 : PSTableCell {
    UIImageView *_background;
    UILabel *label;
    UILabel *label2;
    UIButton *twitterButton;
}
@end

@implementation AndriosMakerCell1
-(id)initWithStyle:(long long)style reuseIdentifier:(NSString *)reuseIdentifier {
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
        UIImage *bkIm = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/AndriosBrandDev.png"];
        _background = [[UIImageView alloc] initWithImage:bkIm];
        _background.frame = CGRectMake(9, 18, 65, 65);
        [self addSubview:_background];
        
        CGRect frame = [self frame];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 84, frame.origin.y + 18, frame.size.width, frame.size.height)];
        [label setText:@"@ImBrandDev - Brandon"];
        [label setBackgroundColor:[UIColor clearColor]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [label setFont:[UIFont fontWithName:@"Helvetica Light" size:30]];
        else
            [label setFont:[UIFont fontWithName:@"Helvetica Light" size:18]];
        
        label.textColor = [UIColor blackColor];
        [self addSubview:label];
        
        label2 = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 84, frame.origin.y + 42, frame.size.width, frame.size.height)];
        [label2 setText:@"Developer"];
        [label2 setBackgroundColor:[UIColor clearColor]];
        [label2 setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
		label2.textColor = [UIColor grayColor];
        [self addSubview:label2];
        
        [twitterButton setBackgroundColor:[UIColor clearColor]];
        twitterButton.frame = CGRectMake(240 ,25, 48, 48);
        [self addSubview:twitterButton];
        
    }
    return self;
}

@end

@interface andriosOpenTwitterBrandDevController : PSListController { }
@end

@implementation andriosOpenTwitterBrandDevController
- (id)specifiers {
    NSString *user = @"ImBrandDev";
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
    
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
    return 0;
}

- (void)viewDidAppear:(BOOL)arg1 {
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:YES];
}
@end

@interface AndriosMakerCell2 : PSTableCell {
    UIImageView *_background;
    UILabel *label;
    UILabel *label2;
    UIButton *twitterButton;
}
@end

@implementation AndriosMakerCell2
-(id)initWithStyle:(long long)style reuseIdentifier:(NSString *)reuseIdentifier {
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
        UIImage *bkIm = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/AndriosLogan.png"];
        _background = [[UIImageView alloc] initWithImage:bkIm];
        _background.frame = CGRectMake(9, 18, 65, 65);
        [self addSubview:_background];
        
        CGRect frame = [self frame];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 84, frame.origin.y + 18, frame.size.width, frame.size.height)];
        [label setText:@"@logandev22 - Logan"];
        label.textColor = [UIColor blackColor];
        [label setBackgroundColor:[UIColor clearColor]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [label setFont:[UIFont fontWithName:@"Helvetica Light" size:30]];
        else
            [label setFont:[UIFont fontWithName:@"Helvetica Light" size:18]];
        
        [self addSubview:label];
        
        label2 = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 84, frame.origin.y + 42, frame.size.width, frame.size.height)];
        
        [label2 setText:@"Developer"];
        [label2 setBackgroundColor:[UIColor clearColor]];
        [label2 setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
		label2.textColor = [UIColor grayColor];
        [self addSubview:label2];
        
        [twitterButton setBackgroundColor:[UIColor clearColor]];
        twitterButton.frame = CGRectMake(240, 25, 48, 48);
        [self addSubview:twitterButton];
    }
    return self;
}

@end

@interface andriosOpenTwitterLoganController : PSListController { }
@end

@implementation andriosOpenTwitterLoganController
- (id)specifiers {
    NSString *user = @"logandev22";
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
    
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
    return 0;
}

- (void)viewDidAppear:(BOOL)arg1 {
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:YES];
}
@end

@interface AndriosMakerCell3 : PSTableCell {
    UIImageView *_background;
    UILabel *label;
    UILabel *label2;
    UIButton *twitterButton;
}
@end

@implementation AndriosMakerCell3
-(id)initWithStyle:(long long)style reuseIdentifier:(NSString *)reuseIdentifier {
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
        UIImage *bkIm = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/AndriosiAmury.png"];
        _background = [[UIImageView alloc] initWithImage:bkIm];
        _background.frame = CGRectMake(9, 18, 65, 65);
        [self addSubview:_background];
        
        CGRect frame = [self frame];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 84, frame.origin.y + 18, frame.size.width, frame.size.height)];
        [label setText:@"@iAmury - Alex"];
        label.textColor = [UIColor blackColor];
        [label setBackgroundColor:[UIColor clearColor]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [label setFont:[UIFont fontWithName:@"Helvetica Light" size:30]];
        else
            [label setFont:[UIFont fontWithName:@"Helvetica Light" size:18]];
        
        [self addSubview:label];
        
        label2 = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 84, frame.origin.y + 42, frame.size.width, frame.size.height)];
        
        [label2 setText:@"Designer"];
        [label2 setBackgroundColor:[UIColor clearColor]];
        [label2 setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
		label2.textColor = [UIColor grayColor];
        [self addSubview:label2];
        
        [twitterButton setBackgroundColor:[UIColor clearColor]];
        twitterButton.frame = CGRectMake(240, 25, 48, 48);
        [self addSubview:twitterButton];
    }
    return self;
}

@end

@interface andriosOpenTwitteriAmuryController : PSListController { }
@end

@implementation andriosOpenTwitteriAmuryController
- (id)specifiers {
    NSString *user = @"iAmury";
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
    
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
    return 0;
}

- (void)viewDidAppear:(BOOL)arg1 {
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:YES];
}
@end

@interface AndriosMakerCell4 : PSTableCell {
    UIImageView *_background;
    UILabel *label;
    UILabel *label2;
    UIButton *twitterButton;
}
@end

@implementation AndriosMakerCell4
-(id)initWithStyle:(long long)style reuseIdentifier:(NSString *)reuseIdentifier {
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
        UIImage *bkIm = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/AndriosHoenir.png"];
        _background = [[UIImageView alloc] initWithImage:bkIm];
        _background.frame = CGRectMake(9, 18, 65, 65);
        [self addSubview:_background];
        
        CGRect frame = [self frame];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 84, frame.origin.y + 18, frame.size.width, frame.size.height)];
        [label setText:@"@Hoenir - Liam"];
        label.textColor = [UIColor blackColor];
        [label setBackgroundColor:[UIColor clearColor]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [label setFont:[UIFont fontWithName:@"Helvetica Light" size:30]];
        else
            [label setFont:[UIFont fontWithName:@"Helvetica Light" size:18]];
        
        [self addSubview:label];
        
        label2 = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 84, frame.origin.y + 42, frame.size.width, frame.size.height)];
        
        [label2 setText:@"Designer"];
        [label2 setBackgroundColor:[UIColor clearColor]];
        [label2 setFont:[UIFont fontWithName:@"Helvetica Light" size:15]];
        label2.textColor = [UIColor grayColor];
        [self addSubview:label2];
        
        [twitterButton setBackgroundColor:[UIColor clearColor]];
        twitterButton.frame = CGRectMake(240, 25, 48, 48);
        [self addSubview:twitterButton];
    }
    return self;
}

@end

@interface andriosOpenTwitterHoenirController : PSListController { }
@end

@implementation andriosOpenTwitterHoenirController
- (id)specifiers {
    NSString *user = @"iamHoenir";
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
    
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
    return 0;
}

- (void)viewDidAppear:(BOOL)arg1 {
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:YES];
}
@end

@interface LegalController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation LegalController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Legal" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

@end

@interface LegalHeaderCell : PSTableCell{
    UILabel *tweakName;
}
@end

@implementation LegalHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect frame = CGRectMake(0, 10, width, 60);
        
        tweakName = [[UILabel alloc] initWithFrame:frame];
        [tweakName setNumberOfLines:1];
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:34];
        [tweakName setText:@"Legal Information"];
        [tweakName setBackgroundColor:[UIColor clearColor]];
        tweakName.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        tweakName.textAlignment = NSTextAlignmentCenter;
        [tweakName startShimmering];
        
        [self addSubview:tweakName];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
    return 60.f;
}
@end

@interface ConfigController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation ConfigController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Config" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    UIBarButtonItem *_customButton = [[[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)] autorelease];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:_customButton, nil];
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

- (void)respring:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Respring to apply changes?" message:@""
                                                       delegate: self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //cancel
    }
    else  if (buttonIndex==1){
        system("killall -9 backboardd || killall -9 SpringBoard");
    }
}

@end

@interface ConfigHeaderCell : PSTableCell{
    UILabel *tweakName;
}
@end

@implementation ConfigHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect frame = CGRectMake(0, 10, width, 60);
        
        tweakName = [[UILabel alloc] initWithFrame:frame];
        [tweakName setNumberOfLines:1];
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:34];
        [tweakName setText:@"Configuration"];
        [tweakName setBackgroundColor:[UIColor clearColor]];
        tweakName.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        tweakName.textAlignment = NSTextAlignmentCenter;
        [tweakName startShimmering];
        
        [self addSubview:tweakName];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
    return 60.f;
}
@end

@interface ActionBarController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation ActionBarController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"ActionBar" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    UIBarButtonItem *_customButton = [[[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)] autorelease];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:_customButton, nil];
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

- (void)respring:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Respring to apply changes?" message:@""
                                                       delegate: self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //cancel
    }
    else  if (buttonIndex==1){
        system("killall -9 backboardd || killall -9 SpringBoard");
    }
}

@end

@interface ActionBarHeaderCell : PSTableCell{
    UILabel *tweakName;
}
@end

@implementation ActionBarHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect frame = CGRectMake(0, 10, width, 60);
        
        tweakName = [[UILabel alloc] initWithFrame:frame];
        [tweakName setNumberOfLines:1];
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:34];
        [tweakName setText:@"Action Bar"];
        [tweakName setBackgroundColor:[UIColor clearColor]];
        tweakName.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        tweakName.textAlignment = NSTextAlignmentCenter;
        [tweakName startShimmering];
        
        [self addSubview:tweakName];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
    return 60.f;
}
@end

@interface AlternateNCController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation AlternateNCController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"AlternateNC" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    UIBarButtonItem *_customButton = [[[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)] autorelease];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:_customButton, nil];
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

- (void)respring:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Respring to apply changes?" message:@""
                                                       delegate: self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //cancel
    }
    else  if (buttonIndex==1){
        system("killall -9 backboardd || killall -9 SpringBoard");
    }
}

@end

@interface AlternateNCHeaderCell : PSTableCell{
    UILabel *tweakName;
}
@end

@implementation AlternateNCHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect frame = CGRectMake(0, 10, width, 60);
        
        tweakName = [[UILabel alloc] initWithFrame:frame];
        [tweakName setNumberOfLines:1];
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:34];
        [tweakName setText:@"AlternateNC"];
        [tweakName setBackgroundColor:[UIColor clearColor]];
        tweakName.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        tweakName.textAlignment = NSTextAlignmentCenter;
        [tweakName startShimmering];
        
        [self addSubview:tweakName];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
    return 60.f;
}
@end

@interface MiniplayerController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation MiniplayerController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Miniplayer" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    UIBarButtonItem *_customButton = [[[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)] autorelease];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:_customButton, nil];
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

- (void)respring:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Respring to apply changes?" message:@""
                                                       delegate: self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //cancel
    }
    else  if (buttonIndex==1){
        system("killall -9 backboardd || killall -9 SpringBoard");
    }
}

@end

@interface MiniplayerHeaderCell : PSTableCell{
    UILabel *tweakName;
}
@end

@implementation MiniplayerHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect frame = CGRectMake(0, 10, width, 60);
        
        tweakName = [[UILabel alloc] initWithFrame:frame];
        [tweakName setNumberOfLines:1];
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:34];
        [tweakName setText:@"Miniplayer Widget"];
        [tweakName setBackgroundColor:[UIColor clearColor]];
        tweakName.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        tweakName.textAlignment = NSTextAlignmentCenter;
        [tweakName startShimmering];
        
        [self addSubview:tweakName];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
    return 60.f;
}
@end

@interface PowerMenuController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation PowerMenuController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"PowerMenu" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    UIBarButtonItem *_customButton = [[[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)] autorelease];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:_customButton, nil];
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

- (void)respring:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Respring to apply changes?" message:@""
                                                       delegate: self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //cancel
    }
    else  if (buttonIndex==1){
        system("killall -9 backboardd || killall -9 SpringBoard");
    }
}

@end

@interface PowerMenuHeaderCell : PSTableCell{
    UILabel *tweakName;
}
@end

@implementation PowerMenuHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect frame = CGRectMake(0, 10, width, 60);
        
        tweakName = [[UILabel alloc] initWithFrame:frame];
        [tweakName setNumberOfLines:1];
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:34];
        [tweakName setText:@"Power Menu"];
        [tweakName setBackgroundColor:[UIColor clearColor]];
        tweakName.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        tweakName.textAlignment = NSTextAlignmentCenter;
        [tweakName startShimmering];
        
        [self addSubview:tweakName];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
    return 60.f;
}
@end

@interface SearchWidgetController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation SearchWidgetController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"SearchWidget" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    UIBarButtonItem *_customButton = [[[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)] autorelease];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:_customButton, nil];
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

- (void)respring:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Respring to apply changes?" message:@""
                                                       delegate: self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //cancel
    }
    else  if (buttonIndex==1){
        system("killall -9 backboardd || killall -9 SpringBoard");
    }
}

@end

@interface SearchWidgetHeaderCell : PSTableCell{
    UILabel *tweakName;
}
@end

@implementation SearchWidgetHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect frame = CGRectMake(0, 10, width, 60);
        
        tweakName = [[UILabel alloc] initWithFrame:frame];
        [tweakName setNumberOfLines:1];
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:34];
        [tweakName setText:@"Search Widget"];
        [tweakName setBackgroundColor:[UIColor clearColor]];
        tweakName.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        tweakName.textAlignment = NSTextAlignmentCenter;
        [tweakName startShimmering];
        
        [self addSubview:tweakName];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
    return 60.f;
}
@end

@interface SwitchesWidgetController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation SwitchesWidgetController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"SwitchesWidget" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    UIBarButtonItem *_customButton = [[[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)] autorelease];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:_customButton, nil];
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

- (void)respring:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Respring to apply changes?" message:@""
                                                       delegate: self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //cancel
    }
    else  if (buttonIndex==1){
        system("killall -9 backboardd || killall -9 SpringBoard");
    }
}

@end

@interface SwitchesWidgetHeaderCell : PSTableCell{
    UILabel *tweakName;
}
@end

@implementation SwitchesWidgetHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect frame = CGRectMake(0, 10, width, 60);
        
        tweakName = [[UILabel alloc] initWithFrame:frame];
        [tweakName setNumberOfLines:1];
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:34];
        [tweakName setText:@"Switches Widget"];
        [tweakName setBackgroundColor:[UIColor clearColor]];
        tweakName.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        tweakName.textAlignment = NSTextAlignmentCenter;
        [tweakName startShimmering];
        
        [self addSubview:tweakName];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
    return 60.f;
}
@end

@interface VolumeSliderController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation VolumeSliderController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"VolumeSlider" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    UIBarButtonItem *_customButton = [[[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)] autorelease];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:_customButton, nil];
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

- (void)respring:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Respring to apply changes?" message:@""
                                                       delegate: self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //cancel
    }
    else  if (buttonIndex==1){
        system("killall -9 backboardd || killall -9 SpringBoard");
    }
}

@end

@interface VolumeSliderHeaderCell : PSTableCell{
    UILabel *tweakName;
}
@end

@implementation VolumeSliderHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect frame = CGRectMake(0, 10, width, 60);
        
        tweakName = [[UILabel alloc] initWithFrame:frame];
        [tweakName setNumberOfLines:1];
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:34];
        [tweakName setText:@"Volume Slider"];
        [tweakName setBackgroundColor:[UIColor clearColor]];
        tweakName.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        tweakName.textAlignment = NSTextAlignmentCenter;
        [tweakName startShimmering];
        
        [self addSubview:tweakName];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
    return 60.f;
}
@end

@interface ExtrasController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation ExtrasController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Extras" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    UIBarButtonItem *_customButton = [[[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)] autorelease];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:_customButton, nil];
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

- (void)respring:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Respring to apply changes?" message:@""
                                                       delegate: self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //cancel
    }
    else  if (buttonIndex==1){
        system("killall -9 backboardd || killall -9 SpringBoard");
    }
}

@end

@interface ExtrasHeaderCell : PSTableCell{
    UILabel *tweakName;
}
@end

@implementation ExtrasHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect frame = CGRectMake(0, 10, width, 60);
        
        tweakName = [[UILabel alloc] initWithFrame:frame];
        [tweakName setNumberOfLines:1];
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:34];
        [tweakName setText:@"Extras"];
        [tweakName setBackgroundColor:[UIColor clearColor]];
        tweakName.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        tweakName.textAlignment = NSTextAlignmentCenter;
        [tweakName startShimmering];
        
        [self addSubview:tweakName];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
    return 60.f;
}
@end


@interface InstructionsHeaderCell : PSTableCell{
    UILabel *tweakName;
}
@end

@implementation InstructionsHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        int width = [[UIScreen mainScreen] bounds].size.width;
        CGRect frame = CGRectMake(0, 10, width, 60);
        
        tweakName = [[UILabel alloc] initWithFrame:frame];
        [tweakName setNumberOfLines:1];
        tweakName.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:34];
        [tweakName setText:@"Instructions"];
        [tweakName setBackgroundColor:[UIColor clearColor]];
        tweakName.textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
        tweakName.textAlignment = NSTextAlignmentCenter;
        [tweakName startShimmering];
        
        [self addSubview:tweakName];
        
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
    return 60.f;
}
@end

@interface ABInstructionsController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation ABInstructionsController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"ABInstructions" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

@end

@interface ANInstructionsController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation ANInstructionsController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"ANInstructions" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

@end

@interface PMInstructionsController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation PMInstructionsController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"PMInstructions" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

@end

@interface MPInstructionsController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation MPInstructionsController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"MPInstructions" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

@end

@interface SWWInstructionsController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation SWWInstructionsController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"SWWInstructions" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

@end

@interface SEWInstructionsController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation SEWInstructionsController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"SEWInstructions" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

@end

@interface VSInstructionsController : PSListController {
     UIWindow *settingsView;
}
@end

@implementation VSInstructionsController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"VSInstructions" target:self] retain];
    }
    return _specifiers;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *directoryPath = @"/Library/PreferenceBundles/andriosprefs.bundle/";
    NSString *iname = [NSString stringWithFormat:@"%@andrios.png",directoryPath];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [image setImage: [UIImage imageWithContentsOfFile:iname]];
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    self.navigationItem.titleView = image;
    self.view.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
    settingsView.tintColor = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.tintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    [self clearCache];
    [self reload];
    [super viewWillAppear:animated];
}

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
    PSTableCell *cell = [super tableView:arg1 cellForRowAtIndexPath:arg2];
    
    ((UILabel *)cell.titleLabel).textColor = [UIColor colorWithRed: 166/255.0 green:203/255.0 blue:69/255.0 alpha:1.0];
    
    return cell;
}

@end

// vim:ft=objc
