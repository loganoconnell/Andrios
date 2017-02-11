#import <CoreGraphics/CoreGraphics.h>
#import <SpringBoard/SpringBoard.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

#define IS_OS_7_OR_UNDER [[[UIDevice currentDevice] systemVersion] floatValue] <= 7.1

UIWindow *edgeWindow;
UIToolbar *toolBar;
UIButton *backButton;
UIButton *homeButton;
UIButton *switcherButton;
UIButton *CCButton;
UIButton *powerMenu;
UIButton *NCButton;

BOOL home;
BOOL switcher;

@interface SBControlCenterController
@property(assign, nonatomic, getter=isPresented) BOOL presented;
-(void)presentAnimated:(BOOL)animated;
-(void)dismissAnimated:(BOOL)animated;
@end

@interface SBNotificationCenterController
@property(readonly, assign, nonatomic, getter=isVisible) BOOL visible;
-(void)presentAnimated:(BOOL)animated;
-(void)dismissAnimated:(BOOL)animated;
@end

@interface SBAssistantController
+(id)sharedInstance;
-(void)_activateSiriForPPT;
@end

@interface SBUIPluginManager
+(id)sharedInstance;
-(void)handleButtonUpEventFromSource:(int)source;
@end

static SBAssistantController *assistantController = nil;