#import "flipswitch/flipswitch.h"
#import "libcolorpicker/colorpicker.h"
#import <CoreGraphics/CoreGraphics.h>
#import <SpringBoard/SpringBoard.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

@interface SBScreenFadeAnimationController
-(double)fadeOutAnimationDuration;
-(void)fadeOutWithCompletion:(id)completion;
@end

@interface SBBacklightController
-(void)animateBacklightToFactor:(float)factor duration:(double)duration source:(int)source completion:(id)completion;
@end

@interface SBLockScreenViewControllerBase
-(void)setInScreenOffMode:(BOOL)screenOffMode;
@end

@interface SBLockScreenManager
@property(readonly, assign, nonatomic) SBLockScreenViewControllerBase *lockScreenViewController;
-(void)lockUIFromSource:(int)source withOptions:(id)options;
@end

UIWindow *lockWindow;

UIView *lockTopView;
UIView *lockBottomView;
UIView *lockLeftView;
UIView *lockRightView;

static NSTimeInterval touchesBeganTime = 0;