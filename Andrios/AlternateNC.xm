#import "AlternateNC.h"	
#import <libactivator/libactivator.h>

static SBIconModel *iconModel = nil;
static NSArray *whiteList = nil;
static BOOL removeBadge = YES;

//preferences
static BOOL alternateEnabled;
static BOOL LSNEnabled;	
static BOOL backdropEnabled;
static BOOL roundIcons;
static BOOL notifAlphaEnabled;
static BOOL replaceNCHeaders;
static BOOL clearButton;
	
static void loadPrefs() {
	
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.orca.andrios.plist"];
	
	alternateEnabled = [prefs objectForKey:@"ancEnabled"] ? [[prefs objectForKey:@"ancEnabled"] boolValue] : NO;
	LSNEnabled = [prefs objectForKey:@"lsnEnabled"] ? [[prefs objectForKey:@"lsnEnabled"] boolValue] : NO;
	backdropEnabled = [prefs objectForKey:@"bdEnabled"] ? [[prefs objectForKey:@"bdEnabled"] boolValue] : NO;
	roundIcons = [prefs objectForKey:@"roundIcons"] ? [[prefs objectForKey:@"roundIcons"] boolValue] : YES;
	notifAlphaEnabled = [prefs objectForKey:@"notifAlphaEnabled"] ? [[prefs objectForKey:@"notifAlphaEnabled"] boolValue] : NO;
	replaceNCHeaders = [prefs objectForKey:@"replaceNCHeaders"] ? [[prefs objectForKey:@"replaceNCHeaders"] boolValue] : NO;
	clearButton = [prefs objectForKey:@"clearButton"] ? [[prefs objectForKey:@"clearButton"] boolValue] : YES;
}
//preferences

