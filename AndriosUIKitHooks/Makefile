GO_EASY_ON_ME=1
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = AndriosUIKitHooks
AndriosUIKitHooks_FILES = UIKitHooks.xm
AndriosUIKitHooks_FRAMEWORKS = UIKit CoreGraphics
AndriosUIKitHooks_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
