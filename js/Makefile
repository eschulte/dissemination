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

all: start
.PHONY: clean start

%.js: %.coffee
	coffee -c $<

start: server.js
	npm start

config.js:
	echo "// Holds optional cofiguration" > $@
	echo "post_save_hook.push(save)"     >> $@

package.json: package_template.json
	cp $< $@; sed -i 's/VERSION/$(VERSION)/' $@;

clean:
	rm -f *.js package.json
