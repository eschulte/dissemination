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

MAN = \
	dissemination.1 \
	server.1 \
	dis.1

SCRIPTS=$(addprefix ../sh/, $(BIN))
MANPAGES=$(addprefix man/, $(MAN))

all: dist
.PHONY: dist clean start doc

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
	mkdir -p $(BUILD_DIR)/man;
	cp README.md $(BUILD_DIR);
	cp package.json $(BUILD_DIR);
	cp $(SOURCES) $(BUILD_DIR);
	cp $(OBJECTS) $(BUILD_DIR);
	cp $(MANPAGES) $(BUILD_DIR)/man;
	cp $(SCRIPTS) $(BUILD_DIR)/bin;
	chmod -x $(BUILD_DIR)/bin/dis-common;

doc: dissemination.1
	groff -t -mdoc -Tascii -P-cbu $<|less

dist: build
	pushd $(BUILD_DIR); npm pack; popd; mv $(BUILD_DIR)/dissemination-*.tgz ./;

clean:
	rm -rf $(BUILD_DIR) $(OBJECTS) package.json
