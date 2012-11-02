VERSION=$(shell git show -s --format="%ci" HEAD | cut -d ' ' -f 1 | tr -d '-')

BINDIR=$(DESTDIR)/usr/bin/
DOCDIR=$(DESTDIR)/usr/share/doc/dissemination/
MN7DIR=$(DESTDIR)/usr/share/man/man7/
MANDIR=$(DESTDIR)/usr/share/man/man1/
LICDIR=$(DESTDIR)/usr/share/liscences/dissemination/

BUILD_DIR:=build
BINBLD=$(BUILD_DIR)/bin/
MANBLD=$(BUILD_DIR)/man/

HOST:=moons.cs.unm.edu:public_html/data/

MAN = \
	dis.1 \
	pack.1 \
	server.1
MANPAGES=$(addprefix man/, $(MAN))
MANBLDPAGES=$(addprefix $(MANBLD), $(MAN))

BIN = \
	dis \
	dis-common \
	dis-pack \
	dis-read \
	dis-save \
	messages.cgi
SCRIPTS=$(addprefix sh/, $(BIN))

all: dist
.PHONY: dist dist-package clean install

js/%:
	$(MAKE) -C js/ $(shell basename $@)

install:
	mkdir -p $(BINDIR) $(DOCDIR) $(LICDIR) $(MANDIR) $(MN7DIR);
	install -D $(SCRIPTS) $(BINDIR);
	install -Dm644 $(MANPAGES) $(MANDIR);
	mv $(MANDIR)server.1 $(MANDIR)dis-server.1;
	mv $(MANDIR)pack.1 $(MANDIR)dis-pack.1;
	install -Dm644 man/dis.7 $(MN7DIR);
	chmod a-x $(BINDIR)dis-common;
	man -l -Tascii man/dis.7 >> $(BINDIR)messages.cgi;
	man -l -Tascii man/dis.7 > $(DOCDIR)dissemination.txt;
	install -Dm644 COPYING $(LICDIR)COPYING;

dist-package: js/README.md js/package.json js/server.js js/server.coffee
	mkdir -p $(BINBLD) $(MANBLD);
	cp js/README.md $(BUILD_DIR);
	cp js/package.json $(BUILD_DIR);
	cp js/server.js js/server.coffee $(BUILD_DIR);
	cp $(MANPAGES) $(MANBLD);
	cp man/dis.7 $(MANBLD);
	gzip $(MANBLDPAGES) $(MANBLD)dis.7;
	cp $(SCRIPTS) $(BINBLD);
	chmod -x $(BINBLD)/dis-common;
	man -l -Tascii man/dis.7 >> $(BINBLD)messages.cgi;
	cp COPYING $(BUILD_DIR);

dist: dist-package
	pushd $(BUILD_DIR); npm pack; popd; mv $(BUILD_DIR)/dis-*.tgz ./;

clean:
	$(MAKE) -C js/ clean

real-clean: clean
	rm -rf *.tar.gz *.tar.xz *.tgz $(BUILD_DIR)
