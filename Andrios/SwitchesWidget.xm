#import "SwitchesWidgetHeader.h"

static BOOL swpinToHomescreen;

static void loadPrefs() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.orca.andrios.plist"];

	swpinToHomescreen = [prefs objectForKey:@"swpinToHomescreen"] ? [[prefs objectForKey:@"swpinToHomescreen"] boolValue] : NO;
}

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1
{
	%orig(arg1);
	
	switcheswindow = [[UIWindow alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width - 300) / 2, 20, 300, 80)];
	switcheswindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	switcheswindow.hidden = YES;
	switcheswindow.alpha = 1.0;
	switcheswindow.backgroundColor = [UIColor colorWithRed: 54/255.0 green:65/255.0 blue:71/255.0 alpha:1.0];

	UIPanGestureRecognizer *moveMP = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swHandleMovePan:)];
	[switcheswindow addGestureRecognizer:moveMP];

	UILongPressGestureRecognizer *centerSwitchesWidget = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(centerSwitchesWidget:)];
	[switcheswindow addGestureRecognizer:centerSwitchesWidget];

	wifiswitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	wifiswitch.frame = CGRectMake(0, 0, 60, 80);
	[wifiswitch setBackgroundColor:[UIColor clearColor]];
	[wifiswitch addTarget:self action:@selector(wifi:) forControlEvents:UIControlEventTouchUpInside];
	[switcheswindow addSubview:wifiswitch];
	wifiswitchImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchon.png"] _flatImageWithColor:[UIColor whiteColor]]];
	wifiswitchImage.frame = CGRectMake(17.5, 27.5, 25, 25);
	[wifiswitch addSubview:wifiswitchImage];
	selectedwifiView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, 60, 5)];
	selectedwifiView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];
	[wifiswitch addSubview:selectedwifiView];

	bluetoothswitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	bluetoothswitch.frame = CGRectMake(60, 0, 60, 80);
	[bluetoothswitch setBackgroundColor:[UIColor clearColor]];
	[bluetoothswitch addTarget:self action:@selector(bluetooth:) forControlEvents:UIControlEventTouchUpInside];
	[switcheswindow addSubview:bluetoothswitch];
	bluetoothswitchImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchon.png"] _flatImageWithColor:[UIColor whiteColor]]];
	bluetoothswitchImage.frame = CGRectMake(17.5, 27.5, 25, 25);
	[bluetoothswitch addSubview:bluetoothswitchImage];
	selectedbluetoothView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, 60, 5)];
	selectedbluetoothView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];
	[bluetoothswitch addSubview:selectedbluetoothView];

	locationswitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	locationswitch.frame = CGRectMake(120, 0, 60, 80);
	[locationswitch setBackgroundColor:[UIColor clearColor]];
	[locationswitch addTarget:self action:@selector(location:) forControlEvents:UIControlEventTouchUpInside];
	[switcheswindow addSubview:locationswitch];
	locationswitchImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchon.png"] _flatImageWithColor:[UIColor whiteColor]]];
	locationswitchImage.frame = CGRectMake(17.5, 27.5, 25, 25);
	[locationswitch addSubview:locationswitchImage];
	selectedlocationView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, 60, 5)];
	selectedlocationView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];
	[locationswitch addSubview:selectedlocationView];

	dndswitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	dndswitch.frame = CGRectMake(180, 0, 60, 80);
	[dndswitch setBackgroundColor:[UIColor clearColor]];
	[dndswitch addTarget:self action:@selector(dnd:) forControlEvents:UIControlEventTouchUpInside];
	[switcheswindow addSubview:dndswitch];
	dndswitchImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor whiteColor]]];
	dndswitchImage.frame = CGRectMake(17.5, 27.5, 25, 25);
	[dndswitch addSubview:dndswitchImage];
	selecteddndView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, 60, 5)];
	selecteddndView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];
	[dndswitch addSubview:selecteddndView];

	autobrightnessswitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	autobrightnessswitch.frame = CGRectMake(240, 0, 60, 80);
	[autobrightnessswitch setBackgroundColor:[UIColor clearColor]];
	[autobrightnessswitch addTarget:self action:@selector(autobrightness:) forControlEvents:UIControlEventTouchUpInside];
	[switcheswindow addSubview:autobrightnessswitch];
	autobrightnessswitchImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor whiteColor]]];
	autobrightnessswitchImage.frame = CGRectMake(17.5, 27.5, 25, 25);
	[autobrightnessswitch addSubview:autobrightnessswitchImage];
	selectedautobrightnessView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, 60, 5)];
	selectedautobrightnessView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];
	[autobrightnessswitch addSubview:selectedautobrightnessView];

	UIView *verticalLineView1 = [[UIView alloc] initWithFrame:CGRectMake(59.75, 0, 0.5, 80)];
	verticalLineView1.backgroundColor = [UIColor blackColor];
	[switcheswindow addSubview:verticalLineView1];

	UIView *verticalLineView2 = [[UIView alloc] initWithFrame:CGRectMake(119.75, 0, 0.5, 80)];
	verticalLineView2.backgroundColor = [UIColor blackColor];
	[switcheswindow addSubview:verticalLineView2];

	UIView *verticalLineView3 = [[UIView alloc] initWithFrame:CGRectMake(179.75, 0, 0.5, 80)];
	verticalLineView3.backgroundColor = [UIColor blackColor];
	[switcheswindow addSubview:verticalLineView3];

	UIView *verticalLineView4 = [[UIView alloc] initWithFrame:CGRectMake(239.75, 0, 0.5, 80)];
	verticalLineView4.backgroundColor = [UIColor blackColor];
	[switcheswindow addSubview:verticalLineView4];

	updateSwitchesWidgetTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateSwitchesWidget:) userInfo:nil repeats:YES];
}

