#import "flipswitch/flipswitch.h"
#import "libcolorpicker/colorpicker.h"
#import <CoreGraphics/CoreGraphics.h>
#import <SpringBoard/SpringBoard.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

@interface UIApplication (PowerMenu)
-(void)_powerDownNow;
-(void)_rebootNow;
-(void)_relaunchSpringBoardNow;
@end

@interface UIImage (PowerMenu)
-(UIImage *)_flatImageWithColor:(UIColor *)color;
@end

UIWindow *pmwindow;
UIView *mainView;
UIView *dimView;
UIView *alertView;

UIButton *powerOffButton;
UIButton *rebootButton;
UIButton *respringButton;
UIButton *safeModeButton;
UIButton *silenceButton;
UIButton *vibrateButton;
UIButton *soundButton;
UIButton *uiCacheButton;
UIButton *lockButton;

UIImageView *powerOffImage;
UIImageView *rebootImage;
UIImageView *respringImage;
UIImageView *safeModeImage;
UIImageView *uiCacheImage;
UIImageView *silenceButtonImage;
UIImageView *soundButtonImage;
UIImageView *vibrateButtonImage;
UIImageView *lockImage;

UIButton *airplaneModeSwitch;

UIImageView *airplaneModeSwitchImage;
UIImageView *selectedSilenceImage;
UIImageView *selectedVibrateImage;
UIImageView *selectedSoundImage;

UIColor *mainColor;
UIColor *cellBGColor;
UIColor *cellTextColor;
UIColor *airplaneSwitchBGColor;
UIColor *switchImageColor;
UIColor *lineViewColor;

UILabel *airplaneSwitchLabel;
UILabel *alertMainLabel;
UILabel *alertSecondLabel;

static BOOL showingButtons = YES;
static BOOL pmPresented = NO;
static const CGFloat kButtonHeight = 70.0f;
static CGFloat height = 60;
static CGFloat width = [[UIScreen mainScreen] bounds].size.width - 20;
static CGFloat x = ([[UIScreen mainScreen] bounds].size.width - width) / 2;