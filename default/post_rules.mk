ifeq ($(strip $(OLED_ENABLE)), yes)
	SRC += keyboards/default/logos.c
	SRC += keyboards/default/oled.c
endif