%new
-(void)updateSwitchesWidget:(id)sender {
	
	FSSwitchState state1 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.wifi"];
	if (state1 == FSSwitchStateOn) {
 
		wifiswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		wifiswitchImage.tintColor = [UIColor whiteColor];
		selectedwifiView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {
 
		wifiswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchoff.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		wifiswitchImage.tintColor = [UIColor lightGrayColor];
		selectedbluetoothView.backgroundColor = [UIColor lightGrayColor];
	}
    
    	FSSwitchState state2 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.bluetooth"];
	if (state2 == FSSwitchStateOn) {
 
		bluetoothswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		bluetoothswitchImage.tintColor = [UIColor whiteColor];
		selectedbluetoothView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {
 
		bluetoothswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchoff.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		bluetoothswitchImage.tintColor = [UIColor lightGrayColor];
		selectedbluetoothView.backgroundColor = [UIColor lightGrayColor];
	}
    
    	FSSwitchState state3 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.location"];
	if (state3 == FSSwitchStateOn) {
 
		locationswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		locationswitchImage.tintColor = [UIColor whiteColor];
		selectedlocationView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {
 
		locationswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchoff.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		locationswitchImage.tintColor = [UIColor lightGrayColor];
		selectedlocationView.backgroundColor = [UIColor lightGrayColor];
	}

	FSSwitchState state4 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"];
	if (state4 == FSSwitchStateOn) {
 
		dndswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor whiteColor]];
		dndswitchImage.tintColor = [UIColor whiteColor];
		selecteddndView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {
 
		dndswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		dndswitchImage.tintColor = [UIColor lightGrayColor];
		selecteddndView.backgroundColor = [UIColor lightGrayColor];
	}

	FSSwitchState state5 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness"];
	if (state5 == FSSwitchStateOn) {
 
		autobrightnessswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor whiteColor]];
		autobrightnessswitchImage.tintColor = [UIColor whiteColor];
		selectedautobrightnessView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {
 
		autobrightnessswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		autobrightnessswitchImage.tintColor = [UIColor lightGrayColor];
		selectedautobrightnessView.backgroundColor = [UIColor lightGrayColor];
	}
}

%new
-(void)swHandleMovePan:(UIPanGestureRecognizer *)recognizer {

    CGPoint translation = [recognizer translationInView:switcheswindow];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:switcheswindow];
}

%new
-(void)centerSwitchesWidget:(id)sender {
	
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		CGRect newFrame = switcheswindow.frame;
		newFrame.origin.x = ([[UIScreen mainScreen] bounds].size.width - 300) / 2;
		switcheswindow.frame = newFrame;
    }
    completion:^(BOOL finished) {

	}];
}

%new
-(void)wifi:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.wifi"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.wifi"];
		wifiswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		wifiswitchImage.tintColor = [UIColor whiteColor];
		selectedwifiView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.wifi"];
		wifiswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchoff.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		wifiswitchImage.tintColor = [UIColor lightGrayColor];
		selectedbluetoothView.backgroundColor = [UIColor lightGrayColor];
	}
}

%new
-(void)bluetooth:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.bluetooth"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.bluetooth"];
		bluetoothswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		bluetoothswitchImage.tintColor = [UIColor whiteColor];
		selectedbluetoothView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.bluetooth"];
		bluetoothswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchoff.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		bluetoothswitchImage.tintColor = [UIColor lightGrayColor];
		selectedbluetoothView.backgroundColor = [UIColor lightGrayColor];
	}
}

%new
-(void)location:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.location"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.location"];
		locationswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		locationswitchImage.tintColor = [UIColor whiteColor];
		selectedlocationView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.location"];
		locationswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchoff.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		locationswitchImage.tintColor = [UIColor lightGrayColor];
		selectedlocationView.backgroundColor = [UIColor lightGrayColor];
	}
}

