
all: package

package: clean
	tar --exclude=".git" --exclude=".gitignore" --exclude="src/c" \
	--exclude="Makefile" --exclude="dissemination.tar.gz" \
	--transform='s:./:dissemination/:' \
	-czf dissemination.tar.gz ./*

clean:
	$(MAKE) -C src/c/ clean; rm -f dissemination.tar.gz