%hook SBModeViewController
-(void)viewDidLoad {
   
	if (alternateEnabled) {
	    %orig;

		switchesView = [[UIView alloc] init];
		switchesView.frame = CGRectMake(7.5, -[[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 15, [[UIScreen mainScreen] bounds].size.height);
		[switchesView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
		[switchesView setBackgroundColor:[UIColor colorWithRed: 38/255.0 green:50/255.0 blue:56/255.0 alpha:1.0]];
		[self.view addSubview:switchesView];
	
		swipeup = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMainView:)];
		swipeup.numberOfTouchesRequired = 1;
		swipeup.direction = (UISwipeGestureRecognizerDirectionUp);
		swipeup.cancelsTouchesInView = NO;
		[switchesView addGestureRecognizer:swipeup];
	
		//top view
		topView = [[UIView alloc] init];
		topView.frame = CGRectMake(7.5, 30, [[UIScreen mainScreen] bounds].size.width - 15, 105);
		[topView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
		[topView setBackgroundColor:[UIColor colorWithRed: 56/255.0 green:66/255.0 blue:72/255.0 alpha:1.0]];
		topView.layer.shadowColor = [[UIColor blackColor] CGColor];
		topView.layer.shadowRadius = 5.0;
		topView.layer.shadowOpacity = 0.8;
		[self.view addSubview:topView];
    
		swipedown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(openMainView:)]; 
		swipedown.numberOfTouchesRequired = 1; 
		swipedown.direction = (UISwipeGestureRecognizerDirectionDown); 
		swipedown.cancelsTouchesInView = YES; 
		[topView addGestureRecognizer:swipedown];
	
		NSDate *now = [[NSDate alloc] init];
    
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"EEEE, MMMM d"];

		NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
		[timeFormat setDateFormat:@"h:mm a"];
		[timeFormat setAMSymbol:@"am"];
		[timeFormat setPMSymbol:@"pm"];
	
		timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 100, 100)];
		timeLabel.text = [timeFormat stringFromDate:now];
		timeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textColor = [UIColor whiteColor];
		timeLabel.textAlignment = NSTextAlignmentLeft;
		[topView addSubview:timeLabel];
	
		dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 30, 200, 100)];
		dateLabel.text = [dateFormat stringFromDate:now];
		dateLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.textColor = [UIColor colorWithRed: 195/255.0 green:198/255.0 blue:200/255.0 alpha:1.0];
		dateLabel.textAlignment = NSTextAlignmentLeft;
		[topView addSubview:dateLabel];
	
		int percent = [[%c(SBUIController) sharedInstance] displayBatteryCapacityAsPercentage];
	
		batteryLabel = [[UILabel alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 130, 15, 22, 20)];
		batteryLabel.text = [NSString stringWithFormat:@"%d",percent];
		batteryLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
		batteryLabel.backgroundColor = [UIColor clearColor];
		batteryLabel.textColor = [UIColor whiteColor];
		batteryLabel.textAlignment = NSTextAlignmentRight;
		[topView addSubview:batteryLabel];
	
		UILabel *percentLabel = [[UILabel alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 118, 15, 20, 20)];
		percentLabel.text = @"%";
		percentLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
		percentLabel.backgroundColor = [UIColor clearColor];
		percentLabel.textColor = [UIColor whiteColor];
		percentLabel.textAlignment = NSTextAlignmentRight;
		[topView addSubview:percentLabel];	
		
		batteryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		batteryButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 145, 16.5, 24, 24);
		[batteryButton setBackgroundColor:[UIColor clearColor]];
		[batteryButton addTarget:self action:@selector(openBatterySettings:) forControlEvents:UIControlEventTouchUpInside];
		[topView addSubview:batteryButton];
		batteryImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/batteryimage.png"] _flatImageWithColor:[UIColor whiteColor]]];;
		batteryImage.frame = CGRectMake(0, 0, 20, 16);
		[batteryButton addSubview:batteryImage];
	
	    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
	
		settingsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		settingsButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 85, 14, 24, 24);
		[settingsButton setBackgroundColor:[UIColor clearColor]];
		[settingsButton addTarget:self action:@selector(openSettings:) forControlEvents:UIControlEventTouchUpInside];
		[topView addSubview:settingsButton];
		settingsButtonImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/settingsbutton.png"] _flatImageWithColor:[UIColor whiteColor]]];
		settingsButtonImage.frame = CGRectMake(0, 0, 22, 22);
		[settingsButton addSubview:settingsButtonImage];
	
		contactsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		contactsButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 48, 13.5, 24, 24);
		[contactsButton setBackgroundColor:[UIColor clearColor]];
		[contactsButton addTarget:self action:@selector(openContacts:) forControlEvents:UIControlEventTouchUpInside];
		[topView addSubview:contactsButton];
		contactsButtonImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/contactsimage.png"] _flatImageWithColor:[UIColor colorWithRed: 0/255.0 green:188/255.0 blue:212/255.0 alpha:1.0]]];
		contactsButtonImage.frame = CGRectMake(0, 0, 24, 24);
		[contactsButton addSubview:contactsButtonImage];
		//top view
	
		brightnessSlider = [[UISlider alloc] init];
		[brightnessSlider setBackgroundColor:[UIColor clearColor]];
		brightnessSlider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		brightnessSlider.continuous = YES;
		brightnessSlider.minimumValue = 0.0;
		brightnessSlider.maximumValue = 1.0;
		brightnessSlider.value = [UIScreen mainScreen].brightness;
		UIImage *thumbImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/sliderImage.png"];
		[brightnessSlider setThumbImage:thumbImage forState:UIControlStateNormal];
		[brightnessSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
		brightnessSlider.maximumTrackTintColor = [UIColor colorWithRed: 190/255.0 green:194/255.0 blue:196/255.0 alpha:1.0];
		brightnessSlider.minimumTrackTintColor = [UIColor colorWithRed: 128/255.0 green:203/255.0 blue:196/255.0 alpha:1.0];
		[brightnessSlider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
		[switchesView addSubview:brightnessSlider];
	
		if (IS_IPHONE_5) {
			brightnessSlider.frame = CGRectMake(switchesView.frame.size.width/2 - 140, 30, 280, 20);
		} else if (IS_IPHONE_6) {
			brightnessSlider.frame = CGRectMake(switchesView.frame.size.width/2 - 167.5, 30, 335, 20);
		} else if (IS_IPHONE_6_PLUS) {
			brightnessSlider.frame = CGRectMake(switchesView.frame.size.width/2 - 187, 30, 374, 20);
		} else {
			brightnessSlider.frame = CGRectMake(switchesView.frame.size.width/2 - 140, 30, 280, 20);
		}
	
		wifiSwitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		wifiSwitch.frame = CGRectMake(0, 60, switchesView.size.width/2, 77);
		[wifiSwitch setBackgroundColor:[UIColor clearColor]];
		[wifiSwitch addTarget:self action:@selector(wifiSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[switchesView addSubview:wifiSwitch];
		wifiImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchon.png"] _flatImageWithColor:[UIColor whiteColor]]];
		wifiImage.frame = CGRectMake(wifiSwitch.frame.size.width/2 - 14, 11, 28, 28);
		wifiImage.tintColor = [UIColor whiteColor];
		[wifiSwitch addSubview:wifiImage];
	
		UIView *wifiHorizontalLine = [[UIView alloc] initWithFrame:CGRectMake(22.5, 52, wifiSwitch.size.width - 45, 1.0)];
		[wifiHorizontalLine setBackgroundColor:[UIColor colorWithRed: 73/255.0 green:83/255.0 blue:88/255.0 alpha:1.0]];
		[wifiSwitch addSubview:wifiHorizontalLine];

		UILabel *wifiSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 62, switchesView.size.width/2, 15)];
		wifiSwitchLabel.textColor = [UIColor colorWithRed: 190/255.0 green:194/255.0 blue:196/255.0 alpha:1.0];
		wifiSwitchLabel.textAlignment = NSTextAlignmentCenter;
		wifiSwitchLabel.font = [UIFont systemFontOfSize:10];
		wifiSwitchLabel.backgroundColor = [UIColor clearColor];
		wifiSwitchLabel.text = @"Wi-Fi";
		[wifiSwitchLabel setUserInteractionEnabled:YES];
		[wifiSwitch addSubview:wifiSwitchLabel];
		UITapGestureRecognizer *wifiTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wifiTap:)];
		[wifiSwitchLabel addGestureRecognizer:wifiTap];
		

		bluetoothSwitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		bluetoothSwitch.frame = CGRectMake(switchesView.size.width/2, 60, switchesView.size.width/2, 77);
		[bluetoothSwitch setBackgroundColor:[UIColor clearColor]];
		[bluetoothSwitch addTarget:self action:@selector(bluetoothSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[switchesView addSubview:bluetoothSwitch];
		bluetoothImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchoff.png"] _flatImageWithColor:[UIColor whiteColor]]];
		bluetoothImage.frame = CGRectMake(bluetoothSwitch.frame.size.width/2 - 14, 11, 28, 28);
		bluetoothImage.tintColor = [UIColor whiteColor];
		[bluetoothSwitch addSubview:bluetoothImage];

		UIView *bluetoothHorizontalLine = [[UIView alloc] initWithFrame:CGRectMake(22.5, 52, bluetoothSwitch.size.width - 45, 1.0)];
		[bluetoothHorizontalLine setBackgroundColor:[UIColor colorWithRed: 73/255.0 green:83/255.0 blue:88/255.0 alpha:1.0]];
		[bluetoothSwitch addSubview:bluetoothHorizontalLine];
	
		UILabel *bluetoothSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 62, switchesView.size.width/2, 15)];
		bluetoothSwitchLabel.textColor = [UIColor colorWithRed: 190/255.0 green:194/255.0 blue:196/255.0 alpha:1.0];
		bluetoothSwitchLabel.textAlignment = NSTextAlignmentCenter;
		bluetoothSwitchLabel.font = [UIFont systemFontOfSize:10];
		bluetoothSwitchLabel.backgroundColor = [UIColor clearColor];
		bluetoothSwitchLabel.text = @"Bluetooth";
		bluetoothSwitchLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *bluetoothTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bluetoothTap:)];
		[bluetoothSwitchLabel addGestureRecognizer:bluetoothTap];
		[bluetoothSwitch addSubview:bluetoothSwitchLabel];
	
	
		dataSwitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		dataSwitch.frame = CGRectMake(0, 155, switchesView.size.width/3, 65);
		[dataSwitch setBackgroundColor:[UIColor clearColor]];
		[dataSwitch addTarget:self action:@selector(dataSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[switchesView addSubview:dataSwitch];
		dataImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/dataswitchon.png"] _flatImageWithColor:[UIColor whiteColor]]];
		dataImage.frame = CGRectMake(dataSwitch.frame.size.width/2 - 14, dataSwitch.frame.size.height/2 - 14, 28, 28);
		dataImage.tintColor = [UIColor whiteColor];
		[dataSwitch addSubview:dataImage];
	
		UILabel *dataSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, switchesView.size.width/3, 15)];
		dataSwitchLabel.textColor = [UIColor colorWithRed: 190/255.0 green:194/255.0 blue:196/255.0 alpha:1.0];
		dataSwitchLabel.textAlignment = NSTextAlignmentCenter;
		dataSwitchLabel.font = [UIFont systemFontOfSize:10];
		dataSwitchLabel.backgroundColor = [UIColor clearColor];
		dataSwitchLabel.text = @"Cellular data";
		dataSwitchLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *dataTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dataTap:)];
		[dataSwitchLabel addGestureRecognizer:dataTap];
		[dataSwitch addSubview:dataSwitchLabel];
	
	
		airplaneSwitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		airplaneSwitch.frame = CGRectMake(switchesView.size.width/3, 155, switchesView.size.width/3, 65);
		[airplaneSwitch setBackgroundColor:[UIColor clearColor]];
		[airplaneSwitch addTarget:self action:@selector(airplaneSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[switchesView addSubview:airplaneSwitch];
		airplaneImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchon.png"] _flatImageWithColor:[UIColor whiteColor]]];
		airplaneImage.frame = CGRectMake(airplaneSwitch.frame.size.width/2 - 14, airplaneSwitch.frame.size.height/2 - 14, 28, 28);
		airplaneImage.tintColor = [UIColor whiteColor];
		[airplaneSwitch addSubview:airplaneImage];
	
		UILabel *airplaneSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, switchesView.size.width/3, 15)];
		airplaneSwitchLabel.textColor = [UIColor colorWithRed: 190/255.0 green:194/255.0 blue:196/255.0 alpha:1.0];
		airplaneSwitchLabel.textAlignment = NSTextAlignmentCenter;
		airplaneSwitchLabel.font = [UIFont systemFontOfSize:10];
		airplaneSwitchLabel.backgroundColor = [UIColor clearColor];
		airplaneSwitchLabel.text = @"Airplane mode";
		airplaneSwitchLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *airplaneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(airplaneTap:)];
		[airplaneSwitchLabel addGestureRecognizer:airplaneTap];
		[airplaneSwitch addSubview:airplaneSwitchLabel];
	
	
		autoRotationSwitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		autoRotationSwitch.frame = CGRectMake(dataSwitch.size.width + airplaneSwitch.size.width + autoRotationSwitch.size.width, 155, switchesView.size.width/3, 65);
		[autoRotationSwitch setBackgroundColor:[UIColor clearColor]];
		[autoRotationSwitch addTarget:self action:@selector(autoRotationSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[switchesView addSubview:autoRotationSwitch];
		autoRotationImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/autorotationswitchon.png"] _flatImageWithColor:[UIColor whiteColor]]];
		autoRotationImage.frame = CGRectMake(autoRotationSwitch.frame.size.width/2 - 14, autoRotationSwitch.frame.size.height/2 - 14, 28, 28);
		autoRotationImage.tintColor = [UIColor whiteColor];
		[autoRotationSwitch addSubview:autoRotationImage];
	
		UILabel *autoRotationSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, switchesView.size.width/3, 15)];
		autoRotationSwitchLabel.textColor = [UIColor colorWithRed: 190/255.0 green:194/255.0 blue:196/255.0 alpha:1.0];
		autoRotationSwitchLabel.textAlignment = NSTextAlignmentCenter;
		autoRotationSwitchLabel.font = [UIFont systemFontOfSize:10];
		autoRotationSwitchLabel.backgroundColor = [UIColor clearColor];
		autoRotationSwitchLabel.text = @"Auto-rotate";
		[autoRotationSwitch addSubview:autoRotationSwitchLabel];
	
	
		flashlightSwitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		flashlightSwitch.frame = CGRectMake(0, 240, switchesView.size.width/3, 65);
		[flashlightSwitch setBackgroundColor:[UIColor clearColor]];
		[flashlightSwitch addTarget:self action:@selector(flashlightSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[switchesView addSubview:flashlightSwitch];
		flashlightImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/flashlightswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]]];
		flashlightImage.frame = CGRectMake(flashlightSwitch.frame.size.width/2 - 14, flashlightSwitch.frame.size.height/2 - 14, 28, 28);
		flashlightImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		[flashlightSwitch addSubview:flashlightImage];
	
		UILabel *flashlightSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, switchesView.size.width/3, 15)];
		flashlightSwitchLabel.textColor = [UIColor colorWithRed: 190/255.0 green:194/255.0 blue:196/255.0 alpha:1.0];
		flashlightSwitchLabel.textAlignment = NSTextAlignmentCenter;
		flashlightSwitchLabel.font = [UIFont systemFontOfSize:10];
		flashlightSwitchLabel.backgroundColor = [UIColor clearColor];
		flashlightSwitchLabel.text = @"Flashlight";
		[flashlightSwitch addSubview:flashlightSwitchLabel];
	
	
		locationSwitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		locationSwitch.frame = CGRectMake(switchesView.size.width/3, 240, switchesView.size.width/3, 65);
		[locationSwitch setBackgroundColor:[UIColor clearColor]];
		[locationSwitch addTarget:self action:@selector(locationSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[switchesView addSubview:locationSwitch];
		locationImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchon.png"] _flatImageWithColor:[UIColor whiteColor]]];
		locationImage.frame = CGRectMake(locationSwitch.frame.size.width/2 - 14, locationSwitch.frame.size.height/2 - 14, 28, 28);
		locationImage.tintColor = [UIColor whiteColor];
		[locationSwitch addSubview:locationImage];
	
		UILabel *locationSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, switchesView.size.width/3, 15)];
		locationSwitchLabel.textColor = [UIColor colorWithRed: 190/255.0 green:194/255.0 blue:196/255.0 alpha:1.0];
		locationSwitchLabel.textAlignment = NSTextAlignmentCenter;
		locationSwitchLabel.font = [UIFont systemFontOfSize:10];
		locationSwitchLabel.backgroundColor = [UIColor clearColor];
		locationSwitchLabel.text = @"Location";
		locationSwitchLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *locationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationTap:)];
		[locationSwitchLabel addGestureRecognizer:locationTap];
		[locationSwitch addSubview:locationSwitchLabel];

	
		hotspotSwitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		hotspotSwitch.frame = CGRectMake(dataSwitch.size.width + airplaneSwitch.size.width + hotspotSwitch.size.width, 240, switchesView.size.width/3, 65);
		[hotspotSwitch setBackgroundColor:[UIColor clearColor]];
		[hotspotSwitch addTarget:self action:@selector(hotspotSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[switchesView addSubview:hotspotSwitch];
		hotspotImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/hotspotswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]]];
		hotspotImage.frame = CGRectMake(hotspotSwitch.frame.size.width/2 - 14, hotspotSwitch.frame.size.height/2 - 14, 28, 28);
		hotspotImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		[hotspotSwitch addSubview:hotspotImage];
	
		UILabel *hotspotSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, switchesView.size.width/3, 15)];
		hotspotSwitchLabel.textColor = [UIColor colorWithRed: 190/255.0 green:194/255.0 blue:196/255.0 alpha:1.0];
		hotspotSwitchLabel.textAlignment = NSTextAlignmentCenter;
		hotspotSwitchLabel.font = [UIFont systemFontOfSize:10];
		hotspotSwitchLabel.backgroundColor = [UIColor clearColor];
		hotspotSwitchLabel.text = @"Hotspot";
		hotspotSwitchLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *hotspotTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hotspotTap:)];
		[hotspotSwitchLabel addGestureRecognizer:hotspotTap];
		[hotspotSwitch addSubview:hotspotSwitchLabel];

	
		doNotDisturbSwitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		doNotDisturbSwitch.frame = CGRectMake(0, 325, switchesView.size.width/3, 65);
		[doNotDisturbSwitch setBackgroundColor:[UIColor clearColor]];
		[doNotDisturbSwitch addTarget:self action:@selector(doNotDisturbSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[switchesView addSubview:doNotDisturbSwitch];
		doNotDisturbImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]]];
		doNotDisturbImage.frame = CGRectMake(doNotDisturbSwitch.frame.size.width/2 - 11, doNotDisturbSwitch.frame.size.height/2 - 11, 22, 22);
		doNotDisturbImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		[doNotDisturbSwitch addSubview:doNotDisturbImage];
	
		UILabel *doNotDisturbSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, switchesView.size.width/3, 15)];
		doNotDisturbSwitchLabel.textColor = [UIColor colorWithRed: 190/255.0 green:194/255.0 blue:196/255.0 alpha:1.0];
		doNotDisturbSwitchLabel.textAlignment = NSTextAlignmentCenter;
		doNotDisturbSwitchLabel.font = [UIFont systemFontOfSize:10];
		doNotDisturbSwitchLabel.backgroundColor = [UIColor clearColor];
		doNotDisturbSwitchLabel.text = @"Do not disturb";
		doNotDisturbSwitchLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *doNotDisturbTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doNotDisturbTap:)];
		[doNotDisturbSwitchLabel addGestureRecognizer:doNotDisturbTap];
		[doNotDisturbSwitch addSubview:doNotDisturbSwitchLabel];
	
	
		autoBrightnessSwitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		autoBrightnessSwitch.frame = CGRectMake(switchesView.size.width/3, 325, switchesView.size.width/3, 65);
		[autoBrightnessSwitch setBackgroundColor:[UIColor clearColor]];
		[autoBrightnessSwitch addTarget:self action:@selector(autoBrightnessSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[switchesView addSubview:autoBrightnessSwitch];
		autoBrightnessImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]]];
		autoBrightnessImage.frame = CGRectMake(autoBrightnessSwitch.frame.size.width/2 - 14, autoBrightnessSwitch.frame.size.height/2 - 14, 28, 28);
		[autoBrightnessSwitch addSubview:autoBrightnessImage];
	
		UILabel *autoBrightnessSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, switchesView.size.width/3, 15)];
		autoBrightnessSwitchLabel.textColor = [UIColor colorWithRed: 190/255.0 green:194/255.0 blue:196/255.0 alpha:1.0];
		autoBrightnessSwitchLabel.textAlignment = NSTextAlignmentCenter;
		autoBrightnessSwitchLabel.font = [UIFont systemFontOfSize:10];
		autoBrightnessSwitchLabel.backgroundColor = [UIColor clearColor];
		autoBrightnessSwitchLabel.text = @"Auto-brightness";
		autoBrightnessSwitchLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *autoBrightnessTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autoBrightnessTap:)];
		[autoBrightnessSwitchLabel addGestureRecognizer:autoBrightnessTap];
		[autoBrightnessSwitch addSubview:autoBrightnessSwitchLabel];

	
		ringerSwitch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		ringerSwitch.frame = CGRectMake(dataSwitch.size.width + airplaneSwitch.size.width + ringerSwitch.size.width, 325, switchesView.size.width/3, 65);
		[ringerSwitch setBackgroundColor:[UIColor clearColor]];
		[ringerSwitch addTarget:self action:@selector(ringerSwitch:) forControlEvents:UIControlEventTouchUpInside];
		[switchesView addSubview:ringerSwitch];
		ringerImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/ringerswitchon.png"] _flatImageWithColor:[UIColor whiteColor]]];
		ringerImage.frame = CGRectMake(ringerSwitch.frame.size.width/2 - 14, ringerSwitch.frame.size.height/2 - 14, 28, 28);
		ringerImage.tintColor = [UIColor whiteColor];
		[ringerSwitch addSubview:ringerImage];
	
		UILabel *ringerSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, switchesView.size.width/3, 15)];
		ringerSwitchLabel.textColor = [UIColor colorWithRed: 190/255.0 green:194/255.0 blue:196/255.0 alpha:1.0];
		ringerSwitchLabel.textAlignment = NSTextAlignmentCenter;
		ringerSwitchLabel.font = [UIFont systemFontOfSize:10];
		ringerSwitchLabel.backgroundColor = [UIColor clearColor];
		ringerSwitchLabel.text = @"Ringer";
		ringerSwitchLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *ringerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ringerTap:)];
		[ringerSwitchLabel addGestureRecognizer:ringerTap];
		[ringerSwitch addSubview:ringerSwitchLabel];
	
		updateAlternateNCTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateAlternateNC:) userInfo:nil repeats:YES];
	
	} else {			
		return %orig;
	}
}

