TARGETS = cdc_acm.ihx erase_eeprom.ihx

all:	$(TARGETS)

%.ihx:	%.c
	sdcc $<

clean:
	rm -f `cat .gitignore` $(TARGETS)

