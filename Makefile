include Makefile.data

all: build

build:
	@ cd build_packages && ocamlbuild -classic-display build_packages.native
	@ ln -sf build_packages/build_packages.native build

doc doc-upload:
	$(MAKE) -C doc $@

web-upload:
	$(MAKE) -C web $@

release-upload:
	cd .. && \
	  rsync -avzP \
	  --include='/$(VERSION)' \
	  --include='/$(VERSION)/logs' \
	  --include='/$(VERSION)/packages' \
	  --exclude='memo_pkg' \
	  --exclude='/$(VERSION)/*' \
	  $(VERSION) $(WEB)/

.PHONY: doc web build
