GROFF=groff -t -mm -Tascii -P-cbu
HOST=moons.cs.unm.edu:public_html/data/
BINDIR=$(DESTDIR)/usr/bin/
DOCDIR=$(DESTDIR)/usr/share/doc/dissemination/
LICDIR=$(DESTDIR)/usr/share/liscences/dissemination/

all: aur
.PHONY: package package-upload aur aur-upload clean doc install

doc: dissemination.mm
	$(GROFF) $<|less

dissemination.txt: dissemination.mm
	$(GROFF) $< > $@

install: dissemination.txt
	mkdir -p $(BINDIR) $(DOCDIR) $(LICDIR); \
	install -D src/sh/* $(BINDIR); \
	cat dissemination.txt >> $(BINDIR)messages.cgi; \
	install -Dm644 dissemination.txt $(DOCDIR)dissemination.txt; \
	install -Dm644 COPYING $(LICDIR)COPYING;

package dissemination.tar.gz: clean dissemination.txt
	tar --exclude=".git" --exclude=".gitignore" --exclude="src/c" \
	--exclude="*.tar.gz" --transform='s:./:dissemination/:' \
	-czf dissemination.tar.gz ./*

package-upload: dissemination.tar.gz
	scp dissemination.tar.gz $(HOST)

aur dissemination-0.1-1.src.tar.gz: dissemination.tar.gz
	sed -i "s/md5sums=('placeholder')/$$(makepkg -g|grep md5sum)/" PKGBUILD; \
	makepkg -f; \
	makepkg -f --source; \
	sed -i "s/^md5sums.*$$/md5sums=('placeholder')/" PKGBUILD;

aur-upload: dissemination-0.1-1.src.tar.gz package-upload
	scp $< $(HOST)

clean:
	$(MAKE) -C src/c/ clean; \
	rm -rf pkg/ src/dissemination/ *.txt

real-clean: clean
	rm -rf *.tar.gz *.tar.xz