%new
-(void)updateAlternateNC:(id)sender {

    NSDate *now = [[NSDate alloc] init];
    
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"EEEE, MMMM d"];

	NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
	[timeFormat setDateFormat:@"h:mm a"];
	[timeFormat setAMSymbol:@"am"];
	[timeFormat setPMSymbol:@"pm"];
	
	timeLabel.text = [timeFormat stringFromDate:now];
	
	dateLabel.text = [dateFormat stringFromDate:now];
	
	int percent = [[%c(SBUIController) sharedInstance] displayBatteryCapacityAsPercentage];
	
	batteryLabel.text = [NSString stringWithFormat:@"%d",percent];

	brightnessSlider.value = [UIScreen mainScreen].brightness;

	FSSwitchState state1 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.wifi"];
	if (state1 == FSSwitchStateOn) {
 
		wifiImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		wifiImage.tintColor = [UIColor whiteColor];

	} else {

		wifiImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		wifiImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
    
    	FSSwitchState state2 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.bluetooth"];
	if (state2 == FSSwitchStateOn) {
 
		bluetoothImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		bluetoothImage.tintColor = [UIColor whiteColor];

	} else {

		bluetoothImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		bluetoothImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
    
    	FSSwitchState state3 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.cellular-data"];
	if (state3 == FSSwitchStateOn) {
 
		dataImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/dataswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		dataImage.tintColor = [UIColor whiteColor];

	} else {

		dataImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/dataswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		dataImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
    
    	FSSwitchState state4 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode"];
	if (state4 == FSSwitchStateOn) {
 
		airplaneImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		airplaneImage.tintColor = [UIColor whiteColor];

	} else {

		airplaneImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		airplaneImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
    
   	FSSwitchState state5 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.rotation"];
	if (state5 == FSSwitchStateOn) {
 
		autoRotationImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/autorotationswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		autoRotationImage.tintColor = [UIColor whiteColor];

	} else {

		autoRotationImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/autorotationswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		autoRotationImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
    
    	FSSwitchState state6 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.flashlight"];
	if (state6 == FSSwitchStateOn) {
 
		flashlightImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/flashlightswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		flashlightImage.tintColor = [UIColor whiteColor];

	} else {

		flashlightImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/flashlightswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		flashlightImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
    
    	FSSwitchState state7 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.location"];
	if (state7 == FSSwitchStateOn) {
 
		locationImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		locationImage.tintColor = [UIColor whiteColor];

	} else {

		locationImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		locationImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
    
    	FSSwitchState state8 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.hotspot"];
	if (state8 == FSSwitchStateOn) {
 
		hotspotImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/hotspotswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		hotspotImage.tintColor = [UIColor whiteColor];

	} else {

		hotspotImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/hotspotswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		hotspotImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}

	FSSwitchState state9 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"];
	if (state9 == FSSwitchStateOn) {
 
		doNotDisturbImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor whiteColor]];
		doNotDisturbImage.tintColor = [UIColor whiteColor];

	} else {

		doNotDisturbImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		doNotDisturbImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}

	FSSwitchState state10 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness"];
	if (state10 == FSSwitchStateOn) {
 
		autoBrightnessImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor whiteColor]];
		autoBrightnessImage.tintColor = [UIColor whiteColor];

	} else {

		autoBrightnessImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		autoBrightnessImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}

	FSSwitchState state11 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.ringer"];
	if (state11 == FSSwitchStateOn) {
 
		ringerImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/ringerswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		ringerImage.tintColor = [UIColor whiteColor];

	} else {

		ringerImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/ringerswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		ringerImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
}

%new
-(void)brightnessChanged:(id)sender {
	
	[[%c(SBBrightnessController) sharedBrightnessController] setBrightnessLevel:brightnessSlider.value];
}

%new
-(void)wifiSwitch:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.wifi"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.wifi"];
		wifiImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		wifiImage.tintColor = [UIColor whiteColor];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.wifi"];
		wifiImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		wifiImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
}

%new
-(void)bluetoothSwitch:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.bluetooth"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.bluetooth"];
		bluetoothImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		bluetoothImage.tintColor = [UIColor whiteColor];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.bluetooth"];
		bluetoothImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		bluetoothImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
}

