SOURCES=$(wildcard *.coffee)
OBJECTS=$(SOURCES:.coffee=.js)

.PHONY: run npm-pack

all: $(OBJECTS) config.js

%.js: %.coffee
	coffee -c $<

config.js:
	echo "// Holds optional cofiguration" > $@
	echo "post_save_hook.push(save)"     >> $@

README.md:
	$(MAKE) -C ../../ src/js/README.md

start: server.js README.md
	npm start

pack: server.coffee package.json README.md Makefile .npmignore
	npm pack

clean:
	rm -f $(OBJECTS) dissemination-*.tgz README.md
