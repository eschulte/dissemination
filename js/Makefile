VERSION=$(shell git show -s --format="%ci" HEAD | cut -d ' ' -f 1 | tr -d '-')
SOURCES=$(wildcard *.coffee)
OBJECTS=$(SOURCES:.coffee=.js)

all: start
.PHONY: clean start

%.js: %.coffee
	coffee -c $<

base:
	touch $@

config.js:
	echo "// Holds optional cofiguration" > $@
	echo "post_save_hook.push(save)"     >> $@

package.json: package_template.json
	cp $< $@; sed -i 's/VERSION/$(VERSION)/' $@;

start: server.js config.js package.json
	npm start

clean:
	rm -f *.js package.json
