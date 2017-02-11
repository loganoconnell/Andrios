#import "SearchWidgetHeader.h"

static BOOL snewAndroid;
static BOOL spinToHomescreen;

static CGRect frameBeforeSearch = CGRectNull;

static void loadPrefs() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.orca.andrios.plist"];

	snewAndroid = [prefs objectForKey:@"snewAndroid"] ? [[prefs objectForKey:@"snewAndroid"] boolValue] : YES;
	spinToHomescreen = [prefs objectForKey:@"spinToHomescreen"] ? [[prefs objectForKey:@"spinToHomescreen"] boolValue] : NO;
}

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1
{
	%orig(arg1);
	
	springBoard = self;
	
	searchWindow = [[UIWindow alloc] initWithFrame:CGRectMake(10, 20, width, 45)];
	[[searchWindow layer] setCornerRadius:2.0];
	searchWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	searchWindow.backgroundColor = [UIColor clearColor];
	sPresented = NO;
	searchWindow.hidden = YES;

	UIPanGestureRecognizer *movePanGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sHandleMovePan:)];
	[searchWindow addGestureRecognizer:movePanGR];

	UILongPressGestureRecognizer *centerSearchWidget = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(centerSearchWidget:)];
	[searchWindow addGestureRecognizer:centerSearchWidget];

	whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 45)];
	[[whiteView layer] setCornerRadius:2.0];
	whiteView.backgroundColor = [UIColor whiteColor];
	whiteView.alpha = 0.4;
	[searchWindow addSubview:whiteView];
	
	textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, width, 45)];
	[[textField layer] setCornerRadius:2.0];
	if (snewAndroid) { textField.backgroundColor = [UIColor whiteColor]; }
	else { textField.backgroundColor = [UIColor clearColor]; }
	[textField addTarget:self action:@selector(beginSearch:) forControlEvents:UIControlEventEditingDidBegin];
	[textField addTarget:self action:@selector(finishSearch:) forControlEvents:UIControlEventEditingDidEndOnExit];
	if (snewAndroid) { textField.textColor = [UIColor grayColor]; }
	else { textField.textColor = [UIColor whiteColor]; }
	[[textField textInputTraits] setValue:[UIColor grayColor] forKey:@"insertionPointColor"];
	textField.font = [UIFont systemFontOfSize:15];
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.returnKeyType = UIReturnKeyGo;
	textField.clearButtonMode = UITextFieldViewModeNever;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textField.textAlignment = NSTextAlignmentLeft;
	UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, textField.frame.size.height)];
	leftView.backgroundColor = textField.backgroundColor;
	textField.leftView = leftView;
	textField.leftViewMode = UITextFieldViewModeAlways;
	[[textField layer] setCornerRadius:3.0];
	[searchWindow addSubview:textField];
	
	if (snewAndroid) { googleImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/googleicon.png"] _flatImageWithColor:[UIColor grayColor]]]; }
	else { googleImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/googleicon.png"] _flatImageWithColor:[UIColor whiteColor]]]; }
	googleImage.frame = CGRectMake(15, -10, 65, 65);
	if (snewAndroid) { googleImage.tintColor = [UIColor grayColor]; }
	else { googleImage.tintColor = [UIColor whiteColor]; }
	googleImage.userInteractionEnabled = YES;
	googleImage.hidden = NO;
	[textField addSubview:googleImage];
	
	UIButton *siriButton = [UIButton buttonWithType:UIButtonTypeCustom];
	siriButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 63, 8.5, 28, 28);
	if (snewAndroid) { [siriButton setBackgroundImage:[[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/siri.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] _flatImageWithColor:[UIColor grayColor]] forState:UIControlStateNormal]; }
	else { [siriButton setBackgroundImage:[[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/siri.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] _flatImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal]; }
	if (snewAndroid) { siriButton.tintColor = [UIColor grayColor]; }
	else { siriButton.tintColor = [UIColor whiteColor]; }
    	[siriButton addTarget:self action:@selector(openSiri:) forControlEvents:UIControlEventTouchUpInside];
	[searchWindow addSubview:siriButton];
	
	webViewWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	webViewWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	webViewWindow.backgroundColor = [UIColor clearColor];
	webViewWindow.hidden = YES;
	
	webView = [[UIWebView alloc] init];
	webView.frame = CGRectMake(0, 0, width, 430);
	webView.center = webViewWindow.center;
	[[webView layer] setCornerRadius:8.0];
	[webView setClipsToBounds:YES];
	webView.hidden = YES;
    webView.scalesPageToFit = YES;
    [webViewWindow addSubview:webView];

	goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	goBackButton.frame = CGRectMake(0, 0, 30, 30);
	[goBackButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/goback.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
	goBackButton.tintColor = [UIColor darkGrayColor];
    [goBackButton addTarget:self action:@selector(goBackward:) forControlEvents:UIControlEventTouchUpInside];
	[webView addSubview:goBackButton];

	forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
	forwardButton.frame = CGRectMake(0, 0, 30, 30);
	[forwardButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/goforward.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
	forwardButton.tintColor = [UIColor darkGrayColor];
    [forwardButton addTarget:self action:@selector(goForward:) forControlEvents:UIControlEventTouchUpInside];
	[webView addSubview:forwardButton];
	
	UIButton *homebutton = [UIButton buttonWithType:UIButtonTypeCustom];
	homebutton.frame = CGRectMake(0, 0, 30, 30);
	[homebutton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/gohome.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
	homebutton.tintColor = [UIColor darkGrayColor];
    [homebutton addTarget:self action:@selector(home:) forControlEvents:UIControlEventTouchUpInside];
	[webView addSubview:homebutton];
	
	UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
	menuButton.frame = CGRectMake(0, 0, 30, 30);
	[menuButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/menu.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
	menuButton.tintColor = [UIColor darkGrayColor];
    [menuButton addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
	[webView addSubview:menuButton];

	UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	exitButton.frame = CGRectMake(0, 0, 30, 30);
	[exitButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/exitwebview.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
	exitButton.tintColor = [UIColor darkGrayColor];
    [exitButton addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
	[webView addSubview:exitButton];
	
	CGSize boundsSize = webView.bounds.size;
    webToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, boundsSize.height - 37, boundsSize.width, 37)];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
   	UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithCustomView:forwardButton];
	UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *home = [[UIBarButtonItem alloc] initWithCustomView:homebutton];
	UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
	UIBarButtonItem *spacer3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *exitView = [[UIBarButtonItem alloc] initWithCustomView:exitButton];
    [webToolBar setItems:[[NSArray alloc] initWithObjects:back, spacer, forward, spacer1, home, spacer2, menu, spacer3, exitView, nil]];
    [webToolBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
	[webToolBar setBackgroundImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	[webToolBar setBackgroundColor:[UIColor whiteColor]];
	[webToolBar setAlpha:0.5];
    [webView addSubview:webToolBar];

	CGRect frame = CGRectMake(0, 0, 320, 480);
	SPUserResizableView *userResizableView = [[SPUserResizableView alloc] initWithFrame:frame];
	userResizableView.contentView = webView;
	lastEditedView = userResizableView;
	[webViewWindow addSubview:userResizableView];
	
	UITapGestureRecognizer *hideHandles = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEditingHandles)];
	[webViewWindow addGestureRecognizer:hideHandles];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([currentlyEditingView hitTest:[touch locationInView:currentlyEditingView] withEvent:nil]) {
        return NO;
    }
    return YES;
}

%new
- (void)hideEditingHandles {
    [lastEditedView hideEditingHandles];
}

%new
-(void)sHandleMovePan:(UIPanGestureRecognizer *)recognizer {
 
    CGPoint translation = [recognizer translationInView:searchWindow];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:searchWindow];
}

%new
-(void)centerSearchWidget:(id)sender {
	
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		CGRect newFrame = searchWindow.frame;
		newFrame.origin.x = ([[UIScreen mainScreen] bounds].size.width - 300) / 2;
		searchWindow.frame = newFrame;
    }
    completion:^(BOOL finished) {

	}];
}

%new
-(void)beginSearch:(UITextField *)field {
	googleImage.hidden = YES;
	textField.textAlignment = NSTextAlignmentLeft;
}

%new
- (void)finishSearch:(UITextField *)field
{
	if([textField.text isEqual:@""]) {
		[textField resignFirstResponder];
		googleImage.hidden = NO;

		if (!spinToHomescreen) {
			
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

        		CGRect slideUpFrame = searchWindow.frame;
				slideUpFrame.origin.y = -45;
				searchWindow.frame = slideUpFrame;
				searchWindow.alpha = 0.0;
   			}
    			completion:^(BOOL finished) {

				sPresented = NO;
				searchWindow.hidden = YES;
			}];
		}
		
	} else {

		frameBeforeSearch = searchWindow.frame;
		
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

        	CGRect slideUpFrame = searchWindow.frame;
			slideUpFrame.origin.y = -45;
			searchWindow.frame = slideUpFrame;
			searchWindow.alpha = 0.0;
   		}
    		completion:^(BOOL finished) {

			googleImage.hidden = NO;
			searchWindow.hidden = YES;
			webViewWindow.hidden = NO;
			webView.hidden = NO;
		}];
	
		NSString *query = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
		NSString *urlAddress = [NSString stringWithFormat:@"http://www.google.com/search?q=%@", query];
		NSURL *url = [NSURL URLWithString:urlAddress];
		NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	    [webView loadRequest:requestObj];
	}
}

