LESSC := $(shell which lessc)
COFFEE := $(shell which coffee)
JADE := $(shell which jade)
NPM := $(shell which npm)

getters := axel curl wget GET
GETTER := $(shell $(patsubst %,which % 2>/dev/null ||,$(getters)) true)
get_axel = $(1) $(2) -an 16 -o $(3)
get_curl = $(1) -X GET --progress-bar $(2) > $(3)
get_wget = $(1) $(2) -nvO $(3)
get_GET = $(1) $(2) > $(3)
GET = $(call get_$(notdir $(GETTER)),$(GETTER),$(1),$(2))

vpath %.less . style styles
vpath %.css . style styles
vpath %.coffee . script scripts
vpath %.js . script scripts
vpath %.jade . view views template templates
vpath %.html . view views template templates

ifeq ($(LESSC),)
LESSC := node_modules/less/bin/lessc
%.css: $(LESSC)
endif
ifeq ($(COFFEE),)
COFFEE := node_modules/coffee-script/bin/coffee
%.js: $(COFFEE)
endif
ifeq ($(JADE),)
JADE := node_modules/jade/bin/jade
%.html: $(JADE)
endif

node_modules/%: $(NPM)
	$(NPM) install $(firstword $(subst /, ,$*))

.SECONDEXPANSION:
%.css: $(notdir $$*).less | $$(@D)/
	$(LESSC) $< $@

%.js: $(notdir $$*).coffee | $$(@D)/
	$(COFFEE) -p $< > $@

%.html: $(notdir $$*).jade | $$(@D)/
	$(JADE) -Pp $(dir $<) < $< > $@

%/:
	mkdir -p $@
