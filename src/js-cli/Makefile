BUILD_DIR=build

VERSION=$(shell git show -s --format="%ci" HEAD | cut -d ' ' -f 1 | tr -d '-')

BIN = \
	dis-common \
	dis-pack \
	dis
SOURCE = $(addprefix ../sh/, $(BIN))

all: dist
.PHONY: dist

build: README.md package.json $(SOURCE)
	rm -rf $(BUILD_DIR);
	mkdir $(BUILD_DIR);
	cp package.json $(BUILD_DIR);
	cp README.md $(BUILD_DIR);
	cp $(SOURCE) $(BUILD_DIR);
	chmod -x $(BUILD_DIR)/dis-common;

package.json: package_template.json
	cp $< $@; sed -i 's/VERSION/$(VERSION)/' $@;

dist: build
	pushd $(BUILD_DIR); npm pack; mv dissemination-cli*tgz ../;

clean:
	rm -rf $(BUILD_DIR)

real-clean: clean
	rm -f dissemination-cli-*.tgz
