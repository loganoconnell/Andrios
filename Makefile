GO_EASY_ON_ME=1
ARCHS = armv7 arm64

THEOS_BUILD_DIR = Packages
THEOS_DEVICE_IP = 192.168.1.25

include theos/makefiles/common.mk

TWEAK_NAME = Andrios
Andrios_FILES = Andrios/ActionBar.xm Andrios/AlternateNC.xm Andrios/Miniplayer.xm Andrios/PowerMenu.xm Andrios/SearchWidget.xm Andrios/SwitchesWidget.xm Andrios/VolumeSlider.xm Andrios/Extras.xm Andrios/CBAutoScrollLabel.m Andrios/SPUserResizableView.m
Andrios_LIBRARIES = substrate flipswitch activator
Andrios_FRAMEWORKS = UIKit CoreGraphics QuartzCore MediaPlayer
Andrios_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard; killall -9 backboardd"
SUBPROJECTS += AndriosUIKitHooks

SUBPROJECTS += andriosprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
