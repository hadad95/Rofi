INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS=arm64
TARGET=iphone:clang:12.4:12.4

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = test

test_FILES = Tweak.x SCView.x SCViewController.x
test_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
