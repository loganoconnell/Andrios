#import "ExtrasHeader.h"

static BOOL homescreenSwitcher;
static BOOL lockAnimation;

static void loadPrefs() {

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.orca.andrios.plist"];

	homescreenSwitcher = [prefs objectForKey:@"homescreenSwitcher"] ? [[prefs objectForKey:@"homescreenSwitcher"] boolValue] : NO;
	lockAnimation = [prefs objectForKey:@"lockAnimation"] ? [[prefs objectForKey:@"lockAnimation"] boolValue] : NO;
}

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1 
{
	%orig(arg1);

	lockWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	lockWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	lockWindow.backgroundColor = [UIColor clearColor];
	lockWindow.alpha = 1.0;
	lockWindow.hidden = YES;

	lockTopView = [[UIView alloc] initWithFrame:CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height / 2) * -1, [[UIScreen mainScreen] bounds].size.width, ([[UIScreen mainScreen] bounds].size.height / 2) - 2.5)];
	lockTopView.alpha = 1.0;
	lockTopView.backgroundColor = [UIColor blackColor];
	[lockWindow addSubview:lockTopView];

	lockBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, ([[UIScreen mainScreen] bounds].size.height / 2) + 2.5)];
	lockBottomView.alpha = 1.0;
	lockBottomView.backgroundColor = [UIColor blackColor];
	[lockWindow addSubview:lockBottomView];

	lockLeftView = [[UIView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width / 2) * -1, ([[UIScreen mainScreen] bounds].size.height / 2) - 2.5, [[UIScreen mainScreen] bounds].size.width / 2, 5)];
	lockLeftView.alpha = 1.0;
	lockLeftView.backgroundColor = [UIColor blackColor];
	[lockWindow addSubview:lockLeftView];

	lockRightView = [[UIView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width, ([[UIScreen mainScreen] bounds].size.height / 2) - 2.5, [[UIScreen mainScreen] bounds].size.width / 2, 5)];
	lockRightView.alpha = 1.0;
	lockRightView.backgroundColor = [UIColor blackColor];
	[lockWindow addSubview:lockRightView];
}
%end

%hook SBIconListView
%new
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    	touchesBeganTime = [(UITouch *)[touches anyObject] timestamp];
}

%new
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

}

%new
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	if ([(UITouch *)[touches anyObject] timestamp] - touchesBeganTime >= 0.5 && homescreenSwitcher) {

		[[%c(SBUIController) sharedInstance] _toggleSwitcher];
	}
}
%end

%hook SBScreenFadeAnimationController
-(void)fadeOutWithCompletion:(id)completion {

	if (lockAnimation) {

		[UIView animateWithDuration:([self fadeOutAnimationDuration] / 2) delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{

			lockWindow.hidden = NO;
			CGRect topFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, ([[UIScreen mainScreen] bounds].size.height / 2) - 2.5);
			CGRect bottomFrame = CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height / 2) + 2.5, [[UIScreen mainScreen] bounds].size.width, ([[UIScreen mainScreen] bounds].size.height / 2) + 2.5);
			lockTopView.frame = topFrame;
			lockBottomView.frame = bottomFrame;
   		}
    		completion:^(BOOL finished) {

			lockWindow.backgroundColor = [UIColor whiteColor];	
		
			[UIView animateWithDuration:([self fadeOutAnimationDuration] / 2) delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{

				CGRect leftFrame = CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height / 2) - 2.5, [[UIScreen mainScreen] bounds].size.width / 2, 5);
				CGRect rightFrame = CGRectMake([[UIScreen mainScreen] bounds].size.width / 2, ([[UIScreen mainScreen] bounds].size.height / 2) - 2.5, [[UIScreen mainScreen] bounds].size.width / 2, 5);
				lockLeftView.frame = leftFrame;
				lockRightView.frame = rightFrame;
   			}
    			completion:^(BOOL finished) {

				[[%c(SBBacklightController) sharedInstance] animateBacklightToFactor:0.0 duration:0.0 source:0 completion:nil];
				[[[%c(SBLockScreenManager) sharedInstance] lockScreenViewController] setInScreenOffMode:YES];
				[[%c(SBLockScreenManager) sharedInstance] lockUIFromSource:1 withOptions:nil];
				lockWindow.hidden = YES;
				lockWindow.backgroundColor = [UIColor clearColor];
				lockTopView.frame = CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height / 2) * -1, [[UIScreen mainScreen] bounds].size.width, ([[UIScreen mainScreen] bounds].size.height / 2) - 2.5);
				lockBottomView.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, ([[UIScreen mainScreen] bounds].size.height / 2) + 2.5);
				lockLeftView.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width / 2) * -1, ([[UIScreen mainScreen] bounds].size.height / 2) - 2.5, [[UIScreen mainScreen] bounds].size.width / 2, 5);
				lockRightView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width, ([[UIScreen mainScreen] bounds].size.height / 2) - 2.5, [[UIScreen mainScreen] bounds].size.width / 2, 5);
			}];
		}];
	
	} else {

		%orig(completion);
	}
}
%end

%ctor {

	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.orca.andrios/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}