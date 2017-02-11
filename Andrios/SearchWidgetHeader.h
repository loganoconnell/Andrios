#import "flipswitch/flipswitch.h"
#import "libcolorpicker/colorpicker.h"
#import <CoreGraphics/CoreGraphics.h>
#import <SpringBoard/SpringBoard.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>
#import "SPUserResizableView.h"

@interface SpringBoard (SearchWidget)
- (void)setNextAssistantRecognitionStrings:(id)arg1;
@end

@interface SBAssistantController
+(id)sharedInstance;
-(void)_activateSiriForPPT;
@end

@interface SBLeafIcon
-(void)launchFromLocation:(int)location;
@end

@interface SBUIPluginManager
+(id)sharedInstance;
-(void)handleButtonUpEventFromSource:(int)source;
@end

@interface UIImage (SearchWidget)
-(UIImage *)_flatImageWithColor:(UIColor *)color;
@end

SPUserResizableView *currentlyEditingView;
SPUserResizableView *lastEditedView;

UIWindow *searchWindow;
UIWindow *webViewWindow;
UIView *whiteView;
UIWebView *webView;
UIButton *forwardButton;
UIButton *goBackButton;
UITextField *textField;
UIToolbar *webToolBar;
UIImageView *googleImage;
UIColor *whiteColor;

static BOOL sPresented = NO;
static CGFloat width = [[UIScreen mainScreen] bounds].size.width - 20;
static SBAssistantController *assistantController = nil;
static SpringBoard *springBoard = nil;