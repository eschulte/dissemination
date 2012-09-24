GROFF=groff -t -mm -Tascii
HOST=moons.cs.unm.edu:public_html/data/

all: aur
.PHONY: package package-upload aur aur-upload clean doc

doc: dissemination.tr
	$(GROFF) $<|less

dissemination.txt: dissemination.tr
	$(GROFF) $< > $@

package dissemination.tar.gz: clean dissemination.txt
	tar --exclude=".git" --exclude=".gitignore" --exclude="src/c" \
	--exclude="Makefile" --exclude="dissemination.tar.gz" \
	--exclude="dissemination.nroff" \
	--transform='s:./:dissemination/:' \
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
	rm -rf pkg/ src/dissemination/

real-clean:
	rm -rf *.tar.gz *.tar.xz *.txt