%new
-(void)dataSwitch:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.cellular-data"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.cellular-data"];
		dataImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/dataswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		dataImage.tintColor = [UIColor whiteColor];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.cellular-data"];
		dataImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/dataswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		dataImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
}

%new
-(void)airplaneSwitch:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode"];
		airplaneImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		airplaneImage.tintColor = [UIColor whiteColor];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode"];
		airplaneImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		airplaneImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
}

%new
-(void)autoRotationSwitch:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.rotation"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.rotation"];
		autoRotationImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/autorotationswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		autoRotationImage.tintColor = [UIColor whiteColor];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.rotation"];
		autoRotationImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/autorotationswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		autoRotationImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
}

%new
-(void)flashlightSwitch:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.flashlight"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.flashlight"];
		flashlightImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/flashlightswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		flashlightImage.tintColor = [UIColor whiteColor];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.flashlight"];
		flashlightImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/flashlightswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		flashlightImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
}

%new
-(void)locationSwitch:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.location"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.location"];
		locationImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		locationImage.tintColor = [UIColor whiteColor];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.location"];
		locationImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		locationImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
}

%new
-(void)hotspotSwitch:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.hotspot"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.hotspot"];
		hotspotImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/hotspotswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		hotspotImage.tintColor = [UIColor whiteColor];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.hotspot"];
		hotspotImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/hotspotswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		hotspotImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
}

