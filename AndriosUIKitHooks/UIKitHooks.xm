#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

static BOOL changeNavbars;
static BOOL changeStatusBarColorForNavbar;
static BOOL pushScreen;

static void loadPrefs() {
	
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.orca.andrios.plist"];
	
	changeNavbars = [prefs objectForKey:@"changeNavbars"] ? [[prefs objectForKey:@"changeNavbars"] boolValue] : NO;
	changeStatusBarColorForNavbar = [prefs objectForKey:@"changeStatusBarColorForNavbar"] ? [[prefs objectForKey:@"changeStatusBarColorForNavbar"] boolValue] : NO;
	pushScreen = [prefs objectForKey:@"pushScreen"] ? [[prefs objectForKey:@"pushScreen"] boolValue] : NO;
}

%hook UINavigationController
-(void)loadView {

	%orig;

	if (changeNavbars) {

		self.navigationBar.barTintColor = self.navigationBar.tintColor;
		self.navigationBar.tintColor = [UIColor whiteColor];
	}
}
%end

%hook UINavigationItemView
-(UIColor *)_currentTextColorForBarStyle:(int)arg1 {

	if (changeNavbars) {

		return [UIColor whiteColor];
	}

	else {

		return %orig;
	}
}
%end

%hook UIStatusBarNewUIStyleAttributes
-(id)initWithRequest:(id)arg1 backgroundColor:(id)arg2 foregroundColor:(UIColor *)arg3 {

	if (changeStatusBarColorForNavbar) {

		return %orig(arg1, arg2, [UIColor whiteColor]);
	}

	else {

		return %orig;
	}
}
%end

%hook UIWindow
- (void)layoutSubviews {

	%orig;
	
	if (CGRectEqualToRect(self.frame, [[UIScreen mainScreen] bounds]) && self.windowLevel < UIWindowLevelStatusBar && pushScreen) {

		CGRect newFrame = [[UIScreen mainScreen] bounds];
		newFrame.size.height = newFrame.size.height - 30;
		self.frame = newFrame;
	}
}
%end
	
%ctor {

	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.orca.andrios/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}