GROFF=groff -t -mm -Tutf8
GROFF_TXT=groff -t -mm -Tascii -P-cbu
GROFF_PS=groff -t -mm
WIDTH=$(shell stty size|awk '{print $$2}')
HOST=moons.cs.unm.edu:public_html/data/
BINDIR=$(DESTDIR)/usr/bin/
DOCDIR=$(DESTDIR)/usr/share/doc/dissemination/
LICDIR=$(DESTDIR)/usr/share/liscences/dissemination/
BLDIR=build

all: aur
.PHONY: package package-upload aur aur-upload clean doc install

doc: dissemination.utf8
	if [ $(WIDTH) -lt 72 ];then \
		cat $<|cut -c6-|less; \
	else \
		cat $<|less; \
	fi

dissemination.utf8: dissemination.mm
	$(GROFF) $<|tail -n -66  > $@; \
	$(GROFF) $<|head -n -66 >> $@;

dissemination.txt: dissemination.mm
	$(GROFF_TXT) $< > $@

dissemination.ps: dissemination.mm
	$(GROFF_PS) $< > $@

dissemination.pdf: dissemination.ps
	ps2pdf $<

install:
	mkdir -p $(BINDIR) $(DOCDIR) $(LICDIR); \
	install -D src/sh/* $(BINDIR); \
	$(GROFF_TXT) dissemination.mm >> $(BINDIR)messages.cgi; \
	$(GROFF) dissemination.mm > $(DOCDIR)dissemination.txt; \
	install -Dm644 COPYING $(LICDIR)COPYING;

package dissemination.tar.gz: clean
	tar --exclude=".git" --exclude=".gitignore" --exclude="src/c" \
	--exclude="src/js" --exclude="src/dissemination.tar.gz" --exclude="stuff"\
	--exclude="*.tar.gz" --transform='s:./:dissemination/:' \
	-czf dissemination.tar.gz ./*

package-upload: dissemination.tar.gz
	scp dissemination.tar.gz $(HOST)

aur dissemination-0.1-1.src.tar.gz: dissemination.tar.gz
	rm -rf $(BLDIR); \
	mkdir -p $(BLDIR); \
	cp PKGBUILD $(BLDIR); \
	cp $< $(BLDIR); \
	cd $(BLDIR); \
	sed -i "s/md5sums=('placeholder')/$$(makepkg -g|grep md5sum)/" PKGBUILD; \
	makepkg -f; \
	mv dissemination-0.1-1-any.pkg.tar.xz ../; \
	makepkg -f --source; \
	mv dissemination-0.1-1.src.tar.gz ../; \
	cd ../

aur-upload: dissemination-0.1-1.src.tar.gz package-upload
	scp $< $(HOST)

src/js/README.md: dissemination.txt
	cp $< $@

npm: src/js/README.md
	$(MAKE) -C src/js/ pack; \
	cp src/js/dissemination-0.0.1.tgz ./

clean:
	$(MAKE) -C src/c/ clean; \
	$(MAKE) -C src/js/ clean; \
	rm -rf pkg/ src/dissemination/ *.txt *.ps *.pdf

real-clean: clean
	rm -rf *.tar.gz *.tar.xz *.tgz $(BLDIR)
