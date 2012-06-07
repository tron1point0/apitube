COFFEE := coffee

.PHONY: all
all: app.js

%.js: %.coffee
	$(COFFEE) -p $^ > $@
