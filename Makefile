INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS=arm64 arm64e
TARGET=iphone:clang:12.4:12.4

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Rofi

Rofi_FILES = Tweak.x SCViewController.x SCView.x
Rofi_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