%new
-(void)doNotDisturbSwitch:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"];
		doNotDisturbImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor whiteColor]];
		doNotDisturbImage.tintColor = [UIColor whiteColor];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"];
		doNotDisturbImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		doNotDisturbImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
}

%new
-(void)autoBrightnessSwitch:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness"];
		autoBrightnessImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor whiteColor]];
		autoBrightnessImage.tintColor = [UIColor whiteColor];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness"];
		autoBrightnessImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		autoBrightnessImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
}

%new
-(void)ringerSwitch:(id)sender {

	FSSwitchState state = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.ringer"];
	if (state == FSSwitchStateOff) {
 
		[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOn forSwitchIdentifier:@"com.a3tweaks.switch.ringer"];
		ringerImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/ringerswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
		ringerImage.tintColor = [UIColor whiteColor];

	} else {
 
    	[[FSSwitchPanel sharedPanel] setState:FSSwitchStateOff forSwitchIdentifier:@"com.a3tweaks.switch.ringer"];
		ringerImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/ringerswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
		ringerImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
	}
}

//label buttons
%new
- (void)wifiTap:(UITapGestureRecognizer *)recognizer {
	NSURL*url = [NSURL URLWithString:@"prefs:root=WIFI"];
	[[UIApplication sharedApplication] openURL:url];
}

%new
- (void)bluetoothTap:(UITapGestureRecognizer *)recognizer {
	NSURL*url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
	[[UIApplication sharedApplication] openURL:url];
}

%new
- (void)dataTap:(UITapGestureRecognizer *)recognizer {
	NSURL*url = [NSURL URLWithString:@"prefs:root=MOBILE_DATA_SETTINGS_ID"];
	[[UIApplication sharedApplication] openURL:url];
}

%new
- (void)airplaneTap:(UITapGestureRecognizer *)recognizer {
	NSURL*url = [NSURL URLWithString:@"prefs:root=AIRPLANE_MODE"];
	[[UIApplication sharedApplication] openURL:url];
}

%new
- (void)locationTap:(UITapGestureRecognizer *)recognizer {
	NSURL*url = [NSURL URLWithString:@"prefs:root=Privacy&path=LOCATION_SERVICES"];
	[[UIApplication sharedApplication] openURL:url];
}

%new
- (void)hotspotTap:(UITapGestureRecognizer *)recognizer {
	NSURL*url = [NSURL URLWithString:@"prefs:root=INTERNET_TETHERING"];
	[[UIApplication sharedApplication] openURL:url];
}

%new
- (void)doNotDisturbTap:(UITapGestureRecognizer *)recognizer {
	NSURL*url = [NSURL URLWithString:@"prefs:root=DO_NOT_DISTURB"];
	[[UIApplication sharedApplication] openURL:url];
}

%new
- (void)autoBrightnessTap:(UITapGestureRecognizer *)recognizer {
	NSURL*url = [NSURL URLWithString:@"prefs:root=DISPLAY"];
	[[UIApplication sharedApplication] openURL:url];
}

%new
- (void)ringerTap:(UITapGestureRecognizer *)recognizer {
	NSURL*url = [NSURL URLWithString:@"prefs:root=Sounds"];
	[[UIApplication sharedApplication] openURL:url];
}
//

%new
-(void)openBatterySettings:(id)sender {

	NSURL*url = [NSURL URLWithString:@"prefs:root=General&path=USAGE"];
	[[UIApplication sharedApplication] openURL:url];
}

