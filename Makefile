VERSION := 1.7.2
JQUERY := jquery-$(VERSION).min.js

download := http://code.jquery.com/$(JQUERY)
downloader := $(shell which curl)
downloader ?= $(shell which wget)

.PHONY: all clean
all: index.html
clean:
	-rm app.js $(JQUERY) style.css index.html

index.html: app.js style.css
app.js: $(JQUERY)

$(JQUERY):
ifeq ($(notdir $(downloader)),curl)
	$(downloader) $(download) > $@
else
ifeq ($(notdir $(downloader)),wget)
	$(downloader) $(download) -O $@
else
	$(error "Get $(download)")
endif
endif

include Makefile.node
