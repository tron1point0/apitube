VERSION := 4.1.0
ZIPFILE := ext-$(VERSION)-gpl.zip

download := http://cdn.sencha.io/$(ZIPFILE)
downloader := $(shell which curl)
downloader ?= $(shell which wget)

COFFEE := $(shell which coffee)
UNZIP := $(shell which unzip)

.PHONY: all clean
all: app.js extjs-$(VERSION)
clean:
	-rm -rf extjs-$(VERSION)/ app.js $(ZIPFILE)

extjs-$(VERSION): ext-$(VERSION)-gpl.zip
ifneq ($(UNZIP),)
	$(UNZIP) $^
else
	$(error "Install unzip")
endif

ext-4.1.0-gpl.zip:
ifeq ($(notdir $(downloader)),curl)
	$(downloader) $(download) > $@
else
ifeq ($(notdir $(downloader)),wget)
	$(downloader) $(download) -O $@
else
	$(error "Get $(download)")
endif
endif

%.js: %.coffee
ifneq ($(COFFEE),)
	$(COFFEE) -p $^ > $@
else
	$(error "Install coffeescript")
endif
