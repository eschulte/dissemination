SOURCES=$(wildcard *.coffee)
OBJECTS=$(SOURCES:.coffee=.js)

.PHONY: run npm-pack

all: $(OBJECTS)

%.js: %.coffee
	coffee -c $<

README.md:
	$(MAKE) -C ../../ src/js/README.md

start: server.js README.md
	npm start

pack: server.coffee package.json README.md Makefile .npmignore
	npm pack

clean:
	rm -f $(OBJECTS) dissemination-*.tgz README.md