%new
-(void)openSettings:(id)sender {
    
	if (IS_OS_7_OR_UNDER) {
	    [[%c(SBUIController) sharedInstance] activateApplicationAnimated:[[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:@"com.apple.Preferences"]];
	} else {
		[[%c(SBUIController) sharedInstance] activateApplicationAnimated:[[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:@"com.apple.Preferences"]];
	}
}

%new
-(void)openContacts:(id)sender {
	
	if (IS_OS_7_OR_UNDER) {
  		[[%c(SBUIController) sharedInstance] activateApplicationAnimated:[[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:@"com.apple.MobileAddressBook"]];
	} else {
		[[%c(SBUIController) sharedInstance] activateApplicationAnimated:[[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:@"com.apple.MobileAddressBook"]];
	}
}

%new
-(void)openMainView:(UISwipeGestureRecognizer *)gestureRecognizer {
	[UIView animateWithDuration:0.5 
	                 animations:^{
	                     switchesView.frame = CGRectMake(7.5, 105, [[UIScreen mainScreen] bounds].size.width - 15, [[UIScreen mainScreen] bounds].size.height - 105);
	                 }];
	clearAllButton.hidden = YES;
}

%new
-(void)hideMainView:(UISwipeGestureRecognizer *)gestureRecognizer {
	[UIView animateWithDuration:0.5 
	                 animations:^{
	                     switchesView.frame = CGRectMake(7.5, -[[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 15, [[UIScreen mainScreen] bounds].size.height);
	                 }];
	clearAllButton.hidden = NO;
}

-(void)hostWillPresent {
	if (alternateEnabled) {	
	    
		%orig;
		
		[self setSelectedViewController:[[self viewControllers] objectAtIndex:1]];

		NSDate *now = [[NSDate alloc] init];
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"EEEE, MMMM d"];

		NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
		[timeFormat setDateFormat:@"h:mm a"];
		[timeFormat setAMSymbol:@"am"];
		[timeFormat setPMSymbol:@"pm"];
	
		timeLabel.text = [timeFormat stringFromDate:now];
	
		dateLabel.text = [dateFormat stringFromDate:now];
	
		int percent = [[%c(SBUIController) sharedInstance] displayBatteryCapacityAsPercentage];
	
		batteryLabel.text = [NSString stringWithFormat:@"%d",percent];

	    brightnessSlider.value = [UIScreen mainScreen].brightness;

		FSSwitchState state1 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.wifi"];
		if (state1 == FSSwitchStateOn) {
 
			wifiImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
			wifiImage.tintColor = [UIColor whiteColor];

		} else {

			wifiImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/wifiswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
			wifiImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		}
    
	    	FSSwitchState state2 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.bluetooth"];
		if (state2 == FSSwitchStateOn) {
 
			bluetoothImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
			bluetoothImage.tintColor = [UIColor whiteColor];

		} else {

			bluetoothImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/bluetoothswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
			bluetoothImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		}
    
	    	FSSwitchState state3 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.cellular-data"];
		if (state3 == FSSwitchStateOn) {
 
			dataImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/dataswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
			dataImage.tintColor = [UIColor whiteColor];

		} else {

			dataImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/dataswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
			dataImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		}
    
	    	FSSwitchState state4 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.airplane-mode"];
		if (state4 == FSSwitchStateOn) {
 
			airplaneImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
			airplaneImage.tintColor = [UIColor whiteColor];

		} else {

			airplaneImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/airplaneswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
			airplaneImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		}
    
	   	FSSwitchState state5 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.rotation"];
		if (state5 == FSSwitchStateOn) {
 
			autoRotationImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/autorotationswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
			autoRotationImage.tintColor = [UIColor whiteColor];

		} else {

			autoRotationImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/autorotationswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
			autoRotationImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		}
    
	    	FSSwitchState state6 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.flashlight"];
		if (state6 == FSSwitchStateOn) {
 
			flashlightImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/flashlightswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
			flashlightImage.tintColor = [UIColor whiteColor];

		} else {

			flashlightImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/flashlightswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
			flashlightImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		}
    
	    	FSSwitchState state7 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.location"];
		if (state7 == FSSwitchStateOn) {
 
			locationImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
			locationImage.tintColor = [UIColor whiteColor];

		} else {

			locationImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/locationswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
			locationImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		}
    
	    	FSSwitchState state8 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.hotspot"];
		if (state8 == FSSwitchStateOn) {
 
			hotspotImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/hotspotswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
			hotspotImage.tintColor = [UIColor whiteColor];

		} else {

			hotspotImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/hotspotswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
			hotspotImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		}

		FSSwitchState state9 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.do-not-disturb"];
		if (state9 == FSSwitchStateOn) {
 
			doNotDisturbImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor whiteColor]];
			doNotDisturbImage.tintColor = [UIColor whiteColor];

		} else {

			doNotDisturbImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/disturbswitch.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
			doNotDisturbImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		}

		FSSwitchState state10 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.auto-brightness"];
		if (state10 == FSSwitchStateOn) {
 
			autoBrightnessImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor whiteColor]];
			autoBrightnessImage.tintColor = [UIColor whiteColor];

		} else {

			autoBrightnessImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/brightnessswitch.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
			autoBrightnessImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		}

		FSSwitchState state11 = [[FSSwitchPanel sharedPanel] stateForSwitchIdentifier:@"com.a3tweaks.switch.ringer"];
		if (state11 == FSSwitchStateOn) {
 
			ringerImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/ringerswitchon.png"] _flatImageWithColor:[UIColor whiteColor]];
			ringerImage.tintColor = [UIColor whiteColor];

		} else {

			ringerImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/ringerswitchoff.png"] _flatImageWithColor:[UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0]];
			ringerImage.tintColor = [UIColor colorWithRed: 104/255.0 green:112/255.0 blue:116/255.0 alpha:1.0];
		}
		
	} else {
		return %orig;
	}
}

//Hide all NC Tabs
-(float)_headerViewHeightForMode:(int)mode {	
	if (alternateEnabled) {
		return 0;
	} else {
		return %orig;
	}
}

//lower notifications view
-(void)_loadContentView {
	if (alternateEnabled) {	
		%orig;
		UIScrollView *contentView = MSHookIvar<UIScrollView *>(self, "_contentView");
		CGRect frame = contentView.frame;
		frame.origin.y = 105;
		frame.size.height = frame.size.height - 105;
		contentView.frame = frame;
	} else {
		return %orig;
	}
}
%end

//change color of notifications header text
%hook _UIContentUnavailableView
-(void)layoutSubviews {
	if (alternateEnabled) {	
		%orig;
		UILabel *titleLabel = MSHookIvar<UILabel *>(self, "_titleLabel");
		titleLabel.textColor = [UIColor whiteColor];
	} else {
		return %orig;
	}
}
%end
	
%hook SBBulletinWindow
- (BOOL)_canBecomeKeyWindow
{
    return YES;
}
%end
	
%hook SBNotificationCenterViewController
-(void)viewDidLoad {

	%orig;

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.orca.andrios.plist"];

	if (alternateEnabled) {

		if (backdropEnabled) {
			self.backdropView.backgroundColor = [UIColor blackColor];
			self.backdropView.alpha = [[prefs objectForKey:@"ncalpha"] floatValue];
		} else {
			self.backdropView.alpha = 0.5;
		}
		
		if (clearButton) {

			//clear all notifications button
	   		clearAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
			clearAllButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 42, [[UIScreen mainScreen] bounds].size.height - 62, 32, 32);
	    	[clearAllButton setBackgroundImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/clearall.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	    	clearAllButton.tintColor = [UIColor whiteColor];
	    	[clearAllButton addTarget:self action:@selector(clearAllNotification:) forControlEvents:UIControlEventTouchUpInside];
			clearAllButton.hidden = NO;

			UIView *contentView = MSHookIvar<UIView *>(self, "_contentView");
			[contentView addSubview:clearAllButton];
			[contentView bringSubviewToFront:clearAllButton];
		}
		
	} else {
		return %orig;
	}
}

//hide statusbar in nc
-(void)_loadStatusBar {
	if (alternateEnabled) {
		
	} else {
		return %orig;
	}
}

//hide bottom separator
-(void)_loadBottomSeparator {
	if (alternateEnabled) {
		
	} else {
		return %orig;
	}	
}

//hide nc grabber
-(void)_loadGrabberContentView {
	if (alternateEnabled) {
	
	} else {
		return %orig;
	}
}

%new
-(void)clearAllNotification:(id)sender {
	SBNotificationCenterController *nc = (SBNotificationCenterController *)[%c(SBNotificationCenterController) sharedInstance];
	    if (nc)
	        [nc clearAllNotifications];
}
%end

//disable nc grabber press
%hook SBNotificationCenterController
-(void)handleGrabberPress:(id)press {
	if (alternateEnabled) {
		%orig(nil);
	} else {
		return %orig;
	}
}

%new
-(void)clearAllNotifications {
    SBBulletinObserverViewController *allCtrl = MSHookIvar<SBBulletinObserverViewController *>(self.viewController, "_allModeViewController");

    NSMutableArray *_visibleSectionIDs = MSHookIvar<NSMutableArray *>(allCtrl, "_visibleSectionIDs");
    NSArray *allSections = [NSArray arrayWithArray:_visibleSectionIDs];
    for (NSString *identifier in allSections) {
        if (whiteList && [whiteList containsObject:identifier])
            continue;

        id sectionInfo = [allCtrl sectionWithIdentifier:identifier];
        if (sectionInfo)
            [allCtrl clearSection:sectionInfo];

        if (removeBadge) {
            if (!iconModel)
                iconModel = (SBIconModel *)[(SBIconViewMap *)[%c(SBIconViewMap) homescreenMap] iconModel];
            if (iconModel) {
                SBIcon *appIcon = nil;
                if (kCFCoreFoundationVersionNumber < 1140.10)
                    appIcon = [iconModel applicationIconForDisplayIdentifier:identifier];
                else
                    appIcon = [iconModel applicationIconForBundleIdentifier:identifier];

                if (appIcon && [appIcon badgeNumberOrString])
                    [appIcon setBadge:nil];
            }
        }
    }
}
%end

//hide NC date
%hook SBTodayTableHeaderView 
-(id)initWithFrame:(CGRect)frame {
	if (alternateEnabled) {
		return nil;
		%orig(frame);
	} else {
		return %orig;;
	}
}

//hide NC date iOS 8
-(BOOL)showsLunarDate {
	if (alternateEnabled) {
		return NO;
	} else {
		return %orig;;
	}
}
%end

//modify notification cells
%hook SBNotificationCell
-(void)layoutSubviews {

	%orig;
	
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.orca.andrios.plist"];

	if (LSNEnabled) {
		
		CGRect frame = self.bounds;
		frame.size.height = frame.size.height - 3;
		frame.size.width = frame.size.width - 15;
		frame.origin.x = [[UIScreen mainScreen] bounds].size.width/2 - frame.size.width/2;
		self.realContentView.frame = frame;
		self.realContentView.backgroundColor = [UIColor whiteColor];
		[[self.realContentView layer] setCornerRadius:3.0];
		if (notifAlphaEnabled) {
			self.realContentView.alpha = [[prefs objectForKey:@"notifalpha"] floatValue];
		} else {
			self.realContentView.alpha = 0.85;
		}
		
		UILabel *primaryLabel = MSHookIvar<UILabel *>(self, "_primaryLabel");
		primaryLabel.textColor = [UIColor blackColor];
		CGRect pLabelFrame = primaryLabel.frame;
		pLabelFrame.origin.y = frame.size.height/2 - primaryLabel.size.height;
		primaryLabel.frame = pLabelFrame;
		
		UILabel *secondaryLabel = MSHookIvar<UILabel *>(self, "_secondaryLabel");
		secondaryLabel.textColor = [UIColor blackColor];
		CGRect bLabelFrame = secondaryLabel.frame;
		bLabelFrame.origin.y = frame.size.height/2 - secondaryLabel.size.height + 23;
		secondaryLabel.frame = bLabelFrame;
		
		UILabel *subtitleLabel = MSHookIvar<UILabel *>(self, "_subtitleLabel");
		subtitleLabel.textColor = [UIColor blackColor];

		UILabel *eventDateLabel = MSHookIvar<UILabel *>(self, "_eventDateLabel");
		eventDateLabel.textColor = [UIColor blackColor];

		NSArray *viewsToRemove = [self.realContentView subviews];
		for (UIView *v in viewsToRemove) {

			if (v.tag == 1000) {

				[v removeFromSuperview];
			}
		}

		UILabel *oldRelevanceDateLabel = MSHookIvar<UILabel *>(self, "_relevanceDateLabel");
		CGRect dateFrame = oldRelevanceDateLabel.frame;
		dateFrame.origin.x = frame.size.width - 53;
		oldRelevanceDateLabel.hidden = YES;
		UILabel *newRelevanceDateLabel = [[UILabel alloc] initWithFrame:dateFrame];
		newRelevanceDateLabel.text = oldRelevanceDateLabel.text;
		newRelevanceDateLabel.textColor = [UIColor blackColor];
		newRelevanceDateLabel.font = oldRelevanceDateLabel.font;
		newRelevanceDateLabel.tag = 1000;
		[self.realContentView addSubview:newRelevanceDateLabel];
		[self.realContentView bringSubviewToFront:newRelevanceDateLabel];

		UIImageView *iconImageView = MSHookIvar<UIImageView *>(self, "_iconImageView");
		CGRect iconFrame = iconImageView.frame;
		iconFrame.origin.y = frame.size.height/2 - iconImageView.size.height + 10;
		iconImageView.frame = iconFrame;
		
		if (roundIcons) {
			iconImageView.layer.cornerRadius = iconImageView.frame.size.height /2;
			iconImageView.layer.masksToBounds = YES;
			iconImageView.layer.borderWidth = 0;
		} else {}
	}
}

//notification lines
-(void)setSecondaryTextNumberOfLines:(unsigned)lines treatAsUpperBound:(BOOL)bounds {
	if (LSNEnabled) {
		%orig(1, bounds);
	} else {
		%orig;
	}
}
%end

%hook SBNotificationsBulletinCell
-(void)layoutSubviews {
	%orig;
	if (LSNEnabled) {	
		
		UIView *selectedBackgroundView = MSHookIvar<UIView *>(self, "_selectedBackgroundView");
		selectedBackgroundView.hidden = YES;
	} 
}
%end

//hide "slide to..." text
%hook SBLockScreenNotificationCell
+(BOOL)wantsUnlockActionText {
	if (LSNEnabled) {	
		return NO;
	} else {
		return %orig;
	}
}

-(BOOL)isTopCell {
	if (LSNEnabled) {	
		return NO;
	} else {
		return %orig;
	}
}
%end

//notification lines
%hook SBBulletinListSection
-(unsigned int)messageNumberOfLines {
	if (LSNEnabled) {	
		return 1;
	} else {
		return %orig;
	}
}	
%end

//hide nc seperators
%hook SBNotificationsBulletinCell
-(BOOL)showsSeparator {
	if (LSNEnabled) {
		return NO;
	} else {
		return %orig;
	}
}

-(BOOL)hasClearableBulletins {
	if (LSNEnabled) {
		return YES;
	} else {
		return %orig;
	}
}
%end

%hook BBServer
-(id)init
{
    id ret = %orig;
    bbserve = self;
    return ret;
}
%end

//swipe left to clear notifications in nc one by one
%hook SBBulletinViewController
%new
-(void)ClearOne:(UISwipeGestureRecognizer *)gesture
{
        if ([gesture state] == UIGestureRecognizerStateEnded) {
                if (bbserve) {
                        UITableViewCell *cell = (UITableViewCell *)[gesture view];
                        NSIndexPath *path = [self.tableView indexPathForCell:cell];

                        SBNotificationsSectionInfo *sectionInfo = [self sectionAtIndex:path.section];
                        SBBulletinListSection *section = (SBBulletinListSection *)[sectionInfo representedListSection];
                        BBBulletin *bulletin = [section bulletinAtIndex:path.row];

                        [bbserve withdrawBulletinRequestsWithRecordID:bulletin.recordID forSectionID:section.sectionID];
                }
        }
}

-(UITableViewCell *)tableView:(UITableView *)tview cellForRowAtIndexPath:(NSIndexPath *)path
{
    UITableViewCell *original = %orig;

    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(ClearOne:)];
	gesture.numberOfTouchesRequired = 1; 
	gesture.cancelsTouchesInView = YES; 
	gesture.direction = (UISwipeGestureRecognizerDirectionLeft); 
    [original addGestureRecognizer:gesture];

    return original;
}
%end

