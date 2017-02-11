#import "PowerMenuHeader.h"

static BOOL newAndroid;
static BOOL minimalPowerMenu;
static BOOL replacePowerDownScreen;

static void loadPrefs() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.orca.andrios.plist"];

	newAndroid = [prefs objectForKey:@"newAndroid"] ? [[prefs objectForKey:@"newAndroid"] boolValue] : YES;
	minimalPowerMenu = [prefs objectForKey:@"minimalPowerMenu"] ? [[prefs objectForKey:@"minimalPowerMenu"] boolValue] : NO;
	replacePowerDownScreen = [prefs objectForKey:@"replacePowerDownScreen"] ? [[prefs objectForKey:@"replacePowerDownScreen"] boolValue] : YES;
}

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1 
{
	%orig(arg1);

	if (newAndroid) {

		cellBGColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
		cellTextColor = [UIColor blackColor];
		airplaneSwitchBGColor = [UIColor colorWithRed: 130/255.0 green:130/255.0 blue:130/255.0 alpha:1.0];
		switchImageColor = [UIColor colorWithRed: 130/255.0 green:130/255.0 blue:130/255.0 alpha:1.0];
		lineViewColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
	
	} else {

		cellBGColor = [UIColor colorWithRed: 38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
		cellTextColor = [UIColor whiteColor];
		airplaneSwitchBGColor = [UIColor lightGrayColor];
		switchImageColor = [UIColor whiteColor];
		lineViewColor = [UIColor grayColor];
	}

	//UIWINDOW CONTAINS MAIN VIEW//
	pmwindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	pmwindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	pmwindow.alpha = 0.0;
	pmwindow.hidden = YES;
	pmwindow.backgroundColor = [UIColor clearColor];
	
	//View that detects tap on outside
	dimView = [[UIView alloc] init];
	dimView.frame = [[UIScreen mainScreen] bounds];
	dimView.center = pmwindow.center;
	dimView.backgroundColor = [UIColor blackColor];
	dimView.alpha = 0.3;
	[pmwindow addSubview:dimView];

	//HIDE POWER MENU//
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
	[dimView addGestureRecognizer:tap];

	//SHOW OTHER VIEW//
	UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changeView)];
	[swipe setDirection:(UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight)];
	[dimView addGestureRecognizer:swipe];

	//MAIN VIEW//
	mainView = [[UIView alloc] init];
	mainView.frame = CGRectMake(0, 0, 270, 210);
	mainView.center = pmwindow.center;
	mainView.backgroundColor = [UIColor clearColor];
	[pmwindow addSubview:mainView];
	//MAIN VIEW//
	
	if (minimalPowerMenu) {

		powerOffButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		powerOffButton.frame = CGRectMake(0, 0, 270, 70);
		powerOffButton.center = pmwindow.center;
		[powerOffButton setBackgroundColor:cellBGColor];
		[powerOffButton setTitle:@"Power off" forState:UIControlStateNormal];
		[powerOffButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[powerOffButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 65, 0, 0)];
		[powerOffButton setTitleColor:cellTextColor forState:UIControlStateNormal];
		[powerOffButton addTarget:self action:@selector(confirmPowerOff:) forControlEvents:UIControlEventTouchUpInside];
		[powerOffButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
		powerOffButton.tag = 1;	
		[[powerOffButton layer] setCornerRadius:3.0];
		[pmwindow addSubview:powerOffButton];
		powerOffImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/powerOff.png"] _flatImageWithColor:switchImageColor]];
		powerOffImage.frame = CGRectMake(16, 18, 32, 32);
		powerOffImage.tintColor = switchImageColor;
		[powerOffButton addSubview:powerOffImage];

		alertView = [[UIView alloc] init];
		alertView.frame = mainView.frame;
		alertView.backgroundColor = cellBGColor;
		alertView.alpha = 0.0;
		alertView.hidden = YES;
		[pmwindow addSubview:alertView];

		alertMainLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 270, 70)];
		alertMainLabel.textColor = [UIColor colorWithRed:0.176 green:0.651 blue:0.871 alpha:1];
		alertMainLabel.textAlignment = NSTextAlignmentLeft;
		alertMainLabel.font = [UIFont systemFontOfSize:28.0];
		alertMainLabel.backgroundColor = [UIColor clearColor];
		alertMainLabel.text = @"";
		[alertView addSubview:alertMainLabel];

		UIView *horizontalLineView5 = [[UIView alloc] initWithFrame:CGRectMake(0, 69.5f, 270, 1)];
		[horizontalLineView5 setBackgroundColor:[UIColor colorWithRed:0.176 green:0.651 blue:0.871 alpha:1]];
		[alertView addSubview:horizontalLineView5];

		alertSecondLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 200, 90)];
		alertSecondLabel.textColor = cellTextColor;
		alertSecondLabel.textAlignment = NSTextAlignmentLeft;
		alertSecondLabel.font = [UIFont systemFontOfSize:22.0];
		alertSecondLabel.backgroundColor = [UIColor clearColor];
		alertSecondLabel.text = @"";
		alertSecondLabel.lineBreakMode = NSLineBreakByWordWrapping;
		alertSecondLabel.numberOfLines = 0;
		[alertView addSubview:alertSecondLabel];

		UIView *horizontalLineView6 = [[UIView alloc] initWithFrame:CGRectMake(0, 159.75f, 270, 0.5f)];
		[horizontalLineView6 setBackgroundColor:lineViewColor];
		[alertView addSubview:horizontalLineView6];

		UIButton *alertCancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		alertCancelButton.frame = CGRectMake(0, 160, 135, 50);
		[alertCancelButton setBackgroundColor:[UIColor clearColor]];
		[alertCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
		[alertCancelButton setTitleColor:cellTextColor forState:UIControlStateNormal];
		[alertCancelButton addTarget:self action:@selector(alertCancel:) forControlEvents:UIControlEventTouchUpInside];
		[alertCancelButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
		[alertView addSubview:alertCancelButton];

		UIButton *alertOKButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		alertOKButton.frame = CGRectMake(135, 160, 135, 50);
		[alertOKButton setBackgroundColor:[UIColor clearColor]];
		[alertOKButton setTitle:@"OK" forState:UIControlStateNormal];
		[alertOKButton setTitleColor:cellTextColor forState:UIControlStateNormal];
		[alertOKButton addTarget:self action:@selector(alertOK:) forControlEvents:UIControlEventTouchUpInside];
		[alertOKButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
		[alertView addSubview:alertOKButton];

		UIView *verticalLineView1 = [[UIView alloc] initWithFrame:CGRectMake(134.75f, 160, 0.5f, 50)];
		[verticalLineView1 setBackgroundColor:lineViewColor];
		[alertView addSubview:verticalLineView1];

		return;
	}

	powerOffButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	powerOffButton.frame = CGRectMake(0, 0, 270, 70);
	[powerOffButton setBackgroundColor:cellBGColor];
	[powerOffButton setTitle:@"Power off" forState:UIControlStateNormal];
	[powerOffButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[powerOffButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 65, 0, 0)];
	[powerOffButton setTitleColor:cellTextColor forState:UIControlStateNormal];
	[powerOffButton addTarget:self action:@selector(confirmPowerOff:) forControlEvents:UIControlEventTouchUpInside];
	[powerOffButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
	powerOffButton.tag = 1;	
	[mainView addSubview:powerOffButton];
	powerOffImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/powerOff.png"] _flatImageWithColor:switchImageColor]];
	powerOffImage.frame = CGRectMake(16, powerOffButton.frame.size.height/2 - 16, 32, 32);
	powerOffImage.tintColor = switchImageColor;
	[powerOffButton addSubview:powerOffImage];
	UIView *horizontalLineView = [[UIView alloc] initWithFrame:CGRectMake(0, kButtonHeight - 1, 270, 1)];
	[horizontalLineView setBackgroundColor:lineViewColor];
	[powerOffButton addSubview:horizontalLineView];

	UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:powerOffButton.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5.0, 5.0)];
	CAShapeLayer *maskLayer1 = [CAShapeLayer layer];
	maskLayer1.frame = powerOffButton.bounds;
	maskLayer1.path = maskPath1.CGPath;
	powerOffButton.layer.mask = maskLayer1;

	rebootButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	rebootButton.hidden = YES;
	rebootButton.frame = CGRectMake(0, 70, 270, 70);
	[rebootButton setBackgroundColor:cellBGColor];
	[rebootButton setTitle:@"Reboot" forState:UIControlStateNormal];
	[rebootButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[rebootButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 70, 0, 0)];
	[rebootButton setTitleColor:cellTextColor forState:UIControlStateNormal];
	[rebootButton addTarget:self action:@selector(confirmReboot:) forControlEvents:UIControlEventTouchUpInside];
	[rebootButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
	[mainView addSubview:rebootButton];
	UIView *horizontalLineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, kButtonHeight - 1, 270, 1)];
	[horizontalLineView2 setBackgroundColor:lineViewColor];
	[rebootButton addSubview:horizontalLineView2];
	rebootImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/reboot.png"] _flatImageWithColor:switchImageColor]];
	rebootImage.frame = CGRectMake(16, rebootButton.frame.size.height/2 - 16, 32, 32);
	rebootImage.tintColor = switchImageColor;
	[rebootButton addSubview:rebootImage];

	respringButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	respringButton.hidden = YES;
	respringButton.frame = CGRectMake(0, 0, 270, 70);
	[respringButton setBackgroundColor:cellBGColor];
	[respringButton setTitle:@"Respring" forState:UIControlStateNormal];
	[respringButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[respringButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 70, 0, 0)];
	[respringButton setTitleColor:cellTextColor forState:UIControlStateNormal];
	[respringButton addTarget:self action:@selector(confirmRespring:) forControlEvents:UIControlEventTouchUpInside];
	[respringButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
	[mainView addSubview:respringButton];
	UIView *horizontalLineView3 = [[UIView alloc] initWithFrame:CGRectMake(0, kButtonHeight - 1, 270, 1)];
	[horizontalLineView3 setBackgroundColor:lineViewColor];
	[respringButton addSubview:horizontalLineView3];
	rebootImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/respring.png"] _flatImageWithColor:switchImageColor]];
	rebootImage.frame = CGRectMake(16, respringButton.frame.size.height/2 - 16, 32, 32);
	rebootImage.tintColor = switchImageColor;
	[respringButton addSubview:rebootImage];

	UIBezierPath *maskPath4 = [UIBezierPath bezierPathWithRoundedRect:respringButton.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5.0, 5.0)];
	CAShapeLayer *maskLayer4 = [CAShapeLayer layer];
	maskLayer4.frame = respringButton.bounds;
	maskLayer4.path = maskPath4.CGPath;
	respringButton.layer.mask = maskLayer4;

	airplaneModeSwitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	airplaneModeSwitch.frame = CGRectMake(0, 70, 270, 70);
	[airplaneModeSwitch setBackgroundColor:cellBGColor];
	[airplaneModeSwitch setTitle:@"Airplane mode" forState:UIControlStateNormal];
	[airplaneModeSwitch setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[airplaneModeSwitch setTitleEdgeInsets:UIEdgeInsetsMake(-25, 65, 0, 0)];
	[airplaneModeSwitch setTitleColor:cellTextColor forState:UIControlStateNormal];
	[airplaneModeSwitch addTarget:self action:@selector(airplane:) forControlEvents:UIControlEventTouchUpInside];
	[airplaneModeSwitch.titleLabel setFont:[UIFont systemFontOfSize:20]];
	[mainView addSubview:airplaneModeSwitch];
	UIView *horizontalLineView4 = [[UIView alloc] initWithFrame:CGRectMake(0, kButtonHeight - 1, 270, 1)];
	[horizontalLineView4 setBackgroundColor:lineViewColor];
	[airplaneModeSwitch addSubview:horizontalLineView4];
	airplaneModeSwitchImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneoff.png"] _flatImageWithColor:switchImageColor]];
	airplaneModeSwitchImage.frame = CGRectMake(16, airplaneModeSwitch.frame.size.height/2 - 16, 32, 32);
	[airplaneModeSwitch addSubview:airplaneModeSwitchImage];
	airplaneSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(-6, 40, 270, 15)];
	airplaneSwitchLabel.textColor = [UIColor lightGrayColor];
	airplaneSwitchLabel.textAlignment = NSTextAlignmentCenter;
	airplaneSwitchLabel.font = [UIFont systemFontOfSize:13];
	airplaneSwitchLabel.backgroundColor = [UIColor clearColor];
	airplaneSwitchLabel.text = @"Airplane mode is OFF";
	[airplaneModeSwitch addSubview:airplaneSwitchLabel];

	silenceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	silenceButton.frame = CGRectMake(0, 140, 90, 70);
	[silenceButton setBackgroundColor:cellBGColor];
	[silenceButton addTarget:self action:@selector(silence:) forControlEvents:UIControlEventTouchUpInside];
	[mainView addSubview:silenceButton];
	silenceButtonImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/ringerswitchoff.png"] _flatImageWithColor:switchImageColor]];
	silenceButtonImage.frame = CGRectMake(silenceButton.frame.size.width/2 - 16, 17.5, 32, 32);
	silenceButtonImage.tintColor = switchImageColor;
	[silenceButton addSubview:silenceButtonImage];
	
	UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:silenceButton.bounds byRoundingCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(5.0, 5.0)];
	CAShapeLayer *maskLayer2 = [CAShapeLayer layer];
	maskLayer2.frame = silenceButton.bounds;
	maskLayer2.path = maskPath2.CGPath;
	silenceButton.layer.mask = maskLayer2;
	
	vibrateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	vibrateButton.frame = CGRectMake(90, 140, 90, 70);
	[vibrateButton setBackgroundColor:cellBGColor];
	[vibrateButton addTarget:self action:@selector(vibrate:) forControlEvents:UIControlEventTouchUpInside];
	[mainView addSubview:vibrateButton];
	vibrateButtonImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/vibratebutton.png"] _flatImageWithColor:switchImageColor]];
	vibrateButtonImage.frame = CGRectMake(vibrateButton.frame.size.width/2 - 16, 17.5, 32, 32);
	vibrateButtonImage.tintColor = switchImageColor;
	[vibrateButton addSubview:vibrateButtonImage];
	
	soundButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	soundButton.frame = CGRectMake(180, 140, 90, 70);
	[soundButton setBackgroundColor:cellBGColor];
	[soundButton addTarget:self action:@selector(sound:) forControlEvents:UIControlEventTouchUpInside];
	[mainView addSubview:soundButton];
	soundButtonImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/ringerswitchon.png"] _flatImageWithColor:switchImageColor]];
	soundButtonImage.frame = CGRectMake(soundButton.frame.size.width/2 - 16, 17.5, 32, 32);
	soundButtonImage.tintColor = switchImageColor;
	[soundButton addSubview:soundButtonImage];
	
	UIBezierPath *maskPath3 = [UIBezierPath bezierPathWithRoundedRect:soundButton.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(5.0, 5.0)];
	CAShapeLayer *maskLayer3 = [CAShapeLayer layer];
	maskLayer3.frame = soundButton.bounds;
	maskLayer3.path = maskPath3.CGPath;
	soundButton.layer.mask = maskLayer3;

	//selection images//
	selectedSilenceImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/selected.png"]];
	selectedSilenceImage.frame = CGRectMake(22.5f, 55, 45, 5);
	selectedSilenceImage.alpha = 0.0;
	[silenceButton addSubview:selectedSilenceImage];
	
	selectedVibrateImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/selectedvibrate.png"]];
	selectedVibrateImage.frame = CGRectMake(22.5f, 55, 45, 5);
	selectedVibrateImage.alpha = 0.0;
	[vibrateButton addSubview:selectedVibrateImage];
	
	selectedSoundImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/selectedsound.png"]];
	selectedSoundImage.frame = CGRectMake(22.5f, 55, 45, 5);
	selectedSoundImage.alpha = 0.0;
	[soundButton addSubview:selectedSoundImage];
	//selection images//

	alertView = [[UIView alloc] init];
	alertView.frame = mainView.frame;
	alertView.backgroundColor = cellBGColor;
	alertView.alpha = 0.0;
	alertView.hidden = YES;
	[pmwindow addSubview:alertView];

	alertMainLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 270, 70)];
	alertMainLabel.textColor = [UIColor colorWithRed:0.176 green:0.651 blue:0.871 alpha:1];
	alertMainLabel.textAlignment = NSTextAlignmentLeft;
	alertMainLabel.font = [UIFont systemFontOfSize:28.0];
	alertMainLabel.backgroundColor = [UIColor clearColor];
	alertMainLabel.text = @"";
	[alertView addSubview:alertMainLabel];

	UIView *horizontalLineView5 = [[UIView alloc] initWithFrame:CGRectMake(0, 69.5f, 270, 1)];
	[horizontalLineView5 setBackgroundColor:[UIColor colorWithRed:0.176 green:0.651 blue:0.871 alpha:1]];
	[alertView addSubview:horizontalLineView5];

	alertSecondLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 200, 90)];
	alertSecondLabel.textColor = cellTextColor;
	alertSecondLabel.textAlignment = NSTextAlignmentLeft;
	alertSecondLabel.font = [UIFont systemFontOfSize:22.0];
	alertSecondLabel.backgroundColor = [UIColor clearColor];
	alertSecondLabel.text = @"";
	alertSecondLabel.lineBreakMode = NSLineBreakByWordWrapping;
	alertSecondLabel.numberOfLines = 0;
	[alertView addSubview:alertSecondLabel];

	UIView *horizontalLineView6 = [[UIView alloc] initWithFrame:CGRectMake(0, 159.75f, 270, 0.5f)];
	[horizontalLineView6 setBackgroundColor:lineViewColor];
	[alertView addSubview:horizontalLineView6];

	UIButton *alertCancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	alertCancelButton.frame = CGRectMake(0, 160, 135, 50);
	[alertCancelButton setBackgroundColor:[UIColor clearColor]];
	[alertCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[alertCancelButton setTitleColor:cellTextColor forState:UIControlStateNormal];
	[alertCancelButton addTarget:self action:@selector(alertCancel:) forControlEvents:UIControlEventTouchUpInside];
	[alertCancelButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
	[alertView addSubview:alertCancelButton];

	UIButton *alertOKButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	alertOKButton.frame = CGRectMake(135, 160, 135, 50);
	[alertOKButton setBackgroundColor:[UIColor clearColor]];
	[alertOKButton setTitle:@"OK" forState:UIControlStateNormal];
	[alertOKButton setTitleColor:cellTextColor forState:UIControlStateNormal];
	[alertOKButton addTarget:self action:@selector(alertOK:) forControlEvents:UIControlEventTouchUpInside];
	[alertOKButton.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
	[alertView addSubview:alertOKButton];

	UIView *verticalLineView1 = [[UIView alloc] initWithFrame:CGRectMake(134.75f, 160, 0.5f, 50)];
	[verticalLineView1 setBackgroundColor:lineViewColor];
	[alertView addSubview:verticalLineView1];
}

%new
-(void)dismiss {

	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		pmwindow.alpha = 0.0;
    	}
    	completion:^(BOOL finished) {

		alertView.alpha = 0.0;
		alertView.hidden = YES;
		pmPresented = NO;
		pmwindow.hidden = YES;
	}];
}

