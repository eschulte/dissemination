SOURCES=$(wildcard *.coffee)
OBJECTS=$(SOURCES:.coffee=.js)

all: $(OBJECTS)

%.js: %.coffee
	coffee -c $<

clean:
	rm -f $(OBJECTS)
