include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TabCount
TabCount_FILES = Tweak.xm
TabCount_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