%new
-(void)changeView {
   
	if (showingButtons) {

		powerOffButton.hidden = YES;
		airplaneModeSwitch.hidden = YES;
		rebootButton.hidden = NO;
		respringButton.hidden = NO;

		showingButtons = NO;
		
	} else {
		
		rebootButton.hidden = YES;
		respringButton.hidden = YES;
		powerOffButton.hidden = NO;
		airplaneModeSwitch.hidden = NO;
		
		showingButtons = YES;	
	}
}

%new
-(void)confirmPowerOff:(id)sender 
{
	alertMainLabel.text = @"Power off";
	alertSecondLabel.text = @"Your phone will shut down.";
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		alertView.hidden = NO;
        	alertView.alpha = 1.0;
    	}
        completion:^(BOOL finished) {
		
	}];
}

%new
-(void)confirmRespring:(id)sender 
{
	alertMainLabel.text = @"Respring";
	alertSecondLabel.text = @"Your phone will respring.";
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		alertView.hidden = NO;
        	alertView.alpha = 1.0;
    	}
        completion:^(BOOL finished) {
		
	}];
}


%new
-(void)confirmReboot:(id)sender 
{
	alertMainLabel.text = @"Reboot";
	alertSecondLabel.text = @"Your phone will reboot.";

	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		alertView.hidden = NO;
        	alertView.alpha = 1.0;
    	}
        completion:^(BOOL finished) {
		
	}];
}

