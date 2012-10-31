VERSION=$(shell git show -s --format="%ci" HEAD | cut -d ' ' -f 1 | tr -d '-')
BUILD_DIR=build

SOURCES=$(wildcard *.coffee)
OBJECTS=$(SOURCES:.coffee=.js)

BIN = \
	dis-common \
	dis-pack \
	dis-read \
	dis-save \
	dis \
	messages.cgi

SCRIPTS=$(addprefix ../sh/, $(BIN))

all: dist
.PHONY: dist clean start

%.js: %.coffee
	coffee -c $<

start: server.js README.md
	npm start

config.js:
	echo "// Holds optional cofiguration" > $@
	echo "post_save_hook.push(save)"     >> $@

package.json: package_template.json
	cp $< $@; sed -i 's/VERSION/$(VERSION)/' $@;

build: README.md package.json $(OBJECTS) $(SCRIPTS)
	rm -rf $(BUILD_DIR);
	mkdir -p $(BUILD_DIR)/bin;
	cp package.json $(BUILD_DIR);
	cp README.md $(BUILD_DIR);
	cp $(SOURCES) $(BUILD_DIR);
	cp $(OBJECTS) $(BUILD_DIR);
	cp $(SCRIPTS) $(BUILD_DIR)/bin;
	chmod -x $(BUILD_DIR)/bin/dis-common;

dist: build
	npm pack

clean:
	rm -rf $(BUILD_DIR) $(OBJECTS) dissemination-*.tgz package.json
