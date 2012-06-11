LESSC = $(shell which lessc 2>/dev/null || echo node_modules/less/bin/lessc)
COFFEE = $(shell which coffee 2>/dev/null || echo node_modules/coffee-script/bin/coffee)
JADE = $(shell which jade 2>/dev/null || echo node_modules/jade/bin/jade)
NPM = $(shell which npm)
INSTALL = install

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

.SECONDARY: $(LESSC) $(COFFEE) $(JADE)

%/:
	mkdir -p $@

node_modules/%: $(NPM)
	$(NPM) install $(firstword $(subst /, ,$*))

.SECONDEXPANSION:
%.css: $(notdir $$*).less | $(LESSC) $(dir $$*)/
	$(LESSC) $< $@

%.js: $(notdir $$*).coffee | $(COFFEE) $(dir $$*)/
	$(COFFEE) -p $< > $@

%.html: $(notdir $$*).jade | $(JADE) $(dir $$*)/
	$(JADE) -Pp $(dir $<) < $< > $@