%new
-(void)alertOK:(id)sender {

	pmPresented = NO;
	pmwindow.hidden = YES;
    	
	if ([alertMainLabel.text isEqual:@"Power off"]) {

    		[[UIApplication sharedApplication] _powerDownNow];
	}
	else if ([alertMainLabel.text isEqual:@"Respring"]) {

		[[UIApplication sharedApplication] _relaunchSpringBoardNow];
	}
	else if ([alertMainLabel.text isEqual:@"Reboot"]) {

		[[UIApplication sharedApplication] _rebootNow];
	}
}

%new
-(void)alertCancel:(id)sender {

	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

        	alertView.alpha = 0.0;
    	}
        completion:^(BOOL finished) {
		
		alertView.hidden = YES;
	}];
}

%new
-(void)airplane:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode"];
		airplaneSwitchLabel.text = @"Airplane mode is ON";
		[airplaneModeSwitch setBackgroundColor:[UIColor colorWithRed: 130/255.0 green:130/255.0 blue:130/255.0 alpha:1.0]];
		airplaneSwitchLabel.textColor = cellTextColor;
		airplaneModeSwitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchon.png"] _flatImageWithColor:cellTextColor];
		
	
	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode"];
		airplaneSwitchLabel.text = @"Airplane mode is OFF";
		airplaneSwitchLabel.textColor = [UIColor lightGrayColor];
		airplaneModeSwitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchoff.png"] _flatImageWithColor:switchImageColor];
		
		if (newAndroid) {

			[airplaneModeSwitch setBackgroundColor:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]];
			
		} else {

			[airplaneModeSwitch setBackgroundColor:[UIColor colorWithRed: 38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0]];
		}
	}
}

