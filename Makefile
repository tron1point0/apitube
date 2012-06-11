VERSION := 1.7.2.min
JQUERY = jquery-$(VERSION).js

JQUERY_PATH := http://code.jquery.com

.PHONY: all clean
all: index.html
clean:
	-rm static/app.js
	-rm static/style.css
	-rm static/$(JQUERY)
	-rmdir static/
	-rm index.html

index.html: static/app.js static/style.css
static/app.js: static/$(JQUERY)

static/$(JQUERY):
	$(INSTALL) -d static/
	$(call GET,$(JQUERY_PATH)/$(notdir $@),$@)

include web.mk