%new
- (void)goBackward:(id)sender {
    
	[webView goBack];
}

%new
- (void)goForward:(id)sender {

	[webView goForward];
}

%new
- (void)home:(id)sender {
	
	NSString *urlAddress = [NSString stringWithFormat:@"https://www.google.com/"];
	NSURL *url = [NSURL URLWithString:urlAddress];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
}

%new
-(void)openMenu:(id)sender {
	[[UIApplication sharedApplication] openURL:[webView.request URL]]; 
}

%new
-(void)exit:(id)sender {

	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		webViewWindow.hidden = YES;
		webView.hidden = YES;
		searchWindow.hidden = NO;
		searchWindow.frame = frameBeforeSearch;
        searchWindow.alpha = 1.0;
		textField.text = @"";
    }
    completion:^(BOOL finished) {

    	frameBeforeSearch = CGRectNull;
	}];
}

%new
-(void)openSiri:(id)sender 
{
	if (![textField.text isEqual:@""] && springBoard && assistantController) {

		[textField resignFirstResponder];
		if (!spinToHomescreen) { sPresented = NO; searchWindow.hidden = YES; }
		NSArray *myStrings = [NSArray arrayWithObjects:textField.text, nil];
    		[springBoard setNextAssistantRecognitionStrings:myStrings];
    		[assistantController _activateSiriForPPT];
		[[%c(SBUIPluginManager) sharedInstance] handleButtonUpEventFromSource:1];
		textField.text = @"";
		googleImage.hidden = NO;
	
	} else {
		
		[textField resignFirstResponder];
		if (!spinToHomescreen) { sPresented = NO; searchWindow.hidden = YES; }
		[assistantController _activateSiriForPPT];
		[[%c(SBUIPluginManager) sharedInstance] handleButtonUpEventFromSource:1];
		googleImage.hidden = NO;
	}
}
%end