%new
-(void)silence:(id)sender {
 
	[UIView animateWithDuration:0.10 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		selectedSoundImage.alpha = 0.0;
		selectedVibrateImage.alpha = 0.0;
        }
        completion:^(BOOL finished) {
		
		[UIView animateWithDuration:0.10 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			selectedSilenceImage.alpha = 1.0;
        }
        		completion:^(BOOL finished) {
		
			}];
	}];
 
    [[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.ringer"];
	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.vibration"];
	[[%c(SBMediaController) sharedInstance] setVolume:0.0];
}

%new
-(void)vibrate:(id)sender {
 
	[UIView animateWithDuration:0.10 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		selectedSoundImage.alpha = 0.0;
		selectedSilenceImage.alpha = 0.0;
        }
        completion:^(BOOL finished) {
		
		[UIView animateWithDuration:0.10 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			selectedVibrateImage.alpha = 1.0;
        }
        		completion:^(BOOL finished) {
		
			}];
	}];
	
	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.vibration"];
	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.ringer"];
}

%new
-(void)sound:(id)sender {

	[UIView animateWithDuration:0.10 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		selectedSilenceImage.alpha = 0.0;
		selectedVibrateImage.alpha = 0.0;
        }
        completion:^(BOOL finished) {
		
		[UIView animateWithDuration:0.10 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			selectedSoundImage.alpha = 1.0;
        }
        		completion:^(BOOL finished) {
		
			}];
	}];
	
	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.ringer"];
	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.vibration"];
	[[%c(SBMediaController) sharedInstance] volume];
}
%end

