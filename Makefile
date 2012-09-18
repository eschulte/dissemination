HOST=moons.cs.unm.edu:public_html/data/

all: package
.PHONY: package-upload aur aur-upload clean

package: clean
	tar --exclude=".git" --exclude=".gitignore" --exclude="src/c" \
	--exclude="Makefile" --exclude="dissemination.tar.gz" \
	--transform='s:./:dissemination/:' \
	-czf dissemination.tar.gz ./*

package-upload: package
	scp dissemination.tar.gz $(HOST)

aur dissemination-0.1-1.src.tar.gz: package-upload
	sed -i "s/md5sums=('placeholder')/$$(makepkg -g|grep md5sum)/" PKGBUILD; \
	makepkg -f; \
	makepkg -f --source; \
	sed -i "s/^md5sums.*$$/md5sums=('placeholder')/" PKGBUILD;

aur-upload: dissemination-0.1-1.src.tar.gz
	scp $< $(HOST)

clean:
	$(MAKE) -C src/c/ clean; \
	rm -rf pkg/ src/dissemination/ *.tar.gz *.tar.xz
