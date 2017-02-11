#import "MiniplayerHeader.h"

static BOOL mnewAndroid;
static BOOL showWhenMusicStarts;
static BOOL hideWhenMusicStops;
static BOOL mpinToHomescreen;
static BOOL mpAlphaEnabled;
static BOOL showWhenOpened;

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.orca.andrios.plist"];

	mnewAndroid = [prefs objectForKey:@"mnewAndroid"] ? [[prefs objectForKey:@"mnewAndroid"] boolValue] : YES;
	showWhenMusicStarts = [prefs objectForKey:@"showWhenMusicStarts"] ? [[prefs objectForKey:@"showWhenMusicStarts"] boolValue] : NO;
	hideWhenMusicStops = [prefs objectForKey:@"hideWhenMusicStops"] ? [[prefs objectForKey:@"hideWhenMusicStops"] boolValue] : NO;
	mpinToHomescreen = [prefs objectForKey:@"mpinToHomescreen"] ? [[prefs objectForKey:@"mpinToHomescreen"] boolValue] : NO;
	mpAlphaEnabled = [prefs objectForKey:@"mpAlphaEnabled"] ? [[prefs objectForKey:@"mpAlphaEnabled"] boolValue] : NO;
	showWhenOpened = [prefs objectForKey:@"showWhenOpened"] ? [[prefs objectForKey:@"showWhenOpened"] boolValue] : NO;
}

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1
{
	%orig(arg1);
    
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.orca.andrios.plist"];
	
	mpwindow = [[UIWindow alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width - 300) / 2, 20, 300, 60)];
	mpwindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	mpwindow.alpha = 0.0;
	mpwindow.hidden = YES;
	mpwindow.backgroundColor = [UIColor clearColor];

	UIPanGestureRecognizer *moveMP = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mpHandleMovePan:)];
	[mpwindow addGestureRecognizer:moveMP];

	UITapGestureRecognizer *hideMiniplayer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mpHideMiniplayer:)];
	hideMiniplayer.numberOfTapsRequired = 2;
	[mpwindow addGestureRecognizer:hideMiniplayer];

	UILongPressGestureRecognizer *centerMiniplayer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mpCenterMiniplayer:)];
	[mpwindow addGestureRecognizer:centerMiniplayer];

	mpMainView = [[UIView alloc] init];
	mpMainView.frame = CGRectMake(0, 0, 300, 60);
	if (mnewAndroid) { mpMainView.backgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; }
	else { mpMainView.backgroundColor = [UIColor colorWithRed: 38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0]; }
	[[mpMainView layer] setCornerRadius:3.0];
	if (mpAlphaEnabled) {
		mpMainView.alpha = [[prefs objectForKey:@"mpalpha"] floatValue];
	} else {
		mpMainView.alpha = 0.85;
	}
	[mpwindow addSubview:mpMainView];
    
	artworkImage = [[UIImageView alloc] initWithImage:nil];
	artworkImage.frame = CGRectMake(0, 0, 60, 60);
	artworkImage.userInteractionEnabled = YES;
	[mpMainView addSubview:artworkImage];

	UITapGestureRecognizer *openNowPlayingApp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mpOpenNowPlayingApp:)];
	openNowPlayingApp.numberOfTapsRequired = 1;
	[artworkImage addGestureRecognizer:openNowPlayingApp];

	UITapGestureRecognizer *albumHideMiniplayer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mpHideMiniplayer:)];
	albumHideMiniplayer.numberOfTapsRequired = 2;
	[artworkImage addGestureRecognizer:albumHideMiniplayer];

	[openNowPlayingApp requireGestureRecognizerToFail:albumHideMiniplayer];

	UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:artworkImage.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(3.0, 3.0)];
	CAShapeLayer *maskLayer1 = [CAShapeLayer layer];
	maskLayer1.frame = artworkImage.bounds;
	maskLayer1.path = maskPath1.CGPath;
	artworkImage.layer.mask = maskLayer1;
    
	dismissButtonImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/close.png"] _flatImageWithColor:[UIColor grayColor]]];
	dismissButtonImage.frame = CGRectMake(270, mpMainView.frame.size.height/2 - 14, 28, 28);
	dismissButtonImage.tintColor = [UIColor grayColor];
	dismissButtonImage.userInteractionEnabled = YES;
	[mpMainView addSubview:dismissButtonImage];
    
	UITapGestureRecognizer *xTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mpDismiss:)];
	[dismissButtonImage addGestureRecognizer:xTap];
    
	
	nowPlayingSongLabel = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake(65, 5, 100, 30)];
	if (mnewAndroid) { nowPlayingSongLabel.textColor = [UIColor blackColor]; }
	else { nowPlayingSongLabel.textColor = [UIColor whiteColor]; }
	nowPlayingSongLabel.textAlignment = NSTextAlignmentLeft;
	nowPlayingSongLabel.font = [UIFont systemFontOfSize:18];
	nowPlayingSongLabel.backgroundColor = [UIColor clearColor];
	nowPlayingSongLabel.text = @"Song Title";
	//add scrolling features
	nowPlayingSongLabel.fadeLength = 3.f;
	nowPlayingSongLabel.labelSpacing = 20; 
	nowPlayingSongLabel.pauseInterval = 1.7;
	nowPlayingSongLabel.scrollSpeed = 30;
	nowPlayingSongLabel.scrollDirection = CBAutoScrollDirectionLeft;
	[nowPlayingSongLabel observeApplicationNotifications];
	[mpMainView addSubview:nowPlayingSongLabel];

	nowPlayingArtistLabel = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake(65, 25, 100, 30)];
	nowPlayingArtistLabel.textColor = [UIColor grayColor];
	nowPlayingArtistLabel.textAlignment = NSTextAlignmentLeft;
	nowPlayingArtistLabel.font = [UIFont systemFontOfSize:16];
	nowPlayingArtistLabel.backgroundColor = [UIColor clearColor];
	nowPlayingArtistLabel.text = @"Artist";
	//add scrolling features
	nowPlayingArtistLabel.fadeLength = 3.f;
	nowPlayingArtistLabel.labelSpacing = 20; 
	nowPlayingArtistLabel.pauseInterval = 1.7;
	nowPlayingArtistLabel.scrollSpeed = 30;
	nowPlayingArtistLabel.scrollDirection = CBAutoScrollDirectionLeft;
	[nowPlayingArtistLabel observeApplicationNotifications];
	[mpMainView addSubview:nowPlayingArtistLabel];

	if (mnewAndroid) { rewindButtonImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/rewind.png"] _flatImageWithColor:[UIColor blackColor]]]; }
	else { rewindButtonImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/rewind.png"] _flatImageWithColor:[UIColor whiteColor]]]; }
	rewindButtonImage.frame = CGRectMake(165, mpMainView.frame.size.height/2 - 16, 32, 32);
	rewindButtonImage.tintColor = [UIColor whiteColor];
	rewindButtonImage.userInteractionEnabled = YES;
	[mpMainView addSubview:rewindButtonImage];

	UITapGestureRecognizer *previous = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mpPreviousTrack:)];
	[rewindButtonImage addGestureRecognizer:previous];

	if (mnewAndroid) { playPauseButtonImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/play.png"] _flatImageWithColor:[UIColor blackColor]]]; }
	else { playPauseButtonImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/play.png"] _flatImageWithColor:[UIColor whiteColor]]]; }
	playPauseButtonImage.frame = CGRectMake(200, mpMainView.frame.size.height/2 - 17.5, 35, 35);
	playPauseButtonImage.tintColor = [UIColor whiteColor];
	playPauseButtonImage.userInteractionEnabled = YES;
	[mpMainView addSubview:playPauseButtonImage];

	UITapGestureRecognizer *playPause = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mpPlayPauseTrack:)];
	[playPauseButtonImage addGestureRecognizer:playPause];

	if (mnewAndroid) { fastForwardButtonImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/fastforward.png"] _flatImageWithColor:[UIColor blackColor]]]; }
	else { fastForwardButtonImage = [[UIImageView alloc] initWithImage:[[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/fastforward.png"] _flatImageWithColor:[UIColor whiteColor]]]; }
	fastForwardButtonImage.frame = CGRectMake(235, mpMainView.frame.size.height/2 - 16, 32, 32);
	fastForwardButtonImage.tintColor = [UIColor whiteColor];
	fastForwardButtonImage.userInteractionEnabled = YES;
	[mpMainView addSubview:fastForwardButtonImage];

	UITapGestureRecognizer *fastForward = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mpFastForwardTrack:)];
	[fastForwardButtonImage addGestureRecognizer:fastForward];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMiniplayerInfo:) name:(NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMiniplayerStatus:) name:(NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

%new 
-(void)mpDismiss:(id)sender {

    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		mpwindow.alpha = 0.0;
    }
    completion:^(BOOL finished) {
		
		mpPresented = NO;
       	mpwindow.hidden = YES;
	}];
}

%new
-(void)mpHandleMovePan:(UIPanGestureRecognizer *)recognizer {
 
    CGPoint translation = [recognizer translationInView:mpwindow];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:mpwindow];
}