//push notifications view down
%hook SBBulletinObserverViewController
-(CGRect)_frameforViewWithContentForMode:(int)mode {
	if (alternateEnabled) {	
		CGRect frame = %orig;
		frame.origin.y = 105;
		frame.size.height = frame.size.height - 105;
		return frame;
	} else {
		return %orig;
	}
}
%end

//hide separators
%hook SBNotificationSeparatorView
-(void)setBounds:(CGRect)bounds {
	if (LSNEnabled) {
		%orig;
		self.hidden = YES;
	} else {
		return %orig;
	}
}

-(void)setFrame:(CGRect)frame {
	if (LSNEnabled) {
		%orig;
		self.hidden = YES;
	} else {
		return %orig;
	}
}

-(void)updateForCurrentState {
	if (LSNEnabled) {
		%orig;
		self.hidden = YES;
	} else {
		return %orig;
	}
}

-(id)initWithFrame:(CGRect)frame mode:(int)mode {
	if (LSNEnabled) {
		id original = %orig;
		self.hidden = YES;
		return original;
	} else {
		return %orig;
	}
}
//
%end

%hook SBTableViewCellActionButton
-(void)layoutSubviews {
	if (LSNEnabled) {
		%orig;
		self.layer.backgroundColor = [[UIColor clearColor] CGColor];
		UIView *hookedBackground = MSHookIvar<UIView *>(self, "_backgroundView");
		hookedBackground.backgroundColor = [UIColor clearColor];
	} else {
		%orig;
	}
}
%end

