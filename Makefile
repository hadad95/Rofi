INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS=arm64
TARGET=iphone:clang:12.4:12.4

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Rofi

Rofi_FILES = Tweak.x RFViewController.x RFView.x
Rofi_CFLAGS = -fobjc-arc
Rofi_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += rofi
include $(THEOS_MAKE_PATH)/aggregate.mk
