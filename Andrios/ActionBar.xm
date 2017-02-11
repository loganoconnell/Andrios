#import "ActionBarHeader.h"

//preferences
#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.orca.andrios.plist"]

static BOOL hideIfOpened;
static BOOL alwaysShow;
static BOOL lollipopStyle;
static BOOL useDarkBG;
static BOOL changeColorIfOpened;
static BOOL hideInSwitcher;

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.orca.andrios.plist"];

	hideIfOpened = [prefs objectForKey:@"hideifopened"] ? [[prefs objectForKey:@"hideifopened"] boolValue] : NO;
	alwaysShow = [prefs objectForKey:@"alwaysShow"] ? [[prefs objectForKey:@"alwaysShow"] boolValue] : NO;
	lollipopStyle = [prefs objectForKey:@"lollipopstyle"] ? [[prefs objectForKey:@"lollipopstyle"] boolValue] : YES;
	useDarkBG = [prefs objectForKey:@"useDarkBG"] ? [[prefs objectForKey:@"useDarkBG"] boolValue] : YES;
	changeColorIfOpened = [prefs objectForKey:@"changecolor"] ? [[prefs objectForKey:@"changecolor"] boolValue] : NO;
	hideInSwitcher = [prefs objectForKey:@"hideInSwitcher"] ? [[prefs objectForKey:@"hideInSwitcher"] boolValue] : NO;
}

//setup for last app
static id lastApp = nil;

static void SlideToApp(id identifier) {
    [[%c(SBUIController) sharedInstance] activateApplicationAnimated:identifier];
}

%hook SBAppToAppWorkspaceTransaction
-(id)_setupAnimationFrom:(id)afrom to:(id)ato {
	if(afrom != NULL) {
		lastApp = afrom;
	}
	return %orig;
}
%end
//
	
