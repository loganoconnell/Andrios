#import "flipswitch/flipswitch.h"
#import "libcolorpicker/colorpicker.h"
#import <CoreGraphics/CoreGraphics.h>
#import <SpringBoard/SpringBoard.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>
#import <MediaPlayer/MPVolumeView.h>

@interface MPVolumeView (VolumeSlider)
@property(nonatomic) BOOL showsRouteButton;
@end

@interface UIImage (VolumeSlider)
-(UIImage *)_flatImageWithColor:(UIColor *)color;
@end

UIColor *vswitchImageColor;
UIColor *vsBackgroundColor;

UIWindow *vsWindow;
NSTimer *timer;
UIImageView *volumeSliderImage;
UISlider *tempSlider;