%new
-(void)dnd:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"];
		dndswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor whiteColor]];
		dndswitchImage.tintColor = [UIColor whiteColor];
		selecteddndView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"];
		dndswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		dndswitchImage.tintColor = [UIColor lightGrayColor];
		selecteddndView.backgroundColor = [UIColor lightGrayColor];
	}
}

%new
-(void)autobrightness:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness"];
		autobrightnessswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor whiteColor]];
		autobrightnessswitchImage.tintColor = [UIColor whiteColor];
		selectedautobrightnessView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness"];
		autobrightnessswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		autobrightnessswitchImage.tintColor = [UIColor lightGrayColor];
		selectedautobrightnessView.backgroundColor = [UIColor lightGrayColor];
	}
}
%end

%hook SBLeafIcon
-(void)launchFromLocation:(int)location {
	
	if (swpinToHomescreen) {
		switcheswindow.hidden = YES;
	}
	%orig;
}
%end

%hook SBIconContentView
-(void)updateLayoutWithDuration:(double)duration {

	if (swpinToHomescreen) {

		%orig(duration);
		[self addSubview:switcheswindow];
		switcheswindow.windowLevel = UIWindowLevelNormal;
		switcheswindow.hidden = NO;
	
	} else {

		%orig(duration);
		switcheswindow.hidden = YES;
	}
}
%end

#import <libactivator/libactivator.h>

@interface SwitchesWidgetActivator : NSObject <LAListener>
@end

@implementation SwitchesWidgetActivator
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {

	FSSwitchState state1 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.wifi"];
	if (state1 == FSSwitchStateOn) {

		wifiswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		wifiswitchImage.tintColor = [UIColor whiteColor];
		selectedwifiView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {

		wifiswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchoff.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		wifiswitchImage.tintColor = [UIColor lightGrayColor];
		selectedbluetoothView.backgroundColor = [UIColor lightGrayColor];
	}

    	FSSwitchState state2 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.bluetooth"];
	if (state2 == FSSwitchStateOn) {

		bluetoothswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		bluetoothswitchImage.tintColor = [UIColor whiteColor];
		selectedbluetoothView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {

		bluetoothswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchoff.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		bluetoothswitchImage.tintColor = [UIColor lightGrayColor];
		selectedbluetoothView.backgroundColor = [UIColor lightGrayColor];
	}

    	FSSwitchState state3 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.location"];
	if (state3 == FSSwitchStateOn) {

		locationswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		locationswitchImage.tintColor = [UIColor whiteColor];
		selectedlocationView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {

		locationswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchoff.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		locationswitchImage.tintColor = [UIColor lightGrayColor];
		selectedlocationView.backgroundColor = [UIColor lightGrayColor];
	}

	FSSwitchState state4 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"];
	if (state4 == FSSwitchStateOn) {

		dndswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor whiteColor]];
		dndswitchImage.tintColor = [UIColor whiteColor];
		selecteddndView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {

		dndswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		dndswitchImage.tintColor = [UIColor lightGrayColor];
		selecteddndView.backgroundColor = [UIColor lightGrayColor];
	}

	FSSwitchState state5 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness"];
	if (state5 == FSSwitchStateOn) {

		autobrightnessswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor whiteColor]];
		autobrightnessswitchImage.tintColor = [UIColor whiteColor];
		selectedautobrightnessView.backgroundColor = [UIColor colorWithRed:0.518 green:0.8 blue:0.761 alpha:1];

	} else {

		autobrightnessswitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor lightGrayColor]];
		autobrightnessswitchImage.tintColor = [UIColor lightGrayColor];
		selectedautobrightnessView.backgroundColor = [UIColor lightGrayColor];
	}

	if (!swpinToHomescreen) {

		if (switcheswindow.hidden) {

			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

				switcheswindow.hidden = NO;
				switcheswindow.alpha = 1.0;
    		}
    		completion:^(BOOL finished) {

			}];
		}

		else {

			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

				switcheswindow.alpha = 0.0;
    		}
    		completion:^(BOOL finished) {

        		switcheswindow.hidden = YES;
			}];
		}
	}

	[event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {}

+ (void)load {
	if ([LASharedActivator isRunningInsideSpringBoard]) {
			[LASharedActivator registerListener:[self new] forName:@"com.orca.andriosswitcheswidget"];
	}
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
	return @"Andrios";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return @"Switches Widget";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Choose action to show Switches Widget";
}
- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
	return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
}
- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {

	return [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/SwitchesWidget.png"] scale:scale];
}
- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {

	return [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/SwitchesWidget.png"] scale:scale];
}
@end

%ctor {

	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.orca.andrios/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);

}