%new
-(void)mpOpenNowPlayingApp:(id)sender {

	MRMediaRemoteGetNowPlayingApplicationPID(dispatch_get_main_queue(), ^(int PID) {

		[[%c(SBUIController) sharedInstance] activateApplicationAnimated:[[%c(SBApplicationController) sharedInstance] applicationWithPid:PID]];
    });
}

%new
-(void)mpHideMiniplayer:(id)sender {
	
	if (mpwindow.frame.origin.x != [[UIScreen mainScreen] bounds].size.width - 15) {

		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			CGRect newFrame = mpwindow.frame;
			newFrame.origin.x = [[UIScreen mainScreen] bounds].size.width - 15;
			mpwindow.frame = newFrame;
    	}
    	completion:^(BOOL finished) {

		}];
	}

	else {

		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			CGRect newFrame = mpwindow.frame;
			newFrame.origin.x = ([[UIScreen mainScreen] bounds].size.width - 300) / 2;
			mpwindow.frame = newFrame;
    	}
    	completion:^(BOOL finished) {

		}];
	}
}

%new
-(void)mpCenterMiniplayer:(id)sender {
	
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		CGRect newFrame = mpwindow.frame;
		newFrame.origin.x = ([[UIScreen mainScreen] bounds].size.width - 300) / 2;
		mpwindow.frame = newFrame;
    }
    completion:^(BOOL finished) {

	}];
}

