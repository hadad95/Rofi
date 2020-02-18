INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS=arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = test

test_FILES = Tweak.x SCView.x SCViewIconViewController.x
test_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
