#import <CoreGraphics/CoreGraphics.h>
#import <SpringBoard/SpringBoard.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>
#import <MediaRemote/MediaRemote.h>
#import "CBAutoScrollLabel.h"

@interface UIImage (Miniplayer)
-(UIImage *)_flatImageWithColor:(UIColor *)color;
@end

UIWindow *mpwindow;

UIView *mpMainView;

UIImageView *artworkImage;
UIImageView *dismissButtonImage;
UIImageView *rewindButtonImage;
UIImageView *playPauseButtonImage;
UIImageView *fastForwardButtonImage;

CBAutoScrollLabel *nowPlayingSongLabel;
CBAutoScrollLabel *nowPlayingArtistLabel;

NSTimer *trackProgressUpdateTimer;

static BOOL mpPresented = NO;