%new
-(void)mpPreviousTrack:(id)sender {

    [[%c(SBMediaController) sharedInstance] changeTrack:-1];
}

%new
-(void)mpPlayPauseTrack:(id)sender {

    [[%c(SBMediaController) sharedInstance] togglePlayPause];
}

%new
-(void)mpFastForwardTrack:(id)sender {

    [[%c(SBMediaController) sharedInstance] changeTrack:1];
}

%new
-(void)updateMiniplayerInfo:(id)sender {

    	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {

		NSDictionary *dict = (NSDictionary *)result;
       	artworkImage.image = [UIImage imageWithData:[dict objectForKey:(NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]];
		nowPlayingSongLabel.text = (NSString *)[dict objectForKey:(NSString *)kMRMediaRemoteNowPlayingInfoTitle];
		nowPlayingArtistLabel.text = (NSString *)[dict objectForKey:(NSString *)kMRMediaRemoteNowPlayingInfoArtist];
    	});
}

%new
-(void)updateMiniplayerStatus:(id)sender {

    MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlaying) {

	BOOL playing = (BOOL)isPlaying;
	if (playing) {
    
      		if (mnewAndroid) { playPauseButtonImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/pause.png"] _flatImageWithColor:[UIColor blackColor]]; }
	else { playPauseButtonImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/pause.png"] _flatImageWithColor:[UIColor whiteColor]]; }

			if (showWhenMusicStarts) {

				[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

					mpwindow.hidden = NO;
					mpwindow.alpha = 1.0;
    			}
    			completion:^(BOOL finished) {

					mpPresented = YES;
				}];
			}
    	} else {
    
        	if (mnewAndroid) { playPauseButtonImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/play.png"] _flatImageWithColor:[UIColor blackColor]]; }
	else { playPauseButtonImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/play.png"] _flatImageWithColor:[UIColor whiteColor]]; }

			if (hideWhenMusicStops) {

				[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

					mpwindow.alpha = 0.0;
    			}
    			completion:^(BOOL finished) {
		
					mpPresented = NO;
        			mpwindow.hidden = YES;
				}];
			}
    	}
	
    });
}
%end