%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1
{
	%orig(arg1);
	
	////////////// ACTION BAR CODE //////////////
	edgeWindow = [[UIWindow alloc] init];
	edgeWindow.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 30, [[UIScreen mainScreen] bounds].size.width, 30);
	[edgeWindow setBackgroundColor:[UIColor clearColor]];
	edgeWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	edgeWindow.hidden = YES;
	
	backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
	backButton.tintColor = [UIColor whiteColor];
	backButton.frame = CGRectMake(0, 0, 50, 30);
	UITapGestureRecognizer *first = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(back:)];
	UITapGestureRecognizer *second = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(hideView:)];
	first.numberOfTapsRequired = 1;
	second.numberOfTapsRequired = 2;
	[first requireGestureRecognizerToFail:second];
	[backButton addGestureRecognizer:first];
	[backButton addGestureRecognizer:second];
	
    homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[homeButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[homeButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/highlighted.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
	homeButton.tintColor = [UIColor whiteColor];
    homeButton.frame = CGRectMake(0, 0, 50, 30);
	
	UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapOnce:)];
	UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapTwice:)];
    UILongPressGestureRecognizer *siri = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(launchSiri:)];
	
	tapOnce.numberOfTapsRequired = 1;
	tapTwice.numberOfTapsRequired = 2;
	
	[tapOnce requireGestureRecognizerToFail:tapTwice];
	[siri requireGestureRecognizerToFail:tapOnce];
	
	[homeButton addGestureRecognizer:tapOnce];
	[homeButton addGestureRecognizer:tapTwice];
	[homeButton addGestureRecognizer:siri];
	
	
	switcherButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[switcherButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/switcher.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	switcherButton.tintColor = [UIColor whiteColor];
	switcherButton.frame = CGRectMake(0, 0, 50, 30);
    [switcherButton addTarget:self action:@selector(switcher:) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	[switcherButton addGestureRecognizer:longPress];
	
	CGRect toolBarFrame = CGRectMake(0, 0, edgeWindow.size.width, 30);
    toolBar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
   	UIBarButtonItem *home = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
	UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *switcher = [[UIBarButtonItem alloc] initWithCustomView:switcherButton];
	UIBarButtonItem *spacer3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [toolBar setItems:[[NSArray alloc] initWithObjects:spacer, back, spacer1, home, spacer2, switcher, spacer3, nil]];
	[toolBar setBarTintColor:[UIColor clearColor]];
	[toolBar setBackgroundImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	toolBar.backgroundColor = [UIColor clearColor];
	[toolBar setClipsToBounds:YES];
	[edgeWindow addSubview:toolBar];
	////////////// ACTION BAR CODE //////////////
	
	if (lollipopStyle) {
		
		[backButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/backnew.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
		[homeButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/homenew.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
		[switcherButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/switchernew.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
		backButton.tintColor = [UIColor whiteColor];
		homeButton.tintColor = [UIColor whiteColor];
		switcherButton.tintColor = [UIColor whiteColor];

		if (useDarkBG) {

			[toolBar setBarTintColor:[UIColor blackColor]];
			toolBar.backgroundColor = [UIColor blackColor];
			
		} else {
			
			[toolBar setBarTintColor:[UIColor clearColor]];
			toolBar.backgroundColor = [UIColor clearColor];
		}
	
	} else {

		[backButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
		[homeButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
		[switcherButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/switcher.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
		[toolBar setBarTintColor:[UIColor blackColor]];
		toolBar.backgroundColor = [UIColor blackColor];
		backButton.tintColor = [UIColor whiteColor];
		homeButton.tintColor = [UIColor whiteColor];
		switcherButton.tintColor = [UIColor whiteColor];
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

//go to last app
%new
-(void)back:(id)sender 
{	
	if(lastApp != NULL) {
		SlideToApp(lastApp);
		
		if(changeColorIfOpened && lollipopStyle) {
			backButton.tintColor = [UIColor blackColor];
			homeButton.tintColor = [UIColor blackColor];
			switcherButton.tintColor = [UIColor blackColor];
		}
	}
	
	if (hideIfOpened) {
		edgeWindow.hidden = YES;			 
	} else {}
}

//home button
%new
- (void)tapOnce:(UIGestureRecognizer *)gesture
{
	[[%c(SBUIController) sharedInstance] clickedMenuButton];
	[[%c(SBUIController) sharedInstance] dismissSwitcherAnimated:YES];
	[[%c(SBNotificationCenterController) sharedInstance] dismissAnimated:YES];
	[[%c(SBControlCenterController) sharedInstance] dismissAnimated:YES];
	[[%c(SBSearchViewController) sharedInstance] dismiss];
}

//double tap home to open switcher
%new
- (void)tapTwice:(UIGestureRecognizer *)gesture
{
	[[%c(SBUIController) sharedInstance] handleMenuDoubleTap];
}

//double tap back button to hide UIWindow
%new
- (void)hideView:(UIGestureRecognizer *)gesture
{
	edgeWindow.hidden = YES;
}

//open and close app switcher
%new
-(void)switcher:(id)sender 
{	
	[[%c(SBUIController) sharedInstance] _toggleSwitcher];
}

//launch siri
%new
- (void)launchSiri:(UILongPressGestureRecognizer *)gesture 
{
	[assistantController _activateSiriForPPT];
	[[%c(SBUIPluginManager) sharedInstance] handleButtonUpEventFromSource:1];
}

//hold to clear app switcher
%new
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture 
{
	if ([gesture state] == UIGestureRecognizerStateBegan) {  
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Clear Switcher?"
                                                  message:@""
                                                 delegate:self
                                        cancelButtonTitle:@"No"
                                        otherButtonTitles:@"Yes", nil];
    
   		[alertView show];
	}
}

%new
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {	
        //cancel
    } else if (buttonIndex == 1) {
		
		if (IS_OS_7_OR_UNDER) {
			[(SBSyncController *)[NSClassFromString(@"SBSyncController") sharedInstance] _killApplications];
			[[[NSClassFromString(@"SBAppSwitcherModel") sharedInstance] valueForKey:@"_recentDisplayIdentifiers"] removeAllObjects];
			[[%c(SBUIController) sharedInstance] dismissSwitcherAnimated:YES];
		} else { //iOS 8
			[(SBSyncController *)[NSClassFromString(@"SBSyncController") sharedInstance] _killApplications];
			[[[NSClassFromString(@"SBAppSwitcherModel") sharedInstance] valueForKey:@"_recentDisplayLayouts"] removeAllObjects];
			[[%c(SBUIController) sharedInstance] dismissSwitcherAnimated:YES];
		}
	}
}
%end

%hook SBLeafIcon
-(void)launchFromLocation:(int)location {
	
	%orig;
	
	if(changeColorIfOpened && lollipopStyle) {
		backButton.tintColor = [UIColor blackColor];
		homeButton.tintColor = [UIColor blackColor];
		switcherButton.tintColor = [UIColor blackColor];
	} else {}

	if (alwaysShow && hideIfOpened) {
		edgeWindow.hidden = YES;				 
	} else if (alwaysShow && !hideIfOpened) {
		edgeWindow.hidden = NO;
	} else if (!alwaysShow && hideIfOpened) {
		edgeWindow.hidden = YES;
	} else {}
}
%end

%hook SBUIController
-(BOOL)_handleButtonEventToSuspendDisplays:(BOOL)suspendDisplays displayWasSuspendedOut:(BOOL*)anOut {
	
	BOOL original = %orig;
	
	if(changeColorIfOpened && lollipopStyle) {
		backButton.tintColor = [UIColor whiteColor];
		homeButton.tintColor = [UIColor whiteColor];
		switcherButton.tintColor = [UIColor whiteColor];
	} else {}
	
	if (alwaysShow) {
		edgeWindow.hidden = NO;
	} else if (hideIfOpened && alwaysShow) {
		edgeWindow.hidden = NO;
	} else if (hideIfOpened) {
		edgeWindow.hidden = NO;
	} else {}
	
	if (hideIfOpened && !alwaysShow) {
		edgeWindow.hidden = YES;
	}
	
	return original;
}
%end

%hook SBIconContentView
-(void)updateLayoutWithDuration:(double)duration {
	
	%orig;
	
	if (alwaysShow) {
		edgeWindow.hidden = NO;
	} else {}
}
%end

%hook SBLockScreenManager
-(void)lockUIFromSource:(int)source withOptions:(id)options {
	
	%orig;

	if (alwaysShow) {
		edgeWindow.hidden = YES;
	} else {}
}
%end

%hook SBLockScreenViewController
-(void)finishUIUnlockFromSource:(int)source {
	
	%orig; 
	
	if (alwaysShow) {
		edgeWindow.hidden = NO;
	} else {}
}
%end

%hook SBAssistantController
-(void)init {

    	%orig;
    	assistantController = self;
}
%end

%hook SBAppSwitcherController
- (void)switcherWasPresented:(BOOL)presented {

	if (alwaysShow && hideInSwitcher) {

		edgeWindow.hidden = YES;
	}

	%orig;
}

- (void)animateDismissalToDisplayLayout:(id)displayLayout withCompletion:(id)completion {

	%orig;
	
	if (alwaysShow && hideInSwitcher) {

		edgeWindow.hidden = NO;
	}
}
%end

%hook SBAppSliderController
- (void)switcherWasPresented:(BOOL)presented {

	if (alwaysShow && hideInSwitcher) {

		edgeWindow.hidden = YES;
	}

	%orig;
}

- (void)animateDismissalToBundleIdentifier:(id)bundleIdentifier withCompletion:(id)completion {

	%orig;

	if (alwaysShow && hideInSwitcher) {

		edgeWindow.hidden = NO;
	}
}
%end

#import <libactivator/libactivator.h>

@interface ActionBarActivator : NSObject <LAListener>
@end

@implementation ActionBarActivator
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {

	if (edgeWindow.hidden) {

		edgeWindow.hidden = NO;

	//original frame
	edgeWindow.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height + 30, [[UIScreen mainScreen] bounds].size.width, 30);

	//show ActionBar
	[UIView animateWithDuration:0.5
                 animations:^{
                     edgeWindow.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 30, [[UIScreen mainScreen] bounds].size.width, 30);
                 }];
	}

	else {

		edgeWindow.hidden = YES;
	}

	[event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {}

+ (void)load {
	if ([LASharedActivator isRunningInsideSpringBoard]) {
			[LASharedActivator registerListener:[self new] forName:@"com.orca.andriosbar"];
	}
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
	return @"Andrios";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return @"Action Bar";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Choose action to show Action Bar";
}
- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
	return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
}
- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {

	return [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/ActionBar.png"] scale:scale];
}
- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {

	return [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/ActionBar.png"] scale:scale];
}
@end

%ctor {

	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.orca.andrios/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);

}