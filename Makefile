HOST=moons.cs.unm.edu:public_html/data/
BINDIR=$(DESTDIR)/usr/bin/
DOCDIR=$(DESTDIR)/usr/share/doc/dissemination/
LICDIR=$(DESTDIR)/usr/share/liscences/dissemination/
VERSION=$(shell git show -s --format="%ci" HEAD | cut -d ' ' -f 1 | tr -d '-')
BUILD_DIR=build

all: dist
.PHONY: dist aur clean install

install:
	mkdir -p $(BINDIR) $(DOCDIR) $(LICDIR); \
	install -D src/sh/* $(BINDIR); \
	$(GROFF_TXT) dissemination.mm >> $(BINDIR)messages.cgi; \
	$(GROFF) dissemination.mm > $(DOCDIR)dissemination.txt; \
	install -Dm644 COPYING $(LICDIR)COPYING;

dist-package: README.md package.json $(OBJECTS) $(SCRIPTS)
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

dist: dist-package
	pushd $(BUILD_DIR); npm pack; popd; mv $(BUILD_DIR)/dissemination-*.tgz ./;

npm: src/js/README.md
	$(MAKE) -C src/js/ dist; \
	mv src/js/dissemination-0.0.*.tgz ./

clean:
	rm -r package.json

real-clean: clean
	rm -rf *.tar.gz *.tar.xz *.tgz $(BUILD_DIR) $(BUILD_DIR)
