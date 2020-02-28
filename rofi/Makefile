include $(THEOS)/makefiles/common.mk

ARCHS=arm64 arm64e
TARGET=iphone:clang:12.4:12.4

BUNDLE_NAME = Rofi

Rofi_FILES = RFRootListController.m
Rofi_INSTALL_PATH = /Library/PreferenceBundles
Rofi_FRAMEWORKS = UIKit
Rofi_PRIVATE_FRAMEWORKS = Preferences
Rofi_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Rofi.plist$(ECHO_END)