%hook SBPowerDownController
-(void)activate {

	if (replacePowerDownScreen) {
		
		FSSwitchState state1 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode"];
		if (state1 == FSSwitchStateOn) {
 
			airplaneSwitchLabel.text = @"Airplane mode is ON";
			[airplaneModeSwitch setBackgroundColor:[UIColor colorWithRed: 130/255.0 green:130/255.0 blue:130/255.0 alpha:1.0]];
			airplaneSwitchLabel.textColor = cellTextColor;
			airplaneModeSwitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchon.png"] _flatImageWithColor:cellTextColor];

		} else {
 
			airplaneSwitchLabel.text = @"Airplane mode is OFF";
			airplaneSwitchLabel.textColor = [UIColor lightGrayColor];
			airplaneModeSwitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchoff.png"] _flatImageWithColor:switchImageColor];

			if (newAndroid) {

				[airplaneModeSwitch setBackgroundColor:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]];
			
			} else {
				
				[airplaneModeSwitch setBackgroundColor:[UIColor colorWithRed: 38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0]];
			}
		}

		FSSwitchState state2 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.ringer"];
		if (state2 == FSSwitchStateOn) {
 
			selectedSilenceImage.alpha = 0.0;
			selectedVibrateImage.alpha = 0.0;
        		selectedSoundImage.alpha = 1.0;

		} else {

			FSSwitchState state3 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.vibration"];
			if (state3 == FSSwitchStateOn) {
 
				selectedSoundImage.alpha = 0.0;
				selectedSilenceImage.alpha = 0.0;
        		selectedVibrateImage.alpha = 1.0;

			} else {

				selectedSoundImage.alpha = 0.0;
				selectedVibrateImage.alpha = 0.0;
       			selectedSilenceImage.alpha = 1.0;
			}
		}

		//show PowerMenu
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			pmwindow.hidden = NO;
        		pmwindow.alpha = 1.0;
    		}
        	completion:^(BOOL finished) {
		
			pmPresented = YES;
		}];

		[self cancel];
		[self deactivate];
	
	} else {

		%orig;
	}
}
%end