%hook SBLeafIcon
-(void)launchFromLocation:(int)location {
	
	if (mpinToHomescreen & !showWhenOpened) {
		mpwindow.alpha = 0.0;
		mpwindow.hidden = YES;
	} else if (mpinToHomescreen && showWhenOpened) {
		mpwindow.alpha = 1.0;
		mpwindow.hidden = NO;
	} else {}
	
	if (showWhenOpened && !mpinToHomescreen) {
		mpwindow.hidden = YES;
	}
	
	%orig;
}
%end

%hook SBIconContentView
-(void)updateLayoutWithDuration:(double)duration {

	if (mpinToHomescreen) {

		%orig(duration);
		mpwindow.alpha = 1.0;
		mpwindow.hidden = NO;
	} else {}
}
%end

%hook SBUIController
-(BOOL)_handleButtonEventToSuspendDisplays:(BOOL)suspendDisplays displayWasSuspendedOut:(BOOL*)anOut {

	BOOL original = %orig;

	if (mpinToHomescreen) {
		mpwindow.hidden = NO;
	} else {}
	
	if (showWhenOpened && !mpinToHomescreen) {
		mpwindow.hidden = YES;
	}
	
	return original;
}
%end

%hook SBLockScreenManager
-(void)lockUIFromSource:(int)source withOptions:(id)options {
	
	%orig;

	if (mpinToHomescreen) {
		mpwindow.hidden = YES;
	} else {}
}
%end

%hook SBLockScreenViewController
-(void)finishUIUnlockFromSource:(int)source {
	
	%orig;

	if (mpinToHomescreen) {
		mpwindow.hidden = NO;
	} else {}
}
%end

#import <libactivator/libactivator.h>

@interface MiniplayerActivator : NSObject <LAListener>
@end

@implementation MiniplayerActivator
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {

	if (!mpPresented || mpinToHomescreen) {
		MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlaying) {

			BOOL playing = (BOOL)isPlaying;
			if (playing) {

      			if (mnewAndroid) { playPauseButtonImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/pause.png"] _flatImageWithColor:[UIColor blackColor]]; }
	else { playPauseButtonImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/pause.png"] _flatImageWithColor:[UIColor whiteColor]]; }
				MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {

					NSDictionary *dict = (NSDictionary *)result;
       				artworkImage.image = [UIImage imageWithData:[dict objectForKey:(NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]];
					nowPlayingSongLabel.text = (NSString *)[dict objectForKey:(NSString *)kMRMediaRemoteNowPlayingInfoTitle];
					nowPlayingArtistLabel.text = (NSString *)[dict objectForKey:(NSString *)kMRMediaRemoteNowPlayingInfoArtist];
    				});
    			} else {

	        		if (mnewAndroid) { playPauseButtonImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/play.png"] _flatImageWithColor:[UIColor blackColor]]; }
	else { playPauseButtonImage.image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Andrios/play.png"] _flatImageWithColor:[UIColor whiteColor]]; }
					artworkImage.image = nil;
					nowPlayingSongLabel.text = @"Song Title";
					nowPlayingArtistLabel.text = @"Artist";
    			}

    		});

		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			mpwindow.hidden = NO;
			CGRect originalFrame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 300) / 2, 20, 300, 60);
			mpwindow.frame = originalFrame;
			mpwindow.alpha = 1.0;
    		}
    		completion:^(BOOL finished) {

			mpPresented = YES;
		}];
	}

	else {

		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

			mpwindow.alpha = 0.0;
    		}
    		completion:^(BOOL finished) {

			mpPresented = NO;
        	mpwindow.hidden = YES;
		}];
	}

	[event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {}

+ (void)load {
	if ([LASharedActivator isRunningInsideSpringBoard]) {
			[LASharedActivator registerListener:[self new] forName:@"com.orca.andriosminiplayer"];
	}
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
	return @"Andrios";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return @"Miniplayer Widget";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Choose action to show Miniplayer Widget";
}
- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
	return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
}
- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {

	return [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/Miniplayer.png"] scale:scale];
}
- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {

	return [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Library/PreferenceBundles/andriosprefs.bundle/Miniplayer.png"] scale:scale];
}
@end

%ctor {

	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.orca.andrios/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);

}