%hook SBLeafIcon
-(void)launchFromLocation:(int)location {
	
	if (spinToHomescreen) {
		searchWindow.hidden = YES;
	}
	%orig;
}
%end

%hook SBIconContentView
-(void)updateLayoutWithDuration:(double)duration {

[self addSubview:searchWindow];

	if (spinToHomescreen) {

		%orig(duration);
		[self addSubview:searchWindow];
		searchWindow.windowLevel = UIWindowLevelNormal;
		sPresented = YES;
		searchWindow.hidden = NO;
	
	} else {

		%orig(duration);
		searchWindow.hidden = YES;
	}
}
%end

%hook SBUIController
-(void)_toggleSwitcher {
	
	if (spinToHomescreen) {

		sPresented = YES;
		searchWindow.hidden = NO;
		%orig;
	} else {

		%orig;
	}
}
%end

%hook SBSearchViewController
-(void)_setShowingKeyboard:(BOOL)keyboard {

	if ((spinToHomescreen) && keyboard) {
		
		sPresented = NO;
		searchWindow.hidden = YES;
		%orig(keyboard);		 
		
	}

	else if ((spinToHomescreen) && !keyboard) {

		sPresented = YES;
		searchWindow.hidden = NO;
		%orig(keyboard);
	
	} else {

		%orig(keyboard);
	}
}
%end

%hook SBAssistantController
-(void)init {

    	%orig;
    	assistantController = self;
}
%end
	
#import <libactivator/libactivator.h>

@interface SearchWidgetActivator : NSObject <LAListener>
@end

@implementation SearchWidgetActivator
- (void)activator:(id)activator receiveEvent:(id)event {

	if (!sPresented || spinToHomescreen) {

		[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			searchWindow.hidden = NO;
			CGRect slideDownFrame = CGRectMake(10, 20, 300, 45);
			searchWindow.frame = slideDownFrame;
        		searchWindow.alpha = 1.0;
        	}
        	completion:^(BOOL finished) {

			sPresented = YES;
		}];
	}

	else {

		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

        		CGRect slideUpFrame = searchWindow.frame;
			slideUpFrame.origin.y = -45;
			searchWindow.frame = slideUpFrame;
			searchWindow.alpha = 0.0;
   		}
    		completion:^(BOOL finished) {

			sPresented = NO;
			searchWindow.hidden = YES;
		}];
	}

	[event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {}

+ (void)load {
	if ([LASharedActivator isRunningInsideSpringBoard]) {
			[LASharedActivator registerListener:[self new] forName:@"com.orca.andriossearch"];
	}
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
	return @"Andrios";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return @"Search Widget";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Choose action to show Search Widget";
}

- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
	return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
}
- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {

	return [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/SearchWidget.png"] scale:scale];
}
- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {

	return [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/SearchWidget.png"] scale:scale];
}
@end

%ctor {

	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.orca.andrios/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);

}