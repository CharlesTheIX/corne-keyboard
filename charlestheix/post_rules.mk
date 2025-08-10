ifeq ($(strip $(OLED_ENABLE)), yes)
	SRC += keyboards/charlestheix/logos.c
	SRC += keyboards/charlestheix/oled.c
endif
