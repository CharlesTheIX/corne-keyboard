ifeq ($(strip $(OLED_ENABLE)), yes)
	SRC += keyboards/charlestheix/display_oled.c
endif
