ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = andriosprefs
andriosprefs_FILES = andriosprefs.mm UIView+Shimmer.m
andriosprefs_INSTALL_PATH = /Library/PreferenceBundles
andriosprefs_FRAMEWORKS = UIKit QuartzCore MessageUI
andriosprefs_PRIVATE_FRAMEWORKS = Preferences Twitter
andriosprefs_LIBRARIES = MobileGestalt substrate activator

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/andriosprefs.plist$(ECHO_END)