%hook SBLockScreenNotificationListView
-(void)layoutSubviews {
	if (LSNEnabled) {
		%orig;

		UIView *containerView = MSHookIvar<UIView*>(self, "_containerView");
		CGRect newFrame = containerView.frame;
		newFrame.origin.x = 7.5;
		newFrame.size.width = [[UIScreen mainScreen] bounds].size.width - 15;
		containerView.frame = newFrame;

		UITableView *notificationsTableView = MSHookIvar<UITableView*>(self, "_tableView");
		notificationsTableView.separatorColor = [UIColor clearColor];
	
		UITapGestureRecognizer *clear = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
		clear.numberOfTapsRequired = 2;
	    [containerView addGestureRecognizer:clear];
	} else {
		return %orig;
	}
}

%new
-(void)dismiss:(UITapGestureRecognizer *)recognizer {
	
	SBNotificationCenterController *nc = (SBNotificationCenterController *)[%c(SBNotificationCenterController) sharedInstance];
	    if (nc)
	        [nc clearAllNotifications];
}
%end

//notification lines
%hook SBAwayBulletinListItem
-(unsigned)maxMessageLines {
	if (LSNEnabled) {
		return 1;
	} else {
		return %orig;
	}
}

-(BOOL)canBeClearedByNotificationCenter {
	if (LSNEnabled) {
		return YES;
	} else {
		return %orig;
	}
}
%end
	
%hook SBLockScreenView
-(void)layoutSubviews {
	
	%orig;
	if (LSNEnabled) {
		UIView *foregroundLockUnderlayView = MSHookIvar<UIView *>(self, "_foregroundLockUnderlayView");
		foregroundLockUnderlayView.hidden = YES;
	}
}

//hide NC grabber on ls
-(void)setTopGrabberHidden:(BOOL)hidden forRequester:(id)requester {
	if (LSNEnabled) {
		%orig(TRUE, requester);
	} else {
		return %orig;
	}
}

//hide CC grabber on LS
-(void)setBottomGrabberHidden:(BOOL)hidden forRequester:(id)requester {
	if (LSNEnabled) {
		%orig(TRUE, requester);
	} else {
		return %orig;
	}
}

//hide slide to unlock text
-(id)_defaultSlideToUnlockText {
	if (LSNEnabled) {
		return nil;
	} else {
		return %orig;
	}
}
%end


//hide LS chevron	
%hook _UIGlintyStringView
- (id)chevron {
	if (LSNEnabled) {
		return nil;
	} else {
		return %orig;
	}
}
%end

//remove LS blur 
%hook SBLockOverlayStyleProperties
- (double)blurRadius {
	if (LSNEnabled) {
		return 0;
	} else {
		return %orig;
	}
}
%end

//add separators iOS 8
%hook SBNotificationCenterHeaderView
-(void)layoutSubviews {
	
	%orig;
	if (alternateEnabled) {
		NSArray *viewsToRemove = [self subviews];
		for (UIView *v in viewsToRemove) {
		    [v removeFromSuperview];
		}
		
		UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(7.5, self.size.height/2 - 1.5, [[UIScreen mainScreen] bounds].size.width - 15, 1.5)];
		[horizontalLine setBackgroundColor:[UIColor lightGrayColor]];
		[self addSubview:horizontalLine];
	}
}
%end

//add separators iOS 7
%hook SBNotificationsSectionHeaderView
-(void)layoutSubviews {
	
	%orig;
	if (alternateEnabled && replaceNCHeaders) {
		NSArray *viewsToRemove = [self subviews];
		for (UIView *v in viewsToRemove) {
		    [v removeFromSuperview];
		}
		
		UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(7.5, self.size.height/2 - 1.5, [[UIScreen mainScreen] bounds].size.width - 15, 1.5)];
		[horizontalLine setBackgroundColor:[UIColor lightGrayColor]];
		[self addSubview:horizontalLine];
	}
}
%end

//clear header background
%hook _UITableViewHeaderFooterContentView
- (void)setBackgroundColor:(id)arg1 {
	if (LSNEnabled) {
		arg1 = [UIColor clearColor];
	} else {
		return %orig;
	}
}
%end

//don't open NC if in landscape and AlternateNC is enabled
%hook SBUIController
-(void)handleShowNotificationsSystemGesture:(id)gesture {
	
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] _frontMostAppOrientation]) && (alternateEnabled || LSNEnabled)) {
		
	} else {
		%orig;
	}
}
%end

//fixes first lockscreen notification from being too big on iOS 8
%hook SBLockScreenBulletinCell
+(double)rowHeightForTitle:(id)arg1 subtitle:(id)arg2 body:(id)arg3 maxLines:(unsigned long long)arg4 attachmentSize:(struct CGSize)arg5 secondaryContentSize:(struct CGSize)arg6 datesVisible:(_Bool)arg7 rowWidth:(double)arg8 includeUnlockActionText:(_Bool)arg9 {
	if (LSNEnabled) {
		return %orig(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, NO);
	} else {
		return %orig;
	}
}
%end
	
%ctor {	

	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.orca.andrios/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}