#import <libactivator/libactivator.h>

@interface PowerMenuActivator : NSObject <LAListener>
@end

@implementation PowerMenuActivator
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {

	if (!pmPresented) {

		FSSwitchState state1 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode"];
		if (state1 == FSSwitchStateOn) {

			airplaneSwitchLabel.text = @"Airplane mode is ON";
			[airplaneModeSwitch setBackgroundColor:[UIColor colorWithRed: 130/255.0 green:130/255.0 blue:130/255.0 alpha:1.0]];
			airplaneSwitchLabel.textColor = cellTextColor;
			airplaneModeSwitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchon.png"] _flatImageWithColor:cellTextColor];

		} else {

			airplaneSwitchLabel.text = @"Airplane mode is OFF";
			airplaneSwitchLabel.textColor = [UIColor lightGrayColor];
			airplaneModeSwitchImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchoff.png"] _flatImageWithColor:switchImageColor];

			if (newAndroid) {

				[airplaneModeSwitch setBackgroundColor:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]];

			} else {

				[airplaneModeSwitch setBackgroundColor:[UIColor colorWithRed: 38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0]];
			}
		}

		FSSwitchState state2 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.ringer"];
		if (state2 == FSSwitchStateOn) {

			selectedSilenceImage.alpha = 0.0;
			selectedVibrateImage.alpha = 0.0;
        	selectedSoundImage.alpha = 1.0;

		} else {

			FSSwitchState state3 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.vibration"];
			if (state3 == FSSwitchStateOn) {

				selectedSoundImage.alpha = 0.0;
				selectedSilenceImage.alpha = 0.0;
        		selectedVibrateImage.alpha = 1.0;

			} else {

				selectedSoundImage.alpha = 0.0;
				selectedVibrateImage.alpha = 0.0;
       			selectedSilenceImage.alpha = 1.0;
			}
		}

		//show PowerMenu
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			pmwindow.hidden = NO;
        		pmwindow.alpha = 1.0;
    		}
        	completion:^(BOOL finished) {

			pmPresented = YES;
		}];

	} else {

		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			pmwindow.alpha = 0.0;
    		}
    		completion:^(BOOL finished) {

			pmPresented = NO;
			pmwindow.hidden = YES;
		}];

	}

	[event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {}

+ (void)load {
	if ([LASharedActivator isRunningInsideSpringBoard]) {
			[LASharedActivator registerListener:[self new] forName:@"com.orca.andriosmenu"];
	}
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
	return @"Andrios";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return @"Power Menu";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Choose action to show Power Menu";
}
- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
	return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
}
- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {

	return [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/PowerMenu.png"] scale:scale];
}
- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {

	return [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/PowerMenu.png"] scale:scale];
}
@end

%ctor {

	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.orca.andrios/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);

}