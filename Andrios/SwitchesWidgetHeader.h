#import "flipswitch/flipswitch.h"
#import "libcolorpicker/colorpicker.h"
#import <CoreGraphics/CoreGraphics.h>
#import <SpringBoard/SpringBoard.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>
#import <MediaRemote/MediaRemote.h>
#import <MediaPlayer/MPVolumeView.h>

@interface UIImage (SwitchesWidget)
-(UIImage *)_flatImageWithColor:(UIColor *)color;
@end

UIWindow *switcheswindow;

UIButton *wifiswitch;
UIButton *bluetoothswitch;
UIButton *locationswitch;
UIButton *dndswitch;
UIButton *autobrightnessswitch;

UIImageView *wifiswitchImage;
UIImageView *bluetoothswitchImage;
UIImageView *locationswitchImage;
UIImageView *dndswitchImage;
UIImageView *autobrightnessswitchImage;

UIView *selectedwifiView;
UIView *selectedbluetoothView;
UIView *selectedlocationView;
UIView *selecteddndView;
UIView *selectedautobrightnessView;

NSTimer *updateSwitchesWidgetTimer;