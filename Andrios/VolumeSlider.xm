#import "VolumeSliderHeader.h"

static BOOL volumeSliderEnabled;
static BOOL vnewAndroid;

static void loadPrefs() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.orca.andrios.plist"];

	volumeSliderEnabled = [prefs objectForKey:@"volumeSliderEnabled"] ? [[prefs objectForKey:@"volumeSliderEnabled"] boolValue] : YES;
	vnewAndroid = [prefs objectForKey:@"vnewAndroid"] ? [[prefs objectForKey:@"vnewAndroid"] boolValue] : YES;
}

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1
{
	%orig(arg1);
	
	if (vnewAndroid) {
		vsBackgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
		vswitchImageColor = [UIColor colorWithRed: 130/255.0 green:130/255.0 blue:130/255.0 alpha:1.0];
	} else {
		vsBackgroundColor = [UIColor colorWithRed: 38/255.0 green:50/255.0 blue:56/255.0 alpha:1.0];
		vswitchImageColor = [UIColor whiteColor];
	}
	
	vsWindow = [[UIWindow alloc] init];
	vsWindow.frame = CGRectMake(10, 20, [[UIScreen mainScreen] bounds].size.width - 20, 60);
	vsWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	[[vsWindow layer] setCornerRadius:2.5];
	vsWindow.hidden = YES;
	vsWindow.alpha = 0.0;
	vsWindow.backgroundColor = vsBackgroundColor;

	volumeSliderImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/volumeSlider.png"] _flatImageWithColor:vswitchImageColor]];
	volumeSliderImage.tintColor = vswitchImageColor;
	volumeSliderImage.frame = CGRectMake(15, vsWindow.frame.size.height/2 - 14, 28, 28);
	[vsWindow addSubview:volumeSliderImage];
	
	MPVolumeView *volumeSlider = [[MPVolumeView alloc] initWithFrame:CGRectMake(58, vsWindow.frame.size.height/2 - 7.5, vsWindow.frame.size.width - 73, 15)];
	volumeSlider.showsRouteButton = NO;
	[volumeSlider setVolumeThumbImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/volumeSliderThumbImage.png"] forState:UIControlStateNormal];
	[volumeSlider setMaximumVolumeSliderImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/maximumTrack.png"] forState:UIControlStateNormal];
	[volumeSlider setMinimumVolumeSliderImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/minimumTrack.png"] forState:UIControlStateNormal];
	[vsWindow addSubview:volumeSlider];
}
%end

%hook SBHUDController
-(void)presentHUDView:(id)arg1 {

	if (volumeSliderEnabled) {
		
		[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
				
			vsWindow.hidden = NO;
			vsWindow.alpha = 1.0;
	    }
	    completion:^(BOOL finished) {
			[timer invalidate];
			timer = nil;
			timer = [[NSTimer scheduledTimerWithTimeInterval:1.25 target:self selector:@selector(hideHUD) userInfo:nil repeats:NO] retain];
		}];
	
	} else {
		%orig(arg1);
	}
}

-(void)presentHUDView:(SBHUDView *)arg1 autoDismissWithDelay:(double)arg2 {

	if (volumeSliderEnabled) {
		
		[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			vsWindow.hidden = NO;
			vsWindow.alpha = 1.0;
	    }
	    completion:^(BOOL finished) {
			[timer invalidate];
			timer = nil;
			timer = [[NSTimer scheduledTimerWithTimeInterval:1.25 target:self selector:@selector(hideHUD) userInfo:nil repeats:NO] retain];
		}];
	
	} else {
		%orig(arg1, arg2);
	}
}

%new
-(void)hideHUD {
	if (timer && !vsWindow.hidden) {
		[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
			vsWindow.alpha = 0.0;
   		}
    		completion:^(BOOL finished) {
			vsWindow.hidden = YES;
		}];
	}
}
%end

%ctor {

	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.orca.andrios/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}