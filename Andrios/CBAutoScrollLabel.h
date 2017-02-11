#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CBAutoScrollDirection) {
    CBAutoScrollDirectionRight,
    CBAutoScrollDirectionLeft
};

@interface CBAutoScrollLabel : UIView <UIScrollViewDelegate>

@property (nonatomic) CBAutoScrollDirection scrollDirection;
@property (nonatomic) float scrollSpeed; // pixels per second
@property (nonatomic) NSTimeInterval pauseInterval;
@property (nonatomic) NSInteger labelSpacing; // pixels

/**
 * The animation options used when scrolling the UILabels.
 * @discussion UIViewAnimationOptionAllowUserInteraction is always applied to the animations.
 */
@property (nonatomic) UIViewAnimationOptions animationOptions;

/**
 * Returns YES, if it is actively scrolling, NO if it has paused or if text is within bounds (disables scrolling).
 */
@property (nonatomic, readonly) BOOL scrolling;
@property (nonatomic) CGFloat fadeLength;

// UILabel properties
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) NSTextAlignment textAlignment; // only applies when not auto-scrolling

/**
 * Lays out the scrollview contents, enabling text scrolling if the text will be clipped.
 * @discussion Uses [scrollLabelIfNeeded] internally.
 */
- (void)refreshLabels;

/**
 * Set the text to the label and refresh labels, if needed.
 * @discussion Useful when you have a situation where you need to layout the scroll label after it's text is set.
 */
- (void)setText:(NSString *)text refreshLabels:(BOOL)refresh;
- (void)setAttributedText:(NSAttributedString *)theText refreshLabels:(BOOL)refresh;

/**
 * Initiates auto-scroll if the label width exceeds the bounds of the scrollview.
 */
- (void)scrollLabelIfNeeded;

/**
 * Observes UIApplication state notifications to auto-restart scrolling and watch for 
 * orientation changes to refresh the labels.
 * @discussion Must be called to observe the notifications. Calling multiple times will still only
 * register the notifications once.
 */
- (void)observeApplicationNotifications;

@end
