#import "flipswitch/flipswitch.h"
#import <CoreGraphics/CoreGraphics.h>
#import <SpringBoard/SpringBoard.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

#define IS_OS_7_OR_UNDER [[[UIDevice currentDevice] systemVersion] floatValue] <= 7.1
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

@interface UIImage (AlternateNC)
-(UIImage *)_flatImageWithColor:(UIColor *)color;
@end

@protocol SBModeViewControllerContentProviding
@end

@interface SBModeViewController : UIViewController <UIGestureRecognizerDelegate>
@property(assign, nonatomic) UIViewController<SBModeViewControllerContentProviding>* selectedViewController;
@property(retain, nonatomic) NSArray* viewControllers;
@end

@interface _UIBackdropView : UIView
@end

@interface SBBulletinWindow
-(BOOL)_canBecomeKeyWindow;
@end

@interface SBNotificationCell : UIView
@property(readonly, assign, nonatomic) UIView* realContentView;
@property(retain, nonatomic) UIColor* relevanceDateColor;
-(void)layoutSubviews;
@end

@interface _UIContentUnavailableView : UIView
-(void)layoutSubviews;
@end

@interface SBNotificationSeparatorView : UIView
-(void)setBounds:(CGRect)bounds;
-(void)setFrame:(CGRect)frame;
-(void)updateForCurrentState;
-(id)initWithFrame:(CGRect)frame mode:(int)mode;
@end

@interface SBTableViewCellActionButton : UIView
-(void)layoutSubviews;
@end

@interface SBNotificationsSectionHeaderView : UIView
-(void)buttonAction:(id)arg1;
@end

@interface SBNotificationCenterHeaderView : UIView
@end

//clear all headers
@interface SBModeControlManager
@property(readonly, assign, nonatomic) NSArray* views;
-(void)insertSegmentWithTitle:(id)title atIndex:(unsigned)index animated:(BOOL)animated;
-(id)_segmentedControlForUse:(int)use;
@end

@interface SBBulletinObserverViewController {
    NSMutableArray* _visibleSectionIDs;
}
-(id)sectionWithIdentifier:(NSString *)identifier;
-(void)clearSection:(id)section;
@end

@interface SBNotificationCenterViewController : UIViewController {
    SBBulletinObserverViewController* _allModeViewController;
}

@property(readonly, assign, nonatomic) _UIBackdropView* backdropView;

-(void)hostWillDismiss;
@end

@interface SBNotificationCenterController
@property(readonly, retain, nonatomic) SBNotificationCenterViewController* viewController;
+(id)sharedInstance;
-(void)clearAllNotifications;
-(void)clearAllNotificationsInternal;
@end

@interface SBIconViewMap
+(SBIconViewMap *)homescreenMap;
-(SBIconModel *)iconModel;
@end

@interface SBLockScreenNotificationListView : UIView
@end

@interface NotificationKillerAlert : NSObject <UIAlertViewDelegate>
-(void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
//clear all headers

//clear one header
@interface SBBulletinListSection
@property (nonatomic,copy) NSString *sectionID;
-(id)bulletinAtIndex:(unsigned)index;
@end

@interface BBServer : NSObject
-(void)withdrawBulletinRequestsWithRecordID:(id)arg1 forSectionID:(id)arg2;
@end

@interface SBBulletinViewController : UITableViewController
- (id)sectionAtIndex:(unsigned long long)arg1;
@end

@interface SBBBSectionInfo
-(id)representedListSection;
@end

@interface SBNotificationsSectionInfo : SBBBSectionInfo
@end

@interface BBBulletin
@property (nonatomic,copy) NSString *recordID;
@end

@interface SBAwayBulletinListItem
-(unsigned)maxMessageLines;
@end

static BBServer *bbserve = nil;
//clear one header

UIView *switchesView;
UIView *topView;
UIButton *settingsButton;
UIButton *contactsButton;
UIButton *batteryButton;
UIImageView *batteryImage;
UIImageView *settingsButtonImage;
UIImageView *contactsButtonImage;
UISwipeGestureRecognizer *swipeup;
UISwipeGestureRecognizer *swipedown;
UISlider *brightnessSlider;

UIButton *wifiSwitch;
UIButton *bluetoothSwitch;
UIButton *dataSwitch;
UIButton *airplaneSwitch;
UIButton *autoRotationSwitch;
UIButton *flashlightSwitch;
UIButton *locationSwitch;
UIButton *hotspotSwitch;
UIButton *doNotDisturbSwitch;
UIButton *autoBrightnessSwitch;
UIButton *ringerSwitch;
UIButton *clearAllButton;

UIImageView *wifiImage;
UIImageView *bluetoothImage;
UIImageView *dataImage;
UIImageView *airplaneImage;
UIImageView *autoRotationImage;
UIImageView *flashlightImage;
UIImageView *locationImage;
UIImageView *hotspotImage;
UIImageView *doNotDisturbImage;
UIImageView *autoBrightnessImage;
UIImageView *ringerImage;

UILabel *timeLabel;
UILabel *dateLabel;
UILabel *batteryLabel;

NSTimer *updateAlternateNCTimer;